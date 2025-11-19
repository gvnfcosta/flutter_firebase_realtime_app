import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_realtime_app/models/client_model.dart';
import 'package:flutter_firebase_realtime_app/providers/client_provider.dart';
import 'package:flutter_firebase_realtime_app/src/common/birth_date_field.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_text_form_field.dart';
import 'package:flutter_firebase_realtime_app/src/common/custon_functions.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_data.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:flutter_firebase_realtime_app/src/screens/sign_in/widgets/custom_button.dart';
import 'package:provider/provider.dart';

import '../../components/phone_field_widget.dart';

class ClientBottomSheet {
  late final String userCode = FirebaseAuth.instance.currentUser!.uid;

  static Future<bool?> show(BuildContext context, {String? clientId}) {
    // 👇 return direto, sem "await"
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ClientBottomSheetContent(clientId: clientId),
    );
  }
}

class _ClientBottomSheetContent extends StatefulWidget {
  final String? clientId;

  const _ClientBottomSheetContent({this.clientId});

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
  late final String userCode;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    userCode = FirebaseAuth.instance.currentUser!.uid;
    if (widget.clientId != null) {
      _loadClientData();
    }
  }

  Future<void> _loadClientData() async {
    setState(() => _loading = true);
    try {
      final provider = context.read<ClientProvider>();
      final client = await provider.fetchById(userCode, widget.clientId!);
      if (client != null) {
        _nameController.text = client.name;
        _emailController.text = client.email;
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
        userCode: userCode,
        weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
      );

      final user = FirebaseAuth.instance.currentUser;

      debugPrint('DEBUG: currentUser = $user');
      debugPrint('DEBUG: currentUser.uid = ${user?.uid}');
      debugPrint('DEBUG: userCode (local) = $userCode');
      debugPrint('DEBUG: saving path = users/$userCode/clients/${client.id}');

      await context.read<ClientProvider>().save(user!.uid, client);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('$clientTitle Cadastrado!')));

      Navigator.pop(context, true);
      Navigator.pushNamed(
        context,
        AppRoutes.clientDetail,
        arguments: {'userCode': userCode, 'clientId': client.id},
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

  Future<void> quickWriteTest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('quickWriteTest: user null');
      return;
    }
    final uid = user.uid;
    try {
      await FirebaseFirestore.instance.collection('debug_tests').doc(uid).set({
        'ts': FieldValue.serverTimestamp(),
        'uid': uid,
      });
      debugPrint('quickWriteTest: OK saved debug_tests/$uid');
    } catch (e) {
      debugPrint('quickWriteTest: ERRO -> $e');
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
                  color: AppColors.secondry,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Campos do $clientTitle
              CustomTextFormField(
                controller: _nameController,
                icon: Icons.person,
                label: 'Nome',
                isEditing: true,
                validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 4),

              PhoneFieldWidget(
                controller: _phoneController,
                onChanged: (value) {
                  debugPrint('PhoneField: Valor digitado = $value');
                },
              ),
              const SizedBox(height: 4),
              BirthDateField(controller: _birthdayController),
              const SizedBox(height: 4),
              CustomTextFormField(
                controller: _weightController,
                icon: Icons.scale,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // substitui ponto por vírgula automaticamente
                    return newValue.copyWith(
                      text: newValue.text.replaceAll('.', ','),
                      selection: newValue.selection,
                    );
                  }),
                ],
                label: 'Peso (kg)',
                isEditing: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o peso' : null,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _loading
                    ? 'Salvando...'
                    : (isEditing ? 'Atualizar' : 'Salvar'),
                onPressed: _loading ? null : _saveClient,
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
