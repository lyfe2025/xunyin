import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

/// Web 平台 HTTP 适配器配置
void configureHttpAdapter(Dio dio) {
  // Web 平台使用浏览器适配器，支持跨域请求
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: false);
}
