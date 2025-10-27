import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

class LocalStorage {
  static const _keyUid = 'uid';
  static const _keyEmail = 'email';
  static const _keyPass = 'password'; // ✅ nova chave para senha

  /// Salvar UID, email e senha
  static Future<void> saveLogin(String uid, String email, [String? password]) async {
    if (kIsWeb) {
      html.window.localStorage[_keyUid] = uid;
      html.window.localStorage[_keyEmail] = email;
      if (password != null) html.window.localStorage[_keyPass] = password;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUid, uid);
      await prefs.setString(_keyEmail, email);
      if (password != null) await prefs.setString(_keyPass, password);
    }
  }

  static Future<String?> getUid() async {
    if (kIsWeb) return html.window.localStorage[_keyUid];
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUid);
  }

  static Future<String?> getEmail() async {
    if (kIsWeb) return html.window.localStorage[_keyEmail];
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// ✅ Novo método: recuperar senha
  static Future<String?> getPassword() async {
    if (kIsWeb) return html.window.localStorage[_keyPass];
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPass);
  }

  /// Remover login
  static Future<void> removeLogin() async {
    if (kIsWeb) {
      html.window.localStorage.remove(_keyUid);
      html.window.localStorage.remove(_keyEmail);
      html.window.localStorage.remove(_keyPass);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUid);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyPass);
    }
  }

  static Future<bool> isLogged() async {
    final uid = await getUid();
    return uid != null && uid.isNotEmpty;
  }
}
