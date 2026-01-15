import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/splash_config.dart';

/// 启动页配置 Provider
final splashConfigProvider = FutureProvider<SplashConfig>((ref) async {
  final api = ApiClient();
  try {
    final response = await api.get('/config/splash/current');
    final data = response['data'];
    if (data != null) {
      return SplashConfig.fromJson(data as Map<String, dynamic>);
    }
  } catch (e) {
    // 网络错误时使用默认配置
  }
  return const SplashConfig();
});
