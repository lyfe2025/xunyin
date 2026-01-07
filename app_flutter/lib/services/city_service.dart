import '../core/api/api_client.dart';
import '../models/city.dart';
import '../models/journey.dart';

class CityService {
  final ApiClient _api;

  CityService(this._api);

  /// 获取所有城市
  Future<List<City>> getCities({String? province}) async {
    final params = <String, dynamic>{};
    if (province != null) params['province'] = province;

    final response = await _api.get<Map<String, dynamic>>(
      '/cities',
      queryParameters: params,
    );
    final list = response['data'] as List;
    return list.map((e) => City.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 获取城市详情
  Future<City> getCityDetail(String cityId) async {
    final response = await _api.get<Map<String, dynamic>>('/cities/$cityId');
    return City.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 获取城市的文化之旅列表
  Future<List<JourneyBrief>> getCityJourneys(String cityId) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/cities/$cityId/journeys',
    );
    final list = response['data'] as List;
    return list
        .map((e) => JourneyBrief.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 获取附近城市
  Future<List<NearbyCity>> getNearbyCities({
    required double latitude,
    required double longitude,
    double? radius,
    int? limit,
  }) async {
    final params = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
    };
    if (radius != null) params['radius'] = radius;
    if (limit != null) params['limit'] = limit;

    final response = await _api.get<Map<String, dynamic>>(
      '/cities/nearby',
      queryParameters: params,
    );
    final list = response['data'] as List;
    return list
        .map((e) => NearbyCity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
