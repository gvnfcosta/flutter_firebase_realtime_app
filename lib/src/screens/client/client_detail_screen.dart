import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/models/client_model.dart';
import 'package:flutter_firebase_realtime_app/providers/client_provider.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_widgets.dart';
import 'package:flutter_firebase_realtime_app/src/common/custon_functions.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_data.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadClientData();
  }

  Future<void> _loadClientData() async {
    try {
      final provider = context.read<ClientProvider>();
      final client = await provider.fetchClientById(
        widget.userCode,
        widget.clientId,
      );

      if (client == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('$clientTitle não encontrado.')),
        );
        Navigator.pop(context);
        return;
      }

      if (mounted) {
        setState(() {
          _client = client;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar $clientTitle: $e");
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar dados do $clientTitle.'),
          ),
        );
      }
    }
  }

  Future<void> _goToClientForm() async {
    if (_client == null) return;

    await Navigator.pushNamed(
      context,
      AppRoutes.clientForm,
      arguments: {'userCode': widget.userCode, 'clientId': widget.clientId},
    );

    // Recarrega após edição
    _loadClientData();
  }

  Future<void> _deleteClient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir $clientTitle'),
        content: Text(
          'Confirma exclusão de ${_client!.name}?',
          style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // fundo vermelho
              foregroundColor: Colors.white, // texto branco
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await context.read<ClientProvider>().deleteClient(
        widget.userCode,
        widget.clientId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('$clientTitle excluído.')));

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Erro ao excluir $clientTitle: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir $clientTitle: $e')),
        );
      }
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

    final client = _client!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Editar',
            onPressed: _goToClientForm,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Excluir',
            onPressed: _deleteClient,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeaderCard(context, client),
            const SizedBox(height: 20),
            InfoCard(
              icon: Icons.phone_rounded,
              label: 'Telefone',
              value: client.phone,
            ),
            InfoCard(
              icon: Icons.cake_rounded,
              label: 'Aniversário',
              value: client.birthday,
            ),
            InfoCard(
              icon: Icons.confirmation_number_rounded,
              label: 'Código do Usuário',
              value: client.userCode,
            ),
            InfoCard(
              icon: Icons.monitor_weight_rounded,
              label: 'Peso',
              value: '${client.weight.toStringAsFixed(1)} kg',
            ),
            const SizedBox(height: 40),
            Text(
              'ID Interno: ${client.id}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ClientModel client) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              child: Text(
                getInitials(client.name),
                style: TextStyle(
                  fontSize: 28,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    client.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
