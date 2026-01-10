/// 用户称号
class UserBadge {
  final String badgeTitle;
  final String sealId;
  final String sealName;
  final String rarity;
  final DateTime earnedTime;
  final bool isActive;

  UserBadge({
    required this.badgeTitle,
    required this.sealId,
    required this.sealName,
    required this.rarity,
    required this.earnedTime,
    required this.isActive,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      badgeTitle: json['badgeTitle'] as String,
      sealId: json['sealId'] as String,
      sealName: json['sealName'] as String,
      rarity: json['rarity'] as String,
      earnedTime: DateTime.parse(json['earnedTime'] as String),
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  /// 稀有度显示名称
  String get rarityLabel {
    switch (rarity) {
      case 'legendary':
        return '传说';
      case 'rare':
        return '稀有';
      default:
        return '普通';
    }
  }
}
