import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/user_provider.dart';
import '../../config/app_routes.dart';
import '../../services/auth_services.dart';

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
        ],
      ),
    );
  }
}
