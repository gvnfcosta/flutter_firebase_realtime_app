import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/models/user_model.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_text_form_field.dart';
import 'package:flutter_firebase_realtime_app/src/common/custon_functions.dart';
import 'package:flutter_firebase_realtime_app/src/common/validators.dart';
import 'package:provider/provider.dart';

import '../sign_in/widgets/close_button.dart';

/// Exibe um [BottomSheet] para visualização e edição dos dados de um usuário.
///
/// Essa classe serve como ponto de entrada para abrir o modal
/// de edição de informações pessoais, recebendo o `uid` do usuário atual.
class UserBottomSheet {
  /// Mostra o modal do usuário com os dados associados ao [uid].
  ///
  /// O [BuildContext] é usado para exibir o modal e acessar o [UserProvider].
  static Future<void> show(BuildContext context, {required String uid}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // permite que ocupe quase a tela toda
      backgroundColor: Colors.transparent,
      builder: (context) => _UserBottomSheetContent(uid: uid),
    );
  }
}

/// Conteúdo interno do [UserBottomSheet].
///
/// Este widget contém o formulário e as ações de salvar/cancelar.
class _UserBottomSheetContent extends StatefulWidget {
  /// ID único do usuário a ser editado.
  final String uid;

  const _UserBottomSheetContent({required this.uid});

  @override
  State<_UserBottomSheetContent> createState() =>
      _UserBottomSheetContentState();
}

class _UserBottomSheetContentState extends State<_UserBottomSheetContent> {
  /// Chave global do formulário usada para validação.
  final _formKey = GlobalKey<FormState>();

  /// Controlador do campo de nome.
  final _nameCtrl = TextEditingController();

  /// Controlador do campo de e-mail.
  final _emailCtrl = TextEditingController();

  /// Define se a tela está em estado de carregamento (evita ações duplicadas).
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Carrega os dados do usuário ao abrir o modal.
  }

  /// Carrega os dados do usuário via [UserProvider].
  ///
  /// Se o usuário já estiver carregado em memória e corresponder ao [uid],
  /// apenas preenche os campos. Caso contrário, faz uma busca no Firebase.
  Future<void> _loadUserData() async {
    final provider = context.read<UserProvider>();
    final uid = widget.uid;

    // Reutiliza dados se já estiverem disponíveis
    if (provider.user != null && provider.user!.id == uid) {
      _nameCtrl.text = provider.user!.name;
      _emailCtrl.text = provider.user!.email;
      return;
    }

    try {
      await provider.fetchUserData(uid);
      final user = provider.user;
      if (user != null) {
        _nameCtrl.text = user.name;
        _emailCtrl.text = user.email;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar dados do usuário.')),
      );
    }
  }

  /// Salva os dados editados do usuário no Firebase.
  ///
  /// Primeiro valida o formulário, depois cria um [UserModel] atualizado
  /// e envia os dados via [UserProvider].
  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final uid = widget.uid;

    try {
      final user = UserModel(
        id: uid,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        code: getLastChars(uid),
        logoUrl: '',
        level: 0,
      );

      await context.read<UserProvider>().saveUserData(user);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dados atualizados!')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Libera os recursos dos controladores ao fechar o modal.
  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  /// Constrói a interface visual do modal, incluindo o formulário
  /// e os botões de ação (salvar/cancelar).
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
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
                  /// Indicador superior (aquela barrinha cinza para arrastar)
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Título principal
                  const Text(
                    'Editar Dados do Usuário',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  /// Campo de texto: Nome
                  CustomTextFormField(
                    controller: _nameCtrl,
                    label: 'Nome',
                    validator: nameValidator,
                    textInputAction: TextInputAction.next,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 12),

                  /// Campo de texto: E-mail
                  CustomTextFormField(
                    controller: _emailCtrl,
                    label: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                    validator: emailValidator,
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 24),

                  /// Botão principal: Salvar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _saveUser,
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _loading ? 'Salvando...' : 'Salvar Alterações',
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// Botão secundário: Cancelar
                  customButton(context, 'Cancelar'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
