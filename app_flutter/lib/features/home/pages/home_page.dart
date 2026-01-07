import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/city.dart';
import '../../../providers/city_providers.dart';
import '../../../shared/widgets/china_map.dart';
import '../../../shared/widgets/floating_controls.dart';
import '../../../shared/widgets/city_bottom_sheet.dart';

/// 首页 - 全屏沉浸式地图
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  City? _selectedCity;

  void _onCityTap(City city) {
    setState(() {
      // 如果点击的是同一个城市，关闭面板；否则切换到新城市
      if (_selectedCity?.id == city.id) {
        _selectedCity = null;
      } else {
        _selectedCity = city;
      }
    });
    ref.read(selectedCityIdProvider.notifier).state = _selectedCity?.id;
  }

  void _closePanel() {
    if (_selectedCity != null) {
      setState(() {
        _selectedCity = null;
      });
      ref.read(selectedCityIdProvider.notifier).state = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 全屏地图（点击空白处关闭面板）
          Positioned.fill(
            child: GestureDetector(
              onTap: _closePanel,
              child: citiesAsync.when(
                data: (cities) => ChinaMap(
                  cities: cities,
                  selectedCityId: _selectedCity?.id,
                  onCityTap: _onCityTap,
                ),
                loading: () => Container(
                  color: AppColors.background,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => _buildErrorView(e, ref),
              ),
            ),
          ),

          // 右侧浮动控件
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 60,
            child: FloatingControls(
              onProfileTap: () => context.push('/profile'),
              onSealsTap: () => context.push('/seals'),
              onAlbumTap: () => context.push('/album'),
              onLocationTap: _handleLocationTap,
            ),
          ),

          // 城市底部面板
          if (_selectedCity != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: CityBottomSheet(
                key: ValueKey(_selectedCity!.id),
                city: _selectedCity!,
                onClose: _closePanel,
              ),
            ),
        ],
      ),
    );
  }

  void _handleLocationTap() {
    // TODO: 实现定位功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在获取位置...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildErrorView(Object error, WidgetRef ref) {
    final errorStr = error.toString();
    String title;
    String message;
    IconData icon;

    if (errorStr.contains('SocketException') ||
        errorStr.contains('Connection refused') ||
        errorStr.contains('Failed host lookup')) {
      // 网络连接问题
      title = '无法连接服务器';
      message = '请检查网络连接，或稍后重试';
      icon = Icons.wifi_off;
    } else if (errorStr.contains('404')) {
      // 接口不存在
      title = '服务暂不可用';
      message = '后端服务可能未启动，请联系管理员';
      icon = Icons.cloud_off;
    } else if (errorStr.contains('timeout') || errorStr.contains('Timeout')) {
      // 超时
      title = '请求超时';
      message = '服务器响应太慢，请稍后重试';
      icon = Icons.timer_off;
    } else if (errorStr.contains('401') || errorStr.contains('403')) {
      // 认证问题
      title = '登录已过期';
      message = '请重新登录';
      icon = Icons.lock_outline;
    } else {
      // 其他错误
      title = '加载失败';
      message = '请稍后重试';
      icon = Icons.error_outline;
    }

    return Container(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ref.invalidate(citiesProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('重试'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
