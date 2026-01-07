/// 印记类型
enum SealType {
  route,
  city,
  special;

  static SealType fromString(String value) {
    switch (value) {
      case 'route':
        return SealType.route;
      case 'city':
        return SealType.city;
      case 'special':
        return SealType.special;
      default:
        return SealType.route;
    }
  }

  String get label {
    switch (this) {
      case SealType.route:
        return '路线印记';
      case SealType.city:
        return '城市印记';
      case SealType.special:
        return '特殊印记';
    }
  }
}

/// 用户印记
class UserSeal {
  final String id;
  final String sealId;
  final SealType type;
  final String name;
  final String imageAsset;
  final String? description;
  final String? badgeTitle;
  final DateTime earnedTime;
  final int? timeSpentMinutes;
  final int pointsEarned;
  final bool isChained;
  final String? txHash;

  UserSeal({
    required this.id,
    required this.sealId,
    required this.type,
    required this.name,
    required this.imageAsset,
    this.description,
    this.badgeTitle,
    required this.earnedTime,
    this.timeSpentMinutes,
    required this.pointsEarned,
    this.isChained = false,
    this.txHash,
  });

  factory UserSeal.fromJson(Map<String, dynamic> json) {
    final imageAsset = json['imageAsset'] as String? ?? '';
    return UserSeal(
      id: json['id'] as String,
      sealId: json['sealId'] as String,
      type: SealType.fromString(json['type'] as String),
      name: json['name'] as String,
      imageAsset: imageAsset.isNotEmpty
          ? imageAsset
          : 'assets/images/seal_placeholder.png',
      description: json['description'] as String?,
      badgeTitle: json['badgeTitle'] as String?,
      earnedTime: DateTime.parse(json['earnedTime'] as String),
      timeSpentMinutes: json['timeSpentMinutes'] as int?,
      pointsEarned: json['pointsEarned'] as int,
      isChained: json['isChained'] as bool? ?? false,
      txHash: json['txHash'] as String?,
    );
  }
}

/// 印记详情
class SealDetail {
  final String id;
  final SealType type;
  final String name;
  final String imageAsset;
  final String? description;
  final String? unlockCondition;
  final String? badgeTitle;
  final String? journeyId;
  final String? journeyName;
  final String? cityId;
  final String? cityName;
  final bool owned;
  final DateTime? earnedTime;
  final int? timeSpentMinutes;
  final int? pointsEarned;
  final bool? isChained;
  final String? txHash;
  final DateTime? chainTime;

  SealDetail({
    required this.id,
    required this.type,
    required this.name,
    required this.imageAsset,
    this.description,
    this.unlockCondition,
    this.badgeTitle,
    this.journeyId,
    this.journeyName,
    this.cityId,
    this.cityName,
    required this.owned,
    this.earnedTime,
    this.timeSpentMinutes,
    this.pointsEarned,
    this.isChained,
    this.txHash,
    this.chainTime,
  });

  factory SealDetail.fromJson(Map<String, dynamic> json) {
    final imageAsset = json['imageAsset'] as String? ?? '';
    return SealDetail(
      id: json['id'] as String,
      type: SealType.fromString(json['type'] as String),
      name: json['name'] as String,
      imageAsset: imageAsset.isNotEmpty
          ? imageAsset
          : 'assets/images/seal_placeholder.png',
      description: json['description'] as String?,
      unlockCondition: json['unlockCondition'] as String?,
      badgeTitle: json['badgeTitle'] as String?,
      journeyId: json['journeyId'] as String?,
      journeyName: json['journeyName'] as String?,
      cityId: json['cityId'] as String?,
      cityName: json['cityName'] as String?,
      owned: json['owned'] as bool,
      earnedTime: json['earnedTime'] != null
          ? DateTime.parse(json['earnedTime'] as String)
          : null,
      timeSpentMinutes: json['timeSpentMinutes'] as int?,
      pointsEarned: json['pointsEarned'] as int?,
      isChained: json['isChained'] as bool?,
      txHash: json['txHash'] as String?,
      chainTime: json['chainTime'] != null
          ? DateTime.parse(json['chainTime'] as String)
          : null,
    );
  }
}

/// 印记收集进度
class SealProgress {
  final int total;
  final int collected;
  final double percentage;
  final List<SealTypeProgress> byType;

  SealProgress({
    required this.total,
    required this.collected,
    required this.percentage,
    required this.byType,
  });

  factory SealProgress.fromJson(Map<String, dynamic> json) {
    return SealProgress(
      total: json['total'] as int,
      collected: json['collected'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      byType: (json['byType'] as List)
          .map((e) => SealTypeProgress.fromJson(e))
          .toList(),
    );
  }
}

/// 按类型的印记进度
class SealTypeProgress {
  final SealType type;
  final int total;
  final int collected;

  SealTypeProgress({
    required this.type,
    required this.total,
    required this.collected,
  });

  factory SealTypeProgress.fromJson(Map<String, dynamic> json) {
    return SealTypeProgress(
      type: SealType.fromString(json['type'] as String),
      total: json['total'] as int,
      collected: json['collected'] as int,
    );
  }

  double get percentage => total > 0 ? collected / total : 0;
}
