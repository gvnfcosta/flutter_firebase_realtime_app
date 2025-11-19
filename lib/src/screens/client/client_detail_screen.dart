import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/client_model.dart';
import '../../../providers/client_provider.dart';
import '../../common/custom_text_form_field.dart';
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
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
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

      if (!mounted) return;

      if (client == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('$clientTitle não encontrado.')),
        );
        Navigator.pop(context);
        return;
      }

      _client = client;

      // Preenche controladores
      _nameCtrl.text = client.name;
      _emailCtrl.text = client.email;
      _phoneCtrl.text = client.phone;
      _birthdayCtrl.text = client.birthday;
      _weightCtrl.text = client.weight.toString().replaceAll('.', ',');

      setState(() => _loading = false);
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
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        phone: _phoneCtrl.text,
        birthday: _birthdayCtrl.text,
        weight:
            double.tryParse(_weightCtrl.text.replaceAll(',', '.')) ??
            _client!.weight,
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

  /// =====================================================
  /// MÉTODO AUXILIAR DE CAMPO
  /// =====================================================
  Widget buildField({
    required IconData icon,
    required String label,
    TextEditingController? controller,
    bool enabled = false,
    TextInputType? type,
  }) {
    return CustomTextFormField(
      icon: icon,
      label: label,
      controller: controller,
      isEditing: enabled, // habilita edição
      keyboardType: type,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados do Cliente'),
        actions: [
          if (!_loading && _client != null) ...[
            IconButton(
              icon: Icon(
                _isEditing ? Icons.check : Icons.edit,
                color: Colors.orange,
              ),
              onPressed: () {
                if (_isEditing) {
                  _saveClient();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _onDelete,
            ),
          ],
        ],
      ),
      body: Builder(
        builder: (_) {
          if (_loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_client == null) {
            return const Center(child: Text('Cliente não encontrado.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ClientHeaderCard(_client!),
                const SizedBox(height: 20),

                // Campos
                buildField(
                  icon: Icons.person,
                  label: "Nome",
                  controller: _nameCtrl,
                  enabled: _isEditing,
                ),

                buildField(
                  icon: Icons.email,
                  label: "Email",
                  controller: _emailCtrl,
                  enabled: _isEditing,
                ),

                buildField(
                  icon: Icons.phone,
                  label: "Telefone",
                  controller: _phoneCtrl,
                  enabled: _isEditing,
                  type: TextInputType.phone,
                ),

                buildField(
                  icon: Icons.date_range,
                  label: "Nascimento",
                  controller: _birthdayCtrl,
                  enabled: _isEditing,
                ),

                buildField(
                  icon: Icons.scale,
                  label: "Peso (kg)",
                  controller: _weightCtrl,
                  enabled: _isEditing,
                  type: TextInputType.number,
                ),

                // Código (somente leitura)
                CustomTextFormField(
                  icon: Icons.code,
                  label: "Código",
                  initialValue: _client!.id,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
