import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'widgets/app_title.dart';
import 'widgets/bottom_inward_clipper.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_text_field.dart';
import 'package:flutter_firebase_realtime_app/src/common/validators.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_data.dart';
import 'package:flutter_firebase_realtime_app/src/screens/sign_in/widgets/signup_buttom_sheet.dart';
import 'package:flutter_firebase_realtime_app/src/services/auth_services.dart';

import 'widgets/custom_button.dart';

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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _setLoading(bool val) => setState(() => _loading = val);

  Future<void> _attemptAutoLogin() async {
    if (_autoTried) return;
    _autoTried = true;

    _setLoading(true);
    await AuthService.autoLogin(
      context: context,
      emailCtrl: _emailCtrl,
      passCtrl: _passCtrl,
      setLoading: (val) => _setLoading(val),
    );
    if (mounted) _setLoading(false);
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
    const double keyboardThreshold = 100;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardOpen = keyboardHeight > keyboardThreshold;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

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
                        ? keyboardHeight +
                              24 // espaço adequado quando teclado abre
                        : 40, // padding fixo e menor para evitar rolagem exagerada
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight -
                          (isKeyboardOpen ? keyboardHeight : 0),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLogo(size),
                          const SizedBox(height: 24),
                          appTitle(size),
                          const SizedBox(height: 12),
                          _buildForm(size),

                          if (_loading && !_autoTried)
                            const Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                'Tentando login automático...',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),

                          // Espaço final mínimo
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
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
      height: size.height * 0.25,
      child: AnimatedOpacity(
        opacity: isKeyboardOpen ? 0.3 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi), // 👈 espelhar horizontalmente
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
      height: size.height * 0.3,
      width: double.infinity,
      child: ClipPath(
        clipper: BottomInwardClipper(),
        child: Container(color: AppColors.backGroundColor),
      ),
    );
  }

  Widget _buildLogo(Size size) {
    final double logoSize = size.height * 0.2;
    return Hero(
      tag: 'app_logo',
      child: ClipOval(
        child: Image.asset(
          'assets/images/Logo.jpg',
          height: logoSize,
          width: logoSize,
          fit: BoxFit.cover,
        ),
      ),
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
                icon: Icons.email,
                validator: emailValidator,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              CustomTextFormField(
                controller: _passCtrl,
                icon: Icons.lock,
                label: 'Senha',
                obscureText: _obscurePass,
                validator: passwordValidator,
              ),
              const SizedBox(height: 24),

              // Botão Entrar
              CustomButton(
                text: 'Entrar',
                isLoading: _loading,
                onPressed: _handleLogin,
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
