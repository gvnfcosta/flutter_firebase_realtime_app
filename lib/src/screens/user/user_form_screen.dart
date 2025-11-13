import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_firebase_realtime_app/src/common/custom_text_form_field.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_widgets.dart';
import 'package:flutter_firebase_realtime_app/src/common/custon_functions.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:flutter_firebase_realtime_app/models/user_model.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';

import '../../common/validators.dart';

class UserFormScreen extends StatefulWidget {
  final String uid;

  const UserFormScreen({super.key, required this.uid});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _loading = false;
  late String _uid;
  late String _userEmail;

  @override
  void initState() {
    super.initState();

    _uid = widget.uid;

    _loadUserData();
  }

  /// Carrega os dados do usuário autenticado, se existirem
  Future<void> _loadUserData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = await userProvider.fetchUserData(_uid);

      if (user != null) {
        _nameController.text = user.name;
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar dados do usuário.')),
      );
    }
  }

  /// Salva (ou atualiza) os dados do usuário
  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = UserModel(
        id: _uid,
        name: _nameController.text.trim(),
        email: _userEmail.trim(),
        code: getLastChars(_uid),
        logoUrl: '',
        level: 0,
      );

      await context.read<UserProvider>().saveUserData(user);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário salvo!')));

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false, // 🔹 limpa toda a pilha
      );
    } catch (e) {
      debugPrint("Erro ao salvar usuário: $e");
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
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userEmail = FirebaseAuth.instance.currentUser!.email ?? 'sem email';
    return Scaffold(
      appBar: CustomAppBar(
        aboveText: 'Cadastro de Usuário',
        showBackButton: false,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Complete seu Cadastro',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _nameController,
                label: 'Nome',
                validator: nameValidator,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                initialValue: _userEmail,
                label: 'Email',
                readOnly: true,
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: 300,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _saveUser,
                  icon: _loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_loading ? 'Salvando...' : 'Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
