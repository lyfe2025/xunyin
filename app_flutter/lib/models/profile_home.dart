import 'user.dart';
import 'journey.dart';

/// 个人中心首页聚合数据
class ProfileHomeData {
  final AppUser? user;
  final UserStats stats;
  final List<JourneyProgress> inProgressJourneys;
  final List<UserActivity> recentActivities;

  ProfileHomeData({
    this.user,
    required this.stats,
    required this.inProgressJourneys,
    required this.recentActivities,
  });

  factory ProfileHomeData.fromJson(Map<String, dynamic> json) {
    return ProfileHomeData(
      user: json['user'] != null
          ? AppUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      stats: json['stats'] != null
          ? UserStats.fromJson(json['stats'] as Map<String, dynamic>)
          : UserStats(),
      inProgressJourneys: (json['inProgressJourneys'] as List? ?? [])
          .map((e) => JourneyProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentActivities: (json['recentActivities'] as List? ?? [])
          .map((e) => UserActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
