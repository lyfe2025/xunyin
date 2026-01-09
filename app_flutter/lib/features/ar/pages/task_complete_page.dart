import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/journey_providers.dart';
import '../../../shared/widgets/simple_share_sheet.dart';
import '../../../services/share_service.dart';

/// 任务完成页 - Aurora UI + Glassmorphism 风格
class TaskCompletePage extends ConsumerStatefulWidget {
  final String pointId;
  final String? photoPath;
  final int? pointsEarned;
  final int? totalPoints;
  final bool journeyCompleted;
  final String? sealId;

  const TaskCompletePage({
    super.key,
    required this.pointId,
    this.photoPath,
    this.pointsEarned,
    this.totalPoints,
    this.journeyCompleted = false,
    this.sealId,
  });

  @override
  ConsumerState<TaskCompletePage> createState() => _TaskCompletePageState();
}

class _TaskCompletePageState extends ConsumerState<TaskCompletePage>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _floatController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    // 庆祝动画
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    );
    _celebrationController.forward();

    // 浮动动画
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentJourneyProvider);
    final point = state.currentPoint;
    final hasNext = state.hasNextPoint && !widget.journeyCompleted;
    final journeyId = state.detail?.id;
    final earnedPoints = widget.pointsEarned ?? point?.pointsReward ?? 50;

    return Scaffold(
      body: Stack(
        children: [
          // Aurora 渐变背景
          _buildAuroraBackground(),
          // 主内容
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildCelebrationHeader(),
                  const SizedBox(height: 32),
                  _buildPhotoCard(),
                  const SizedBox(height: 16),
                  _buildPointName(point?.name ?? '探索点'),
                  const SizedBox(height: 24),
                  _buildRewardCard(earnedPoints),
                  if (widget.sealId != null) ...[
                    const SizedBox(height: 16),
                    _buildSealCard(),
                  ],
                  if (point?.culturalKnowledge != null) ...[
                    const SizedBox(height: 24),
                    _buildKnowledgeCard(point!.culturalKnowledge!),
                  ],
                  const SizedBox(height: 32),
                  _buildButtons(context, hasNext, journeyId),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Aurora 渐变背景
  Widget _buildAuroraBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F5F0), // 宣纸色
            Color(0xFFFDF2F8), // 淡粉
            Color(0xFFF0F9FF), // 淡蓝
            Color(0xFFF8F5F0), // 宣纸色
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: CustomPaint(painter: _AuroraPatternPainter(), size: Size.infinite),
    );
  }

  /// 庆祝头部
  Widget _buildCelebrationHeader() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: child,
          );
        },
        child: Column(
          children: [
            // 印章图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accent, AppColors.accentDark],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.verified_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.journeyCompleted ? '文化之旅完成！' : '探索成功！',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.journeyCompleted ? '恭喜你完成了整个文化之旅' : '恭喜你完成了这个探索点',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 照片卡片 - Glassmorphism 风格
  Widget _buildPhotoCard() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.8),
            Colors.white.withValues(alpha: 0.4),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: widget.photoPath != null
            ? Image.network(widget.photoPath!, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_rounded,
                    size: 48,
                    color: AppColors.textHint.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '探索记录',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textHint.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 探索点名称
  Widget _buildPointName(String name) {
    return Text(
      '$name 探索成功',
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// 奖励卡片 - Glassmorphism 风格
  Widget _buildRewardCard(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.sealGold.withValues(alpha: 0.15),
            AppColors.sealGold.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: AppColors.sealGold.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.sealGold.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.sealGold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: AppColors.sealGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '获得积分',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                '+$points',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.sealGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 印记卡片
  Widget _buildSealCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.12),
            AppColors.accent.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            '获得新印记！',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  /// 文化知识卡片 - Glassmorphism 风格
  Widget _buildKnowledgeCard(String knowledge) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 18,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '文化小知识',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            knowledge,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// 操作按钮
  Widget _buildButtons(BuildContext context, bool hasNext, String? journeyId) {
    return Row(
      children: [
        Expanded(
          child: _GlassButton(
            onPressed: () => SimpleShareSheet.show(
              context,
              title: '分享探索成果',
              shareLink: ShareService.generateSealShareLink(widget.pointId),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share_rounded, size: 18),
                SizedBox(width: 6),
                Text('分享'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _PrimaryButton(
            onPressed: () {
              if (hasNext) {
                ref.read(currentJourneyProvider.notifier).nextPoint();
                context.go('/journey/$journeyId/progress');
              } else {
                context.go('/journey/$journeyId/complete');
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(hasNext ? '继续下一个' : '完成之旅'),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Aurora 背景图案绘制
class _AuroraPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 绘制柔和的圆形光晕
    paint.color = AppColors.accent.withValues(alpha: 0.03);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.4,
      paint,
    );

    paint.color = AppColors.tertiary.withValues(alpha: 0.04);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.7),
      size.width * 0.35,
      paint,
    );

    paint.color = AppColors.sealGold.withValues(alpha: 0.02);
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.5),
      size.width * 0.3,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 玻璃态按钮
class _GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _GlassButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.8),
                Colors.white.withValues(alpha: 0.5),
              ],
            ),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            child: IconTheme(
              data: const IconThemeData(color: AppColors.textPrimary),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 主要操作按钮
class _PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _PrimaryButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accent, AppColors.accentDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
