import 'package:dio/dio.dart';

/// Stub 实现，不应该被调用
void configureHttpAdapter(Dio dio) {
  throw UnsupportedError('Cannot configure HTTP adapter without dart:io or dart:html');
}
