import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_realtime_app/utils/local_storage.dart';
import 'signup_screen.dart';
import 'user_detail_screen.dart';
import 'user_form_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

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
    _loadSavedLogin();
  }

  Future<void> _loadSavedLogin() async {
    final email = await LocalStorage.getEmail();
    final pass = await LocalStorage.getPassword();
    if (email != null) _emailCtrl.text = email;
    if (pass != null) _passCtrl.text = pass;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      // salva login localmente
      await LocalStorage.saveLogin(
        cred.user!.uid,
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      // verifica se há dados do usuário
      final provider = context.read<UserProvider>();
      await provider.fetchUserData(cred.user!.uid);

      if (provider.user == null) {
        // não há dados → abrir form
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserFormScreen(uid: cred.user!.uid),
          ),
        );
      } else {
        // há dados → abrir detalhe
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserDetailScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'Erro ao logar';
      if (e.code == 'user-not-found') msg = 'Usuário não encontrado';
      if (e.code == 'wrong-password') msg = 'Senha incorreta';
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
