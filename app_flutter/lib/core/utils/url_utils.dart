import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/app_config.dart';

/// URL 工具类
class UrlUtils {
  /// 获取服务器基础 URL（不含 /api/app 路径）
  static String get serverBaseUrl {
    // Web 环境：使用 Uri.base 获取当前页面的 origin
    // Flutter Web 的 Image.network 需要完整 URL（不像浏览器 img 标签能自动解析相对路径）
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return origin;
    }

    // 原生 App：从 apiBaseUrl 提取域名
    final baseUrl = AppConfig.apiBaseUrl;
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

    // 已经是完整 HTTP/HTTPS URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // 处理 file:// 协议（移除 file:// 前缀，转换为相对路径）
    if (url.startsWith('file://')) {
      url = url.replaceFirst('file://', '');
    }

    final base = serverBaseUrl;

    // 相对路径，拼接服务器地址
    if (url.startsWith('/')) {
      return '$base$url';
    } else {
      // 没有斜杠开头，补上
      return '$base/$url';
    }
  }
}
