import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/journey_providers.dart';

/// 任务完成页
class TaskCompletePage extends ConsumerWidget {
  final String pointId;
  final String? photoPath;
  const TaskCompletePage({super.key, required this.pointId, this.photoPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(currentJourneyProvider);
    final point = state.currentPoint;
    final hasNext = state.hasNextPoint;
    final journeyId = state.detail?.id;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                '恭喜！',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                '任务完成！',
                style: TextStyle(fontSize: 20, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              _buildPhotoCard(),
              const SizedBox(height: 16),
              Text(
                '${point?.name ?? "探索点"} 探索成功',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              _buildRewardCard(point?.pointsReward ?? 50),
              const SizedBox(height: 24),
              if (point?.culturalKnowledge != null)
                _buildKnowledgeCard(point!.culturalKnowledge!),
              const Spacer(),
              _buildButtons(context, ref, hasNext, journeyId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: const Center(
        child: Icon(Icons.photo, size: 64, color: AppColors.textHint),
      ),
    );
  }

  Widget _buildRewardCard(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.sealGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: AppColors.sealGold),
          const SizedBox(width: 8),
          Text(
            '+$points 积分',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.sealGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeCard(String knowledge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_stories, size: 16, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                '文化小知识',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            knowledge,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(
    BuildContext context,
    WidgetRef ref,
    bool hasNext,
    String? journeyId,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('分享功能开发中'))),
            child: const Text('分享'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (hasNext) {
                ref.read(currentJourneyProvider.notifier).nextPoint();
                context.go('/journey/$journeyId/progress');
              } else {
                context.go('/journey/$journeyId/complete');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: Text(hasNext ? '继续下一个' : '完成之旅'),
          ),
        ),
      ],
    );
  }
}
