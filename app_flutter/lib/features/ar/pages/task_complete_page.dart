import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../providers/journey_providers.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_glass_card.dart';
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
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    );
    _celebrationController.forward();

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
          const AuroraBackground(variant: AuroraVariant.celebration),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xxxl),
                  _buildCelebrationHeader(),
                  const SizedBox(height: AppSpacing.xxxl),
                  _buildPhotoCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPointName(point?.name ?? '探索点'),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildRewardCard(earnedPoints),
                  if (widget.sealId != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildSealCard(),
                  ],
                  if (point?.culturalKnowledge != null) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    _buildKnowledgeCard(point!.culturalKnowledge!),
                  ],
                  const SizedBox(height: AppSpacing.xxxl),
                  _buildButtons(context, hasNext, journeyId),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                boxShadow: AppShadow.accent(AppColors.accent),
              ),
              child: const Icon(
                Icons.verified_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              widget.journeyCompleted ? '文化之旅完成！' : '探索成功！',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryAdaptive(context),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.journeyCompleted ? '恭喜你完成了整个文化之旅' : '恭喜你完成了这个探索点',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondaryAdaptive(context).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard() {
    return AppGlassCard(
      width: 200,
      height: 200,
      borderRadius: AppRadius.cardLarge,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        child: widget.photoPath != null
            ? Image.network(widget.photoPath!, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_rounded,
                    size: 48,
                    color: AppColors.textHintAdaptive(context).withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '探索记录',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textHintAdaptive(context).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPointName(String name) {
    return Text(
      '$name 探索成功',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryAdaptive(context),
      ),
    );
  }

  Widget _buildRewardCard(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl + 4,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
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
            padding: const EdgeInsets.all(AppSpacing.sm),
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
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '获得积分',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryAdaptive(context),
                ),
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

  Widget _buildSealCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.md + 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
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

  Widget _buildKnowledgeCard(String knowledge) {
    return AppSimpleGlassCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.tag),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 18,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '文化小知识',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimaryAdaptive(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md + 2),
          Text(
            knowledge,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryAdaptive(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, bool hasNext, String? journeyId) {
    return Row(
      children: [
        Expanded(
          child: AppGlassButton(
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
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: AppPrimaryButton(
            height: AppSize.buttonHeightSmall,
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
