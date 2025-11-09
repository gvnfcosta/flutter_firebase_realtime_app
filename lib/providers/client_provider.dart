import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_firebase_realtime_app/models/client_model.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_data.dart';

class ClientProvider with ChangeNotifier {
  final dbRef = FirebaseDatabase.instance.ref();

  /// Lista todos os $clientTitles do usuário logado
  Future<List<ClientModel>> fetchAllClients({required String userCode}) async {
    try {
      final snapshot = await dbRef.child('users/$userCode/clients').get();

      if (!snapshot.exists) return [];

      final clientsMap = Map<String, dynamic>.from(snapshot.value as Map);
      final clients = clientsMap.entries.map((entry) {
        final data = Map<String, dynamic>.from(entry.value);
        return ClientModel.fromMap(data);
      }).toList();

      return clients;
    } catch (e) {
      debugPrint('Erro ao buscar $clientTitle: $e');
      return [];
    }
  }

  /// Busca um $clientTitle específico pelo ID
  Future<ClientModel?> fetchClientById(String userCode, String clientId) async {
    try {
      final snapshot = await dbRef
          .child('users/$userCode/clients/$clientId')
          .get();

      if (!snapshot.exists) return null;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return ClientModel.fromMap(data);
    } catch (e) {
      debugPrint('Erro ao buscar $clientTitle: $e');
      return null;
    }
  }

  /// Salva ou atualiza um $clientTitle
  Future<void> saveClient(String userCode, ClientModel client) async {
    try {
      await dbRef
          .child('users/$userCode/clients/${client.id}')
          .set(client.toMap());
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao salvar $clientTitle: $e');
      rethrow;
    }
  }

  /// Exclui um $clientTitle
  Future<void> deleteClient(String userCode, String clientId) async {
    try {
      await dbRef.child('users/$userCode/clients/$clientId').remove();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao excluir $clientTitle: $e');
      rethrow;
    }
  }
}
