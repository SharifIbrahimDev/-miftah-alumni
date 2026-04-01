import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsManager {
  static const String keyToken = 'auth_token';
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveAuthData({
    required String token,
    required String role,
    required int id,
    required String name,
  }) async {
    await _prefs?.setString(keyToken, token);
    await _prefs?.setString(keyUserRole, role);
    await _prefs?.setInt(keyUserId, id);
    await _prefs?.setString(keyUserName, name);
  }

  static String? getToken() => _prefs?.getString(keyToken);
  static String? getRole() => _prefs?.getString(keyUserRole);
  static int? getUserId() => _prefs?.getInt(keyUserId);
  static String? getUserName() => _prefs?.getString(keyUserName);

  static Future<void> clearAuthData() async {
    await _prefs?.remove(keyToken);
    await _prefs?.remove(keyUserRole);
    await _prefs?.remove(keyUserId);
    await _prefs?.remove(keyUserName);
  }
}
