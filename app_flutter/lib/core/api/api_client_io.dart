import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// 原生平台（iOS/Android）HTTP 适配器配置
void configureHttpAdapter(Dio dio) {
  final httpAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      // 临时禁用证书验证（仅用于调试）
      client.badCertificateCallback = (cert, host, port) => true;
      // 增加超时时间
      client.connectionTimeout = const Duration(seconds: 30);
      client.idleTimeout = const Duration(seconds: 30);
      // 启用自动解压
      client.autoUncompress = true;
      return client;
    },
  );

  // 临时禁用证书验证
  httpAdapter.validateCertificate = (cert, host, port) => true;
  dio.httpClientAdapter = httpAdapter;
}
