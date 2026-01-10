import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../providers/journey_providers.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/simple_share_sheet.dart';
import '../../../services/share_service.dart';

/// 文化之旅完成页 - Aurora UI + Glassmorphism + 粒子庆祝效果
class JourneyCompletePage extends ConsumerStatefulWidget {
  final String journeyId;
  const JourneyCompletePage({super.key, required this.journeyId});

  @override
  ConsumerState<JourneyCompletePage> createState() =>
      _JourneyCompletePageState();
}

class _JourneyCompletePageState extends ConsumerState<JourneyCompletePage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0)),
    );

    // 粒子动画控制器
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // 生成粒子
    _generateParticles();

    _controller.forward();
    _confettiController.forward();
  }

  void _generateParticles() {
    final colors = [
      AppColors.sealGold,
      AppColors.accent,
      AppColors.tertiary,
      AppColors.primary,
      Colors.orange,
      Colors.pink,
    ];

    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.3,
        size: _random.nextDouble() * 8 + 4,
        color: colors[_random.nextInt(colors.length)],
        speed: _random.nextDouble() * 0.4 + 0.3,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
        wobble: _random.nextDouble() * 0.1,
        wobbleSpeed: _random.nextDouble() * 4 + 2,
        shape: _random.nextInt(3), // 0: 圆形, 1: 方形, 2: 星形
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentJourneyProvider);
    final detail = state.detail;

    return Scaffold(
      body: Stack(
        children: [
          const AuroraBackground(variant: AuroraVariant.celebration),
          // 粒子效果层
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                ),
                size: Size.infinite,
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: AppSpacing.cardPadding),
                          _buildCelebrationIcon(),
                          const SizedBox(height: AppSpacing.cardPadding),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              '恭喜完成文化之旅！',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryAdaptive(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildSealCard(detail?.name ?? '文化之旅'),
                          ),
                          const SizedBox(height: AppSpacing.cardPadding),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildRewardCard(),
                          ),
                          const SizedBox(height: AppSpacing.cardPadding),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildChainCard(context),
                          ),
                          const SizedBox(height: AppSpacing.cardPadding),
                        ],
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildButtons(context, ref),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationIcon() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SvgPicture.asset(
        'assets/illustrations/journey_complete.svg',
        width: 180,
        height: 135,
      ),
    );
  }

  Widget _buildSealCard(String name) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.sealGold.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 48,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryAdaptive(context),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '完成时间：${DateTime.now().toString().substring(0, 16)}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHintAdaptive(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.sealGold.withValues(alpha: 0.15),
            AppColors.sealGold.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.sealGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.sealGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: AppColors.sealGold,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '收集奖励',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimaryAdaptive(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '+500 积分  +1 路线印记',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryAdaptive(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChainCard(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: AppOpacity.glassCard),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.5),
        ),
        boxShadow: AppShadow.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.link_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '上链存证',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimaryAdaptive(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '将此印记永久记录到区块链，收集不可篡改的完成证明',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryAdaptive(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: AppSize.buttonHeightSmall,
            child: OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('上链功能开发中'))),
              icon: const Icon(Icons.rocket_launch_rounded, size: 18),
              label: const Text(
                '立即上链',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: AppSecondaryButton(
            onPressed: () => SimpleShareSheet.show(
              context,
              title: '分享印记',
              subtitle: '完成文化之旅',
              shareLink: ShareService.generateSealShareLink(widget.journeyId),
            ),
            height: AppSize.buttonHeightSmall,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share_rounded, size: 18),
                SizedBox(width: 6),
                Text('分享印记'),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppPrimaryButton(
            onPressed: () {
              ref.read(currentJourneyProvider.notifier).clear();
              context.go('/');
            },
            height: AppSize.buttonHeightSmall,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_rounded, size: 18),
                SizedBox(width: 6),
                Text('返回首页'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 粒子数据类
class _ConfettiParticle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;
  final double rotation;
  final double rotationSpeed;
  final double wobble;
  final double wobbleSpeed;
  final int shape;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.wobble,
    required this.wobbleSpeed,
    required this.shape,
  });
}

/// 粒子绘制器
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final currentY = particle.y + progress * particle.speed * 1.5;
      if (currentY > 1.2) continue;

      final wobbleOffset = math.sin(progress * particle.wobbleSpeed * math.pi * 2) * particle.wobble;
      final currentX = particle.x + wobbleOffset;
      final currentRotation = particle.rotation + progress * particle.rotationSpeed * math.pi * 4;

      // 淡出效果
      final opacity = progress > 0.7 ? (1 - progress) / 0.3 : 1.0;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity * 0.8)
        ..style = PaintingStyle.fill;

      final x = currentX * size.width;
      final y = currentY * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentRotation);

      switch (particle.shape) {
        case 0: // 圆形
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case 1: // 方形
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size * 0.6,
            ),
            paint,
          );
          break;
        case 2: // 星形
          _drawStar(canvas, particle.size / 2, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    const points = 5;
    const innerRadius = 0.4;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * innerRadius;
      final angle = (i * math.pi / points) - math.pi / 2;
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
