/// 文化之旅简要信息
class JourneyBrief {
  final String id;
  final String name;
  final String theme;
  final String? coverImage;
  final int rating;
  final int estimatedMinutes;
  final double totalDistance;
  final int completedCount;
  final bool isLocked;
  final String? unlockCondition;

  JourneyBrief({
    required this.id,
    required this.name,
    required this.theme,
    this.coverImage,
    required this.rating,
    required this.estimatedMinutes,
    required this.totalDistance,
    this.completedCount = 0,
    this.isLocked = false,
    this.unlockCondition,
  });

  factory JourneyBrief.fromJson(Map<String, dynamic> json) {
    final coverImage = json['coverImage'] as String?;
    return JourneyBrief(
      id: json['id'] as String,
      name: json['name'] as String,
      theme: json['theme'] as String,
      coverImage: coverImage?.isNotEmpty == true ? coverImage : null,
      rating: json['rating'] as int,
      estimatedMinutes: json['estimatedMinutes'] as int,
      totalDistance: (json['totalDistance'] as num).toDouble(),
      completedCount: json['completedCount'] as int? ?? 0,
      isLocked: json['isLocked'] as bool? ?? false,
      unlockCondition: json['unlockCondition'] as String?,
    );
  }
}

/// 文化之旅详情
class JourneyDetail {
  final String id;
  final String cityId;
  final String name;
  final String theme;
  final String? coverImage;
  final String? description;
  final int rating;
  final int estimatedMinutes;
  final double totalDistance;
  final int completedCount;
  final bool isLocked;
  final String? unlockCondition;
  final String? bgmUrl;
  final int pointCount;
  final List<ExplorationPoint>? points;

  JourneyDetail({
    required this.id,
    required this.cityId,
    required this.name,
    required this.theme,
    this.coverImage,
    this.description,
    required this.rating,
    required this.estimatedMinutes,
    required this.totalDistance,
    this.completedCount = 0,
    this.isLocked = false,
    this.unlockCondition,
    this.bgmUrl,
    required this.pointCount,
    this.points,
  });

  factory JourneyDetail.fromJson(Map<String, dynamic> json) {
    final coverImage = json['coverImage'] as String?;
    final bgmUrl = json['bgmUrl'] as String?;
    return JourneyDetail(
      id: json['id'] as String,
      cityId: json['cityId'] as String,
      name: json['name'] as String,
      theme: json['theme'] as String,
      coverImage: coverImage?.isNotEmpty == true ? coverImage : null,
      description: json['description'] as String?,
      rating: json['rating'] as int,
      estimatedMinutes: json['estimatedMinutes'] as int,
      totalDistance: (json['totalDistance'] as num).toDouble(),
      completedCount: json['completedCount'] as int? ?? 0,
      isLocked: json['isLocked'] as bool? ?? false,
      unlockCondition: json['unlockCondition'] as String?,
      bgmUrl: bgmUrl?.isNotEmpty == true ? bgmUrl : null,
      pointCount: json['pointCount'] as int,
      points: json['points'] != null
          ? (json['points'] as List)
                .map((e) => ExplorationPoint.fromJson(e))
                .toList()
          : null,
    );
  }
}

/// 探索点
class ExplorationPoint {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String taskType; // gesture, photo, treasure
  final String taskDescription;
  final String? targetGesture;
  final String? arAssetUrl;
  final String? culturalBackground;
  final String? culturalKnowledge;
  final double? distanceFromPrev;
  final int pointsReward;
  final int orderNum;

  ExplorationPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.taskType,
    required this.taskDescription,
    this.targetGesture,
    this.arAssetUrl,
    this.culturalBackground,
    this.culturalKnowledge,
    this.distanceFromPrev,
    required this.pointsReward,
    required this.orderNum,
  });

  factory ExplorationPoint.fromJson(Map<String, dynamic> json) {
    return ExplorationPoint(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      taskType: json['taskType'] as String,
      taskDescription: json['taskDescription'] as String,
      targetGesture: json['targetGesture'] as String?,
      arAssetUrl: json['arAssetUrl'] as String?,
      culturalBackground: json['culturalBackground'] as String?,
      culturalKnowledge: json['culturalKnowledge'] as String?,
      distanceFromPrev: (json['distanceFromPrev'] as num?)?.toDouble(),
      pointsReward: json['pointsReward'] as int,
      orderNum: json['orderNum'] as int,
    );
  }
}

/// 开始文化之旅响应
class StartJourneyResponse {
  final String progressId;
  final String journeyId;
  final DateTime startTime;

  StartJourneyResponse({
    required this.progressId,
    required this.journeyId,
    required this.startTime,
  });

  factory StartJourneyResponse.fromJson(Map<String, dynamic> json) {
    return StartJourneyResponse(
      progressId: json['progressId'] as String,
      journeyId: json['journeyId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
    );
  }
}

/// 文化之旅进度
class JourneyProgress {
  final String id;
  final String journeyId;
  final String journeyName;
  final String status; // in_progress, completed, abandoned
  final DateTime startTime;
  final DateTime? completeTime;
  final int? timeSpentMinutes;
  final int completedPoints;
  final int totalPoints;

  JourneyProgress({
    required this.id,
    required this.journeyId,
    required this.journeyName,
    required this.status,
    required this.startTime,
    this.completeTime,
    this.timeSpentMinutes,
    required this.completedPoints,
    required this.totalPoints,
  });

  factory JourneyProgress.fromJson(Map<String, dynamic> json) {
    return JourneyProgress(
      id: json['id'] as String,
      journeyId: json['journeyId'] as String,
      journeyName: json['journeyName'] as String,
      status: json['status'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      completeTime: json['completeTime'] != null
          ? DateTime.parse(json['completeTime'] as String)
          : null,
      timeSpentMinutes: json['timeSpentMinutes'] as int?,
      completedPoints: json['completedPoints'] as int,
      totalPoints: json['totalPoints'] as int,
    );
  }

  double get progressPercent =>
      totalPoints > 0 ? completedPoints / totalPoints : 0;
  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
}
