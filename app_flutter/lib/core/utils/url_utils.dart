import '../config/app_config.dart';

/// URL 工具类
class UrlUtils {
  /// 获取服务器基础 URL（不含 /api/app 路径）
  /// 从 AppConfig.baseUrl 中提取
  static String get serverBaseUrl {
    final baseUrl = AppConfig.baseUrl;
    // 移除 /api/app 后缀
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
  }

  /// 将相对路径转换为完整的图片 URL
  ///
  /// 如果 [url] 已经是完整 URL（以 http:// 或 https:// 开头），则直接返回
  /// 如果是相对路径（如 /uploads/images/xxx.png），则拼接服务器地址
  /// 如果 [url] 为空，返回空字符串（由 UI 层处理占位图）
  static String getFullImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return '';
    }

    // 已经是完整 URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // 相对路径，拼接服务器地址
    if (url.startsWith('/')) {
      return '$serverBaseUrl$url';
    }

    // 没有斜杠开头，补上
    return '$serverBaseUrl/$url';
  }
}
