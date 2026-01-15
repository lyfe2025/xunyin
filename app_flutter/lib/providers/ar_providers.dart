import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/ar/services/camera_service.dart';
import '../features/ar/services/gesture_recognition_service.dart';
import '../features/ar/services/ar_service.dart';

/// 相机服务 Provider
final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = CameraService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 手势识别服务 Provider
final gestureRecognitionServiceProvider = Provider<GestureRecognitionService>((ref) {
  final service = GestureRecognitionService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// AR 服务 Provider
final arServiceProvider = Provider<ARService>((ref) {
  final service = ARService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 当前手势识别结果
final currentGestureResultProvider = StateProvider<GestureResult?>((ref) => null);

/// 手势是否匹配
final gestureMatchedProvider = StateProvider<bool>((ref) => false);

/// AR 任务状态
class ARTaskState {
  final bool isInitialized;
  final bool isProcessing;
  final double progress;
  final String? error;

  const ARTaskState({
    this.isInitialized = false,
    this.isProcessing = false,
    this.progress = 0,
    this.error,
  });

  ARTaskState copyWith({
    bool? isInitialized,
    bool? isProcessing,
    double? progress,
    String? error,
  }) {
    return ARTaskState(
      isInitialized: isInitialized ?? this.isInitialized,
      isProcessing: isProcessing ?? this.isProcessing,
      progress: progress ?? this.progress,
      error: error,
    );
  }
}

/// AR 任务状态 Provider
final arTaskStateProvider = StateNotifierProvider<ARTaskStateNotifier, ARTaskState>((ref) {
  return ARTaskStateNotifier();
});

class ARTaskStateNotifier extends StateNotifier<ARTaskState> {
  ARTaskStateNotifier() : super(const ARTaskState());

  void setInitialized(bool value) {
    state = state.copyWith(isInitialized: value);
  }

  void setProcessing(bool value) {
    state = state.copyWith(isProcessing: value);
  }

  void setProgress(double value) {
    state = state.copyWith(progress: value);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void reset() {
    state = const ARTaskState();
  }
}
