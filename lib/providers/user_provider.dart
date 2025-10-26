import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final dbRef = FirebaseDatabase.instance.ref();

  UserModel? get user => _user;

  Future<void> fetchUserData(String uid) async {
    try {
      final snapshot = await dbRef.child('users/$uid').get();
      if (snapshot.exists) {
        _user = UserModel.fromMap(snapshot.value as Map);
      } else {
        _user = null; // usuário ainda sem dados pessoais
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao buscar dados do usuário: $e");
      _user = null;
      notifyListeners();
    }
  }

  Future<void> saveUserData(UserModel user) async {
    try {
      await dbRef.child('users/${user.id}').set(user.toMap());
      _user = user;
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao salvar usuário: $e");
      rethrow;
    }
  }
}
