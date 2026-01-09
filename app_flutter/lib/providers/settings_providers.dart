import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/settings_storage.dart';

/// 设置状态
class SettingsState {
  final bool notificationEnabled;
  final bool autoLocationEnabled;
  final String cacheSize;
  final bool isLoading;

  const SettingsState({
    this.notificationEnabled = true,
    this.autoLocationEnabled = true,
    this.cacheSize = '计算中...',
    this.isLoading = false,
  });

  SettingsState copyWith({
    bool? notificationEnabled,
    bool? autoLocationEnabled,
    String? cacheSize,
    bool? isLoading,
  }) {
    return SettingsState(
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      autoLocationEnabled: autoLocationEnabled ?? this.autoLocationEnabled,
      cacheSize: cacheSize ?? this.cacheSize,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 设置状态管理
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = state.copyWith(isLoading: true);
    final notification = await SettingsStorage.getNotificationEnabled();
    final location = await SettingsStorage.getAutoLocationEnabled();
    final cacheSize = await SettingsStorage.getFormattedCacheSize();
    state = SettingsState(
      notificationEnabled: notification,
      autoLocationEnabled: location,
      cacheSize: cacheSize,
      isLoading: false,
    );
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    state = state.copyWith(notificationEnabled: enabled);
    await SettingsStorage.setNotificationEnabled(enabled);
  }

  Future<void> setAutoLocationEnabled(bool enabled) async {
    state = state.copyWith(autoLocationEnabled: enabled);
    await SettingsStorage.setAutoLocationEnabled(enabled);
  }

  /// 清除缓存
  Future<void> clearCache() async {
    await SettingsStorage.clearCache();
    final cacheSize = await SettingsStorage.getFormattedCacheSize();
    state = state.copyWith(cacheSize: cacheSize);
  }

  /// 刷新缓存大小
  Future<void> refreshCacheSize() async {
    final cacheSize = await SettingsStorage.getFormattedCacheSize();
    state = state.copyWith(cacheSize: cacheSize);
  }

  /// 重新加载设置
  Future<void> reload() => _loadSettings();
}

/// 设置状态 Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);
