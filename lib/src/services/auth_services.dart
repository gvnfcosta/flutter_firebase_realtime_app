import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:flutter_firebase_realtime_app/utils/local_storage.dart';
import 'package:provider/provider.dart';

class AuthService {
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

  /// Realiza login e redireciona conforme status do usuário
  static Future<void> login({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required ValueChanged<bool> setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;
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

      if (provider.user == null) {
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.userForm,
            arguments: currentUid);
      } else {
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.userDetail,
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'Erro ao logar';
      if (e.code == 'user-not-found') msg = 'Usuário não encontrado';
      if (e.code == 'wrong-password') msg = 'Senha incorreta';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  /// Cria uma nova conta de usuário e navega para o formulário de perfil
  static Future<void> signUp({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required TextEditingController confirmPassCtrl,
    required ValueChanged<bool> setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final uid = cred.user?.uid;
      if (uid == null) throw Exception('Erro ao recuperar UID do usuário.');

      // salva login localmente
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

      Navigator.pushReplacementNamed(context, AppRoutes.userForm,
          arguments: cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
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

  /// Faz logout e limpa dados locais
  static Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await LocalStorage.removeLogin();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão encerrada com sucesso.')),
      );

      // Retorna à tela inicial de login
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.signIn, (r) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sair: $e')),
      );
    }
  }
}
