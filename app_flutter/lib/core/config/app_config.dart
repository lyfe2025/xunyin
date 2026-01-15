/// App 配置
class AppConfig {
  static const String appName = '寻印';
  static const String appVersion = '1.0.0';

  // API 地址 - 打包前改成你的服务器地址
  // 格式：https://你的域名/api/app
  // static const String apiBaseUrl = 'https://api.xunyin.com/api/app'; // 生产环境
  static const String apiBaseUrl = 'http://localhost:3000/api/app'; // 本地开发

  // 分享链接域名 - 用于生成印记分享链接
  // 通常与管理后台 (web/) 同域名，如：https://admin.xunyin.com 如果分享链接是给普通用户看的，用独立短域名体验更好
  // static const String shareBaseUrl = 'https://xunyin.app'; // 生产环境
  static const String shareBaseUrl = 'http://localhost:5173'; // 本地开发

  // 网络超时
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // 存储 Key
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_info';
}
