/// App 配置
class AppConfig {
  static const String appName = '寻印';
  static const String appVersion = '1.0.0';

  // API 地址 - 打包前改成你的服务器地址
  // 生产环境：Nginx 会将 /api/* 反向代理到后端 3000 端口
  // 示例：https://xunyin.com/api/app → http://localhost:3000/api/app
  // static const String apiBaseUrl = 'https://xunyin.com/api/app'; // 生产环境
  static const String apiBaseUrl = 'http://localhost:3000/api/app'; // 本地开发

  // 分享链接域名 - 用于生成印记分享链接
  // 生产环境：与 API 同域名即可，Nginx 会根据路径分发请求
  // /api/* → 后端服务 (3000)
  // /* → 前端静态文件 (web/)
  // static const String shareBaseUrl = 'https://xunyin.com'; // 生产环境
  static const String shareBaseUrl = 'http://localhost:5173'; // 本地开发

  // 网络超时
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // 存储 Key
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_info';
}
