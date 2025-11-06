import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_text_field.dart';
import 'package:flutter_firebase_realtime_app/src/common/validators.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_data.dart';
import 'package:flutter_firebase_realtime_app/src/screens/sign/signup_buttom_sheet.dart';
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

  bool _loading = false;
  bool _autoTried = false;
  static const bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    if (_autoTried) return;
    _autoTried = true;

    setState(() => _loading = true);
    await AuthService.autoLogin(
      context: context,
      emailCtrl: _emailCtrl,
      passCtrl: _passCtrl,
      setLoading: (val) => setState(() => _loading = val),
    );
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await AuthService.login(
      context: context,
      formKey: _formKey,
      emailCtrl: _emailCtrl,
      passCtrl: _passCtrl,
      setLoading: (val) => setState(() => _loading = val),
    );
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
          final isKeyboardOpen = keyboardHeight > 100;

          // Altura disponível para conteúdo (sem footer)

          return Stack(
            children: [
              _buildHeaderDecoration(size),
              _buildFooterImage(size, isKeyboardOpen),

              // === CONTEÚDO PRINCIPAL (com scroll inteligente) ===
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: isKeyboardOpen
                        ? keyboardHeight + 16
                        : size.height * 0.35, // espaço para footer
                  ),
                  child: Column(
                    children: [
                      // === LOGO ===
                      SizedBox(height: size.height * 0.05),
                      _buildLogo(),

                      const SizedBox(height: 32),

                      // === TÍTULO ===
                      _buildTitle(),

                      const SizedBox(height: 32),

                      // === FORMULÁRIO ===
                      _buildForm(size),

                      // === MENSAGEM DE AUTO LOGIN ===
                      if (_loading && !_autoTried)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'Tentando login automático...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                      // === ESPAÇO MÍNIMO PARA ROLAGEM ===
                      SizedBox(height: isKeyboardOpen ? 100 : 120),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ===================== WIDGETS =====================

  Widget _buildFooterImage(Size size, bool isKeyboardOpen) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: size.height * 0.3,
      child: AnimatedOpacity(
        opacity: isKeyboardOpen ? 0.3 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi), // 👈 espelha horizontalmente
          child: Image.asset(
            'assets/images/Footer.png',
            fit: BoxFit.fitHeight,
            alignment: Alignment.bottomLeft,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderDecoration(Size size) {
    return SizedBox(
      height: size.height * 0.35,
      width: double.infinity,
      child: ClipPath(
        clipper: BottomInwardClipper(),
        child: Container(color: Colors.green),
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'app_logo',
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.jpg',
          height: 250,
          width: 250,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          programName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Arbotek',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green,
            height: 1.2,
          ),
        ),
        Text(
          'ILUMINIX',
          textAlign: TextAlign.center,
          style: const TextStyle(
            // fontFamily: 'Arbotek',
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.green,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(Size size) {
    final maxWidth = size.width > 600 ? 420.0 : double.infinity;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextFormField(
                controller: _emailCtrl,
                label: 'Email',
                validator: emailValidator,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _passCtrl,
                label: 'Senha',
                obscureText: _obscurePass,
                validator: passwordValidator,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleLogin,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Entrar'),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentGeometry.centerRight,
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => SignUpBottomSheet.show(context),
                  child: const Text(
                    'Criar nova conta',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ===================== CLIPPER =====================

class BottomInwardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final factor = size.width > 500 ? 2.0 : 1.7;
    final path = Path();

    final leftDepth = size.height * 0.78;
    final circleRadius = size.width * factor;
    final centerY = leftDepth + circleRadius * 0.92;
    final centerX = size.width * 0.85;
    final rightHeight = size.height * 0.2;

    path
      ..moveTo(0, 0)
      ..lineTo(0, leftDepth)
      ..arcTo(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: circleRadius),
        3.14159,
        3.14159,
        false,
      )
      ..lineTo(size.width, rightHeight)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
