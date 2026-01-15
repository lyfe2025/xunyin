import 'dart:io';
import 'dart:convert';

/// 简单的 HTTP 测试（不使用 Dio）
class SimpleHttpTest {
  static Future<String> testConnection(String url) async {
    try {
      final uri = Uri.parse(url);
      final client = HttpClient();
      
      // 临时禁用证书验证
      client.badCertificateCallback = (cert, host, port) => true;
      
      final request = await client.getUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'Xunyin-App/1.0.0 (iOS)');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      client.close();
      
      return '状态码: ${response.statusCode}\n'
          '响应: $responseBody';
    } catch (e) {
      return '错误: $e';
    }
  }

  static Future<String> testPostLogin(String phone, String code) async {
    try {
      final uri = Uri.parse('https://xunyin.pynb.org/api/app/auth/login/phone');
      final client = HttpClient();
      
      // 临时禁用证书验证
      client.badCertificateCallback = (cert, host, port) => true;
      
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'Xunyin-App/1.0.0 (iOS)');
      
      final body = jsonEncode({'phone': phone, 'code': code});
      request.write(body);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      client.close();
      
      return '状态码: ${response.statusCode}\n'
          '响应: $responseBody';
    } catch (e) {
      return '错误: $e\n'
          '错误类型: ${e.runtimeType}';
    }
  }
}
