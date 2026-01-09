/// 用户信息
class AppUser {
  final String id;
  final String? phone;
  final String? nickname;
  final String? avatarUrl;
  final String? badgeTitle;
  final int totalPoints;
  final int level;
  final DateTime createdAt;

  AppUser({
    required this.id,
    this.phone,
    this.nickname,
    this.avatarUrl,
    this.badgeTitle,
    this.totalPoints = 0,
    this.level = 1,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final avatarUrl = json['avatar'] as String?;
    final createTime = json['createTime'] ?? json['createdAt'];
    return AppUser(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      nickname: json['nickname'] as String?,
      avatarUrl: avatarUrl?.isNotEmpty == true ? avatarUrl : null,
      badgeTitle: json['badgeTitle'] as String?,
      totalPoints: json['totalPoints'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      createdAt: createTime != null
          ? DateTime.parse(createTime as String)
          : DateTime.now(),
    );
  }

  String get displayName => nickname ?? phone ?? '旅行者';
}

/// 用户统计
class UserStats {
  final int completedJourneys;
  final int inProgressJourneys;
  final int completedPoints;
  final int collectedSeals;
  final int chainedSeals;
  final int unlockedCities;
  final int totalCities;
  final int totalPoints;
  final int totalPhotos;
  final int totalDistance;
  final int totalTimeSpentMinutes;

  UserStats({
    this.completedJourneys = 0,
    this.inProgressJourneys = 0,
    this.completedPoints = 0,
    this.collectedSeals = 0,
    this.chainedSeals = 0,
    this.unlockedCities = 0,
    this.totalCities = 0,
    this.totalPoints = 0,
    this.totalPhotos = 0,
    this.totalDistance = 0,
    this.totalTimeSpentMinutes = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      completedJourneys: json['completedJourneys'] as int? ?? 0,
      inProgressJourneys: json['inProgressJourneys'] as int? ?? 0,
      completedPoints: json['completedPoints'] as int? ?? 0,
      collectedSeals:
          json['collectedSeals'] as int? ?? json['totalSeals'] as int? ?? 0,
      chainedSeals: json['chainedSeals'] as int? ?? 0,
      unlockedCities: json['unlockedCities'] as int? ?? 0,
      totalCities: json['totalCities'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      totalPhotos: json['totalPhotos'] as int? ?? 0,
      totalDistance: json['totalDistance'] as int? ?? 0,
      totalTimeSpentMinutes: json['totalTimeSpentMinutes'] as int? ?? 0,
    );
  }

  /// 格式化距离显示
  String get formattedDistance {
    if (totalDistance >= 1000) {
      return '${(totalDistance / 1000).toStringAsFixed(1)}km';
    }
    return '${totalDistance}m';
  }

  /// 格式化时间显示
  String get formattedTime {
    if (totalTimeSpentMinutes >= 60) {
      final hours = totalTimeSpentMinutes ~/ 60;
      final minutes = totalTimeSpentMinutes % 60;
      return minutes > 0 ? '${hours}h${minutes}m' : '${hours}h';
    }
    return '${totalTimeSpentMinutes}m';
  }
}

/// 用户动态
class UserActivity {
  final String id;
  final String type;
  final String title;
  final String? relatedId;
  final DateTime createTime;

  UserActivity({
    required this.id,
    required this.type,
    required this.title,
    this.relatedId,
    required this.createTime,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      relatedId: json['relatedId'] as String?,
      createTime: DateTime.parse(json['createTime'] as String),
    );
  }

  /// 获取动态图标
  String get iconName {
    switch (type) {
      case 'journey_started':
        return 'play_arrow';
      case 'journey_completed':
        return 'check_circle';
      case 'seal_earned':
        return 'workspace_premium';
      case 'seal_chained':
        return 'link';
      case 'photo_taken':
        return 'photo_camera';
      default:
        return 'event';
    }
  }
}

/// 登录响应
class LoginResponse {
  final String token;
  final String refreshToken;
  final int expiresIn;
  final AppUser? user;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int? ?? 604800,
      user: json['user'] != null
          ? AppUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
