/// 用户信息
class AppUser {
  final String id;
  final String? phone;
  final String? nickname;
  final String? avatarUrl;
  final String? badgeTitle;
  final DateTime createdAt;

  AppUser({
    required this.id,
    this.phone,
    this.nickname,
    this.avatarUrl,
    this.badgeTitle,
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
  final int completedPoints;
  final int collectedSeals;
  final int chainedSeals;
  final int unlockedCities;
  final int totalCities;
  final int totalPoints;

  UserStats({
    this.completedJourneys = 0,
    this.completedPoints = 0,
    this.collectedSeals = 0,
    this.chainedSeals = 0,
    this.unlockedCities = 0,
    this.totalCities = 0,
    this.totalPoints = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      completedJourneys: json['completedJourneys'] as int? ?? 0,
      completedPoints: json['completedPoints'] as int? ?? 0,
      collectedSeals: json['collectedSeals'] as int? ?? 0,
      chainedSeals: json['chainedSeals'] as int? ?? 0,
      unlockedCities: json['unlockedCities'] as int? ?? 0,
      totalCities: json['totalCities'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
    );
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
