import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/models/cliente_model.dart';
import 'package:flutter_firebase_realtime_app/providers/client_provider.dart';
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
        content: const Text(
          'Tem certeza que deseja excluir este $clientTitle?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('$clientTitle excluído com sucesso.')),
      );

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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final client = _client;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(client != null ? client.name : 'Detalhes do $clientTitle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir $clientTitle',
            onPressed: _deleteClient,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : client == null
          ? Center(
              child: Text(
                '$clientTitle não encontrado.',
                style: theme.textTheme.titleMedium,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'client_avatar_${client.id}',
                    child: _buildAvatar(client, theme),
                  ),
                  const SizedBox(height: 24),
                  _buildClientInfoCard(client, theme),
                  const SizedBox(height: 40),
                  _buildEditButton(theme, client),
                ],
              ),
            ),
    );
  }

  /// 🟣 Avatar circular com gradiente e animação
  Widget _buildAvatar(ClientModel client, ThemeData theme) {
    final initials = _getInitials(client.name);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer..withValues(alpha: 0.9),
            theme.colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary..withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 📄 Card de informações do cliente
  Widget _buildClientInfoCard(ClientModel client, ThemeData theme) {
    final labelStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    final valueStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurface,
    );

    Widget infoRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: labelStyle),
          Expanded(child: Text(value, style: valueStyle)),
        ],
      ),
    );

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            infoRow('Nome', client.name),
            infoRow('Fone', client.phone),
            infoRow('Data de Nascimento', client.birthday),
            infoRow('Peso', '${client.weight.toStringAsFixed(1)} kg'),
            infoRow('UserCode', client.userCode),
            infoRow('Client ID', client.id),
          ],
        ),
      ),
    );
  }

  /// ✏️ Botão moderno com animação Hero
  Widget _buildEditButton(ThemeData theme, ClientModel client) {
    return Hero(
      tag: 'edit_button_${client.id}',
      child: ElevatedButton.icon(
        onPressed: _goToClientForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        icon: const Icon(Icons.edit_outlined, size: 22),
        label: const Text(
          'Editar Dados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
