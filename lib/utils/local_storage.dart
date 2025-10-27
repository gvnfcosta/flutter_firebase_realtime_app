import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _keyUid = 'uid';
  static const _keyEmail = 'email';
  static const _keyPass = 'password';

  /// Salvar UID, email e senha
  static Future<void> saveLogin(String uid, String email,
      [String? password]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUid, uid);
    await prefs.setString(_keyEmail, email);
    if (password != null) await prefs.setString(_keyPass, password);
  }

  /// Recuperar UID
  static Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUid);
  }

  /// Recuperar email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// Recuperar senha
  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPass);
  }

  /// Remover login
  static Future<void> removeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUid);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPass);
  }

  /// Verifica se o usuário está logado
  static Future<bool> isLogged() async {
    final uid = await getUid();
    return uid != null && uid.isNotEmpty;
  }
}
