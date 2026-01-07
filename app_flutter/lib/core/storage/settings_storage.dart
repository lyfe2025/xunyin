import 'package:shared_preferences/shared_preferences.dart';

/// 设置偏好存储
class SettingsStorage {
  static const _keyNotificationEnabled = 'notification_enabled';
  static const _keyAutoLocationEnabled = 'auto_location_enabled';

  /// 获取消息通知开关状态
  static Future<bool> getNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationEnabled) ?? true;
  }

  /// 设置消息通知开关
  static Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationEnabled, enabled);
  }

  /// 获取自动定位开关状态
  static Future<bool> getAutoLocationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoLocationEnabled) ?? true;
  }

  /// 设置自动定位开关
  static Future<void> setAutoLocationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoLocationEnabled, enabled);
  }

  /// 清除所有缓存
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    // 保留登录相关的 token，只清除其他缓存
    final keysToKeep = ['access_token', 'refresh_token'];
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (!keysToKeep.contains(key)) {
        await prefs.remove(key);
      }
    }
  }
}
