import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/journey_providers.dart';
import '../../../models/journey.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/app_loading.dart';

/// 我的旅程页面 - Aurora UI + Glassmorphism
class MyJourneysPage extends ConsumerWidget {
  const MyJourneysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeysAsync = ref.watch(allUserJourneysProvider);

    return Scaffold(
      body: Stack(
        children: [
          const AuroraBackground(variant: AuroraVariant.standard),
          SafeArea(
            child: Column(
              children: [
                const AppPageHeader(title: '我的旅程'),
                Expanded(
                  child: journeysAsync.when(
                    data: (journeys) => journeys.isEmpty
                        ? _buildEmpty(context)
                        : _buildList(context, journeys),
                    loading: () => const AppLoading(message: '加载中...'),
                    error: (e, _) => _buildError(e.toString()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/'),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/illustrations/empty_journey.svg',
                width: 180,
                height: 135,
              ),
              const SizedBox(height: 20),
              const Text(
                '还没有开始任何旅程',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '去探索城市，开启你的文化之旅吧',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '发现城市',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
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
              '加载失败: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<JourneyProgress> journeys) {
    // 分组：进行中 + 已完成
    final inProgress = journeys.where((j) => j.isInProgress).toList();
    final completed = journeys.where((j) => j.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (inProgress.isNotEmpty) ...[
          SectionTitleWithBadge(
            title: '进行中',
            count: inProgress.length,
            color: AppColors.accent,
          ),
          const SizedBox(height: 14),
          ...inProgress.map((j) => _JourneyCard(journey: j)),
          const SizedBox(height: 24),
        ],
        if (completed.isNotEmpty) ...[
          SectionTitleWithBadge(
            title: '已完成',
            count: completed.length,
            color: AppColors.success,
          ),
          const SizedBox(height: 14),
          ...completed.map((j) => _JourneyCard(journey: j)),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

class _JourneyCard extends StatelessWidget {
  final JourneyProgress journey;
  const _JourneyCard({required this.journey});

  @override
  Widget build(BuildContext context) {
    final progress = journey.progressPercent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (journey.isInProgress) {
              context.push('/journey/${journey.journeyId}/progress');
            } else {
              context.push('/journey/${journey.journeyId}');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: journey.isCompleted
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        journey.isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.play_circle_rounded,
                        color: journey.isCompleted
                            ? AppColors.success
                            : AppColors.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            journey.journeyName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(journey),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHint.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.divider.withValues(
                            alpha: 0.3,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            journey.isCompleted
                                ? AppColors.success
                                : AppColors.accent,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${journey.completedPoints}/${journey.totalPoints}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: journey.isCompleted
                            ? AppColors.success
                            : AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(JourneyProgress journey) {
    if (journey.isCompleted && journey.completeTime != null) {
      return '完成于 ${_formatDate(journey.completeTime!)}';
    }
    return '开始于 ${_formatDate(journey.startTime)}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}
