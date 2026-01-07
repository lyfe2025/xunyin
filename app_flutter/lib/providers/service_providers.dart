import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../services/services.dart';

/// API 客户端 Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// 认证服务 Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiClientProvider));
});

/// 城市服务 Provider
final cityServiceProvider = Provider<CityService>((ref) {
  return CityService(ref.watch(apiClientProvider));
});

/// 文化之旅服务 Provider
final journeyServiceProvider = Provider<JourneyService>((ref) {
  return JourneyService(ref.watch(apiClientProvider));
});

/// 印记服务 Provider
final sealServiceProvider = Provider<SealService>((ref) {
  return SealService(ref.watch(apiClientProvider));
});

/// 用户服务 Provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(apiClientProvider));
});

/// 照片服务 Provider
final photoServiceProvider = Provider<PhotoService>((ref) {
  return PhotoService(ref.watch(apiClientProvider));
});

/// 音频 API 服务 Provider
final audioApiServiceProvider = Provider<AudioApiService>((ref) {
  return AudioApiService(ref.watch(apiClientProvider));
});

/// 地图 API 服务 Provider
final mapApiServiceProvider = Provider<MapApiService>((ref) {
  return MapApiService(ref.watch(apiClientProvider));
});

/// 地图配置服务 Provider
final mapConfigServiceProvider = Provider<MapConfigService>((ref) {
  return MapConfigService(ref.watch(apiClientProvider));
});

/// 用户资料服务 Provider
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.watch(apiClientProvider));
});
