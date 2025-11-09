import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../providers/user_provider.dart';
import '../../utils/local_storage.dart';
import '../config/app_routes.dart';

class AuthService {
  static const _defaultError = 'Ocorreu um erro inesperado. Tente novamente.';

  /// 🔹 Verifica conexão com a internet
  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// 🔹 Exibe mensagem SnackBar
  static void _showSnack(BuildContext context, String message) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(
      const Duration(seconds: 5),
    ).then((_) => overlayEntry.remove());
  }

  /// 🔹 Mapeia códigos do FirebaseAuth para mensagens em português
  static String _mapFirebaseAuthCodeToMessage(String code) {
    return switch (code) {
      'network-request-failed' => 'Falha de conexão. Verifique sua internet.',
      'user-not-found' => 'Usuário não encontrado.',
      'wrong-password' => 'Senha incorreta.',
      'invalid-email' => 'Email inválido.',
      'email-already-in-use' => 'Este email já está em uso.',
      'weak-password' => 'Senha fraca. Use pelo menos 6 caracteres.',
      'user-disabled' => 'Conta desativada. Contate o suporte.',
      'operation-not-allowed' => 'Operação não permitida.',
      'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
      // Credenciais / verificação
      'invalid-credential' => 'Conta não cadastrada ou expirada.',
      'invalid-verification-code' => 'Código de verificação inválido.',
      'invalid-verification-id' => 'ID de verificação inválido.',
      'credential-already-in-use' =>
        'Credencial já está em uso por outra conta.',
      _ => _defaultError,
    };
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

  /// 🔹 Pós-login unificado
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

  /// 🔹 Login genérico (reutilizado por manual e automático)
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
      await _signInAndNavigate(
        context,
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthCodeToMessage(e.code);
      _showSnack(context, msg);
    } catch (e) {
      debugPrint('⚠️ Erro no autoLogin: $e');
      _showSnack(context, _defaultError);
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
      _showSnack(context, 'Sem conexão com a internet.');
      return;
    }

    setLoading(true);
    try {
      await _signInAndNavigate(
        context,
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthCodeToMessage(e.code);
      _showSnack(context, msg);
    } catch (e) {
      debugPrint('⚠️ Erro no login: $e');
      _showSnack(context, _defaultError);
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
      _showSnack(context, 'Sem conexão com a internet.');
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

      _showSnack(context, 'Conta criada. Complete seu cadastro.');

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.userForm,
        arguments: uid,
      );
    } on FirebaseAuthException catch (e) {
      final msg = _mapFirebaseAuthCodeToMessage(e.code);
      _showSnack(context, msg);
    } catch (e) {
      debugPrint('⚠️ Erro no signUp: $e');
      _showSnack(context, _defaultError);
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  /// 🔹 Logout (sem necessidade de internet)
  static Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await LocalStorage.removeLogin();

      _showSnack(context, 'Sessão encerrada.');

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.signIn,
        (r) => false,
      );
    } catch (e) {
      _showSnack(context, 'Erro ao sair: $e');
    }
  }
}
