import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/url_utils.dart';
import '../../../models/journey.dart';
import '../../../providers/journey_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_snackbar.dart';

/// 文化之旅详情页 - Aurora UI + Glassmorphism
class JourneyDetailPage extends ConsumerWidget {
  final String journeyId;
  const JourneyDetailPage({super.key, required this.journeyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyAsync = ref.watch(journeyDetailProvider(journeyId));
    final pointsAsync = ref.watch(journeyPointsProvider(journeyId));
    return Scaffold(
      body: journeyAsync.when(
        data: (journey) => _JourneyContent(
          journey: journey,
          journeyId: journeyId,
          pointsAsync: pointsAsync,
        ),
        loading: () => _buildLoadingState(),
        error: (e, _) => _buildErrorState(e.toString()),
      ),
      bottomNavigationBar: _StartButton(journeyId: journeyId),
    );
  }

  Widget _buildLoadingState() {
    return Stack(
      children: [
        const AuroraBackground(variant: AuroraVariant.standard),
        const AppLoadingOverlay(message: '加载中...'),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Stack(
      children: [
        const AuroraBackground(variant: AuroraVariant.standard),
        Builder(
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
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      '加载失败: $error',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textPrimaryAdaptive(context)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _JourneyContent extends StatelessWidget {
  final JourneyDetail journey;
  final String journeyId;
  final AsyncValue<List<ExplorationPoint>> pointsAsync;

  const _JourneyContent({
    required this.journey,
    required this.journeyId,
    required this.pointsAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AuroraBackground(variant: AuroraVariant.standard),
        CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(child: _buildInfoSection()),
            pointsAsync.when(
              data: (points) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _PointCard(
                    point: points[i],
                    index: i,
                    isLast: i == points.length - 1,
                  ),
                  childCount: points.length,
                ),
              ),
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('$e', style: const TextStyle(color: AppColors.error)),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: AppBackButton(onTap: () => context.pop()),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            journey.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            journey.coverImage != null
                ? Image.network(
                    UrlUtils.getFullImageUrl(journey.coverImage),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.95),
            AppColors.primaryDark.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: const Icon(Icons.landscape_rounded, size: 64, color: Colors.white38),
    );
  }

  Widget _buildInfoSection() {
    return Builder(
      builder: (context) {
        final isDark = context.isDarkMode;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 信息卡片
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface.withValues(alpha: 0.88)
                      : Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _InfoItem(
                          icon: Icons.category_rounded,
                          label: '主题',
                          value: journey.theme,
                          color: AppColors.primary,
                        ),
                        _InfoItem(
                          icon: Icons.schedule_rounded,
                          label: '时长',
                          value: '${journey.estimatedMinutes}分钟',
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _InfoItem(
                          icon: Icons.straighten_rounded,
                          label: '距离',
                          value: '${(journey.totalDistance / 1000).toStringAsFixed(1)}km',
                          color: AppColors.tertiary,
                        ),
                        _InfoItem(
                          icon: Icons.people_rounded,
                          label: '完成',
                          value: '${journey.completedCount}人',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (journey.description != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    journey.description!,
                    style: TextStyle(
                      height: 1.7,
                      color: AppColors.textSecondaryAdaptive(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // 探索点标题
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.accent, AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '探索点列表',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryAdaptive(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: AppColors.textHintAdaptive(context)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryAdaptive(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 探索点卡片 - 优化版，添加任务类型图标
class _PointCard extends StatelessWidget {
  final ExplorationPoint point;
  final int index;
  final bool isLast;

  const _PointCard({
    required this.point,
    required this.index,
    this.isLast = false,
  });

  IconData get _taskIcon {
    switch (point.taskType) {
      case 'gesture':
        return Icons.pan_tool_rounded;
      case 'photo':
        return Icons.camera_alt_rounded;
      case 'treasure':
        return Icons.search_rounded;
      default:
        return Icons.explore_rounded;
    }
  }

  String get _taskLabel {
    switch (point.taskType) {
      case 'gesture':
        return 'AR手势';
      case 'photo':
        return '拍照打卡';
      case 'treasure':
        return 'AR寻宝';
      default:
        return '探索任务';
    }
  }

  Color get _taskColor {
    switch (point.taskType) {
      case 'gesture':
        return AppColors.sealGold;
      case 'photo':
        return AppColors.accent;
      case 'treasure':
        return AppColors.tertiary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 时间线
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, Color(0xFFE85A4F)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.accent.withValues(alpha: 0.5),
                            AppColors.accent.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // 卡片内容
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface.withValues(alpha: 0.88)
                      : Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题行 + 任务类型
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            point.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryAdaptive(context),
                            ),
                          ),
                        ),
                        // 任务类型标签
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _taskColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _taskColor.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_taskIcon, size: 12, color: _taskColor),
                              const SizedBox(width: 4),
                              Text(
                                _taskLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _taskColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 任务描述
                    Text(
                      point.taskDescription,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryAdaptive(context),
                        height: 1.5,
                      ),
                    ),
                    // 底部信息
                    if (point.distanceFromPrev != null || point.pointsReward > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (point.distanceFromPrev != null) ...[
                            Icon(
                              Icons.straighten_rounded,
                              size: 12,
                              color: AppColors.textHintAdaptive(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${point.distanceFromPrev!.toInt()}m',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textHintAdaptive(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          const Spacer(),
                          // 积分奖励
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.sealGold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.stars_rounded,
                                  size: 12,
                                  color: AppColors.sealGold,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '+${point.pointsReward}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.sealGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 开始按钮 - 优化脉冲动画
class _StartButton extends ConsumerStatefulWidget {
  final String journeyId;
  const _StartButton({required this.journeyId});

  @override
  ConsumerState<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends ConsumerState<_StartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startJourney(BuildContext context) async {
    try {
      final service = ref.read(journeyServiceProvider);
      await service.startJourney(widget.journeyId);
      if (context.mounted) context.push('/journey/${widget.journeyId}/progress');
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, '开始失败: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) => Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: _glowAnimation.value),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _startJourney(context),
            icon: const Icon(Icons.explore_rounded, size: 20),
            label: const Text(
              '开始这条文化之旅',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
