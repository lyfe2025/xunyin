import 'dart:io';

/// 高德地图配置
///
/// Key 从后端 API 动态获取，这里只保留隐私合规配置
class AMapConfig {
  /// 隐私合规配置
  static const bool privacyShow = true;
  static const bool privacyAgree = true;

  // 动态配置（从 API 获取后设置）
  static String _androidKey = '';
  static String _iosKey = '';

  /// 设置 Key（从 API 获取后调用）
  static void setKeys({required String androidKey, required String iosKey}) {
    _androidKey = androidKey;
    _iosKey = iosKey;
  }

  /// 获取当前平台的 Key
  static String get currentPlatformKey {
    if (Platform.isAndroid) {
      return _androidKey;
    } else if (Platform.isIOS) {
      return _iosKey;
    }
    return '';
  }

  /// Android 平台 Key
  static String get androidKey => _androidKey;

  /// iOS 平台 Key
  static String get iosKey => _iosKey;

  /// 是否已配置
  static bool get isConfigured => _androidKey.isNotEmpty || _iosKey.isNotEmpty;
}
