import '../core/api/api_client.dart';

class WalkingRoute {
  final double distance;
  final int duration;
  final List<RouteStep> steps;

  WalkingRoute({
    required this.distance,
    required this.duration,
    required this.steps,
  });

  factory WalkingRoute.fromJson(Map<String, dynamic> json) {
    return WalkingRoute(
      distance: (json['distance'] as num).toDouble(),
      duration: json['duration'] as int,
      steps: (json['steps'] as List).map((e) => RouteStep.fromJson(e)).toList(),
    );
  }
}

class RouteStep {
  final String instruction;
  final double distance;

  RouteStep({required this.instruction, required this.distance});

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['instruction'] as String,
      distance: (json['distance'] as num).toDouble(),
    );
  }
}

class LocationValidation {
  final bool isInRange;
  final double distance;

  LocationValidation({required this.isInRange, required this.distance});

  factory LocationValidation.fromJson(Map<String, dynamic> json) {
    return LocationValidation(
      isInRange: json['isInRange'] as bool,
      distance: (json['distance'] as num).toDouble(),
    );
  }
}

class MapApiService {
  final ApiClient _api;

  MapApiService(this._api);

  /// 获取步行路线
  Future<WalkingRoute> getWalkingRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final response = await _api.post(
      '/map/walking-route',
      data: {
        'origin': {'latitude': startLat, 'longitude': startLng},
        'destination': {'latitude': endLat, 'longitude': endLng},
      },
    );
    return WalkingRoute.fromJson(response['data']);
  }

  /// 验证位置是否在探索点范围内
  Future<LocationValidation> validateLocation({
    required String pointId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _api.post(
      '/map/validate-location',
      data: {'pointId': pointId, 'latitude': latitude, 'longitude': longitude},
    );
    return LocationValidation.fromJson(response['data']);
  }

  /// 获取地图配置
  Future<Map<String, dynamic>> getMapConfig() async {
    final response = await _api.get('/map/config');
    return response['data'] as Map<String, dynamic>;
  }

  /// 获取城市标记点
  Future<List<Map<String, dynamic>>> getCityMarkers() async {
    final response = await _api.get('/map/city-markers');
    return (response['data'] as List).cast<Map<String, dynamic>>();
  }
}
