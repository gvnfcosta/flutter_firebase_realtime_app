import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:flutter_firebase_realtime_app/utils/local_storage.dart';

import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AuthService {
  /// 🔹 Verifica conexão com a internet
  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// 🔹 Carrega email/senha salvos localmente
  static Future<void> loadSavedLogin({
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
  }) async {
    final email = await LocalStorage.getEmail();
    final pass = await LocalStorage.getPassword();

    if (email != null) emailCtrl.text = email;
    if (pass != null) passCtrl.text = pass;
  }

  /// 🔹 Método interno — pós-login unificado
  static Future<void> _handlePostLogin(BuildContext context, User user) async {
    final provider = context.read<UserProvider>();
    await provider.fetchUserData(user.uid);

    if (!context.mounted) return;

    if (provider.user == null) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.userForm,
        arguments: user.uid,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
    }
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
      if (!await hasInternet()) return;

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
      await _handlePostLogin(context, cred.user!);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        final msg = switch (e.code) {
          'network-request-failed' =>
            'Falha de conexão. Verifique sua internet.',
          'user-not-found' => 'Usuário não encontrado.',
          'wrong-password' => 'Senha incorreta.',
          _ => e.message ?? 'Erro ao fazer login automático.',
        };

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      debugPrint('⚠️ Erro no autoLogin: $e');
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  /// 🔹 Login Manual
  static Future<void> login({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required ValueChanged<bool> setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;

    if (!await hasInternet()) {
      if (!context.mounted) return;

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

      if (!context.mounted) return;
      await _handlePostLogin(context, cred.user!);
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'network-request-failed' => 'Falha de conexão. Verifique sua internet.',
        'user-not-found' => 'Usuário não encontrado.',
        'wrong-password' => 'Senha incorreta.',
        _ => e.message ?? 'Erro ao logar.',
      };

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  /// 🔹 Cadastro
  static Future<void> signUp({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required TextEditingController confirmPassCtrl,
    required ValueChanged<bool> setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;

    if (!await hasInternet()) {
      if (!context.mounted) return;

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
        const SnackBar(content: Text('Conta criada. Complete seu cadastro.')),
      );

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.userForm,
        arguments: uid,
      );
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'email-already-in-use' => 'Este email já está em uso.',
        'invalid-email' => 'Email inválido.',
        'weak-password' => 'Senha fraca. Use pelo menos 6 caracteres.',
        _ => e.message ?? 'Erro ao criar conta.',
      };

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  /// 🔹 Logout (sem necessidade de internet)
  static Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await LocalStorage.removeLogin();

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sessão encerrada.')));

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.signIn,
        (r) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao sair: $e')));
      }
    }
  }
}
