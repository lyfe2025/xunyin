import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../core/utils/url_utils.dart';
import '../services/audio_service.dart';
import 'service_providers.dart';

/// 音频上下文类型
enum AudioContext { home, city, journey, explorationPoint, ar }

/// 音频播放状态
class AudioState {
  final bool isPlaying;
  final bool isMuted;
  final bool isLoading;
  final String? currentTrackUrl;
  final String? currentTrackTitle;
  final AudioContext context;
  final String? contextId;

  AudioState({
    this.isPlaying = false,
    this.isMuted = false,
    this.isLoading = false,
    this.currentTrackUrl,
    this.currentTrackTitle,
    this.context = AudioContext.home,
    this.contextId,
  });

  AudioState copyWith({
    bool? isPlaying,
    bool? isMuted,
    bool? isLoading,
    String? currentTrackUrl,
    String? currentTrackTitle,
    AudioContext? context,
    String? contextId,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isMuted: isMuted ?? this.isMuted,
      isLoading: isLoading ?? this.isLoading,
      currentTrackUrl: currentTrackUrl ?? this.currentTrackUrl,
      currentTrackTitle: currentTrackTitle ?? this.currentTrackTitle,
      context: context ?? this.context,
      contextId: contextId ?? this.contextId,
    );
  }
}

/// 音频状态 Notifier
class AudioNotifier extends StateNotifier<AudioState> {
  final AudioPlayer _player = AudioPlayer();
  final AudioApiService _audioApi;
  bool _wasPlayingBeforeAR = false;

  AudioNotifier(this._audioApi) : super(AudioState()) {
    _player.setLoopMode(LoopMode.one);
    _player.setVolume(0.5);

    // 监听播放状态
    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      if (state.isPlaying != isPlaying) {
        state = state.copyWith(isPlaying: isPlaying);
      }
    });
  }

  Future<void> play() async {
    if (state.currentTrackUrl != null) {
      await _player.play();
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> togglePlay() async {
    developer.log(
      'togglePlay 被调用, isPlaying: ${state.isPlaying}, currentTrackUrl: ${state.currentTrackUrl}, isLoading: ${state.isLoading}',
      name: 'AudioNotifier',
    );
    
    // 如果正在加载，忽略点击
    if (state.isLoading) return;
    
    if (state.isPlaying) {
      await pause();
    } else if (state.currentTrackUrl != null) {
      await play();
    } else {
      // 没有音乐时，加载首页背景音乐
      // 立即设置加载状态，让 UI 显示加载中
      state = state.copyWith(isLoading: true);
      // 强制加载，即使上下文相同
      await _loadContextAudio(AudioContext.home, null);
    }
  }

  /// 内部方法：加载指定上下文的音频（不检查上下文是否相同）
  Future<void> _loadContextAudio(AudioContext context, String? contextId) async {
    developer.log(
      '加载音频上下文: $context, contextId: $contextId',
      name: 'AudioNotifier',
    );

    AudioInfo? audioInfo;

    try {
      switch (context) {
        case AudioContext.home:
          audioInfo = await _audioApi.getHomeBgm();
          break;
        case AudioContext.city:
          if (contextId != null) {
            audioInfo = await _audioApi.getCityBgm(contextId);
          }
          break;
        case AudioContext.journey:
          if (contextId != null) {
            audioInfo = await _audioApi.getJourneyBgm(contextId);
          }
          break;
        case AudioContext.explorationPoint:
          if (contextId != null) {
            audioInfo = await _audioApi.getExplorationPointBgm(contextId);
          }
          break;
        case AudioContext.ar:
          // AR 模式暂停音乐
          break;
      }
    } catch (e) {
      developer.log('获取音频信息失败: $e', name: 'AudioNotifier');
      state = state.copyWith(isLoading: false);
      return;
    }

    developer.log('获取到音频信息: ${audioInfo?.url}', name: 'AudioNotifier');

    if (audioInfo != null) {
      try {
        final fullUrl = UrlUtils.getFullImageUrl(audioInfo.url);
        developer.log('加载音频: $fullUrl', name: 'AudioNotifier');
        await _player.setUrl(fullUrl);
        state = AudioState(
          isPlaying: true,
          isMuted: state.isMuted,
          isLoading: false,
          currentTrackUrl: fullUrl,
          currentTrackTitle: audioInfo.title,
          context: context,
          contextId: contextId,
        );
        if (!state.isMuted) {
          await _player.play();
        }
      } catch (e) {
        developer.log('加载/播放音频失败: $e', name: 'AudioNotifier');
        state = state.copyWith(isLoading: false);
      }
    } else {
      developer.log('未获取到音频信息', name: 'AudioNotifier');
      state = state.copyWith(context: context, contextId: contextId, isLoading: false);
    }
  }

  Future<void> toggleMute() async {
    final newMuted = !state.isMuted;
    await _player.setVolume(newMuted ? 0 : 0.5);
    state = state.copyWith(isMuted: newMuted);
  }

  Future<void> setTrack(String url, {String? title}) async {
    try {
      final fullUrl = UrlUtils.getFullImageUrl(url);
      developer.log('设置音轨: $fullUrl', name: 'AudioNotifier');
      await _player.setUrl(fullUrl);
      state = state.copyWith(
        currentTrackUrl: fullUrl,
        currentTrackTitle: title,
      );
      await _player.play();
    } catch (e) {
      developer.log('播放失败: $e', name: 'AudioNotifier');
    }
  }

  Future<void> switchContext(AudioContext context, {String? contextId}) async {
    // 如果上下文相同且 ID 相同，不重复加载
    if (state.context == context && state.contextId == contextId) {
      state = state.copyWith(isLoading: false);
      return;
    }

    // 设置加载状态
    state = state.copyWith(isLoading: true);
    
    // 调用内部加载方法
    await _loadContextAudio(context, contextId);
  }

  Future<void> pauseForAR() async {
    _wasPlayingBeforeAR = state.isPlaying;
    if (state.isPlaying) {
      await _player.pause();
    }
  }

  Future<void> resumeFromAR() async {
    if (_wasPlayingBeforeAR &&
        state.currentTrackUrl != null &&
        !state.isMuted) {
      await _player.play();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    state = AudioState(isMuted: state.isMuted);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

/// 音频状态 Provider
final audioStateProvider = StateNotifierProvider<AudioNotifier, AudioState>((
  ref,
) {
  final audioApi = ref.watch(audioApiServiceProvider);
  return AudioNotifier(audioApi);
});
