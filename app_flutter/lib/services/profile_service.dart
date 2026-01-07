import '../core/api/api_client.dart';

/// 用户资料服务
class ProfileService {
  final ApiClient _api;

  ProfileService(this._api);

  /// 获取当前用户资料
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _api.get('/profile');
    return response['data'] as Map<String, dynamic>;
  }

  /// 更新用户资料
  Future<Map<String, dynamic>> updateProfile({
    String? nickname,
    String? avatar,
    String? bio,
    String? gender,
  }) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (avatar != null) data['avatar'] = avatar;
    if (bio != null) data['bio'] = bio;
    if (gender != null) data['gender'] = gender;

    final response = await _api.patch('/profile', data: data);
    return response['data'] as Map<String, dynamic>;
  }

  /// 更新昵称
  Future<void> updateNickname(String nickname) async {
    await _api.patch('/profile/nickname', data: {'nickname': nickname});
  }

  /// 更新头像
  Future<void> updateAvatar(String avatarUrl) async {
    await _api.patch('/profile/avatar', data: {'avatar': avatarUrl});
  }
}
