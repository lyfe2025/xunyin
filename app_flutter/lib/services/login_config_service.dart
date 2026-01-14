import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../models/login_config.dart';

/// 配置更新回调
typedef ConfigUpdateCallback = void Function(LoginConfig config);

/// 登录页配置服务
/// 
/// 策略：默认配置 + 动态覆盖
/// - 立即返回缓存/默认配置，确保离线可用
/// - 后台静默获取远程配置并缓存
/// - 配置更新后通过回调通知 UI
class LoginConfigService {
  final ApiClient _api = ApiClient();
  static const _cacheKey = 'login_config_cache';
  
  ConfigUpdateCallback? _onConfigUpdated;

  /// 设置配置更新回调
  void setOnConfigUpdated(ConfigUpdateCallback? callback) {
    _onConfigUpdated = callback;
  }

  /// 获取登录配置（优先缓存，后台刷新）
  Future<LoginConfig> getConfig() async {
    // 1. 先尝试从缓存获取
    final cached = await _getCachedConfig();
    
    // 2. 后台静默刷新（不阻塞）
    _refreshConfigInBackground();
    
    // 3. 返回缓存或默认配置
    return cached ?? LoginConfig.defaultConfig;
  }

  /// 强制刷新配置（用于下拉刷新等场景）
  Future<LoginConfig> refreshConfig() async {
    try {
      final config = await _fetchRemoteConfig();
      await _cacheConfig(config);
      return config;
    } catch (e) {
      // 失败时返回缓存或默认
      return await _getCachedConfig() ?? LoginConfig.defaultConfig;
    }
  }

  /// 从缓存获取配置
  Future<LoginConfig?> _getCachedConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_cacheKey);
      if (jsonStr != null) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        return LoginConfig.fromJson(json);
      }
    } catch (e) {
      // 缓存读取失败，忽略
    }
    return null;
  }

  /// 缓存配置
  Future<void> _cacheConfig(LoginConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(config.toJson()));
    } catch (e) {
      // 缓存写入失败，忽略
    }
  }

  /// 后台静默刷新
  void _refreshConfigInBackground() {
    _fetchRemoteConfig().then((config) {
      _cacheConfig(config);
      // 通知 UI 更新
      _onConfigUpdated?.call(config);
    }).catchError((e) {
      // 静默失败，不影响用户
    });
  }

  /// 从远程获取配置
  Future<LoginConfig> _fetchRemoteConfig() async {
    final response = await _api.get('/config/login');
    return LoginConfig.fromJson(response['data'] as Map<String, dynamic>);
  }
}
