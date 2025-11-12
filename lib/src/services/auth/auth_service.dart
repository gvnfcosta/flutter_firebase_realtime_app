import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/src/services/auth/auth_utils.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../providers/user_provider.dart';
import '../../../utils/local_storage.dart';
import '../../config/app_data.dart';
import '../../config/app_routes.dart';

class AuthService {
  static DateTime? _lastReset;

  static Future<void> loadSavedLogin({
    required TextEditingController emailCtrl,
    required TextEditingController passCtrl,
  }) async {
    final email = await LocalStorage.getEmail();
    final pass = await LocalStorage.getPassword();

    if (email != null) emailCtrl.text = email;
    if (pass != null) passCtrl.text = pass;
  }

  // ===============================================================
  // FLUXO DE LOGIN / CADASTRO
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
    try {
      await loadSavedLogin(emailCtrl: emailCtrl, passCtrl: passCtrl);

      // ⚠️ Se não há dados salvos, encerra o processo
      if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;

      if (!await AuthUtils.hasInternet()) {
        debugPrint('🌐 Sem conexão, auto-login ignorado.');
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
        // ⚠️ Se a conta foi excluída ou é inválida
        if (e.code == 'user-not-found' ||
            e.code == 'invalid-credential' ||
            e.code == 'wrong-password') {
          debugPrint('🚫 Conta removida ou credenciais inválidas: ${e.code}');
          await LocalStorage.removeLogin();

          if (context.mounted) {
            AuthUtils.showSnack(
              context,
              'Sessão expirada. Faça login novamente.',
            );
            Navigator.pushReplacementNamed(context, AppRoutes.signIn);
          }
          return;
        }

        AuthUtils.showSnack(
          context,
          AuthUtils.mapFirebaseAuthCodeToMessage(e.code),
        );
      }
    } catch (e) {
      debugPrint('⚠️ Erro no autoLogin: $e');
      AuthUtils.showSnack(context, defaultError);
    } finally {
      if (context.mounted) setLoading(false);
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

    if (!await AuthUtils.hasInternet()) {
      AuthUtils.showSnack(context, 'Sem conexão com a internet.');
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
      AuthUtils.showSnack(
        context,
        AuthUtils.mapFirebaseAuthCodeToMessage(e.code),
      );
    } catch (e) {
      debugPrint('⚠️ Erro no login: $e');
      AuthUtils.showSnack(context, defaultError);
    } finally {
      if (context.mounted) setLoading(false);
    }
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

    if (!await AuthUtils.hasInternet()) {
      AuthUtils.showSnack(context, 'Sem conexão com a internet.');
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

      AuthUtils.showSnack(
        context,
        'Conta criada. Complete seu cadastro.',
        backgroundColor: Colors.green,
      );

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.userForm,
        arguments: uid,
      );
    } on FirebaseAuthException catch (e) {
      AuthUtils.showSnack(
        context,
        AuthUtils.mapFirebaseAuthCodeToMessage(e.code),
      );
    } catch (e) {
      debugPrint('⚠️ Erro no signUp: $e');
      AuthUtils.showSnack(context, defaultError);
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  // ===============================================================
  // LOGOUT
  // ===============================================================

  static Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await LocalStorage.removeLogin();
      AuthUtils.showSnack(
        context,
        'Sessão encerrada.',
        backgroundColor: Colors.green,
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.signIn,
        (r) => false,
      );
    } catch (e) {
      AuthUtils.showSnack(context, 'Erro ao sair: $e');
    }
  }

  // ===============================================================
  // RESET DE SENHA
  // ===============================================================
  static Future<void> resetPassword({
    required BuildContext context,
    required String email,
  }) async {
    // evita chamadas muito frequentes
    if (_lastReset != null &&
        DateTime.now().difference(_lastReset!) < const Duration(minutes: 1)) {
      AuthUtils.showSnack(
        context,
        'Aguarde 1 minuto antes de tentar novamente.',
      );
      return;
    }

    _lastReset = DateTime.now();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      AuthUtils.showSnack(
        context,
        'E-mail de redefinição enviado para $email!',
      );
    } on FirebaseAuthException catch (e) {
      String message = AuthUtils.mapFirebaseAuthCodeToMessage(e.code);
      AuthUtils.showSnack(context, message);
    } catch (e) {
      AuthUtils.showSnack(
        context,
        'Erro inesperado. Tente novamente mais tarde.',
      );
    }
  }
}

// 🧭 Estrutura visual do código:

// Seção	  Tema	                   Descrição

// 🧩 1	    Métodos auxiliares	    Conectividade, snackbar e tradução de erros
// 🧭 2	    Pós-login	              Busca dados e redirecionamento
// 🔑 3	    Login genérico	        Reutilizável para manual e automático
// ⚙️ 4	    Login automático	      Usa dados salvos localmente
// 👤 5   	Login manual	           Quando o usuário preenche o formulário
// 🆕 6	    Cadastro	              Criação de nova conta
// 🚪 7	    Logout	                Finaliza sessão e limpa dados locais
