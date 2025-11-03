import 'package:flutter/material.dart';

import 'package:flutter_firebase_realtime_app/src/common/custom_text_field.dart';
import 'package:flutter_firebase_realtime_app/src/common/validators.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_data.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';
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

  bool _obscurePass = true;
  bool _loading = false;
  bool _autoTried = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!_autoTried) {
        _autoTried = true;
        await AuthService.autoLogin(
          context: context,
          emailCtrl: _emailCtrl,
          passCtrl: _passCtrl,
          setLoading: (val) => setState(() => _loading = val),
        );
      }
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
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: size.height * 0.38,
                    width: double.infinity,
                    child: ClipPath(
                      clipper: BottomInwardClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            width: size.width - 30,
                            child: Text(
                              programName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 50),
                          CustomTextFormField(
                            controller: _emailCtrl,
                            label: 'Email',
                            validator: emailValidator,
                          ),
                          CustomTextFormField(
                            controller: _passCtrl,
                            iconColor: Colors.grey.shade400,
                            label: 'Senha',
                            obscureText: _obscurePass,
                            validator: passwordValidator,
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
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )
                                : const Text('Entrar'),
                          ),
                          const SizedBox(height: 18),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.signUp,
                                    ),
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
          Positioned(
            top: (size.height / 2.5) - 300,
            left: 0,
            right: 0,
            child: Center(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.jpg',
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (!isKeyboardVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: size.height / 3,
                child: Image.asset(
                  'assets/images/Footer.png',
                  fit: BoxFit.contain, // mostra a imagem inteira, sem cortar
                  alignment: Alignment.bottomLeft, // opcional
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BottomInwardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final large = size.width > 500 ? 2 : 1.7;

    final path = Path();

    // Início: canto superior esquerdo
    path.moveTo(0, 0);

    // Ponto mais baixo à esquerda
    final double leftDepth = size.height * 0.78; // desce um pouco mais
    path.lineTo(0, leftDepth);

    // === CÍRCULO PARA DENTRO ===
    final double circleRadius = size.width * large; // raio
    final double centerY =
        leftDepth + circleRadius * 0.92; // um pouco mais baixo
    final double centerX = size.width * 0.85; // move o centro mais à direita

    // Arco (de esquerda para direita)
    path.arcTo(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: circleRadius),
      3.14159, // começa à esquerda (180°)
      3.14159, // arco de 180°
      false,
    );

    // Direita mais alta (ligeiramente acima)
    final double rightHeight = size.height * 0.2;
    path.lineTo(size.width, rightHeight);

    // Fecha no topo
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
