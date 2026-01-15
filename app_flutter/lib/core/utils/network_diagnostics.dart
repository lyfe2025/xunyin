import 'dart:io';
import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// 网络诊断工具
class NetworkDiagnostics {
  /// 测试网络连接
  static Future<Map<String, dynamic>> testConnection() async {
    final results = <String, dynamic>{};

    // 1. 测试 DNS 解析
    try {
      final host = Uri.parse(AppConfig.apiBaseUrl).host;
      final addresses = await InternetAddress.lookup(host);
      results['dns'] = {
        'success': true,
        'host': host,
        'addresses': addresses.map((e) => e.address).toList(),
      };
    } catch (e) {
      results['dns'] = {'success': false, 'error': e.toString()};
    }

    // 2. 测试 HTTP 连接
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      
      final response = await dio.get('${AppConfig.apiBaseUrl}/cities');
      results['http'] = {
        'success': true,
        'statusCode': response.statusCode,
        'headers': response.headers.map,
      };
    } catch (e) {
      results['http'] = {
        'success': false,
        'error': e.toString(),
        'type': e.runtimeType.toString(),
      };
      
      if (e is DioException) {
        results['http']['dioError'] = {
          'type': e.type.toString(),
          'message': e.message,
          'response': e.response?.toString(),
        };
      }
    }

    // 3. 测试 Socket 连接
    try {
      final uri = Uri.parse(AppConfig.apiBaseUrl);
      final port = uri.port != 0 ? uri.port : (uri.scheme == 'https' ? 443 : 80);
      final socket = await Socket.connect(uri.host, port, timeout: const Duration(seconds: 10));
      socket.destroy();
      results['socket'] = {
        'success': true,
        'host': uri.host,
        'port': port,
      };
    } catch (e) {
      results['socket'] = {'success': false, 'error': e.toString()};
    }

    return results;
  }

  /// 格式化诊断结果
  static String formatResults(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    buffer.writeln('=== 网络诊断结果 ===\n');

    // DNS
    buffer.writeln('1. DNS 解析:');
    final dns = results['dns'] as Map<String, dynamic>;
    if (dns['success'] == true) {
      buffer.writeln('   ✓ 成功');
      buffer.writeln('   主机: ${dns['host']}');
      buffer.writeln('   IP: ${(dns['addresses'] as List).join(', ')}');
    } else {
      buffer.writeln('   ✗ 失败');
      buffer.writeln('   错误: ${dns['error']}');
    }

    // HTTP
    buffer.writeln('\n2. HTTP 连接:');
    final http = results['http'] as Map<String, dynamic>;
    if (http['success'] == true) {
      buffer.writeln('   ✓ 成功');
      buffer.writeln('   状态码: ${http['statusCode']}');
    } else {
      buffer.writeln('   ✗ 失败');
      buffer.writeln('   错误类型: ${http['type']}');
      buffer.writeln('   错误信息: ${http['error']}');
      if (http['dioError'] != null) {
        final dioError = http['dioError'] as Map<String, dynamic>;
        buffer.writeln('   Dio 错误类型: ${dioError['type']}');
        buffer.writeln('   Dio 错误信息: ${dioError['message']}');
      }
    }

    // Socket
    buffer.writeln('\n3. Socket 连接:');
    final socket = results['socket'] as Map<String, dynamic>;
    if (socket['success'] == true) {
      buffer.writeln('   ✓ 成功');
      buffer.writeln('   主机: ${socket['host']}');
      buffer.writeln('   端口: ${socket['port']}');
    } else {
      buffer.writeln('   ✗ 失败');
      buffer.writeln('   错误: ${socket['error']}');
    }

    return buffer.toString();
  }
}
