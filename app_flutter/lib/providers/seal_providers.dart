import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/seal.dart';
import '../models/badge.dart';
import 'service_providers.dart';

/// 用户印记列表
final userSealsProvider = FutureProvider<List<UserSeal>>((ref) async {
  final service = ref.watch(sealServiceProvider);
  return service.getUserSeals();
});

/// 按类型筛选的用户印记
final userSealsByTypeProvider =
    FutureProvider.family<List<UserSeal>, SealType?>((ref, type) async {
      final service = ref.watch(sealServiceProvider);
      return service.getUserSeals(type: type?.name);
    });

/// 印记详情
final sealDetailProvider = FutureProvider.family<SealDetail, String>((
  ref,
  sealId,
) async {
  final service = ref.watch(sealServiceProvider);
  return service.getSealDetail(sealId);
});

/// 印记收集进度
final sealProgressProvider = FutureProvider<SealProgress>((ref) async {
  final service = ref.watch(sealServiceProvider);
  return service.getSealProgress();
});

/// 所有可用印记（含未解锁）
final allSealsProvider = FutureProvider<List<SealDetail>>((ref) async {
  final service = ref.watch(sealServiceProvider);
  return service.getAllSeals();
});

/// 当前选中的印记类型筛选
final selectedSealTypeProvider = StateProvider<SealType?>((ref) => null);

/// 用户已解锁的称号列表
final userBadgesProvider = FutureProvider<List<UserBadge>>((ref) async {
  final service = ref.watch(sealServiceProvider);
  return service.getUserBadges();
});
