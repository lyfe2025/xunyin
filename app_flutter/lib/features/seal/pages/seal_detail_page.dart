import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/seal_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../shared/widgets/share_bottom_sheet.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_snackbar.dart';

/// 印记详情页 - Aurora UI + Glassmorphism + 3D翻转效果
class SealDetailPage extends ConsumerStatefulWidget {
  final String sealId;
  const SealDetailPage({super.key, required this.sealId});

  @override
  ConsumerState<SealDetailPage> createState() => _SealDetailPageState();
}

class _SealDetailPageState extends ConsumerState<SealDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _flipController;
  late Animation<double> _glowAnimation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    // 光晕呼吸动画
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 翻转动画
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_showBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showBack = !_showBack);
  }

  @override
  Widget build(BuildContext context) {
    final sealAsync = ref.watch(sealDetailProvider(widget.sealId));

    return Scaffold(
      body: Stack(
        children: [
          const AuroraBackground(variant: AuroraVariant.golden),
          SafeArea(
            child: Column(
              children: [
                const AppPageHeader(title: '印记详情'),
                Expanded(
                  child: sealAsync.when(
                    data: (seal) => _buildContent(context, ref, seal),
                    loading: () => const AppLoading(message: '加载中...'),
                    error: (e, _) => _buildErrorState(e.toString()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Builder(
      builder: (context) {
        final isDark = context.isDarkMode;
        return Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondaryAdaptive(context)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, seal) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 3D翻转印记卡片
        Center(child: _buildFlippableSealCard(seal)),
        const SizedBox(height: 12),
        // 点击提示
        Center(
          child: Text(
            '点击印记查看详情',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHintAdaptive(context).withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 印记名称
        Center(
          child: Text(
            seal.name,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryAdaptive(context),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // 类型标签
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.sealGold.withValues(alpha: 0.15),
                  AppColors.accent.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.sealGold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTypeIcon(seal.type.label),
                  size: 14,
                  color: AppColors.sealGold,
                ),
                const SizedBox(width: 6),
                Text(
                  seal.type.label,
                  style: const TextStyle(
                    color: AppColors.sealGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (seal.earnedTime != null) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              '获得时间：${seal.earnedTime.toString().substring(0, 16)}',
              style: TextStyle(fontSize: 12, color: AppColors.textHintAdaptive(context)),
            ),
          ),
        ],
        const SizedBox(height: 28),
        _buildInfoSection(seal),
        const SizedBox(height: 20),
        if (seal.isChained == true)
          _buildChainedSection(seal.txHash)
        else
          _buildChainButton(context, ref),
        const SizedBox(height: 20),
        _buildShareButton(context, seal),
        const SizedBox(height: 20),
      ],
    );
  }

  /// 3D翻转印记卡片
  Widget _buildFlippableSealCard(seal) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          final angle = _flipController.value * math.pi;
          final isFront = angle < math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront
                ? _buildSealFront(seal)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildSealBack(seal),
                  ),
          );
        },
      ),
    );
  }

  /// 印记正面 - 精美展示
  Widget _buildSealFront(seal) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                AppColors.sealGold.withValues(alpha: 0.2),
                AppColors.sealGold.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(90),
            boxShadow: [
              BoxShadow(
                color: AppColors.sealGold.withValues(alpha: _glowAnimation.value * 0.4),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(75),
              border: Border.all(
                color: AppColors.sealGold.withValues(alpha: 0.6),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sealGold.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 10,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 印记图标
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.sealGold,
                      AppColors.accent,
                      AppColors.sealGold,
                    ],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // 印记名称
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    seal.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryAdaptive(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 印记背面 - 详细信息
  Widget _buildSealBack(seal) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.9),
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(90),
        border: Border.all(
          color: AppColors.sealGold.withValues(alpha: 0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 类型标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.sealGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              seal.type.label,
              style: const TextStyle(
                color: AppColors.sealGold,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 获得时间
          if (seal.earnedTime != null) ...[
            const Icon(
              Icons.access_time_rounded,
              size: 16,
              color: Colors.white70,
            ),
            const SizedBox(height: 4),
            Text(
              seal.earnedTime.toString().substring(0, 10),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // 上链状态
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                seal.isChained == true
                    ? Icons.link_rounded
                    : Icons.link_off_rounded,
                size: 14,
                color: seal.isChained == true
                    ? AppColors.sealGold
                    : Colors.white54,
              ),
              const SizedBox(width: 4),
              Text(
                seal.isChained == true ? '已上链' : '未上链',
                style: TextStyle(
                  color: seal.isChained == true
                      ? AppColors.sealGold
                      : Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(seal) {
    return Builder(
      builder: (context) {
        final isDark = context.isDarkMode;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_rounded, size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    '完成信息',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (seal.timeSpentMinutes != null)
                _infoRow(context, Icons.timer_rounded, '用时', '${seal.timeSpentMinutes}分钟'),
              if (seal.pointsEarned != null)
                _infoRow(context, Icons.stars_rounded, '获得积分', '${seal.pointsEarned}'),
              if (seal.journeyName != null)
                _infoRow(context, Icons.route_rounded, '关联文化之旅', seal.journeyName!),
              if (seal.cityName != null)
                _infoRow(context, Icons.location_city_rounded, '关联城市', seal.cityName!),
              if (seal.badgeTitle != null)
                _infoRow(context, Icons.military_tech_rounded, '解锁称号', seal.badgeTitle!),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textHintAdaptive(context)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondaryAdaptive(context),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.textPrimaryAdaptive(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChainedSection(String? txHash) {
    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.sealGold.withValues(alpha: 0.15),
                AppColors.sealGold.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.sealGold.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_rounded, size: 18, color: AppColors.sealGold),
                  const SizedBox(width: 8),
                  const Text(
                    '已上链',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.sealGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _infoRow(context, Icons.link_rounded, '链', 'Polygon'),
              _infoRow(
                context,
                Icons.tag_rounded,
                '交易哈希',
                txHash != null && txHash.length > 16
                    ? '${txHash.substring(0, 8)}...${txHash.substring(txHash.length - 6)}'
                    : txHash ?? '',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (txHash != null) {
                            Clipboard.setData(ClipboardData(text: txHash));
                          }
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('复制哈希'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.sealGold,
                          side: const BorderSide(color: AppColors.sealGold),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('链上查看'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.sealGold,
                          side: const BorderSide(color: AppColors.sealGold),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChainButton(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link_rounded, size: 18, color: AppColors.tertiary),
              const SizedBox(width: 8),
              Text(
                '上链存证',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '将此印记永久记录到区块链',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryAdaptive(context)),
          ),
          const SizedBox(height: 16),
          AppPrimaryButton(
            onPressed: () async {
              try {
                await ref.read(sealServiceProvider).chainSeal(widget.sealId);
                ref.invalidate(sealDetailProvider(widget.sealId));
                if (context.mounted) {
                  AppSnackBar.success(context, '上链成功');
                }
              } catch (e) {
                if (context.mounted) {
                  AppSnackBar.error(context, '上链失败: $e');
                }
              }
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch_rounded, size: 18),
                SizedBox(width: 8),
                Text('立即上链'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, seal) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => ShareBottomSheet.show(context, seal: seal),
        icon: const Icon(Icons.share_rounded, size: 20),
        label: const Text(
          '分享印记',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case '路线印记':
        return Icons.route_rounded;
      case '城市印记':
        return Icons.location_city_rounded;
      case '探索点印记':
        return Icons.explore_rounded;
      case '成就印记':
        return Icons.emoji_events_rounded;
      default:
        return Icons.verified_rounded;
    }
  }
}
