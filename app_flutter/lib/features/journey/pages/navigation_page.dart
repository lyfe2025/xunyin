import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../providers/journey_providers.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_buttons.dart';

/// 导航页面 - Aurora UI + Glassmorphism
class NavigationPage extends ConsumerStatefulWidget {
  final String journeyId;
  final String pointId;

  const NavigationPage({
    super.key,
    required this.journeyId,
    required this.pointId,
  });

  @override
  ConsumerState<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<NavigationPage>
    with TickerProviderStateMixin {
  bool _isArrived = false;
  double _remainingDistance = 350;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _arrivedController;
  late Animation<double> _arrivedScaleAnimation;
  late Animation<double> _arrivedFadeAnimation;

  @override
  void initState() {
    super.initState();
    // 导航脉冲动画
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 到达庆祝动画
    _arrivedController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _arrivedScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _arrivedController, curve: Curves.elasticOut),
    );
    _arrivedFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _arrivedController, curve: Curves.easeOut),
    );

    _simulateNavigation();
  }

  void _simulateNavigation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _remainingDistance = 150);
    });
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _remainingDistance = 0;
          _isArrived = true;
        });
        _arrivedController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _arrivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentJourneyProvider);
    final point = state.currentPoint;

    return Scaffold(
      body: Stack(
        children: [
          const AuroraBackground(variant: AuroraVariant.navigation),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, point?.name ?? '探索点'),
                Expanded(flex: 2, child: _buildMapPlaceholder()),
                _buildNavigationInfo(),
                if (_isArrived) _buildArrivedCard() else _buildNavigatingCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String pointName) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          AppCloseButton(onTap: () => context.pop()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                '导航到：$pointName',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimaryAdaptive(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: AppSize.iconButtonSize),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    final isDark = context.isDarkMode;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor.withValues(alpha: 0.92),
            cardColor.withValues(alpha: 0.8),
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
            color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 背景网格
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: _MapGridPainter(isDark: isDark),
          ),
          // 模拟路线
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: _NavigationRoutePainter(
              progress: 1 - (_remainingDistance / 350),
              isDark: isDark,
            ),
          ),
          // 当前位置标记（带脉冲动画）
          Positioned(
            left: 60 + (MediaQuery.of(context).size.width - 152) * (1 - _remainingDistance / 350) * 0.7,
            top: 80,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _isArrived ? 1.0 : _pulseAnimation.value,
                child: child,
              ),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 目的地标记
          Positioned(
            right: 40,
            top: 70,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.sealGold, Color(0xFFD4A017)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sealGold.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Text(
                    '目的地',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sealGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 底部提示
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.navigation_rounded,
                      size: 14,
                      color: AppColors.textHintAdaptive(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '高德地图集成后显示实际导航',
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

  Widget _buildNavigationInfo() {
    final isDark = context.isDarkMode;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.15),
                      AppColors.accent.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  size: 28,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '前方 100米 右转',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryAdaptive(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  '剩余距离',
                  '${_remainingDistance.toInt()}m',
                  Icons.straighten_rounded,
                  AppColors.primary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.borderAdaptive(context),
                ),
                _buildInfoColumn(
                  '预计到达',
                  '${(_remainingDistance / 80).ceil()}分钟',
                  Icons.schedule_rounded,
                  AppColors.accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textHintAdaptive(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryAdaptive(context),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigatingCard() {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: AppSecondaryButton(
        onPressed: () => context.pop(),
        height: AppSize.buttonHeight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.close_rounded, size: 20),
            SizedBox(width: AppSpacing.sm),
            Text('结束导航'),
          ],
        ),
      ),
    );
  }

  Widget _buildArrivedCard() {
    final state = ref.watch(currentJourneyProvider);
    final point = state.currentPoint;

    return AnimatedBuilder(
      animation: _arrivedController,
      builder: (context, child) => Transform.scale(
        scale: _arrivedScaleAnimation.value,
        child: Opacity(
          opacity: _arrivedFadeAnimation.value,
          child: child,
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
        ),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accent.withValues(alpha: 0.15),
              AppColors.sealGold.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, Color(0xFFE85A4F)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '🎉 你已到达探索点！',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryAdaptive(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              point?.name ?? '',
              style: TextStyle(
                color: AppColors.textSecondaryAdaptive(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.cardPadding),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppSize.buttonHeightSmall,
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondaryAdaptive(context),
                        side: BorderSide(color: AppColors.borderAdaptive(context)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('稍后再来'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: AppSize.buttonHeightSmall,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/ar-task/${widget.pointId}'),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '开始任务',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 地图网格绘制
class _MapGridPainter extends CustomPainter {
  final bool isDark;

  _MapGridPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? AppColors.darkBorder : AppColors.divider).withValues(alpha: 0.25)
      ..strokeWidth = 0.5;

    const spacing = 25.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) => oldDelegate.isDark != isDark;
}

/// 导航路线绘制
class _NavigationRoutePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _NavigationRoutePainter({required this.progress, this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final pendingPaint = Paint()
      ..color = (isDark ? AppColors.darkTextHint : AppColors.textHint).withValues(alpha: 0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final completedPaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 绘制路线（简单的曲线）
    final path = Path();
    path.moveTo(70, 90);
    path.quadraticBezierTo(size.width * 0.4, 120, size.width * 0.6, 85);
    path.quadraticBezierTo(size.width * 0.8, 60, size.width - 58, 88);

    // 绘制待完成路线
    canvas.drawPath(path, pendingPaint);

    // 绘制已完成路线
    final pathMetrics = path.computeMetrics().first;
    final completedPath = pathMetrics.extractPath(0, pathMetrics.length * progress);
    canvas.drawPath(completedPath, completedPaint);
  }

  @override
  bool shouldRepaint(covariant _NavigationRoutePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
