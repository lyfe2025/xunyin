import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../models/journey.dart';
import '../../../providers/journey_providers.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_buttons.dart';

/// 文化之旅进行中页面 - Aurora UI + Glassmorphism
class JourneyProgressPage extends ConsumerStatefulWidget {
  final String journeyId;

  const JourneyProgressPage({super.key, required this.journeyId});

  @override
  ConsumerState<JourneyProgressPage> createState() =>
      _JourneyProgressPageState();
}

class _JourneyProgressPageState extends ConsumerState<JourneyProgressPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final detail = await ref.read(
      journeyDetailProvider(widget.journeyId).future,
    );
    final points = await ref.read(
      journeyPointsProvider(widget.journeyId).future,
    );
    ref.read(currentJourneyProvider.notifier).setDetail(detail);
    ref.read(currentJourneyProvider.notifier).setPoints(points);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentJourneyProvider);
    final detail = state.detail;
    final points = state.points;
    final currentIndex = state.currentPointIndex;

    return Scaffold(
      body: Stack(
        children: [
          const AuroraBackground(variant: AuroraVariant.navigation),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, detail, currentIndex, points.length),
                _buildProgressBar(currentIndex, points.length),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    children: [
                      _MapPlaceholder(points: points, currentIndex: currentIndex),
                      if (state.currentPoint != null)
                        _CurrentPointCard(point: state.currentPoint!, journeyId: widget.journeyId),
                      _PointsList(points: points, currentIndex: currentIndex),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    detail,
    int currentIndex,
    int total,
  ) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          AppCloseButton(onTap: () => _showExitDialog(context)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppRadius.iconButton),
                boxShadow: AppShadow.light,
              ),
              child: Text(
                detail?.name ?? '文化之旅',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimaryAdaptive(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, Color(0xFFE85A4F)],
              ),
              borderRadius: BorderRadius.circular(AppRadius.iconButton),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              '${currentIndex + 1}/$total',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int currentIndex, int total) {
    final progress = total == 0 ? 0.0 : (currentIndex + 1) / total;
    return Builder(
      builder: (context) {
        final isDark = context.isDarkMode;
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          height: 6,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.progress),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, Color(0xFFE6B422)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.progress),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: const Text('退出文化之旅？'),
        content: const Text('当前进度将被保存，你可以稍后继续。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text('退出', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

/// 精致地图占位符 - 带动画路线
class _MapPlaceholder extends StatefulWidget {
  final List<ExplorationPoint> points;
  final int currentIndex;

  const _MapPlaceholder({required this.points, required this.currentIndex});

  @override
  State<_MapPlaceholder> createState() => _MapPlaceholderState();
}

class _MapPlaceholderState extends State<_MapPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkSurface.withValues(alpha: 0.92),
                  AppColors.darkSurface.withValues(alpha: 0.8),
                ]
              : [
                  Colors.white.withValues(alpha: 0.92),
                  Colors.white.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 背景网格
          CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _GridPainter(isDark: isDark),
          ),
          // 路线连接线
          CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _RoutePainter(
              pointCount: widget.points.length,
              currentIndex: widget.currentIndex,
              isDark: isDark,
            ),
          ),
          // 探索点标记
          ...widget.points.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            final isCompleted = index < widget.currentIndex;
            final isCurrent = index == widget.currentIndex;

            // 计算位置（简单的水平分布）
            final totalPoints = widget.points.length;
            final xRatio = totalPoints > 1
                ? (index / (totalPoints - 1))
                : 0.5;
            final yOffset = (index % 2) * 30.0 - 15.0;

            return Positioned(
              left: 30 + (MediaQuery.of(context).size.width - 92) * xRatio * 0.85,
              top: 85 + yOffset,
              child: _PointMarker(
                index: index,
                name: point.name,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                pulseAnimation: isCurrent ? _pulseAnimation : null,
              ),
            );
          }),
          // 底部提示
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.map_rounded,
                      size: 14,
                      color: AppColors.textHintAdaptive(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '高德地图集成后显示实际路线',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textHintAdaptive(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 网格背景绘制
class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? AppColors.darkBorder : AppColors.divider).withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    const spacing = 20.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.isDark != isDark;
}

/// 路线绘制
class _RoutePainter extends CustomPainter {
  final int pointCount;
  final int currentIndex;
  final bool isDark;

  _RoutePainter({
    required this.pointCount,
    required this.currentIndex,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pointCount < 2) return;

    final completedPaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pendingPaint = Paint()
      ..color = (isDark ? AppColors.darkTextHint : AppColors.textHint).withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < pointCount - 1; i++) {
      final xRatio1 = i / (pointCount - 1);
      final xRatio2 = (i + 1) / (pointCount - 1);
      final yOffset1 = (i % 2) * 30.0 - 15.0;
      final yOffset2 = ((i + 1) % 2) * 30.0 - 15.0;

      final x1 = 47 + (size.width - 94) * xRatio1 * 0.85;
      final x2 = 47 + (size.width - 94) * xRatio2 * 0.85;
      final y1 = 100 + yOffset1;
      final y2 = 100 + yOffset2;

      final paint = i < currentIndex ? completedPaint : pendingPaint;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.currentIndex != currentIndex || oldDelegate.isDark != isDark;
}

/// 探索点标记
class _PointMarker extends StatelessWidget {
  final int index;
  final String name;
  final bool isCompleted;
  final bool isCurrent;
  final Animation<double>? pulseAnimation;

