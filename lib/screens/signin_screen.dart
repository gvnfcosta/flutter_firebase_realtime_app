import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/src/common/validators.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_data.dart';
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
  bool _obscurePass = true;
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
        child: Stack(
          children: [
            Positioned(
              top: 50,
              left: 30,
              child: Row(
                children: [
                  Transform.rotate(
                    angle: -15 *
                        3.1415926535 /
                        180, // 🔹 Converte 30° para radianos
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/logo.png'),
                          fit: BoxFit.contain,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                  SizedBox(
                    width: 250,
                    child: const Text(
                      programName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black26,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                        textInputAction: TextInputAction.next,
                        validator: (v) => emailValidator(v),
                      ),
                      TextFormField(
                        controller: _passCtrl,
                        textInputAction: TextInputAction.next,
                        obscureText: _obscurePass,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.foregroundIcon,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePass = !_obscurePass;
                              });
                            },
                          ),
                        ),
                        validator: (v) => passwordValidator(v),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () => AuthService.login(
                                  context: context,
                                  formKey: _formKey,
                                  emailCtrl: _emailCtrl,
                                  passCtrl: _passCtrl,
                                  setLoading: (val) =>
                                      setState(() => _loading = val),
                                ),
                        child: _loading
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : const Text('Entrar'),
                      ),
                      SizedBox(height: 18),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.pushReplacementNamed(
                                context, AppRoutes.signUp),
                        child: const Text(
                          'Criar nova conta',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
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
            ),
          ],
        ),
      ),
    );
  }
}
