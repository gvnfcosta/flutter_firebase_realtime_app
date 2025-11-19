import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/models/client_model.dart';
import 'package:flutter_firebase_realtime_app/providers/client_provider.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_widgets.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_data.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_routes.dart';
import 'package:flutter_firebase_realtime_app/src/screens/client/components/client_buttom_sheet.dart';
import 'package:flutter_firebase_realtime_app/src/screens/client/client_card.dart';
import 'package:provider/provider.dart';

class ClientTab extends StatefulWidget {
  const ClientTab({super.key});

  @override
  State<ClientTab> createState() => _ClientTabState();
}

class _ClientTabState extends State<ClientTab> {
  String? userCode;
  String? userName;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();

      userCode = userProvider.user?.id;
      userName = userProvider.user?.name;

      if (userCode != null) {
        context.read<ClientProvider>().load(userCode!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientProvider>();
    final clients = provider.clients;

    return Scaffold(
      appBar: CustomAppBar(
        aboveText: '  ${clientTitle}s de $userName',
        leading: Icon(Icons.business_center),
        showBackButton: false,
      ),

      body: provider.isLoading
          ? const Center(child: CustomProgressIndicator())
          : clients.isEmpty
          ? const Center(child: Text('Nenhum $clientTitle Cadastrado.'))
          : Center(
              child: SizedBox(
                width: 400,
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (userCode != null) {
                      await context.read<ClientProvider>().load(userCode!);
                    }
                  },
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,

                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
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
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          if (userCode == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Usuário não identificado')),
            );
            return;
          }

          final created = await ClientBottomSheet.show(context);

          if (created == true) {
            await context.read<ClientProvider>().load(userCode!);
          }
        },
      ),
    );
  }
}
