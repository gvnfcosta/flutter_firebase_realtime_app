import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:flutter_firebase_realtime_app/src/services/auth_services.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final bool _autoTried = false; // evita múltiplas tentativas automáticas
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await AuthService.autoLogin(
        context: context,
        emailCtrl: _emailCtrl,
        passCtrl: _passCtrl,
        setLoading: (val) => setState(() => _loading = val),
      );
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
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
                onPressed: _loading
                    ? null
                    : () => AuthService.login(
                          context: context,
                          formKey: _formKey,
                          emailCtrl: _emailCtrl,
                          passCtrl: _passCtrl,
                          setLoading: (val) => setState(() => _loading = val),
                        ),
                child: _loading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text('Entrar'),
              ),
              TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.pushReplacementNamed(
                        context, AppRoutes.signUp),
                child: const Text('Criar nova conta'),
              ),
              if (_loading && !_autoTried)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Tentando login automático...'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
