import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:flutter_firebase_realtime_app/utils/local_storage.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AuthService {
  /// 🔹 Verifica se há conexão com a internet
  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Carrega o email e senha salvos no armazenamento local
  static Future<void> loadSavedLogin({
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
  }) async {
    final email = await LocalStorage.getEmail();
    final pass = await LocalStorage.getPassword();

    if (email != null) emailCtrl.text = email;
    if (pass != null) passCtrl.text = pass;
  }

  /// 🔹 Login Automático
  static Future<void> autoLogin({
    required BuildContext context,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required ValueChanged<bool> setLoading,
  }) async {
    try {
      await loadSavedLogin(emailCtrl: emailCtrl, passCtrl: passCtrl);

      if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;

      // ✅ Verifica conexão
      final connected = await hasInternet();
      if (!connected) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sem conexão com a internet.')),
          );
        }
        return;
      }

      setLoading(true);

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      await LocalStorage.saveLogin(
        cred.user!.uid,
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      if (!context.mounted) return;

      final provider = context.read<UserProvider>();
      await provider.fetchUserData(cred.user!.uid);

      final currentUid = cred.user!.uid;

      if (!context.mounted) return;

      if (provider.user == null) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.userForm,
          arguments: currentUid,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.userDetail,
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'network-request-failed':
          msg = 'Falha de conexão. Verifique sua internet.';
          break;
        case 'user-not-found':
          msg = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          msg = 'Senha incorreta.';
          break;
        default:
          msg = e.message ?? 'Erro ao fazer login automático.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      debugPrint('Erro no autoLogin: $e');
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  /// 🔹 Login manual
  static Future<void> login({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required ValueChanged<bool> setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;

    // ✅ Verifica conexão
    final connected = await hasInternet();
    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sem conexão com a internet.')),
      );
      return;
    }

    setLoading(true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      await LocalStorage.saveLogin(
        cred.user!.uid,
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      final provider = context.read<UserProvider>();
      await provider.fetchUserData(cred.user!.uid);

      final currentUid = cred.user!.uid;

      if (!context.mounted) return;

      if (provider.user == null) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.userForm,
          arguments: currentUid,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.userDetail,
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'network-request-failed':
          msg = 'Falha de conexão. Verifique sua internet.';
          break;
        case 'user-not-found':
          msg = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          msg = 'Senha incorreta.';
          break;
        default:
          msg = e.message ?? 'Erro ao logar.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  /// 🔹 Cadastro de usuário
  static Future<void> signUp({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required TextEditingController confirmPassCtrl,
    required ValueChanged<bool> setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;

    // ✅ Verifica conexão
    final connected = await hasInternet();
    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sem conexão com a internet.')),
      );
      return;
    }

    setLoading(true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final uid = cred.user?.uid;
      if (uid == null) throw Exception('Erro ao recuperar UID do usuário.');

      await LocalStorage.saveLogin(
        uid,
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso. Complete seu cadastro.'),
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.userForm,
        arguments: cred.user!.uid,
      );
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'network-request-failed':
          msg = 'Falha de conexão. Verifique sua internet.';
          break;
        case 'email-already-in-use':
          msg = 'Este email já está em uso.';
          break;
        case 'invalid-email':
          msg = 'Email inválido.';
          break;
        case 'operation-not-allowed':
          msg = 'Operação não permitida. Verifique a configuração do Auth.';
          break;
        case 'weak-password':
          msg = 'Senha fraca. Use pelo menos 6 caracteres.';
          break;
        default:
          msg = e.message ?? 'Erro ao criar conta.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  /// 🔹 Logout
  static Future<void> logout(BuildContext context) async {
    try {
      // ✅ Verifica conexão (só se quiser garantir o signOut remoto)
      final connected = await hasInternet();
      if (!connected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sem conexão. Não foi possível sair.')),
        );
        return;
      }

      await FirebaseAuth.instance.signOut();
      await LocalStorage.removeLogin();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão encerrada com sucesso.')),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.signIn,
        (r) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sair: $e')),
      );
    }
  }
}
