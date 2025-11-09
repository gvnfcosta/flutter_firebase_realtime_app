import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:flutter_firebase_realtime_app/utils/local_storage.dart';

class UserTab extends StatefulWidget {
  const UserTab({super.key});

  @override
  State<UserTab> createState() => _UserTabState();
}

class _UserTabState extends State<UserTab> {
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final provider = context.read<UserProvider>();
      await provider.fetchUserData(currentUser.uid);

      final userData = provider.user;

      if (userData == null) {
        await _goToUserForm();
        return;
      }

      if (mounted) {
        setState(() {
          _userData = userData.toMap();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _goToUserForm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !mounted) return;
    Navigator.pushNamed(context, AppRoutes.userForm, arguments: user.uid);
  }

  Future<void> _logout() async {
    await LocalStorage.removeLogin();
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.signIn, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = context.watch<UserProvider>().user;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userData == null) {
      return const Scaffold(body: Center(child: Text('Redirecionando...')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bem-vindo, ${userInfo?.name ?? ''} (${userInfo?.role ?? ''})',
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nome: ${_userData?['name'] ?? ''}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'E-mail: ${_userData?['email'] ?? ''}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${FirebaseAuth.instance.currentUser?.uid ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Code: ${_userData?['code'] ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Nível: ${_userData?['level'] ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 60),
            ElevatedButton.icon(
              onPressed: _goToUserForm,
              icon: const Icon(Icons.edit),
              label: const Text('Editar Dados'),
            ),
          ],
        ),
      ),
    );
  }
}
