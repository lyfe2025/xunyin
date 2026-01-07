import '../core/api/api_client.dart';
import '../models/user.dart';

class UserService {
  final ApiClient _api;

  UserService(this._api);

  /// 获取当前用户信息
  Future<AppUser> getCurrentUser() async {
    final response = await _api.get('/users/me');
    return AppUser.fromJson(response['data']);
  }

  /// 更新用户资料
  Future<AppUser> updateProfile({String? nickname, String? avatarUrl}) async {
    final response = await _api.put(
      '/users/me',
      data: {
        if (nickname != null) 'nickname': nickname,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
    );
    return AppUser.fromJson(response['data']);
  }

  /// 获取用户统计
  Future<UserStats> getUserStats() async {
    final response = await _api.get('/users/stats');
    return UserStats.fromJson(response['data']);
  }
}
