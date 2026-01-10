import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/seal.dart';
import '../../../providers/seal_providers.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_page_header.dart';

/// 印记集页面 - 优化版本
/// 1. 环形总进度展示
/// 2. 已解锁印记显示图片和获取时间
/// 3. 未解锁印记显示模糊轮廓
/// 4. 稀有度标识（根据类型推断）
/// 5. 可折叠分组
/// 6. 点击未解锁印记显示获取提示
class SealListPage extends ConsumerStatefulWidget {
  const SealListPage({super.key});

  @override
  ConsumerState<SealListPage> createState() => _SealListPageState();
}

class _SealListPageState extends ConsumerState<SealListPage> {
  // 分组折叠状态
  final Map<SealType, bool> _expandedSections = {
    SealType.route: true,
    SealType.city: true,
    SealType.special: true,
  };

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    ref.invalidate(sealProgressProvider);
    ref.invalidate(allSealsProvider);
    await Future.wait([
      ref.read(sealProgressProvider.future),
      ref.read(allSealsProvider.future),
    ]);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(sealProgressProvider);
    final sealsAsync = ref.watch(allSealsProvider);
    final selectedType = ref.watch(selectedSealTypeProvider);

    return Scaffold(
      body: Stack(
        children: [
          const AuroraBackground(variant: AuroraVariant.golden),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppColors.accent,
                    backgroundColor: AppColors.cardBackground(context),
                    child: _buildContent(
                      context,
                      progressAsync,
                      sealsAsync,
                      selectedType,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppPageHeader(
      title: '我的印记集',
      trailing: AppHeaderAction(
        icon: Icons.filter_list_rounded,
        onTap: () => _showFilterSheet(context),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AsyncValue<SealProgress> progressAsync,
    AsyncValue<List<SealDetail>> sealsAsync,
    SealType? selectedType,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        // 环形进度卡片
        progressAsync.when(
          data: (progress) => _CircularProgressCard(progress: progress),
          loading: () => _buildSkeletonCard(180),
          error: (e, _) => _ErrorCard(
            message: '加载进度失败',
            onRetry: () => ref.invalidate(sealProgressProvider),
          ),
        ),
        const SizedBox(height: 24),
        // 印记列表（按类型分组，可折叠）
        sealsAsync.when(
          data: (seals) => _buildSealSections(context, seals, selectedType),
          loading: () => _buildLoadingSections(),
          error: (e, _) => _ErrorCard(
            message: '加载印记失败',
            onRetry: () => ref.invalidate(allSealsProvider),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSealSections(
    BuildContext context,
    List<SealDetail> seals,
    SealType? selectedType,
  ) {
    final types = selectedType != null ? [selectedType] : SealType.values;

    return Column(
      children: [
        for (final type in types) ...[
          _CollapsibleSealSection(
            type: type,
            seals: seals.where((s) => s.type == type).toList(),
            isExpanded: _expandedSections[type] ?? true,
            onToggle: () {
              HapticFeedback.lightImpact();
              setState(() {
                _expandedSections[type] = !(_expandedSections[type] ?? true);
              });
            },
          ),
          if (type != types.last) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildLoadingSections() {
    return Column(
      children: [
        for (final type in SealType.values) ...[
          _buildSkeletonSection(type),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSkeletonCard(double height) {
    return _ShimmerBox(height: height, borderRadius: 20);
  }

  Widget _buildSkeletonSection(SealType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(type: type, count: 0, total: 0, isExpanded: true, onToggle: () {}),
        const SizedBox(height: 12),
        _ShimmerBox(height: 120, borderRadius: 16),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FilterSheet(ref: ref),
    );
  }
}


// ==================== 环形进度卡片（带动画和渐变） ====================

class _CircularProgressCard extends StatefulWidget {
  final SealProgress progress;
  const _CircularProgressCard({required this.progress});

  @override
  State<_CircularProgressCard> createState() => _CircularProgressCardState();
}

class _CircularProgressCardState extends State<_CircularProgressCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<int> _countAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final targetProgress = widget.progress.total > 0
        ? widget.progress.collected / widget.progress.total
        : 0.0;

    _progressAnimation = Tween<double>(begin: 0, end: targetProgress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _countAnimation = IntTween(begin: 0, end: widget.progress.collected).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // 光晕呼吸动画
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _CircularProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress.collected != widget.progress.collected) {
      final targetProgress = widget.progress.total > 0
          ? widget.progress.collected / widget.progress.total
          : 0.0;

      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: targetProgress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

      _countAnimation = IntTween(
        begin: _countAnimation.value,
        end: widget.progress.collected,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkSurface.withValues(alpha: 0.95),
                  AppColors.darkSurface.withValues(alpha: 0.85),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // 环形进度（带渐变和光晕）
          SizedBox(
            width: 100,
            height: 100,
            child: AnimatedBuilder(
              animation: Listenable.merge([_controller, _glowController]),
              builder: (context, child) => Stack(
                alignment: Alignment.center,
                children: [
                  // 光晕效果
                  if (_progressAnimation.value > 0)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: _glowAnimation.value * 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  // 背景圆环
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 10,
                      backgroundColor: AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.4),
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  // 渐变进度圆环
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CustomPaint(
                      painter: _GradientCircularProgressPainter(
                        progress: _progressAnimation.value,
                        strokeWidth: 10,
                        gradient: const SweepGradient(
                          startAngle: -1.5708,
                          endAngle: 4.7124,
                          colors: [
                            Color(0xFFFF6B6B),
                            AppColors.accent,
                            Color(0xFFE6B422),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 中心文字
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_countAnimation.value}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                      Text(
                        '/ ${widget.progress.total}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textHintAdaptive(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          // 分类进度
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '收集进度',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryAdaptive(context),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final percentage = widget.progress.total > 0
                        ? (_countAnimation.value / widget.progress.total * 100).toInt()
                        : 0;
                    return Text(
                      '已收集 $percentage%',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHintAdaptive(context),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // 分类小进度条
                for (final tp in widget.progress.byType) ...[
                  _MiniProgressBar(typeProgress: tp),
                  if (tp != widget.progress.byType.last) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 渐变圆环进度绘制器
class _GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Gradient gradient;

  _GradientCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // 从顶部开始 (-90度)
      progress * 2 * 3.14159,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _MiniProgressBar extends StatelessWidget {
  final SealTypeProgress typeProgress;
  const _MiniProgressBar({required this.typeProgress});

  Color get _color {
    switch (typeProgress.type) {
      case SealType.route:
        return AppColors.primary;
      case SealType.city:
        return AppColors.tertiary;
      case SealType.special:
        return AppColors.sealGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            typeProgress.type.label.replaceAll('印记', ''),
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondaryAdaptive(context),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.5)
                  : AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: typeProgress.percentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${typeProgress.collected}/${typeProgress.total}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textHintAdaptive(context),
          ),
        ),
      ],
    );
  }
}


// ==================== 错误卡片 ====================

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: AppColors.textHintAdaptive(context).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondaryAdaptive(context)),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onRetry();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 16, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    '点击重试',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 可折叠印记分组 ====================

class _SectionHeader extends StatelessWidget {
  final SealType type;
  final int count;
  final int total;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _SectionHeader({
    required this.type,
    required this.count,
    required this.total,
    required this.isExpanded,
    required this.onToggle,
  });

  IconData get _icon {
    switch (type) {
      case SealType.route:
        return Icons.route_rounded;
      case SealType.city:
        return Icons.location_city_rounded;
      case SealType.special:
        return Icons.star_rounded;
    }
  }

  Color get _color {
    switch (type) {
      case SealType.route:
        return AppColors.primary;
      case SealType.city:
        return AppColors.tertiary;
      case SealType.special:
        return AppColors.sealGold;
    }
  }

  String get _rarityLabel {
    switch (type) {
      case SealType.route:
        return '普通';
      case SealType.city:
        return '稀有';
      case SealType.special:
        return '传说';
    }
  }

  Color get _rarityBgColor {
    switch (type) {
      case SealType.route:
        return _color.withValues(alpha: 0.1);
      case SealType.city:
        return const Color(0xFF9C27B0).withValues(alpha: 0.1); // 紫色
      case SealType.special:
        return AppColors.sealGold.withValues(alpha: 0.15);
    }
  }

  Color get _rarityTextColor {
    switch (type) {
      case SealType.route:
        return _color;
      case SealType.city:
        return const Color(0xFF9C27B0); // 紫色
      case SealType.special:
        return AppColors.sealGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(_icon, size: 18, color: _color),
          const SizedBox(width: 6),
          Text(
            type.label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryAdaptive(context),
            ),
          ),
          const SizedBox(width: 8),
          // 稀有度标签 - 更突出的样式
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _rarityBgColor,
              borderRadius: BorderRadius.circular(10),
              border: type == SealType.special
                  ? Border.all(color: AppColors.sealGold.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (type == SealType.special) ...[
                  Icon(Icons.auto_awesome, size: 10, color: _rarityTextColor),
                  const SizedBox(width: 3),
                ],
                Text(
                  _rarityLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _rarityTextColor,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // 收集数量
          Text(
            '$count/$total',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textHintAdaptive(context),
            ),
          ),
          const SizedBox(width: 8),
          // 折叠箭头
          AnimatedRotation(
            turns: isExpanded ? 0 : -0.25,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.textHintAdaptive(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsibleSealSection extends StatelessWidget {
  final SealType type;
  final List<SealDetail> seals;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _CollapsibleSealSection({
    required this.type,
    required this.seals,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final ownedCount = seals.where((s) => s.owned).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          type: type,
          count: ownedCount,
          total: seals.length,
          isExpanded: isExpanded,
          onToggle: onToggle,
        ),
        AnimatedCrossFade(
          firstChild: Column(
            children: [
              const SizedBox(height: 12),
              seals.isEmpty
                  ? _EmptySection(type: type)
                  : _SealGrid(seals: seals, type: type),
            ],
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  final SealType type;
  const _EmptySection({required this.type});

  String get _hint {
    switch (type) {
      case SealType.route:
        return '完成文化之旅即可获得路线印记';
      case SealType.city:
        return '解锁城市所有旅程即可获得城市印记';
      case SealType.special:
        return '完成特殊成就即可获得特殊印记';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderAdaptive(context).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/illustrations/empty_seal.svg',
            width: 120,
            height: 90,
          ),
          const SizedBox(height: 12),
          Text(
            '暂无${type.label}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryAdaptive(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _hint,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHintAdaptive(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


// ==================== 印记网格 ====================

class _SealGrid extends StatelessWidget {
  final List<SealDetail> seals;
  final SealType type;
  const _SealGrid({required this.seals, required this.type});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: seals.length,
      itemBuilder: (ctx, i) => _SealCard(seal: seals[i]),
    );
  }
}

// ==================== 印记卡片（优化版） ====================

class _SealCard extends StatefulWidget {
  final SealDetail seal;
  const _SealCard({required this.seal});

  @override
  State<_SealCard> createState() => _SealCardState();
}

class _SealCardState extends State<_SealCard> with TickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );

    // 已获得印记的微光动画
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    if (widget.seal.owned) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _tapController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  String _formatEarnedTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      return '今天获得';
    } else if (diff.inDays == 1) {
      return '昨天获得';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前获得';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}周前获得';
    } else {
      return '${time.month}月${time.day}日获得';
    }
  }

  void _showUnlockHint(BuildContext context) {
    HapticFeedback.lightImpact();
    final seal = widget.seal;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UnlockHintSheet(seal: seal),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seal = widget.seal;
    final isLocked = !seal.owned;
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTapDown: (_) => _tapController.forward(),
      onTapUp: (_) {
        _tapController.reverse();
        HapticFeedback.lightImpact();
        if (isLocked) {
          _showUnlockHint(context);
        } else {
          context.push('/seal/${seal.id}');
        }
      },
      onTapCancel: () => _tapController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
        builder: (context, child) {
          final glowValue = _glowAnimation.value;

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: isLocked
                    ? (isDark
                        ? AppColors.darkSurfaceVariant.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.6))
                    : AppColors.cardBackground(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLocked
                      ? AppColors.borderAdaptive(context).withValues(alpha: 0.3)
                      : AppColors.sealGold.withValues(alpha: 0.5 + glowValue * 0.3),
                  width: isLocked ? 1 : 2,
                ),
                boxShadow: isLocked
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.sealGold.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 印记图片/图标
            _buildSealImage(context, seal, isLocked),
            const SizedBox(height: 8),
            // 印记名称
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                seal.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isLocked ? FontWeight.w400 : FontWeight.w600,
                  color: isLocked
                      ? AppColors.textHintAdaptive(context)
                      : AppColors.textPrimaryAdaptive(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 获取时间 / 上链标识
            if (!isLocked) ...[
              const SizedBox(height: 4),
              _buildSealMeta(context, seal),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSealImage(BuildContext context, SealDetail seal, bool isLocked) {
    final hasImage = seal.imageAsset.isNotEmpty &&
        !seal.imageAsset.contains('placeholder');

    if (isLocked) {
      // 未解锁：简洁锁图标
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.lock_outline_rounded,
          size: 22,
          color: AppColors.textHintAdaptive(context).withValues(alpha: 0.5),
        ),
      );
    }

    // 已解锁：显示图标，带金色光晕
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            AppColors.sealGold.withValues(alpha: 0.15),
            AppColors.sealGold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.sealGold.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: seal.imageAsset,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildMedalIcon(),
                errorWidget: (_, __, ___) => _buildMedalIcon(),
              ),
            )
          : _buildMedalIcon(),
    );
  }

  /// 勋章图标
  Widget _buildMedalIcon() {
    return Icon(
      Icons.workspace_premium_rounded,
      size: 28,
      color: AppColors.sealGold,
    );
  }

  Widget _buildSealMeta(BuildContext context, SealDetail seal) {
    if (seal.isChained == true) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.sealGold.withValues(alpha: 0.2),
              AppColors.sealGold.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_rounded, size: 10, color: AppColors.sealGold),
            SizedBox(width: 2),
            Text(
              '已上链',
              style: TextStyle(
                fontSize: 9,
                color: AppColors.sealGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (seal.earnedTime != null) {
      return Text(
        _formatEarnedTime(seal.earnedTime!),
        style: TextStyle(
          fontSize: 9,
          color: AppColors.textHintAdaptive(context),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
// ==================== 解锁提示弹窗 ====================

class _UnlockHintSheet extends StatelessWidget {
  final SealDetail seal;
  const _UnlockHintSheet({required this.seal});

  Color get _rarityColor {
    switch (seal.rarity) {
      case SealRarity.common:
        return AppColors.sealGold; // 金色
      case SealRarity.rare:
        return const Color(0xFF9C27B0); // 紫色
      case SealRarity.legendary:
        return const Color(0xFFFF6B35); // 橙红色
    }
  }

  String get _rarityLabel => seal.rarity.label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示器
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderAdaptive(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // 印记图标 + 名称 + 稀有度（横向布局更紧凑）
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _rarityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      size: 32,
                      color: _rarityColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seal.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryAdaptive(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _rarityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_rarityLabel印记',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _rarityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 解锁条件（更紧凑）
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_open_rounded,
                      size: 16,
                      color: AppColors.textSecondaryAdaptive(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        seal.unlockCondition ?? _getDefaultUnlockHint(),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimaryAdaptive(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 关联信息
              if (seal.journeyName != null || seal.cityName != null) ...[
                const SizedBox(height: 12),
                _buildRelatedInfo(context),
              ],
              const SizedBox(height: 16),
              // 去探索按钮
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.mediumImpact();
                  if (seal.journeyId != null) {
                    context.push('/journey/${seal.journeyId}');
                  } else if (seal.cityId != null) {
                    context.push('/city/${seal.cityId}');
                  } else {
                    context.go('/explore');
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_rarityColor, _rarityColor.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.explore_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        '去探索',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDefaultUnlockHint() {
    switch (seal.type) {
      case SealType.route:
        return '完成对应的文化之旅即可解锁此印记';
      case SealType.city:
        return '完成该城市的所有文化之旅即可解锁此印记';
      case SealType.special:
        return '完成特定成就或活动即可解锁此传说印记';
    }
  }

  Widget _buildRelatedInfo(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        HapticFeedback.lightImpact();
        if (seal.journeyId != null) {
          context.push('/journey/${seal.journeyId}');
        } else if (seal.cityId != null) {
          context.push('/city/${seal.cityId}');
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              seal.journeyName != null ? Icons.route_rounded : Icons.location_city_rounded,
              size: 16,
              color: AppColors.textHintAdaptive(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                seal.journeyName ?? seal.cityName ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryAdaptive(context),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppColors.textHintAdaptive(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 筛选底部弹窗 ====================

class _FilterSheet extends StatelessWidget {
  final WidgetRef ref;
  const _FilterSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(selectedSealTypeProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderAdaptive(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    size: 20,
                    color: AppColors.textSecondaryAdaptive(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '筛选印记类型',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryAdaptive(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _FilterOption(
                    label: '全部印记',
                    icon: Icons.grid_view_rounded,
                    isSelected: selectedType == null,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(selectedSealTypeProvider.notifier).state = null;
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  for (final type in SealType.values) ...[
                    _FilterOption(
                      label: type.label,
                      icon: _getTypeIcon(type),
                      color: _getTypeColor(type),
                      isSelected: selectedType == type,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(selectedSealTypeProvider.notifier).state = type;
                        Navigator.pop(context);
                      },
                    ),
                    if (type != SealType.values.last) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(SealType type) {
    switch (type) {
      case SealType.route:
        return Icons.route_rounded;
      case SealType.city:
        return Icons.location_city_rounded;
      case SealType.special:
        return Icons.star_rounded;
    }
  }

  Color _getTypeColor(SealType type) {
    switch (type) {
      case SealType.route:
        return AppColors.primary;
      case SealType.city:
        return AppColors.tertiary;
      case SealType.special:
        return AppColors.sealGold;
    }
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textSecondaryAdaptive(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor.withValues(alpha: 0.1)
              : AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? effectiveColor.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? effectiveColor : AppColors.textHintAdaptive(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? effectiveColor : AppColors.textSecondaryAdaptive(context),
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, size: 20, color: effectiveColor),
          ],
        ),
      ),
    );
  }
}


// ==================== 闪烁骨架屏 ====================

class _ShimmerBox extends StatefulWidget {
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.height,
    required this.borderRadius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_animation.value - 0.3).clamp(0.0, 1.0),
              _animation.value.clamp(0.0, 1.0),
              (_animation.value + 0.3).clamp(0.0, 1.0),
            ],
            colors: [
              Colors.white.withValues(alpha: 0.5),
              Colors.white.withValues(alpha: 0.8),
              Colors.white.withValues(alpha: 0.5),
            ],
          ),
        ),
      ),
    );
  }
}
