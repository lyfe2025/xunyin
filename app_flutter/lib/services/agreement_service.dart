import '../core/api/api_client.dart';

/// 协议内容模型
class Agreement {
  final String type;
  final String title;
  final String content;
  final String version;
  final DateTime? updateTime;

  Agreement({
    required this.type,
    required this.title,
    required this.content,
    required this.version,
    this.updateTime,
  });

  factory Agreement.fromJson(Map<String, dynamic> json) {
    return Agreement(
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      version: json['version'] as String? ?? '1.0',
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'] as String)
          : null,
    );
  }
}

/// 协议服务
class AgreementService {
  final ApiClient _api = ApiClient();

  /// 获取用户协议
  Future<Agreement> getUserAgreement() => _getAgreement('user_agreement');

  /// 获取隐私政策
  Future<Agreement> getPrivacyPolicy() => _getAgreement('privacy_policy');

  /// 获取关于我们
  Future<Agreement> getAboutUs() => _getAgreement('about_us');

  Future<Agreement> _getAgreement(String type) async {
    final response = await _api.get('/agreements/$type');
    return Agreement.fromJson(response['data'] as Map<String, dynamic>);
  }
}
