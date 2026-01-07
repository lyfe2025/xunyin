import '../core/api/api_client.dart';

class AudioInfo {
  final String url;
  final String? title;
  final String? artist;

  AudioInfo({required this.url, this.title, this.artist});

  factory AudioInfo.fromJson(Map<String, dynamic> json) {
    return AudioInfo(
      url: json['url'] as String,
      title: json['title'] as String?,
      artist: json['artist'] as String?,
    );
  }
}

class AudioApiService {
  final ApiClient _api;

  AudioApiService(this._api);

  /// 获取城市背景音乐
  Future<AudioInfo?> getCityBgm(String cityId) async {
    try {
      final response = await _api.get('/audio/city/$cityId');
      return AudioInfo.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }

  /// 获取文化之旅背景音乐
  Future<AudioInfo?> getJourneyBgm(String journeyId) async {
    try {
      final response = await _api.get('/audio/journey/$journeyId');
      return AudioInfo.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }

  /// 获取首页默认背景音乐
  Future<AudioInfo?> getHomeBgm() async {
    try {
      final response = await _api.get('/audio/home');
      return AudioInfo.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }

  /// 获取探索点背景音乐
  Future<AudioInfo?> getExplorationPointBgm(String pointId) async {
    try {
      final response = await _api.get('/audio/exploration-point/$pointId');
      return AudioInfo.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }
}
