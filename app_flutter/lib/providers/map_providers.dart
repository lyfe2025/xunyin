import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/map_config_service.dart';
import 'service_providers.dart';

/// 地图配置 Provider
final mapConfigProvider = FutureProvider<MapConfig>((ref) async {
  final service = ref.watch(mapConfigServiceProvider);
  return service.getConfig();
});

/// 高德 Key Provider（根据平台自动选择）
final amapKeyProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(mapConfigServiceProvider);
  return service.getAmapKey();
});
