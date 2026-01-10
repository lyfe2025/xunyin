import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/settings_providers.dart';

/// 设置偏好存储
class SettingsStorage {
  static const _keyNotificationEnabled = 'notification_enabled';
  static const _keyAutoLocationEnabled = 'auto_location_enabled';
  static const _keyThemeMode = 'theme_mode';

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

  /// 获取主题模式
  static Future<AppThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyThemeMode) ?? 0;
    return AppThemeMode.values[index.clamp(0, AppThemeMode.values.length - 1)];
  }

  /// 设置主题模式
  static Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
  }

  /// 获取缓存大小（字节）
  static Future<int> getCacheSize() async {
    int totalSize = 0;

    try {
      // 临时目录缓存
      final tempDir = await getTemporaryDirectory();
      totalSize += await _getDirectorySize(tempDir);

      // 应用缓存目录
      if (!kIsWeb) {
        final cacheDir = await getApplicationCacheDirectory();
        if (cacheDir.path != tempDir.path) {
          totalSize += await _getDirectorySize(cacheDir);
        }
      }
    } catch (e) {
      debugPrint('获取缓存大小失败: $e');
    }

    return totalSize;
  }

  /// 获取格式化的缓存大小字符串
  static Future<String> getFormattedCacheSize() async {
    final bytes = await getCacheSize();
    return _formatBytes(bytes);
  }

  /// 计算目录大小
  static Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    try {
      if (await dir.exists()) {
        await for (final entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File) {
            size += await entity.length();
          }
        }
      }
    } catch (e) {
      debugPrint('计算目录大小失败: $e');
    }
    return size;
  }

  /// 格式化字节数
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 清除所有缓存
  static Future<void> clearCache() async {
    // 清除 SharedPreferences（保留 token）
    final prefs = await SharedPreferences.getInstance();
    final keysToKeep = ['access_token', 'refresh_token'];
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (!keysToKeep.contains(key)) {
        await prefs.remove(key);
      }
    }

    // 清除临时目录
    try {
      final tempDir = await getTemporaryDirectory();
      await _clearDirectory(tempDir);

      // 清除应用缓存目录
      if (!kIsWeb) {
        final cacheDir = await getApplicationCacheDirectory();
        if (cacheDir.path != tempDir.path) {
          await _clearDirectory(cacheDir);
        }
      }
    } catch (e) {
      debugPrint('清除缓存目录失败: $e');
    }
  }

  /// 清空目录内容
  static Future<void> _clearDirectory(Directory dir) async {
    try {
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          await entity.delete(recursive: true);
        }
      }
    } catch (e) {
      debugPrint('清空目录失败: $e');
    }
  }
}
