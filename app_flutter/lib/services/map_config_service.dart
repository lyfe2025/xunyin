import 'dart:io';
import '../core/api/api_client.dart';

/// 地图配置服务
class MapConfigService {
  final ApiClient _apiClient;

  // 缓存配置
  static MapConfig? _cachedConfig;

  MapConfigService(this._apiClient);

  /// 获取地图配置
  Future<MapConfig> getConfig() async {
    // 如果有缓存，直接返回
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }

    // 注意：baseUrl 已经是 /api/app，所以这里只需要 /map/config
    final response = await _apiClient.get('/map/config');
    final data = response['data'] ?? response;
    _cachedConfig = MapConfig.fromJson(data as Map<String, dynamic>);
    return _cachedConfig!;
  }

  /// 获取当前平台的高德 Key
  Future<String> getAmapKey() async {
    final config = await getConfig();
    if (Platform.isAndroid) {
      return config.amap.androidKey;
    } else if (Platform.isIOS) {
      return config.amap.iosKey;
    }
    return config.amap.webKey;
  }

  /// 清除缓存
  void clearCache() {
    _cachedConfig = null;
  }
}

/// 地图配置
class MapConfig {
  final String provider;
  final AmapConfig amap;
  final List<CityMarker> cityMarkers;

  MapConfig({
    required this.provider,
    required this.amap,
    required this.cityMarkers,
  });

  factory MapConfig.fromJson(Map<String, dynamic> json) {
    return MapConfig(
      provider: json['provider'] ?? 'amap',
      amap: AmapConfig.fromJson(json['amap'] ?? {}),
      cityMarkers:
          (json['cityMarkers'] as List<dynamic>?)
              ?.map((e) => CityMarker.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// 高德地图配置
class AmapConfig {
  final String webKey;
  final String androidKey;
  final String iosKey;
  final String securityCode;

  AmapConfig({
    required this.webKey,
    required this.androidKey,
    required this.iosKey,
    required this.securityCode,
  });

  factory AmapConfig.fromJson(Map<String, dynamic> json) {
    return AmapConfig(
      webKey: json['webKey'] ?? '',
      androidKey: json['androidKey'] ?? '',
      iosKey: json['iosKey'] ?? '',
      securityCode: json['securityCode'] ?? '',
    );
  }
}

/// 城市标记
class CityMarker {
  final String cityId;
  final String iconAsset;
  final double lat;
  final double lng;

  CityMarker({
    required this.cityId,
    required this.iconAsset,
    required this.lat,
    required this.lng,
  });

  factory CityMarker.fromJson(Map<String, dynamic> json) {
    final position = json['position'] ?? {};
    return CityMarker(
      cityId: json['cityId'] ?? '',
      iconAsset: json['iconAsset'] ?? '',
      lat: (position['lat'] ?? 0).toDouble(),
      lng: (position['lng'] ?? 0).toDouble(),
    );
  }
}
