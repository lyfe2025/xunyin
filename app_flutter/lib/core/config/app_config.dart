import 'package:flutter/foundation.dart' show kIsWeb;

/// App 配置
class AppConfig {
  static const String appName = '寻印';
  static const String appVersion = '1.0.0';

  // API 地址
  // Web 环境使用相对路径（由 Nginx 代理），原生 App 使用完整 URL
  static String get apiBaseUrl {
    if (kIsWeb) {
      // Web 环境：使用相对路径，Nginx 会代理到后端
      return '/api/app';
    }
    // 原生 App：使用完整 URL
    return 'https://xunyin.pynb.org/api/app'; // 生产环境
    // return 'http://localhost:3000/api/app'; // 本地开发
  }

  // 分享链接域名 - 用于生成印记分享链接
  static const String shareBaseUrl = 'https://xunyin.pynb.org'; // 生产环境
  // static const String shareBaseUrl = 'http://localhost:5173'; // 本地开发

  // 网络超时
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // 存储 Key
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_info';
}
