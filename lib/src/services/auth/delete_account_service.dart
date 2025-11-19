import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../config/app_routes.dart';
import 'auth_service.dart';
import 'auth_utils.dart';

// ===============================================================
// EXCLUIR USUÁRIO
// ===============================================================
class DeleteAccountService {
  static Future<void> deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      AuthUtils.showSnack(context, 'Usuário não logado.');
      return;
    }

    try {
      final userProvider = context.read<UserProvider>();

      // 🗑️ Exclui dados do usuário no Firebase Database
      await userProvider.deleteUserData(user.uid);

      // 🧹 Remove conta do Auth
      await user.delete();
      AuthService.logout(context);

      // 🔒 Limpa cache e estado local
      userProvider.clearUser();

      if (context.mounted) {
        AuthUtils.showSnack(
          context,
          'Conta excluída e dados removidos com sucesso.',
        );

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      if (e.code == 'requires-recent-login') {
        final success = await _reauthenticateUser(context, user);
        if (success) {
          if (!context.mounted) return;
          await deleteAccount(context); // tenta novamente
        } else {
          if (!context.mounted) return;
          AuthUtils.showSnack(context, 'Reautenticação cancelada.');
        }
      } else {
        AuthUtils.showSnack(context, 'Erro ao excluir conta: ${e.code}');
      }
    } catch (e) {
      if (!context.mounted) return;
      AuthUtils.showSnack(context, 'Erro inesperado: $e');
    }
  }

  /// 🔒 Solicita reautenticação via diálogo de senha
  static Future<bool> _reauthenticateUser(
    BuildContext context,
    User user,
  ) async {
    final email = user.email;
    if (email == null) return false;

    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar identidade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Por segurança, digite novamente sua senha para excluir a conta de $email',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      final cred = EmailAuthProvider.credential(
        email: email,
        password: passwordController.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);
      return true;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        AuthUtils.showSnack(
          context,
          AuthUtils.mapFirebaseAuthCodeToMessage(e.code),
        );
      }
      return false;
    }
  }
}
