import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/models/client_model.dart';
import 'package:flutter_firebase_realtime_app/providers/client_provider.dart';
import 'package:flutter_firebase_realtime_app/src/common/birth_date_field.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_text_field.dart';
import 'package:flutter_firebase_realtime_app/src/common/custon_functions.dart';
import 'package:flutter_firebase_realtime_app/src/common/validators.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_data.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:provider/provider.dart';

class ClientBottomSheet {
  static Future<bool?> show(
    BuildContext context, {
    required String userCode,
    String? clientId,
  }) {
    // 👇 return direto, sem "await"
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          _ClientBottomSheetContent(userCode: userCode, clientId: clientId),
    );
  }
}

class _ClientBottomSheetContent extends StatefulWidget {
  final String userCode;
  final String? clientId;

  const _ClientBottomSheetContent({required this.userCode, this.clientId});

  @override
  State<_ClientBottomSheetContent> createState() =>
      _ClientBottomSheetContentState();
}

class _ClientBottomSheetContentState extends State<_ClientBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _weightController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.clientId != null) {
      _loadClientData();
    }
  }

  Future<void> _loadClientData() async {
    setState(() => _loading = true);
    try {
      final provider = context.read<ClientProvider>();
      final client = await provider.fetchClientById(
        widget.userCode,
        widget.clientId!,
      );
      if (client != null) {
        _nameController.text = client.name;
        _emailController.text = client.name;
        _phoneController.text = client.phone;
        _birthdayController.text = client.birthday;
        _weightController.text = client.weight.toString();
      }
    } catch (e) {
      debugPrint("Erro ao carregar $clientTitle: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar dados do $clientTitle.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final client = ClientModel(
        id: widget.clientId ?? generateRandomId(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        birthday: _birthdayController.text.trim(),
        userCode: widget.userCode,
        weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
      );

      final user = FirebaseAuth.instance.currentUser;
      await context.read<ClientProvider>().saveClient(user!.uid, client);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('$clientTitle Cadastrado!')));

      Navigator.pop(context, true);
      Navigator.pushNamed(
        context,
        AppRoutes.clientDetail,
        arguments: {'userCode': widget.userCode, 'clientId': client.id},
      );
    } catch (e) {
      debugPrint("Erro ao salvar $clientTitle: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar $clientTitle: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom + 16;
    final isEditing = widget.clientId != null && widget.clientId!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset,
        left: 24,
        right: 24,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEditing ? 'Editar $clientTitle' : 'Novo $clientTitle',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Campos do $clientTitle
              CustomTextFormField(
                controller: _nameController,
                label: 'Nome',
                validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _phoneController,
                label: 'Telefone',
                validator: (v) => phoneValidator(v),
              ),
              const SizedBox(height: 16),
              BirthDateField(controller: _birthdayController),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                label: 'Peso (kg)',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o peso' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _saveClient,
                  icon: _loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _loading
                        ? 'Salvando...'
                        : (isEditing ? 'Atualizar' : 'Salvar'),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Fechar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
