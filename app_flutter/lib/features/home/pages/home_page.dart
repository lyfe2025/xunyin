import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/city.dart';
import '../../../providers/city_providers.dart';
import '../../../providers/audio_providers.dart';
import '../../../shared/widgets/china_map.dart';
import '../../../shared/widgets/floating_controls.dart';
import '../../../shared/widgets/city_bottom_sheet.dart';
import '../../../shared/widgets/app_snackbar.dart';

/// 首页 - 全屏沉浸式地图
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  City? _selectedCity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioStateProvider.notifier).switchContext(AudioContext.home);
    });
  }

  void _onCityTap(City city) {
    setState(() {
      if (_selectedCity?.id == city.id) {
        _selectedCity = null;
        ref.read(audioStateProvider.notifier).switchContext(AudioContext.home);
      } else {
        _selectedCity = city;
        ref
            .read(audioStateProvider.notifier)
            .switchContext(AudioContext.city, contextId: city.id);
      }
    });
    ref.read(selectedCityIdProvider.notifier).state = _selectedCity?.id;
  }

  void _closePanel() {
    if (_selectedCity != null) {
      setState(() => _selectedCity = null);
      ref.read(selectedCityIdProvider.notifier).state = null;
      ref.read(audioStateProvider.notifier).switchContext(AudioContext.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 全屏地图
          Positioned.fill(
            child: GestureDetector(
              onTap: _closePanel,
              child: citiesAsync.when(
                data: (cities) => ChinaMap(
                  cities: cities,
                  selectedCityId: _selectedCity?.id,
                  onCityTap: _onCityTap,
                ),
                loading: () => _buildLoadingState(),
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

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F5F0), Color(0xFFF5F0EB)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.accent.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '正在加载地图...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryAdaptive(context).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLocationTap() {
    AppSnackBar.loading(context, '正在获取位置...');
  }

  Widget _buildErrorView(Object error, WidgetRef ref) {
    final errorStr = error.toString();
    String title;
    String message;

    if (errorStr.contains('SocketException') ||
        errorStr.contains('Connection refused') ||
        errorStr.contains('Failed host lookup')) {
      title = '无法连接服务器';
      message = '请检查网络连接，或稍后重试';
    } else if (errorStr.contains('404')) {
      title = '服务暂不可用';
      message = '后端服务可能未启动，请联系管理员';
    } else if (errorStr.contains('timeout') || errorStr.contains('Timeout')) {
      title = '请求超时';
      message = '服务器响应太慢，请稍后重试';
    } else if (errorStr.contains('401') || errorStr.contains('403')) {
      title = '登录已过期';
      message = '请重新登录';
    } else {
      title = '加载失败';
      message = '请稍后重试';
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F5F0), Color(0xFFF5F0EB)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 使用插画替代图标
              SvgPicture.asset(
                'assets/illustrations/error_network.svg',
                width: 180,
                height: 135,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryAdaptive(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryAdaptive(context).withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 160,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => ref.invalidate(citiesProvider),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.accentDark],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '重试',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
