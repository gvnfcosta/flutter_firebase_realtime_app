import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_firebase_realtime_app/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  // ======================================================
  // BUSCAR USUÁRIO
  // ======================================================
  Future<UserModel?> fetchUserData(String uid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null || currentUid != uid) {
      throw Exception(
        "Acesso negado: UID não corresponde ao usuário autenticado",
      );
    }

    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        _user = UserModel.fromMap(map: doc.data()!, id: doc.id);
      }

      notifyListeners();
      return _user;
    } catch (e) {
      debugPrint("Erro ao buscar usuário: $e");
      _user = null;
      notifyListeners();
      return null;
    }
  }

  // ======================================================
  // SALVAR / ATUALIZAR USUÁRIO
  // ======================================================
  Future<void> saveUserData(UserModel user) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null || user.id != currentUid) {
      throw Exception("Não é permitido salvar dados de outro usuário");
    }

    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
      _user = user;
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao salvar usuário: $e");
      rethrow;
    }
  }

  // ======================================================
  // EXCLUIR USUÁRIO
  // ======================================================
  Future<void> deleteUserData(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      clearUser();
      debugPrint("✅ Dados do usuário $uid removidos do Firestore");
    } catch (e) {
      debugPrint("Erro ao excluir usuário: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _user = null;
    super.dispose();
  }
}
