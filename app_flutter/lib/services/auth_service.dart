import '../core/api/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  /// 发送验证码
  Future<Map<String, dynamic>> sendSmsCode(String phone) async {
    final response = await _api.post('/auth/sms/send', data: {'phone': phone});
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// 手机号验证码登录
  Future<LoginResponse> loginWithPhone({
    required String phone,
    required String code,
  }) async {
    final response = await _api.post(
      '/auth/login/phone',
      data: {'phone': phone, 'code': code},
    );
    final loginResponse = LoginResponse.fromJson(response['data']);

    // 保存 token
    await TokenStorage.saveTokens(
      loginResponse.token,
      loginResponse.refreshToken,
    );

    return loginResponse;
  }

  /// 微信登录
  Future<LoginResponse> loginWithWechat(String code) async {
    final response = await _api.post(
      '/auth/login/wechat',
      data: {'code': code},
    );
    final loginResponse = LoginResponse.fromJson(response['data']);

    await TokenStorage.saveTokens(
      loginResponse.token,
      loginResponse.refreshToken,
    );

    return loginResponse;
  }

  /// 刷新 token
  Future<String> refreshToken() async {
    final oldRefreshToken = await TokenStorage.getRefreshToken();
    if (oldRefreshToken == null) throw Exception('No refresh token');

    final response = await _api.post(
      '/auth/refresh',
      data: {'refreshToken': oldRefreshToken},
    );
    final newToken = response['data']['token'] as String;

    await TokenStorage.saveTokens(newToken, oldRefreshToken);
    return newToken;
  }

  /// 登出
  Future<void> logout() async {
    await TokenStorage.clearTokens();
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    return await TokenStorage.hasToken();
  }
}
