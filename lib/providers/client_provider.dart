import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/models/client_model.dart';

class ClientProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<ClientModel> _clients = [];
  List<ClientModel> get clients => _clients;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Carrega todos os clientes do usuário logado
  Future<void> load(String userCode) async {
    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot = await firestore
          .collection('users')
          .doc(userCode)
          .collection('clients')
          .get();

      _clients = querySnapshot.docs
          .map((doc) => ClientModel.fromMap(doc.data()))
          .toList();

      _clients.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      debugPrint('Erro ao buscar clientes: $e');
      rethrow; // mantém rastreabilidade do erro
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Busca um cliente específico pelo ID
  Future<ClientModel?> fetchById(String userCode, String clientId) async {
    try {
      final docSnapshot = await firestore
          .collection('users')
          .doc(userCode)
          .collection('clients')
          .doc(clientId)
          .get();

      if (!docSnapshot.exists) return null;

      return ClientModel.fromMap(docSnapshot.data()!);
    } catch (e) {
      debugPrint('Erro ao buscar cliente: $e');
      return null;
    }
  }

  /// Salva ou atualiza um cliente
  Future<void> save(String userCode, ClientModel client) async {
    try {
      await firestore
          .collection('users')
          .doc(userCode)
          .collection('clients')
          .doc(client.id)
          .set(client.toMap());

      await load(userCode); // garante atualização automática
    } catch (e) {
      debugPrint('Erro ao salvar cliente: $e');
      rethrow;
    }
  }

  /// Exclui um cliente
  Future<void> delete(String userCode, String clientId) async {
    try {
      await firestore
          .collection('users')
          .doc(userCode)
          .collection('clients')
          .doc(clientId)
          .delete();

      await load(userCode); // garante remoção da lista automaticamente
    } catch (e) {
      debugPrint('Erro ao excluir cliente: $e');
      rethrow;
    }
  }
}
