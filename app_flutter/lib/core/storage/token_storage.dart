import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

/// Token 安全存储
class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    await _storage.write(key: AppConfig.tokenKey, value: accessToken);
    await _storage.write(key: AppConfig.refreshTokenKey, value: refreshToken);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: AppConfig.tokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConfig.refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: AppConfig.tokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
