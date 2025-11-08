import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter_firebase_realtime_app/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final dbRef = FirebaseDatabase.instance.ref();

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  // Busca os dados do usuário autenticado
  // Busca os dados do usuário autenticado
  Future<UserModel?> fetchUserData(String uid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null || uid != currentUid) {
      throw Exception(
        "Acesso negado: UID não corresponde ao usuário autenticado",
      );
    }

    try {
      final snapshot = await dbRef.child('users/$uid').get();

      _user = snapshot.exists
          ? UserModel.fromMap(Map<String, dynamic>.from(snapshot.value as Map))
          : null;

      notifyListeners();
      return _user; // ✅ retorna o modelo
    } catch (e) {
      debugPrint("Erro ao buscar dados do usuário: $e");
      _user = null;
      notifyListeners();
      return null; // ✅ evita erro ao tentar acessar depois
    }
  }

  // Salva ou atualiza os dados do usuário autenticado
  Future<void> saveUserData(UserModel user) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null || user.id != currentUid) {
      throw Exception("Não é permitido salvar dados de outro usuário");
    }

    try {
      await dbRef.child('users/${user.id}').set(user.toMap());
      _user = user;
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao salvar usuário: $e");
      rethrow;
    }
  }

  // Limpa o estado quando o provider for descartado
  @override
  void dispose() {
    _user = null;
    super.dispose();
  }
}
