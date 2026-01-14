import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/login_config.dart';
import '../services/login_config_service.dart';

/// 登录配置服务 Provider
final loginConfigServiceProvider = Provider<LoginConfigService>((ref) {
  return LoginConfigService();
});

/// 登录配置 Provider
/// 
/// 策略：
/// 1. 立即返回默认配置（确保 UI 不阻塞）
/// 2. 后台获取远程配置并更新 UI
/// 3. 支持手动刷新
final loginConfigProvider = StateNotifierProvider<LoginConfigNotifier, LoginConfig>((ref) {
  final service = ref.watch(loginConfigServiceProvider);
  return LoginConfigNotifier(service);
});

class LoginConfigNotifier extends StateNotifier<LoginConfig> {
  final LoginConfigService _service;
  bool _initialized = false;

  LoginConfigNotifier(this._service) : super(LoginConfig.defaultConfig) {
    // 设置回调，当后台刷新完成时更新 state
    _service.setOnConfigUpdated((config) {
      if (mounted) {
        state = config;
      }
    });
    _init();
  }

  Future<void> _init() async {
    if (_initialized) return;
    _initialized = true;
    
    // 异步获取配置（会触发后台刷新，刷新完成后通过回调更新 state）
    try {
      final config = await _service.getConfig();
      if (mounted) {
        state = config;
      }
    } catch (e) {
      // 失败时保持默认配置
    }
  }

  /// 强制刷新配置
  Future<void> refresh() async {
    try {
      final config = await _service.refreshConfig();
      if (mounted) {
        state = config;
      }
    } catch (e) {
      // 刷新失败，保持当前配置
    }
  }

  @override
  void dispose() {
    _service.setOnConfigUpdated(null);
    super.dispose();
  }
}
