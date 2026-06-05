import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageManager {
  static const _storage = FlutterSecureStorage();
  static const String keyToken = 'auth_token';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: keyToken, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: keyToken);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: keyToken);
  }
}
