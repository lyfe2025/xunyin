import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city.dart';
import '../models/journey.dart';
import 'journey_providers.dart';
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

/// 城市的文化之旅列表（原始数据，不含用户进度）
final cityJourneysProvider = FutureProvider.family<List<JourneyBrief>, String>((
  ref,
  cityId,
) async {
  final service = ref.watch(cityServiceProvider);
  return service.getCityJourneys(cityId);
});

/// 城市的文化之旅列表（带用户进度）
final cityJourneysWithProgressProvider =
    FutureProvider.family<List<JourneyBrief>, String>((
  ref,
  cityId,
) async {
  // 获取城市的旅程列表
  final journeys = await ref.watch(cityJourneysProvider(cityId).future);

  // 尝试获取用户的所有旅程进度（可能未登录，所以用 try-catch）
  List<JourneyProgress> userProgress = [];
  try {
    userProgress = await ref.watch(allUserJourneysProvider.future);
  } catch (_) {
    // 未登录或获取失败，返回原始列表
    return journeys;
  }

  // 创建进度映射 Map<journeyId, JourneyProgress>
  final progressMap = <String, JourneyProgress>{};
  for (final progress in userProgress) {
    progressMap[progress.journeyId] = progress;
  }

  // 合并数据
  return journeys.map((journey) {
    final progress = progressMap[journey.id];
    if (progress == null) {
      return journey; // 未开始
    }

    // 根据进度状态设置用户状态
    JourneyUserStatus status;
    if (progress.status == 'completed') {
      status = JourneyUserStatus.completed;
    } else if (progress.status == 'in_progress') {
      status = JourneyUserStatus.inProgress;
    } else {
      status = JourneyUserStatus.notStarted;
    }

    return journey.withUserProgress(
      status: status,
      progress: progress.progressPercent,
      completedPoints: progress.completedPoints,
      totalPoints: progress.totalPoints,
    );
  }).toList();
});

/// 当前选中的城市 ID
final selectedCityIdProvider = StateProvider<String?>((ref) => null);

/// 当前选中的城市
final selectedCityProvider = Provider<AsyncValue<City?>>((ref) {
  final cityId = ref.watch(selectedCityIdProvider);
  if (cityId == null) return const AsyncValue.data(null);
  return ref.watch(cityDetailProvider(cityId));
});