  const _PointMarker({
    required this.index,
    required this.name,
    required this.isCompleted,
    required this.isCurrent,
    this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    Widget marker = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: isCompleted
            ? const LinearGradient(
                colors: [AppColors.success, Color(0xFF4CAF50)],
              )
            : isCurrent
                ? const LinearGradient(
                    colors: [AppColors.accent, Color(0xFFE85A4F)],
                  )
                : null,
        color: (!isCompleted && !isCurrent)
            ? AppColors.textHintAdaptive(context).withValues(alpha: 0.4)
            : null,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.darkSurface : Colors.white,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCurrent ? AppColors.accent : AppColors.textHintAdaptive(context))
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
            : Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );

    if (isCurrent && pulseAnimation != null) {
      marker = AnimatedBuilder(
        animation: pulseAnimation!,
        builder: (context, child) => Transform.scale(
          scale: pulseAnimation!.value,
          child: child,
        ),
        child: marker,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        marker,
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            name.length > 4 ? '${name.substring(0, 4)}...' : name,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              color: isCurrent ? AppColors.accent : AppColors.textHintAdaptive(context),
            ),
          ),
        ),
      ],
    );
  }
}


/// 当前探索点卡片 - 优化版
class _CurrentPointCard extends StatelessWidget {
  final ExplorationPoint point;
  final String journeyId;

  const _CurrentPointCard({required this.point, required this.journeyId});

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '下一个探索点',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
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
          const SizedBox(height: 14),
          Text(
            point.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryAdaptive(context),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (point.distanceFromPrev != null) ...[
                Icon(Icons.straighten_rounded, size: 14, color: AppColors.textHintAdaptive(context)),
                const SizedBox(width: 4),
                Text(
                  '${point.distanceFromPrev!.toInt()}m',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondaryAdaptive(context)),
                ),
                const SizedBox(width: 16),
              ],
              Icon(Icons.directions_walk_rounded, size: 14, color: AppColors.textHintAdaptive(context)),
              const SizedBox(width: 4),
              Text(
                '约${((point.distanceFromPrev ?? 500) / 80).ceil()}分钟',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryAdaptive(context)),
              ),
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
                    Icon(Icons.stars_rounded, size: 12, color: AppColors.sealGold),
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
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            onPressed: () {
              context.push('/journey/$journeyId/navigate/${point.id}');
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.navigation_rounded, size: 18),
                SizedBox(width: AppSpacing.sm),
                Text('开始导航'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 探索点列表 - 优化版
class _PointsList extends StatelessWidget {
  final List<ExplorationPoint> points;
  final int currentIndex;

  const _PointsList({required this.points, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.accent, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '探索点列表',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryAdaptive(context),
                  ),
                ),
                const Spacer(),
                Text(
                  '$currentIndex/${points.length} 已完成',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHintAdaptive(context),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: points.asMap().entries.map((entry) {
                final index = entry.key;
                final point = entry.value;
                final isCompleted = index < currentIndex;
                final isCurrent = index == currentIndex;

                return _PointListItem(
                  index: index,
                  point: point,
                  isCompleted: isCompleted,
                  isCurrent: isCurrent,
                  isLast: index == points.length - 1,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointListItem extends StatelessWidget {
  final int index;
  final ExplorationPoint point;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  const _PointListItem({
    required this.index,
    required this.point,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          // 状态圆圈
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: isCompleted
                  ? const LinearGradient(colors: [AppColors.success, Color(0xFF4CAF50)])
                  : isCurrent
                      ? const LinearGradient(colors: [AppColors.accent, Color(0xFFE85A4F)])
                      : null,
              color: (!isCompleted && !isCurrent) ? Colors.transparent : null,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted
                    ? AppColors.success
                    : isCurrent
                        ? AppColors.accent
                        : AppColors.textHintAdaptive(context).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isCurrent ? Colors.white : AppColors.textHintAdaptive(context),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // 名称
          Expanded(
            child: Text(
              point.name,
              style: TextStyle(
                fontSize: 13,
                color: isCompleted
                    ? AppColors.textHintAdaptive(context)
                    : AppColors.textPrimaryAdaptive(context),
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          // 任务类型图标
          Icon(
            _taskIcon,
            size: 14,
            color: isCurrent
                ? AppColors.accent
                : AppColors.textHintAdaptive(context).withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          // 距离
          if (point.distanceFromPrev != null)
            Text(
              '${(point.distanceFromPrev! / 1000).toStringAsFixed(1)}km',
              style: TextStyle(fontSize: 11, color: AppColors.textHintAdaptive(context)),
            ),
        ],
      ),
    );
  }
}
