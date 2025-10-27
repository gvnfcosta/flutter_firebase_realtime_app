import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'signin_screen.dart';
import 'user_form_screen.dart';

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
    if (snapshot.exists && mounted) {
      setState(() {
        _userData = Map<String, dynamic>.from(snapshot.value as Map);
        _loading = false;
      });
    } else {
      // Se não há dados pessoais, direciona para o formulário
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserFormScreen(uid: user!.uid)),
        );
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  Future<void> _editData() async {
    if (user == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserFormScreen(uid: user!.uid)),
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
      return const Scaffold(
        body: Center(child: Text('Nenhum dado encontrado.')),
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
            Text('Telefone: ${_userData!['phone'] ?? ''}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('ID: ${user!.uid}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _editData,
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Dados'),
                ),
               
              ],
            )
          ],
        ),
      ),
    );
  }
}
