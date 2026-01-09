import '../core/api/api_client.dart';
import '../models/user.dart';
import '../models/profile_home.dart';

class UserService {
  final ApiClient _api;

  UserService(this._api);

  /// 获取个人中心首页聚合数据（推荐使用，减少请求次数）
  Future<ProfileHomeData> getProfileHomeData() async {
    final response = await _api.get('/stats/home');
    return ProfileHomeData.fromJson(response['data']);
  }

  /// 获取当前用户信息
  Future<AppUser> getCurrentUser() async {
    final response = await _api.get('/profile');
    return AppUser.fromJson(response['data']);
  }

  /// 更新用户资料
  Future<AppUser> updateProfile({String? nickname, String? avatarUrl}) async {
    final response = await _api.patch(
      '/profile',
      data: {
        if (nickname != null) 'nickname': nickname,
        if (avatarUrl != null) 'avatar': avatarUrl,
      },
    );
    return AppUser.fromJson(response['data']);
  }

  /// 获取用户统计概览
  Future<UserStats> getUserStats() async {
    final response = await _api.get('/stats/overview');
    return UserStats.fromJson(response['data']);
  }

  /// 获取用户最近动态
  Future<List<UserActivity>> getUserActivities({int limit = 20}) async {
    final response = await _api.get(
      '/stats/activities',
      queryParameters: {'limit': limit},
    );
    final list = response['data'] as List;
    return list
        .map((e) => UserActivity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 获取旅行统计详情
  Future<TravelStats> getTravelStats() async {
    final response = await _api.get('/stats/travel');
    return TravelStats.fromJson(response['data']);
  }

  /// 注销账户
  Future<void> deleteAccount() async {
    await _api.delete('/profile');
  }
}

/// 旅行统计
class TravelStats {
  final List<CityTravelStat> byCity;
  final List<MonthlyTravelStat> byMonth;

  TravelStats({required this.byCity, required this.byMonth});

  factory TravelStats.fromJson(Map<String, dynamic> json) {
    return TravelStats(
      byCity: (json['byCity'] as List? ?? [])
          .map((e) => CityTravelStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      byMonth: (json['byMonth'] as List? ?? [])
          .map((e) => MonthlyTravelStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 城市旅行统计
class CityTravelStat {
  final String cityId;
  final String cityName;
  final int journeyCount;
  final int totalTime;

  CityTravelStat({
    required this.cityId,
    required this.cityName,
    required this.journeyCount,
    required this.totalTime,
  });

  factory CityTravelStat.fromJson(Map<String, dynamic> json) {
    return CityTravelStat(
      cityId: json['cityId'] as String,
      cityName: json['cityName'] as String,
      journeyCount: json['journeyCount'] as int? ?? 0,
      totalTime: json['totalTime'] as int? ?? 0,
    );
  }
}

/// 月度旅行统计
class MonthlyTravelStat {
  final String month;
  final int count;

  MonthlyTravelStat({required this.month, required this.count});

  factory MonthlyTravelStat.fromJson(Map<String, dynamic> json) {
    return MonthlyTravelStat(
      month: json['month'] as String,
      count: json['count'] as int? ?? 0,
    );
  }
}
