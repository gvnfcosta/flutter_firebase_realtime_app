// lib/screens/signin_screen.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_realtime_app/screens/signup_screen.dart';
import 'package:flutter_firebase_realtime_app/screens/user_detail_screen.dart';
import 'package:flutter_firebase_realtime_app/screens/user_form_screen.dart';
import 'package:flutter_firebase_realtime_app/utils/local_storage.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

@override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final savedEmail = await LocalStorage.getEmail();
    final savedPass = await LocalStorage.getPassword();
    if (savedEmail != null) _emailCtrl.text = savedEmail;
    if (savedPass != null) _passCtrl.text = savedPass;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      // Salvar UID e email
      await LocalStorage.saveLogin(
          uid, _emailCtrl.text.trim(), _passCtrl.text.trim());

      // Checar dados do usuário no Firebase
      final ref = FirebaseDatabase.instance.ref('users/$uid');
      final snapshot = await ref.get();

      if (!mounted) return;

      if (snapshot.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserDetailScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserFormScreen(uid: uid)),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          msg = 'Senha incorreta.';
          break;
        case 'invalid-email':
          msg = 'Email inválido.';
          break;
        default:
          msg = e.message ?? 'Erro ao fazer login.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a senha' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Entrar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
                child: const Text('Criar nova conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
