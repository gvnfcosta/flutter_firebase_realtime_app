import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class UserDataScreen extends StatelessWidget {
  const UserDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Dados do Usuário')),
      body: user == null
          ? const Center(child: Text('Nenhum dado encontrado'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${user.id}'),
                  Text('Nome: ${user.name}'),
                  Text('Telefone: ${user.phone}'),
                ],
              ),
            ),
    );
  }
}
