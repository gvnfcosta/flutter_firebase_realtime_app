import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/models/client_model.dart';
import 'package:flutter_firebase_realtime_app/providers/client_provider.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_widgets.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_data.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
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
      return const Center(child: CustomProgressIndicator());
    }

    return Scaffold(
      appBar: CustomAppBar(
        aboveText: '  ${clientTitle}s de $userName',
        leading: Icon(Icons.business_center),
        showBackButton: false,
      ),

      body: _clients.isEmpty
          ? const Center(child: Text('Nenhum $clientTitle Cadastrado.'))
          : Center(
              child: SizedBox(
                width: 400,
                child: RefreshIndicator(
                  onRefresh: _loadClients,
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,

                      itemCount: 8, //_clients.length,
                      itemBuilder: (context, index) {
                        final client = _clients[0];
                        return ClientCard(
                          client: client,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.clientDetail,
                              arguments: {
                                'userCode': userCode,
                                'clientId': client.id,
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (userCode != null) {
            final created = await ClientBottomSheet.show(
              context,
              userCode: userCode!,
            );

            if (created == true) {
              _loadClients();
            }
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
