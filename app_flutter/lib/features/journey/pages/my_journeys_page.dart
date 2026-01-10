import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/journey_providers.dart';
import '../../../models/journey.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/app_loading.dart';
import '../widgets/journey_card.dart';
import '../widgets/empty_journey_section.dart';

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
                        : _buildList(context, ref, journeys),
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
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: () => context.go('/'),
      child: Align(
        alignment: const Alignment(0, -0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.88)
                  : Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/illustrations/empty_journey.svg',
                  width: 220,
                  height: 165,
                ),
                const SizedBox(height: 24),
              Text(
                '还没有开始任何旅程',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryAdaptive(context),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '去探索城市，开启你的文化之旅吧',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textHintAdaptive(context),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentDark],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '发现城市',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
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
      ),
    );
  }

  Widget _buildError(String error) {
    return Builder(
      builder: (context) {
        final isDark = context.isDarkMode;
        return Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.88)
                  : Colors.white.withValues(alpha: 0.88),
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
                  style: TextStyle(color: AppColors.textSecondaryAdaptive(context)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<JourneyProgress> journeys,
  ) {
    // 分组：进行中（未完成的，即使 4/4 也要检查 status）+ 已完成
    final inProgress = journeys.where((j) => j.isInProgress).toList();
    final completed = journeys.where((j) => j.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // 进行中分组
        _SectionHeader(
          title: '进行中',
          count: inProgress.length,
          color: AppColors.accent,
        ),
        const SizedBox(height: 14),
        if (inProgress.isEmpty)
          EmptyJourneySection.inProgress()
        else
          ...inProgress.map(
            (j) => JourneyCard(
              journey: j,
              onDismissed: () {
                // TODO: 调用归档 API
                ref.invalidate(allUserJourneysProvider);
              },
            ),
          ),

        // 分组间距
        const SizedBox(height: 28),

        // 已完成分组
        _SectionHeader(
          title: '已完成',
          count: completed.length,
          color: AppColors.success,
        ),
        const SizedBox(height: 14),
        if (completed.isEmpty)
          EmptyJourneySection.completed()
        else
          ...completed.map(
            (j) => JourneyCard(
              journey: j,
              enableDismiss: false, // 已完成的不支持滑动删除
            ),
          ),

        const SizedBox(height: 32),
      ],
    );
  }
}

/// 分组标题组件 - 优化间距和视觉层次
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
