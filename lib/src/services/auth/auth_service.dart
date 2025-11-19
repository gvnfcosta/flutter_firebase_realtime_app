import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../providers/user_provider.dart';
import '../../../utils/local_storage.dart';
import '../../config/app_colors.dart';
import '../../config/app_data.dart';
import '../../config/app_routes.dart';
import 'auth_utils.dart';

class AuthService {
  static DateTime? _lastReset;

  // ===============================================================
  // MÉTODOS AUXILIARES
  // ===============================================================
  static Future<void> loadSavedLogin({
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
  }) async {
    final email = await LocalStorage.getEmail();
    final pass = await LocalStorage.getPassword();

    if (email != null) emailCtrl.text = email;
    if (pass != null) passCtrl.text = pass;
  }

  static void _safeSnack(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    if (!context.mounted) return;
    AuthUtils.showSnack(
      context,
      message,
      backgroundColor: AppColors.backGroundColor,
    );
  }

  static Future<void> _safeAuthAction(
    BuildContext context,
    ValueChanged<bool> setLoading,
    Future<void> Function() action,
  ) async {
    setLoading(true);
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      _safeSnack(context, AuthUtils.mapFirebaseAuthCodeToMessage(e.code));
    } catch (e) {
      debugPrint('⚠️ Erro inesperado: $e');
      if (!context.mounted) return;
      _safeSnack(context, defaultError);
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  // ===============================================================
  // PÓS LOGIN
  // ===============================================================
  static Future<void> _handlePostLogin(BuildContext context, User user) async {
    final provider = context.read<UserProvider>();
    try {
      await provider.fetchUserData(user.uid);
    } catch (e) {
      debugPrint('⚠️ Erro ao buscar dados do usuário: $e');
    }

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

  static Future<void> _signInAndNavigate(
    BuildContext context,
    String email,
    String password,
  ) async {
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await LocalStorage.saveLogin(cred.user!.uid, email, password);

    if (!context.mounted) return;
    await _handlePostLogin(context, cred.user!);
  }

  // ===============================================================
  // AUTO LOGIN
  // ===============================================================
  static Future<void> autoLogin({
    required BuildContext context,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required ValueChanged<bool> setLoading,
  }) async {
    // se outra rotina pediu para pular o auto-login (ex.: exclusão de conta)
    final skip = await LocalStorage.getSkipAutoLogin();
    if (skip) {
      debugPrint('[autoLogin] skip_auto_login está true — ignorando autoLogin');
      return;
    }

    try {
      await loadSavedLogin(emailCtrl: emailCtrl, passCtrl: passCtrl);

      if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;

      if (!await AuthUtils.hasInternet()) {
        debugPrint('🌐 Sem conexão, auto-login ignorado.');
        return;
      }

      if (!context.mounted) return;
      await _safeAuthAction(context, setLoading, () async {
        await _signInAndNavigate(
          context,
          emailCtrl.text.trim(),
          passCtrl.text.trim(),
        );
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'invalid-credential' ||
          e.code == 'wrong-password') {
        debugPrint('🚫 Conta removida ou credenciais inválidas: ${e.code}');
        await LocalStorage.removeLogin();

        if (!context.mounted) return;
        _safeSnack(context, 'Sessão expirada. Faça login novamente.');

        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.signIn);
        return;
      }

      if (!context.mounted) return;
      _safeSnack(context, AuthUtils.mapFirebaseAuthCodeToMessage(e.code));
    } catch (e) {
      debugPrint('⚠️ Erro no autoLogin: $e');
      if (!context.mounted) return;
      _safeSnack(context, defaultError);
    }
  }

  // ===============================================================
  // LOGIN MANUAL
  // ===============================================================
  static Future<void> login({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required ValueChanged<bool> setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;

    if (!await AuthUtils.hasInternet() && context.mounted) {
      _safeSnack(context, 'Sem conexão com a internet.');
      return;
    }

    await _safeAuthAction(context, setLoading, () async {
      await _signInAndNavigate(
        context,
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );
    });
  }

  // ===============================================================
  // CADASTRO
  // ===============================================================
  static Future<void> signUp({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
    required TextEditingController confirmPassCtrl,
    required ValueChanged<bool> setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;

    if (!await AuthUtils.hasInternet() && context.mounted) {
      _safeSnack(context, 'Sem conexão com a internet.');
      return;
    }

    await _safeAuthAction(context, setLoading, () async {
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
      _safeSnack(
        context,
        'Conta criada. Complete seu cadastro.',
        backgroundColor: Colors.green,
      );

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.userForm,
        arguments: uid,
      );
    });
  }

  // ===============================================================
  // LOGOUT
  // ===============================================================
  static Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await LocalStorage.removeLogin();

      if (!context.mounted) return;
      _safeSnack(context, 'Sessão encerrada.', backgroundColor: Colors.green);

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.signIn,
          (r) => false,
        );
      }
    } catch (e) {
      _safeSnack(context, 'Erro ao sair: $e');
    }
  }

  // ===============================================================
  // RESET DE SENHA
  // ===============================================================
  static Future<void> resetPassword({
    required BuildContext context,
    required String email,
  }) async {
    if (_lastReset != null &&
        DateTime.now().difference(_lastReset!) < const Duration(minutes: 1)) {
      _safeSnack(context, 'Aguarde 1 minuto antes de tentar novamente.');
      return;
    }

    _lastReset = DateTime.now();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

      if (!context.mounted) return;
      _safeSnack(context, 'E-mail de redefinição enviado para $email!');
    } on FirebaseAuthException catch (e) {
      _safeSnack(context, AuthUtils.mapFirebaseAuthCodeToMessage(e.code));
    } catch (e) {
      _safeSnack(context, 'Erro inesperado. Tente novamente mais tarde.');
    }
  }
}
