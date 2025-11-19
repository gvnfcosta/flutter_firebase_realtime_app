import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _keyUid = 'uid';
  static const _keyEmail = 'email';
  static const _keyPass = 'password';
  static const _keySkipAutoLogin = 'skip_auto_login';

  /// 🔹 Salva UID, email e senha (com codificação Base64)
  static Future<void> saveLogin(
    String uid,
    String email, [
    String? password,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    prefs
      ..setString(_keyUid, uid)
      ..setString(_keyEmail, email);
    if (password != null && password.isNotEmpty) {
      final encodedPass = base64Encode(utf8.encode(password));
      await prefs.setString(_keyPass, encodedPass);
    }
  }

  static Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUid);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// 🔹 Recupera a senha, decodificando se estiver em Base64
  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyPass);

    if (stored == null || stored.isEmpty) return null;

    try {
      return utf8.decode(base64Decode(stored));
    } catch (_) {
      return stored;
    }
  }

  /// 🔹 Limpa todos os dados de login
  static Future<void> removeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUid);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPass);
  }

  /// 🔹 Verifica se há login salvo
  static Future<bool> isLogged() async {
    final uid = await getUid();
    return uid != null && uid.isNotEmpty;
  }

  // ===============================================================
  // 🚫 AUTO LOGIN FLAG
  // ===============================================================

  /// Define se o autoLogin deve ser ignorado (ex.: após exclusão de conta)
  static Future<void> setSkipAutoLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySkipAutoLogin, value);
  }

  /// Retorna true se o autoLogin deve ser ignorado
  static Future<bool> getSkipAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySkipAutoLogin) ?? false;
  }
}
