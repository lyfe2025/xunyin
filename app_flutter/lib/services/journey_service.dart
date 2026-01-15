import '../core/api/api_client.dart';
import '../models/journey.dart';

/// 完成探索点响应
class CompletePointResponse {
  final int pointsEarned;
  final int totalPoints;
  final bool journeyCompleted;
  final String? sealId;
  final String? userSealId;

  CompletePointResponse({
    required this.pointsEarned,
    required this.totalPoints,
    required this.journeyCompleted,
    this.sealId,
    this.userSealId,
  });

  factory CompletePointResponse.fromJson(Map<String, dynamic> json) {
    return CompletePointResponse(
      pointsEarned: json['pointsEarned'] as int,
      totalPoints: json['totalPoints'] as int,
      journeyCompleted: json['journeyCompleted'] as bool,
      sealId: json['sealId'] as String?,
      userSealId: json['userSealId'] as String?,
    );
  }
}

class JourneyService {
  final ApiClient _api;

  JourneyService(this._api);

  /// 获取文化之旅详情
  Future<JourneyDetail> getJourneyDetail(String journeyId) async {
    final response = await _api.get('/journeys/$journeyId');
    return JourneyDetail.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 获取文化之旅的探索点列表
  Future<List<ExplorationPoint>> getJourneyPoints(String journeyId) async {
    final response = await _api.get('/journeys/$journeyId/points');
    final list = response['data'] as List;
    return list
        .map((e) => ExplorationPoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 开始文化之旅
  Future<StartJourneyResponse> startJourney(String journeyId) async {
    final response = await _api.post('/journeys/$journeyId/start');
    return StartJourneyResponse.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// 获取进行中的文化之旅
  Future<List<JourneyProgress>> getInProgressJourneys() async {
    final response = await _api.get('/journeys/progress');
    final list = response['data'] as List;
    return list
        .map((e) => JourneyProgress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 获取用户所有文化之旅（包括已完成）
  Future<List<JourneyProgress>> getAllUserJourneys() async {
    final response = await _api.get('/journeys/my');
    final list = response['data'] as List;
    return list
        .map((e) => JourneyProgress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 完成探索点（调用正确的后端 API 路径）
  Future<CompletePointResponse> completePoint({
    required String pointId,
    String? photoUrl,
  }) async {
    final response = await _api.post(
      '/points/$pointId/complete',
      data: {if (photoUrl != null) 'photoUrl': photoUrl},
    );
    return CompletePointResponse.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// 放弃文化之旅
  Future<void> abandonJourney(String journeyId) async {
    await _api.put('/journeys/$journeyId/abandon');
  }
}
