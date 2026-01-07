import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 音频上下文类型
enum AudioContext { home, city, journey, ar }

/// 音频播放状态
class AudioState {
  final bool isPlaying;
  final bool isMuted;
  final String? currentTrackUrl;
  final String? currentTrackTitle;
  final AudioContext context;
  final String? contextId;

  AudioState({
    this.isPlaying = false,
    this.isMuted = false,
    this.currentTrackUrl,
    this.currentTrackTitle,
    this.context = AudioContext.home,
    this.contextId,
  });

  AudioState copyWith({
    bool? isPlaying,
    bool? isMuted,
    String? currentTrackUrl,
    String? currentTrackTitle,
    AudioContext? context,
    String? contextId,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isMuted: isMuted ?? this.isMuted,
      currentTrackUrl: currentTrackUrl ?? this.currentTrackUrl,
      currentTrackTitle: currentTrackTitle ?? this.currentTrackTitle,
      context: context ?? this.context,
      contextId: contextId ?? this.contextId,
    );
  }
}

/// 音频状态 Notifier
class AudioNotifier extends StateNotifier<AudioState> {
  AudioNotifier() : super(AudioState());

  void play() {
    state = state.copyWith(isPlaying: true);
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
  }

  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void setTrack(String url, {String? title}) {
    state = state.copyWith(
      currentTrackUrl: url,
      currentTrackTitle: title,
      isPlaying: true,
    );
  }

  void switchContext(
    AudioContext context, {
    String? contextId,
    String? trackUrl,
    String? title,
  }) {
    state = AudioState(
      isPlaying: trackUrl != null,
      isMuted: state.isMuted,
      currentTrackUrl: trackUrl,
      currentTrackTitle: title,
      context: context,
      contextId: contextId,
    );
  }

  void pauseForAR() {
    if (state.isPlaying) {
      state = state.copyWith(isPlaying: false);
    }
  }

  void resumeFromAR() {
    if (state.currentTrackUrl != null && !state.isMuted) {
      state = state.copyWith(isPlaying: true);
    }
  }

  void stop() {
    state = AudioState(isMuted: state.isMuted);
  }
}

/// 音频状态 Provider
final audioStateProvider = StateNotifierProvider<AudioNotifier, AudioState>((
  ref,
) {
  return AudioNotifier();
});
