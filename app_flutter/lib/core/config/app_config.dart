/// App 配置
class AppConfig {
  static const String appName = '寻印';
  static const String appVersion = '1.0.0';

  // 环境配置 - 通过 --dart-define=ENV=prod 切换
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
  static bool get isDev => env == 'dev';
  static bool get isProd => env == 'prod';

  // API 配置
  static String get baseUrl {
    switch (env) {
      case 'prod':
        return 'https://api.xunyin.com/api/app'; // 生产环境
      case 'dev':
      default:
        return 'http://localhost:3000/api/app'; // 开发环境
    }
  }

  // 分享链接域名
  static String get shareBaseUrl {
    switch (env) {
      case 'prod':
        return 'https://xunyin.app';
      case 'dev':
      default:
        return 'http://localhost:5173'; // 开发环境使用前端地址
    }
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // 存储 Key
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_info';
}
