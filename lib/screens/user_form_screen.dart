import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/src/common/custon_functions.dart';
import 'package:flutter_firebase_realtime_app/src/common/validators.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_realtime_app/models/user_model.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';

class UserFormScreen extends StatefulWidget {
  final String uid;
  const UserFormScreen({super.key, required this.uid});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = widget.uid; // agora temos o UID garantido
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recupera o argumento passado pela rota nomeada
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _uid = args;
      _loadUserData();
    }
  }

  /// Carrega os dados do usuário autenticado, se existirem
  Future<void> _loadUserData() async {
    final provider = context.read<UserProvider>();

    // Evita recarregar dados já disponíveis no provider
    if (provider.user != null && provider.user!.id == _uid) {
      _nameController.text = provider.user!.name;
      _emailController.text = provider.user!.email;
      return;
    }

    try {
      await provider.fetchUserData(_uid!);
      final user = provider.user;
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados do usuário: $e");
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
          id: _uid!,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          code: getLastChars(_uid),
          level: 0);

      await context.read<UserProvider>().saveUserData(user);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário salvo com sucesso!')),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.userDetail,
        (route) => false, // 🔹 limpa toda a pilha
      );
    } catch (e) {
      debugPrint("Erro ao salvar usuário: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
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
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => emailValidator(v),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
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
