import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/client_model.dart';
import '../../../providers/client_provider.dart';
import '../../common/custom_text_form_field.dart';
import '../../common/custom_widgets.dart';
import '../../config/app_data.dart';
import 'components/client_head_card.dart';
import 'components/confirm_delete.dart';

class ClientDetailScreen extends StatefulWidget {
  final String userCode;
  final String clientId;

  const ClientDetailScreen({
    super.key,
    required this.userCode,
    required this.clientId,
  });

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  ClientModel? _client;
  bool _loading = true;
  bool _isEditing = false;

  // Controllers
  final _phoneCtrl = TextEditingController();
  final _birthdayCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClientData();
  }

  Future<void> _loadClientData() async {
    try {
      final provider = context.read<ClientProvider>();
      final client = await provider.fetchById(widget.userCode, widget.clientId);

      if (client == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('$clientTitle não encontrado.')),
        );
        Navigator.pop(context);
        return;
      }

      if (mounted) {
        _client = client;

        // Preenche controladores
        _phoneCtrl.text = client!.phone;
        _birthdayCtrl.text = client.birthday;
        _weightCtrl.text = client.weight.toString();

        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint("Erro ao carregar $clientTitle: $e");
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar dados do cliente.')),
        );
      }
    }
  }

  Future<void> _saveClient() async {
    if (_client == null) return;

    try {
      final updated = _client!.copyWith(
        phone: _phoneCtrl.text,
        birthday: _birthdayCtrl.text,
        weight: double.tryParse(_weightCtrl.text) ?? _client!.weight,
      );

      await context.read<ClientProvider>().save(widget.userCode, updated);

      setState(() {
        _client = updated;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dados atualizados com sucesso!")),
      );
    } catch (e) {
      debugPrint('Erro ao salvar cliente: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  Future<void> _onDelete() async {
    if (_client == null) return;

    if (!await confirmDelete(context, _client!.name)) return;

    try {
      await context.read<ClientProvider>().delete(
        widget.userCode,
        widget.clientId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cliente excluído.')));

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao excluir: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil do Usuário')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil do Usuário')),
        body: const Center(child: Text('Cliente não encontrado.')),
      );
    }

    final c = _client!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveClient();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _onDelete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClientHeaderCard(c),
            const SizedBox(height: 20),

            // TELEFONE
            CustomTextFormField(
              icon: Icons.phone,
              label: "Telefone",
              controller: _phoneCtrl,
              readOnly: !_isEditing,
              keyboardType: TextInputType.phone,
              onChanged: (_) {},
            ),

            // NASCIMENTO
            CustomTextFormField(
              icon: Icons.date_range,
              label: "Nascimento",
              controller: _birthdayCtrl,
              readOnly: !_isEditing,
              onTap: _isEditing
                  ? () async {
                      // opcional: você pode abrir um datepicker se quiser
                    }
                  : null,
            ),

            // PESO
            CustomTextFormField(
              icon: Icons.monitor_weight,
              label: "Peso (kg)",
              controller: _weightCtrl,
              keyboardType: TextInputType.number,
              readOnly: !_isEditing,
            ),

            // CÓDIGO DO CLIENTE
            CustomTextFormField(
              icon: Icons.code,
              label: "Código",
              initialValue: c.id,
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}
