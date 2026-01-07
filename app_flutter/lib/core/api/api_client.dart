import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';

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
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
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
        '${AppConfig.baseUrl}/auth/refresh',
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
