import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase_realtime_app/utils/local_storage.dart';
import 'signin_screen.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final ref = FirebaseDatabase.instance.ref('users/${user!.uid}');
    final snapshot = await ref.get();

    // Se o usuário ainda não tem dados pessoais, redireciona automaticamente
    if (!snapshot.exists) {
      await _redirectToForm();
      return;
    }

    if (mounted) {
      setState(() {
        _userData = Map<String, dynamic>.from(snapshot.value as Map);
        _loading = false;
      });
    }
  }

  Future<void> _redirectToForm() async {
    if (user == null || !mounted) return;

    // 🔹 Redireciona automaticamente para completar cadastro
    Navigator.pushNamed(context, '/userForm', arguments: user!.uid);
  }

  Future<void> _logout() async {
    // 🔹 Limpa credenciais locais (se existir a função)
    await LocalStorage.removeLogin();

    // 🔹 Sai do Firebase
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null) {
      // 🔹 Caso não haja dados, o redirecionamento já ocorre em _loadUserData()
      return const Scaffold(
        body: Center(child: Text('Redirecionando...')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seus Dados'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${_userData!['name'] ?? ''}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Email: ${_userData!['email'] ?? ''}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('ID: ${user!.uid}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _redirectToForm(),
              icon: const Icon(Icons.edit),
              label: const Text('Editar Dados'),
            ),
          ],
        ),
      ),
    );
  }
}
