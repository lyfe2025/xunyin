import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journey.dart';
import 'service_providers.dart';

/// 文化之旅详情
final journeyDetailProvider = FutureProvider.family<JourneyDetail, String>((
  ref,
  journeyId,
) async {
  final service = ref.watch(journeyServiceProvider);
  return service.getJourneyDetail(journeyId);
});

/// 文化之旅探索点列表
final journeyPointsProvider =
    FutureProvider.family<List<ExplorationPoint>, String>((
      ref,
      journeyId,
    ) async {
      final service = ref.watch(journeyServiceProvider);
      return service.getJourneyPoints(journeyId);
    });

/// 进行中的文化之旅
final inProgressJourneysProvider = FutureProvider<List<JourneyProgress>>((
  ref,
) async {
  final service = ref.watch(journeyServiceProvider);
  return service.getInProgressJourneys();
});

/// 当前进行中的文化之旅状态
class CurrentJourneyState {
  final JourneyProgress? progress;
  final JourneyDetail? detail;
  final List<ExplorationPoint> points;
  final int currentPointIndex;
  final bool isNavigating;

  CurrentJourneyState({
    this.progress,
    this.detail,
    this.points = const [],
    this.currentPointIndex = 0,
    this.isNavigating = false,
  });

  CurrentJourneyState copyWith({
    JourneyProgress? progress,
    JourneyDetail? detail,
    List<ExplorationPoint>? points,
    int? currentPointIndex,
    bool? isNavigating,
  }) {
    return CurrentJourneyState(
      progress: progress ?? this.progress,
      detail: detail ?? this.detail,
      points: points ?? this.points,
      currentPointIndex: currentPointIndex ?? this.currentPointIndex,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }

  ExplorationPoint? get currentPoint =>
      points.isNotEmpty && currentPointIndex < points.length
      ? points[currentPointIndex]
      : null;

  bool get hasNextPoint => currentPointIndex < points.length - 1;
}

/// 当前文化之旅状态 Notifier
class CurrentJourneyNotifier extends StateNotifier<CurrentJourneyState> {
  CurrentJourneyNotifier() : super(CurrentJourneyState());

  void setProgress(JourneyProgress progress) {
    state = state.copyWith(progress: progress);
  }

  void setDetail(JourneyDetail detail) {
    state = state.copyWith(detail: detail);
  }

  void setPoints(List<ExplorationPoint> points) {
    state = state.copyWith(points: points);
  }

  void setCurrentPointIndex(int index) {
    state = state.copyWith(currentPointIndex: index);
  }

  void nextPoint() {
    if (state.hasNextPoint) {
      state = state.copyWith(currentPointIndex: state.currentPointIndex + 1);
    }
  }

  void startNavigating() {
    state = state.copyWith(isNavigating: true);
  }

  void stopNavigating() {
    state = state.copyWith(isNavigating: false);
  }

  void clear() {
    state = CurrentJourneyState();
  }
}

/// 当前文化之旅状态 Provider
final currentJourneyProvider =
    StateNotifierProvider<CurrentJourneyNotifier, CurrentJourneyState>((ref) {
      return CurrentJourneyNotifier();
    });
