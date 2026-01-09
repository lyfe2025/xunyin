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
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      statsAsync.when(
                        data: (stats) => _buildStatsCard(
                          stats.totalPhotos,
                          stats.journeyCount,
                        ),
                        loading: () => const AppLoadingCard(height: 80),
                        error: (e, _) => _buildStatsCard(0, 0),
                      ),
                      const SizedBox(height: 24),
                      // 优化2: 只有在有照片时才显示分类标题
                      if (hasPhotos) ...[
                        const SectionTitle(
                          title: '按文化之旅分类',
                        ),
                        const SizedBox(height: 14),
                      ],
                      journeyPhotosAsync.when(
                        data: (journeyPhotos) => journeyPhotos.isEmpty
                            ? _buildEmptyState(context, null)
                            : Column(
                                children: journeyPhotos
                                    .map(
                                      (jp) => _JourneyPhotoCard(
                                        journeyName: jp.journeyName,
                                        photoCount: jp.photoCount,
                                        photos: jp.photos
                                            .take(3)
                                            .map(
                                              (p) =>
                                                  p.thumbnailUrl ?? p.imageUrl,
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

  // 优化5&6: 改进统计卡片文案和信息展示
  Widget _buildStatsCard(int totalPhotos, int journeyCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.accent.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.photo_library_rounded,
              color: AppColors.primary,
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
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '张照片',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 优化5: 改进文案表述
                Text(
                  '已参与 $journeyCount 条文化之旅',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 优化1&4&7: 改进空状态设计，使用品牌插画
  Widget _buildEmptyState(BuildContext context, String? error) {
    final needLogin =
        error != null && (error.contains('请先登录') || error.contains('20001'));

    return GestureDetector(
      // 优化4: 空状态区域可点击，跳转到文化之旅列表
      onTap: needLogin ? null : () => context.push('/journeys'),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 优化7: 使用品牌插画替代图标
              if (needLogin)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                )
              else
                SvgPicture.asset(
                  'assets/illustrations/empty_album.svg',
                  width: 180,
                  height: 135,
                ),
              const SizedBox(height: 20),
              // 优化1: 添加引导性文案
              Text(
                needLogin ? '请先登录' : '还没有照片',
                style: TextStyle(
                  color: needLogin ? AppColors.textHint : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!needLogin) ...[
                const SizedBox(height: 8),
                const Text(
                  '去完成文化之旅，收集你的第一张照片吧',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // 优化1: 添加行动按钮
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
                        '探索文化之旅',
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
            ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHint,
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
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      child: i < photos.length
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.network(
                                photos[i],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.photo_rounded,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.photo_rounded,
                                color: AppColors.textHint,
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
