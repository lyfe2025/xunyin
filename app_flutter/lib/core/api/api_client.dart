import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/app_config.dart';
import '../storage/token_storage.dart';

// 条件导入：Web 使用浏览器适配器，其他平台使用 IO 适配器
import 'api_client_stub.dart'
    if (dart.library.io) 'api_client_io.dart'
    if (dart.library.html) 'api_client_web.dart' as adapter;

/// 业务异常
class ApiException implements Exception {
  final int code;
  final String message;

  ApiException(this.code, this.message);

  @override
  String toString() => message;

  /// 是否需要登录
  bool get needLogin => code == 20001 || code == 40101 || code == 40102;
}

/// API 客户端
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30), // 增加超时时间
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Language': 'zh-CN,zh;q=0.9',
          'User-Agent': 'Xunyin-iOS/1.0.0',
        },
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // 配置 HTTP 适配器 - Web 和原生平台使用不同适配器
    if (!kIsWeb) {
      adapter.configureHttpAdapter(_dio);
    }

    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: true,
        logPrint: (obj) {
          // 使用 print 确保日志输出
          print('[DIO] $obj');
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// 检查业务响应码
  void _checkResponse(Map<String, dynamic> data) {
    final code = data['code'] as int?;
    if (code != null && code != 200) {
      final msg = data['msg'] as String? ?? '请求失败';
      throw ApiException(code, msg);
    }
  }

  Future<Map<String, dynamic>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
    );
    final data = response.data!;
    _checkResponse(data);
    return data;
  }

  Future<Map<String, dynamic>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    final respData = response.data!;
    _checkResponse(respData);
    return respData;
  }

  Future<Map<String, dynamic>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    final respData = response.data!;
    _checkResponse(respData);
    return respData;
  }

  Future<Map<String, dynamic>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
    );
    final respData = response.data!;
    _checkResponse(respData);
    return respData;
  }

  Future<Map<String, dynamic>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    final respData = response.data!;
    _checkResponse(respData);
    return respData;
  }
}

/// 错误处理拦截器
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('[ERROR] DioException Type: ${err.type}');
    print('[ERROR] Message: ${err.message}');
    print('[ERROR] URL: ${err.requestOptions.uri}');
    print('[ERROR] Error: ${err.error}');
    
    // 增强错误信息，帮助调试
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout) {
      final message = '网络连接失败，请检查网络设置\n'
          '错误类型: ${err.type}\n'
          '错误详情: ${err.message}\n'
          'URL: ${err.requestOptions.uri}\n'
          '原始错误: ${err.error}';
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: message,
          type: err.type,
        ),
      );
      return;
    }
    handler.next(err);
  }
}

/// 认证拦截器
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token 过期，尝试刷新
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // 重试请求
        final response = await ApiClient().dio.fetch(err.requestOptions);
        return handler.resolve(response);
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await Dio().post(
        '${AppConfig.apiBaseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data['data'];
      await TokenStorage.saveTokens(data['accessToken'], data['refreshToken']);
      return true;
    } catch (e) {
      await TokenStorage.clearTokens();
      return false;
    }
  }
}
