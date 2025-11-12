import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/user_provider.dart';
import '../../config/app_routes.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/delete_account_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel usuario = Provider.of<UserProvider>(context).user!;

    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Bem vindo ${usuario.name.split(' ')[0]}!'),
            automaticallyImplyLeading: false,
          ),
          usuario.isAdmin
              ? Column(
                  children: [
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.person_2_outlined),
                      title: Text(usuario.role),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.userForm);
                      },
                    ),
                    const Divider(),
                  ],
                )
              : const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Ajuda'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sair'),
            onTap: () {
              AuthService.logout(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Excluir Conta',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              _showDeleteAccountDialog(context);
            },
          ),
        ],
      ),
    );
  }

  /// 🗑️ Exibe o diálogo de confirmação e executa a exclusão
  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Tem certeza de que deseja excluir permanentemente sua conta? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DeleteAccountService.deleteAccount(context);
    }
  }
}
