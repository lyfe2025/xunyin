import 'package:package_info_plus/package_info_plus.dart';

/// 应用信息工具类
class AppInfo {
  static PackageInfo? _packageInfo;

  /// 初始化（在 main.dart 中调用）
  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// 获取版本号 (如 1.0.0)
  static String get version => _packageInfo?.version ?? '1.0.0';

  /// 获取构建号 (如 1)
  static String get buildNumber => _packageInfo?.buildNumber ?? '1';

  /// 获取完整版本 (如 1.0.0+1)
  static String get fullVersion => '$version+$buildNumber';

  /// 获取应用名称
  static String get appName => _packageInfo?.appName ?? '寻印';

  /// 获取包名
  static String get packageName => _packageInfo?.packageName ?? '';
}
