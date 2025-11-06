import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/models/cliente_model.dart';
import 'package:flutter_firebase_realtime_app/providers/client_provider.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_widgets.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_data.dart';
import 'package:flutter_firebase_realtime_app/src/screens/client/client_buttom_sheet.dart';
import 'package:flutter_firebase_realtime_app/src/screens/client/client_card.dart';
import 'package:provider/provider.dart';

class ClientTab extends StatefulWidget {
  const ClientTab({super.key});

  @override
  State<ClientTab> createState() => _ClientTabState();
}

class _ClientTabState extends State<ClientTab> {
  bool _loading = true;
  String? userCode;
  String? userName;
  List<ClientModel> _clients = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClients();
    });
  }

  Future<void> _loadClients() async {
    try {
      final provider = context.read<ClientProvider>();
      final userProvider = context.read<UserProvider>();
      userName = userProvider.user?.name;
      userCode = userProvider.user?.id;

      if (userCode == null) return;

      final clients = await provider.fetchAllClients(userCode: userCode!);

      if (!mounted) return;

      setState(() {
        _clients = clients;
        _clients.sort((a, b) => a.name.compareTo(b.name));
        _loading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar $clientTitle: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar $clientTitle')),
        );
      }
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CustomProgessIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.business_center),
        title: Text('  ${clientTitle}s de $userName'),
      ),
      body: _clients.isEmpty
          ? const Center(child: Text('Nenhum $clientTitle Cadastrado.'))
          : RefreshIndicator(
              onRefresh: _loadClients,
              child: SingleChildScrollView(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    childAspectRatio: 1,
                  ),
                  itemCount: _clients.length,
                  itemBuilder: (context, index) {
                    final client = _clients[index];
                    return ClientCard(client: client, onTap: () {});
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (userCode != null) {
            ClientBottomSheet.show(context, userCode: userCode!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('$clientTitle não definido')),
            );
          }
        },
        mini: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
