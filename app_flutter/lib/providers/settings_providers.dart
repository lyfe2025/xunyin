import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/settings_storage.dart';

/// 主题模式枚举
enum AppThemeMode {
  system, // 跟随系统
  light,  // 浅色
  dark,   // 深色
}

/// 设置状态
class SettingsState {
  final bool notificationEnabled;
  final bool autoLocationEnabled;
  final String cacheSize;
  final bool isLoading;
  final AppThemeMode themeMode;

  const SettingsState({
    this.notificationEnabled = true,
    this.autoLocationEnabled = true,
    this.cacheSize = '计算中...',
    this.isLoading = false,
    this.themeMode = AppThemeMode.system,
  });

  SettingsState copyWith({
    bool? notificationEnabled,
    bool? autoLocationEnabled,
    String? cacheSize,
    bool? isLoading,
    AppThemeMode? themeMode,
  }) {
    return SettingsState(
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      autoLocationEnabled: autoLocationEnabled ?? this.autoLocationEnabled,
      cacheSize: cacheSize ?? this.cacheSize,
      isLoading: isLoading ?? this.isLoading,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  /// 获取 Flutter ThemeMode
  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// 获取主题模式显示名称
  String get themeModeLabel {
    switch (themeMode) {
      case AppThemeMode.system:
        return '跟随系统';
      case AppThemeMode.light:
        return '浅色模式';
      case AppThemeMode.dark:
        return '深色模式';
    }
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
    final themeMode = await SettingsStorage.getThemeMode();
    state = SettingsState(
      notificationEnabled: notification,
      autoLocationEnabled: location,
      cacheSize: cacheSize,
      themeMode: themeMode,
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

  /// 设置主题模式
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await SettingsStorage.setThemeMode(mode);
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
