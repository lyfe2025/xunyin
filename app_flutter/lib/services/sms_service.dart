import '../core/api/api_client.dart';

class SmsService {
  final ApiClient _api;

  SmsService(this._api);

  /// 发送验证码
  Future<String> sendCode(String phone) async {
    final response = await _api.post('/sms/send', data: {'phone': phone});
    return response['message'] as String? ?? '验证码已发送';
  }

  /// 绑定手机号
  Future<void> bindPhone(String phone, String code) async {
    await _api.post('/sms/bind', data: {'phone': phone, 'code': code});
  }
}
