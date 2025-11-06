import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/models/user_model.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_text_field.dart';
import 'package:flutter_firebase_realtime_app/src/common/custon_functions.dart';
import 'package:flutter_firebase_realtime_app/src/common/validators.dart';
import 'package:provider/provider.dart';

class UserBottomSheet {
  static Future<void> show(BuildContext context, {required String uid}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserBottomSheetContent(uid: uid),
    );
  }
}

class _UserBottomSheetContent extends StatefulWidget {
  final String uid;
  const _UserBottomSheetContent({required this.uid});

  @override
  State<_UserBottomSheetContent> createState() =>
      _UserBottomSheetContentState();
}

class _UserBottomSheetContentState extends State<_UserBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final provider = context.read<UserProvider>();
    final uid = widget.uid;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso!')),
      );

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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

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
                  // Indicador superior
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Editar Dados do Usuário',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  CustomTextFormField(
                    controller: _nameCtrl,
                    label: 'Nome',
                    validator: nameValidator,
                    textInputAction: TextInputAction.next,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 12),

                  CustomTextFormField(
                    controller: _emailCtrl,
                    label: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                    validator: emailValidator,
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 24),

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

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
