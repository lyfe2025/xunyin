import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/photo_providers.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/app_loading.dart';

/// 相册页面 - Aurora UI + Glassmorphism
class AlbumPage extends ConsumerWidget {
  const AlbumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(photoStatsProvider);
    final journeyPhotosAsync = ref.watch(photosByJourneyProvider);

    // 获取照片总数，用于控制筛选按钮显示
    final totalPhotos = statsAsync.valueOrNull?.totalPhotos ?? 0;
    final hasPhotos = totalPhotos > 0;

    return Scaffold(
      body: Stack(
        children: [
          const AuroraBackground(variant: AuroraVariant.standard),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, hasPhotos),
                Expanded(
                  child: hasPhotos
                      ? ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            statsAsync.when(
                              data: (stats) => _buildStatsCard(
                                context,
                                ref,
                                stats.totalPhotos,
                                stats.journeyCount,
                              ),
                              loading: () => const AppLoadingCard(height: 80),
                              error: (e, _) => _buildStatsCard(context, ref, 0, 0),
                            ),
                            const SizedBox(height: 24),
                            const SectionTitle(
                              title: '按文化之旅分类',
                            ),
                            const SizedBox(height: 14),
                            journeyPhotosAsync.when(
                              data: (journeyPhotos) => Column(
                                children: journeyPhotos
                                    .map(
                                      (jp) => _JourneyPhotoCard(
                                        journeyName: jp.journeyName,
                                        photoCount: jp.photoCount,
                                        photos: jp.photos
                                            .take(3)
                                            .map(
                                              (p) => p.thumbnailUrl ?? p.imageUrl,
                                            )
                                            .toList(),
                                        onTap: () {},
                                      ),
                                    )
                                    .toList(),
                              ),
                              loading: () => const AppLoading(message: '加载中...'),
                              error: (e, _) => _buildEmptyState(context, e.toString()),
                            ),
                            const SizedBox(height: 32),
                          ],
                        )
                      : journeyPhotosAsync.when(
                          data: (_) => _buildEmptyState(context, null),
                          loading: () => const AppLoading(message: '加载中...'),
                          error: (e, _) => _buildEmptyState(context, e.toString()),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 优化3: 筛选按钮在无照片时隐藏
  Widget _buildAppBar(BuildContext context, bool hasPhotos) {
    return AppPageHeader(
      title: '我的相册',
      trailing: hasPhotos
          ? AppHeaderAction(
              icon: Icons.filter_list_rounded,
              onTap: () {
                // TODO: 筛选功能
              },
            )
          : null,
    );
  }

  // 优化: 统计卡片可点击跳转到我的旅程
  Widget _buildStatsCard(
    BuildContext context,
    WidgetRef ref,
    int totalPhotos,
    int journeyCount,
  ) {
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: () => context.push('/my-journeys'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          children: [
            // 优化: 图标改用品牌红色
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: isDark ? 0.25 : 0.15),
                    AppColors.accentLight.withValues(alpha: isDark ? 0.2 : 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$totalPhotos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryAdaptive(context),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '张照片',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondaryAdaptive(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '来自 $journeyCount 条文化之旅',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textHintAdaptive(context),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.textHintAdaptive(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 空状态设计
  Widget _buildEmptyState(BuildContext context, String? error) {
    final needLogin =
        error != null && (error.contains('请先登录') || error.contains('20001'));
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: needLogin ? null : () => context.push('/journeys'),
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
                if (needLogin)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.textHintAdaptive(context).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 48,
                      color: AppColors.textHintAdaptive(context),
                    ),
                  )
                else
                  SvgPicture.asset(
                    'assets/illustrations/empty_album.svg',
                    width: 220,
                    height: 165,
                  ),
                const SizedBox(height: 24),
                Text(
                  needLogin ? '请先登录' : '还没有照片',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: needLogin
                        ? AppColors.textHintAdaptive(context)
                        : AppColors.textPrimaryAdaptive(context),
                  ),
                ),
                if (!needLogin) ...[
                  const SizedBox(height: 12),
                  Text(
                    '去完成文化之旅，收集你的第一张照片吧',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textHintAdaptive(context),
                    ),
                    textAlign: TextAlign.center,
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
                          '探索文化之旅',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JourneyPhotoCard extends StatelessWidget {
  final String journeyName;
  final int photoCount;
  final List<String> photos;
  final VoidCallback onTap;

  const _JourneyPhotoCard({
    required this.journeyName,
    required this.photoCount,
    required this.photos,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    journeyName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimaryAdaptive(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$photoCount张',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHintAdaptive(context),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (var i = 0; i < 3; i++)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                      height: 85,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariantAdaptive(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderAdaptive(context).withValues(alpha: 0.5),
                        ),
                      ),
                      child: i < photos.length
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.network(
                                photos[i],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Icon(
                                    Icons.photo_rounded,
                                    color: AppColors.textHintAdaptive(context),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.photo_rounded,
                                color: AppColors.textHintAdaptive(context),
                                size: 24,
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
