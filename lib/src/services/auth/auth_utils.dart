import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../config/app_data.dart';

// ===============================================================
// UTILITÁRIOS
// ===============================================================
class AuthUtils {
  static String mapFirebaseAuthCodeToMessage(String code) {
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
      'invalid-credential' => 'Conta não cadastrada ou expirada.',
      'invalid-verification-code' => 'Código de verificação inválido.',
      'invalid-verification-id' => 'ID de verificação inválido.',
      'credential-already-in-use' =>
        'Credencial já está em uso por outra conta.',
      _ => defaultError,
    };
  }

  static Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// SnackBar segura, mesmo após pop() ou widget desmontado.
  static void showSnack(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.red,
  }) {
    try {
      // Se o contexto já foi desmontado, o ScaffoldMessenger.of(context) falha.
      if (!context.mounted) {
        debugPrint('⚠️ Contexto desmontado, tentando contexto alternativo...');
        // Usa o contexto do Navigator (se ainda existir)
        final navContext = Navigator.of(context, rootNavigator: true).context;
        ScaffoldMessenger.maybeOf(navContext)
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: backgroundColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        return;
      }

      // Contexto ainda válido → mostra normalmente
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
    } catch (e) {
      debugPrint('⚠️ Erro ao exibir snackbar: $e');
    }
  }
}
