import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'widgets/app_title.dart';
import 'widgets/bottom_inward_clipper.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_text_form_field.dart';
import 'package:flutter_firebase_realtime_app/src/common/validators.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';
import 'package:flutter_firebase_realtime_app/src/screens/sign_in/widgets/signup_buttom_sheet.dart';
import 'package:flutter_firebase_realtime_app/src/services/auth_services.dart';

import 'widgets/custom_button.dart';

/// Tela de login principal.
/// Exibe o formulário de email e senha, tenta login automático e
/// direciona para o fluxo de autenticação controlado pelo AuthService.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // ===================== CONTROLES E VARIÁVEIS =====================

  final _emailCtrl = TextEditingController(); // controla campo de email
  final _passCtrl = TextEditingController(); // controla campo de senha
  final _formKey = GlobalKey<FormState>(); // controla o formulário

  bool _loading = false; // controla estado de carregamento (spinner)
  bool _autoTried = false; // evita tentar autoLogin mais de uma vez
  static const bool _obscurePass = true; // oculta caracteres da senha

  // ===================== CICLO DE VIDA =====================

  @override
  void initState() {
    super.initState();
    _attemptAutoLogin(); // tenta login automático ao abrir a tela
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ===================== FUNÇÕES AUXILIARES =====================

  /// Atualiza o estado de carregamento
  void _setLoading(bool val) => setState(() => _loading = val);

  /// Tenta realizar login automático (usando dados salvos no dispositivo)
  Future<void> _attemptAutoLogin() async {
    if (_autoTried) return; // garante que só roda uma vez
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

  /// Executa login manual após o clique no botão “Entrar”
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return; // valida campos

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

  // ===================== INTERFACE =====================

  @override
  Widget build(BuildContext context) {
    // Detecta se o teclado está aberto (para ajustar o layout dinamicamente)
    const double keyboardThreshold = 100;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardOpen = keyboardHeight > keyboardThreshold;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          // Usa Stack para sobrepor fundo decorativo, imagem inferior e conteúdo
          return Stack(
            children: [
              _buildHeaderDecoration(size), // faixa superior colorida
              _buildFooterImage(size, isKeyboardOpen), // imagem inferior
              // === CONTEÚDO PRINCIPAL ===
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: isKeyboardOpen
                        ? keyboardHeight +
                              24 // ajusta espaço ao teclado
                        : 40, // padding padrão se teclado fechado
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      // Garante altura mínima do conteúdo igual à tela
                      minHeight:
                          constraints.maxHeight -
                          (isKeyboardOpen ? keyboardHeight : 0),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          _buildLogo(size), // logotipo circular
                          const SizedBox(height: 24),
                          appTitle(size), // título animado / nome do app
                          const SizedBox(height: 12),
                          _buildForm(size), // formulário de login

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

  // ===================== WIDGETS DE DECORAÇÃO =====================

  /// Imagem decorativa inferior (espelhada horizontalmente)
  Widget _buildFooterImage(Size size, bool isKeyboardOpen) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: size.height * 0.25, // ocupa 25% da altura da tela
      child: AnimatedOpacity(
        opacity: isKeyboardOpen ? 0.3 : 1.0, // reduz opacidade ao abrir teclado
        duration: const Duration(milliseconds: 300),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(
            math.pi,
          ), // espelha a imagem horizontalmente
          child: Image.asset(
            'assets/images/Footer.png',
            fit: BoxFit.fitHeight,
            alignment: Alignment.bottomLeft,
          ),
        ),
      ),
    );
  }

  /// Faixa superior curva com cor de fundo principal
  Widget _buildHeaderDecoration(Size size) {
    return SizedBox(
      height: size.height * 0.3, // ocupa 30% da altura
      width: double.infinity,
      child: ClipPath(
        clipper: BottomInwardClipper(), // aplica curva personalizada
        child: Container(color: AppColors.backGroundColor),
      ),
    );
  }

  /// Exibe o logotipo circular com animação Hero
  Widget _buildLogo(Size size) {
    final double logoSize = size.height * 0.2;
    return Hero(
      tag: 'app_logo', // animação entre telas com mesmo tag
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

  // ===================== FORMULÁRIO DE LOGIN =====================

  /// Monta o formulário de login com campos e botões
  Widget _buildForm(Size size) {
    // Em telas grandes, limita largura para melhor visualização
    final maxWidth = size.width > 600 ? 420.0 : double.infinity;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo de email
              CustomTextFormField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email,
                validator: emailValidator, // valida formato do email
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),

              // Campo de senha
              CustomTextFormField(
                controller: _passCtrl,
                icon: Icons.lock,
                label: 'Senha',
                obscureText: _obscurePass, // oculta caracteres
                validator: passwordValidator, // valida comprimento mínimo
              ),
              const SizedBox(height: 24),

              // Botão de login
              CustomButton(
                text: 'Entrar',
                isLoading: _loading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 12),

              // Botão para criar nova conta (abre bottom sheet)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => SignUpBottomSheet.show(
                          context,
                        ), // abre modal de cadastro
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

// 🧭 Estrutura resumida:

// Seção	          Conteúdo	                                                Função

// Ciclo de Vida	   initState, dispose	                                      Inicializa e limpa controladores
// AutoLogin	      _attemptAutoLogin	                                        Tenta autenticar automaticamente
// Login Manual	    _handleLogin	                                            Executa login via formulário
// UI Responsiva	   build	                                                  Ajusta layout ao abrir teclado
// Decoração	      _buildHeaderDecoration, _buildFooterImage, _buildLogo	    Cria fundo e logotipo
// Formulário	      _buildForm	                                              Campos, botão de login e link de cadastro
