import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageUtils {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Token Keys
  static const String accessTokenKey = 'API_ACCESS_TOKEN';
  static const String refreshTokenKey = 'API_REFRESH_TOKEN';

  // Token Operations
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: refreshTokenKey);
  }

  static Future<void> setAccessToken(String token) async {
    await _storage.write(key: accessTokenKey, value: token);
  }

  static Future<void> setRefreshToken(String token) async {
    await _storage.write(key: refreshTokenKey, value: token);
  }

  static Future<void> deleteAccessToken() async {
    await _storage.delete(key: accessTokenKey);
  }

  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: refreshTokenKey);
  }

  static Future<void> deleteAllTokens() async {
    await deleteAccessToken();
    await deleteRefreshToken();
  }
}
