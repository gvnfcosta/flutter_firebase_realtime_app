import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_firebase_realtime_app/models/user_model.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;

  String? _uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recupera o argumento passado pela rota nomeada
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _uid = args;
      _loadUserData(); // carrega os dados com base no UID
    }
  }

  Future<void> _loadUserData() async {
    if (_uid == null) return;
    try {
      final provider = context.read<UserProvider>();
      await provider.fetchUserData(_uid!);
      final user = provider.user;
      if (user != null) {
        _nameController.text = user.name;
        _phoneController.text = user.phone;
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados do usuário: $e");
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = UserModel(
        id: _uid!,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      await context.read<UserProvider>().saveUserData(user);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário salvo com sucesso!')),
      );

      Navigator.pushReplacementNamed(context, '/userDetail');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
      debugPrint("Erro ao salvar usuário: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                validator: (v) => v!.isEmpty ? 'Informe o telefone' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _saveUser,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
