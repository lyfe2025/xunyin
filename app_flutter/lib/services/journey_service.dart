import '../core/api/api_client.dart';
import '../models/journey.dart';

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

  /// 完成探索点
  Future<void> completePoint({
    required String journeyId,
    required String pointId,
    String? photoUrl,
  }) async {
    await _api.post(
      '/journeys/$journeyId/points/$pointId/complete',
      data: {if (photoUrl != null) 'photoUrl': photoUrl},
    );
  }

  /// 放弃文化之旅
  Future<void> abandonJourney(String journeyId) async {
    await _api.post('/journeys/$journeyId/abandon');
  }
}
