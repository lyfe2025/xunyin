import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, kReleaseMode;
import '../config/app_config.dart';

/// URL 工具类
class UrlUtils {
  /// 调试日志（在 release 模式下也会输出到浏览器控制台）
  static void _log(String message) {
    // ignore: avoid_print
    print(message);
    developer.log(message, name: 'UrlUtils');
  }

  /// 获取服务器基础 URL（不含 /api/app 路径）
  static String get serverBaseUrl {
    // Web 环境：使用 Uri.base 获取当前页面的 origin
    if (kIsWeb) {
      final base = Uri.base;
      final port = base.port;
      // 标准端口不需要显示
      final portStr = (port == 80 || port == 443 || port == 0) ? '' : ':$port';
      final result = '${base.scheme}://${base.host}$portStr';
      _log('[serverBaseUrl] kIsWeb=true, Uri.base=$base, result=$result');
      return result;
    }

    // 原生 App：从 apiBaseUrl 提取域名
    final baseUrl = AppConfig.apiBaseUrl;
    final uri = Uri.parse(baseUrl);
    final result = '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
    _log('[serverBaseUrl] kIsWeb=false, apiBaseUrl=$baseUrl, result=$result');
    return result;
  }

  /// 将相对路径转换为完整的图片 URL
  ///
  /// 如果 [url] 已经是完整 URL（以 http:// 或 https:// 开头），则直接返回
  /// 如果是相对路径（如 /uploads/images/xxx.png），则拼接服务器地址
  /// 如果 [url] 为空，返回空字符串（由 UI 层处理占位图）
  static String getFullImageUrl(String? url) {
    _log('[getFullImageUrl] called with: $url, kIsWeb=$kIsWeb, kDebugMode=$kDebugMode, kReleaseMode=$kReleaseMode');

    if (url == null || url.trim().isEmpty) {
      _log('[getFullImageUrl] input is null or empty');
      return '';
    }

    // 已经是完整 HTTP/HTTPS URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      _log('[getFullImageUrl] already full URL: $url');
      return url;
    }

    // 处理 file:// 协议（移除 file:// 前缀，转换为相对路径）
    if (url.startsWith('file://')) {
      url = url.replaceFirst('file://', '');
    }

    final base = serverBaseUrl;
    String result;

    // 相对路径，拼接服务器地址
    if (url.startsWith('/')) {
      result = '$base$url';
    } else {
      // 没有斜杠开头，补上
      result = '$base/$url';
    }

    _log('[getFullImageUrl] input=$url, base=$base, result=$result');
    return result;
  }
}
