import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/src/services/auth_services.dart';
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
  bool _autoTried = false; // evita múltiplas tentativas automáticas

  @override
  void initState() {
    super.initState();
    _initAutoLogin();
  }

  Future<void> _initAutoLogin() async {
    // Carrega email e senha do armazenamento local
    await AuthService.loadSavedLogin(
      emailCtrl: _emailCtrl,
      passCtrl: _passCtrl,
    );

    // Se já há credenciais salvas, tenta login automático
    if (_emailCtrl.text.isNotEmpty && _passCtrl.text.isNotEmpty) {
      setState(() {
        _loading = true;
        _autoTried = true;
      });

      await AuthService.login(
        context: context,
        formKey: _formKey,
        emailCtrl: _emailCtrl,
        passCtrl: _passCtrl,
        setLoading: (val) => setState(() => _loading = val),
      );
    }
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
                    : () => Navigator.pushReplacementNamed(context, '/signup'),
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
