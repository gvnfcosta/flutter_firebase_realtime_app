import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_text_field.dart';
import 'package:flutter_firebase_realtime_app/src/common/validators.dart';
import 'package:flutter_firebase_realtime_app/src/services/auth_services.dart';

class SignUpBottomSheet {
  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SignUpContent(),
    );
  }
}

class _SignUpContent extends StatefulWidget {
  const _SignUpContent();

  @override
  State<_SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends State<_SignUpContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final bool obscureText = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await AuthService.signUp(
      context: context,
      formKey: _formKey,
      emailCtrl: _emailCtrl,
      passCtrl: _passCtrl,
      confirmPassCtrl: _confirmPassCtrl,
      setLoading: (val) => setState(() => _loading = val),
    );
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.48,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 30,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Título
                    const Text(
                      'Criar Conta',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    CustomTextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      icon: Icons.email,
                      label: 'E-mail',
                      validator: emailValidator,
                    ),
                    const SizedBox(height: 12),

                    // Senha
                    CustomTextFormField(
                      controller: _passCtrl,
                      label: 'Senha',
                      obscureText: obscureText,
                      icon: Icons.lock,
                      validator: passwordValidator,
                    ),

                    const SizedBox(height: 12),

                    // Confirmar Senha
                    CustomTextFormField(
                      controller: _confirmPassCtrl,
                      obscureText: obscureText,
                      icon: Icons.lock,
                      textInputAction: TextInputAction.done,
                      label: 'Confirmar senha',
                      validator: (v) =>
                          matchPasswordValidator(v, _passCtrl.text),
                    ),
                    const SizedBox(height: 24),

                    // Botão Cadastrar
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Cadastrar'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Fechar
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Já tenho conta / Fechar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                    // Espaço final
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
