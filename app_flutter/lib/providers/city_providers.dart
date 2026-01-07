import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../models/journey.dart';
import 'service_providers.dart';

/// 所有城市列表
final citiesProvider = FutureProvider<List<City>>((ref) async {
  final service = ref.watch(cityServiceProvider);
  return service.getCities();
});

/// 城市详情
final cityDetailProvider = FutureProvider.family<City, String>((
  ref,
  cityId,
) async {
  final service = ref.watch(cityServiceProvider);
  return service.getCityDetail(cityId);
});

/// 城市的文化之旅列表
final cityJourneysProvider = FutureProvider.family<List<JourneyBrief>, String>((
  ref,
  cityId,
) async {
  final service = ref.watch(cityServiceProvider);
  return service.getCityJourneys(cityId);
});

/// 当前选中的城市 ID
final selectedCityIdProvider = StateProvider<String?>((ref) => null);

/// 当前选中的城市
final selectedCityProvider = Provider<AsyncValue<City?>>((ref) {
  final cityId = ref.watch(selectedCityIdProvider);
  if (cityId == null) return const AsyncValue.data(null);
  return ref.watch(cityDetailProvider(cityId));
});
