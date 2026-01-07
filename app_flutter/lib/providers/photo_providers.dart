import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo.dart';
import 'service_providers.dart';

/// 所有照片
final photosProvider = FutureProvider<List<Photo>>((ref) async {
  final service = ref.watch(photoServiceProvider);
  return service.getPhotos();
});

/// 按文化之旅筛选的照片
final photosByJourneyIdProvider = FutureProvider.family<List<Photo>, String>((
  ref,
  journeyId,
) async {
  final service = ref.watch(photoServiceProvider);
  return service.getPhotos(journeyId: journeyId);
});

/// 照片统计
final photoStatsProvider = FutureProvider<PhotoStats>((ref) async {
  final service = ref.watch(photoServiceProvider);
  return service.getPhotoStats();
});

/// 按文化之旅分组的照片
final photosByJourneyProvider = FutureProvider<List<JourneyPhotos>>((
  ref,
) async {
  final service = ref.watch(photoServiceProvider);
  return service.getPhotosByJourney();
});
