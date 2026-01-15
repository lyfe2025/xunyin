import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../models/photo.dart';
import '../../../providers/photo_providers.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/app_loading.dart';

/// 显示模式
enum AlbumViewMode { byJourney, timeline }

/// 排序方式
enum AlbumSortOrder { newest, oldest }

/// 相册筛选状态
final albumViewModeProvider = StateProvider<AlbumViewMode>(
  (ref) => AlbumViewMode.byJourney,
);

final albumSortOrderProvider = StateProvider<AlbumSortOrder>(
  (ref) => AlbumSortOrder.newest,
);

/// 相册页面 - Aurora UI + Glassmorphism
class AlbumPage extends ConsumerWidget {
  const AlbumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(photoStatsProvider);
    final journeyPhotosAsync = ref.watch(photosByJourneyProvider);
    final allPhotosAsync = ref.watch(photosProvider);
    final viewMode = ref.watch(albumViewModeProvider);
    final sortOrder = ref.watch(albumSortOrderProvider);

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
                _buildAppBar(context, ref, hasPhotos),
                Expanded(
                  child: hasPhotos
                      ? viewMode == AlbumViewMode.byJourney
                          ? _buildJourneyView(
                              context,
                              ref,
                              statsAsync,
                              journeyPhotosAsync,
                              sortOrder,
                            )
                          : _buildTimelineView(
                              context,
                              ref,
                              statsAsync,
                              allPhotosAsync,
                              sortOrder,
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

  Widget _buildAppBar(BuildContext context, WidgetRef ref, bool hasPhotos) {
    return AppPageHeader(
      title: '我的相册',
      trailing: hasPhotos
          ? AppHeaderAction(
              icon: Icons.filter_list_rounded,
              onTap: () => _showFilterSheet(context, ref),
            )
          : null,
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final viewMode = ref.watch(albumViewModeProvider);
          final sortOrder = ref.watch(albumSortOrderProvider);

          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 拖动条
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
                  // 标题
                  Text(
                    '筛选与排序',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryAdaptive(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 显示模式
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '显示模式',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondaryAdaptive(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _FilterChip(
                                label: '按旅程分组',
                                icon: Icons.folder_rounded,
                                isSelected: viewMode == AlbumViewMode.byJourney,
                                onTap: () => ref
                                    .read(albumViewModeProvider.notifier)
                                    .state = AlbumViewMode.byJourney,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _FilterChip(
                                label: '时间线',
                                icon: Icons.view_timeline_rounded,
                                isSelected: viewMode == AlbumViewMode.timeline,
                                onTap: () => ref
                                    .read(albumViewModeProvider.notifier)
                                    .state = AlbumViewMode.timeline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 排序方式
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '排序方式',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondaryAdaptive(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _FilterChip(
                                label: '最新优先',
                                icon: Icons.arrow_downward_rounded,
                                isSelected: sortOrder == AlbumSortOrder.newest,
                                onTap: () => ref
                                    .read(albumSortOrderProvider.notifier)
                                    .state = AlbumSortOrder.newest,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _FilterChip(
                                label: '最早优先',
                                icon: Icons.arrow_upward_rounded,
                                isSelected: sortOrder == AlbumSortOrder.oldest,
                                onTap: () => ref
                                    .read(albumSortOrderProvider.notifier)
                                    .state = AlbumSortOrder.oldest,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 完成按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '完成',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 按旅程分组视图
  Widget _buildJourneyView(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<PhotoStats> statsAsync,
    AsyncValue<List<JourneyPhotos>> journeyPhotosAsync,
    AlbumSortOrder sortOrder,
  ) {
    return ListView(
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
        const SectionTitle(title: '按文化之旅分类'),
        const SizedBox(height: 14),
        journeyPhotosAsync.when(
          data: (journeyPhotos) {
            // 根据排序方式排序
            final sorted = List<JourneyPhotos>.from(journeyPhotos);
            if (sortOrder == AlbumSortOrder.oldest) {
              sorted.sort((a, b) {
                final aTime = a.photos.isNotEmpty
                    ? a.photos.first.createdAt
                    : DateTime.now();
                final bTime = b.photos.isNotEmpty
                    ? b.photos.first.createdAt
                    : DateTime.now();
                return aTime.compareTo(bTime);
              });
            }
            return Column(
              children: sorted
                  .map(
                    (jp) => _JourneyPhotoCard(
                      journeyId: jp.journeyId,
                      journeyName: jp.journeyName,
                      photoCount: jp.photoCount,
                      photos: jp.photos
                          .take(3)
                          .map(
                            (p) => _PhotoItem(
                              id: p.id,
                              imageUrl: p.thumbnailUrl ?? p.imageUrl,
                            ),
                          )
                          .toList(),
                      onTap: () {},
                    ),
                  )
                  .toList(),
            );
          },
          loading: () => const AppLoading(message: '加载中...'),
          error: (e, _) => _buildEmptyState(context, e.toString()),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  /// 时间线视图
  Widget _buildTimelineView(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<PhotoStats> statsAsync,
    AsyncValue<List<Photo>> allPhotosAsync,
    AlbumSortOrder sortOrder,
  ) {
    return allPhotosAsync.when(
      data: (photos) {
        // 排序
        final sorted = List<Photo>.from(photos);
        sorted.sort((a, b) => sortOrder == AlbumSortOrder.newest
            ? b.createdAt.compareTo(a.createdAt)
            : a.createdAt.compareTo(b.createdAt));

        // 按日期分组
        final grouped = <String, List<Photo>>{};
        for (final photo in sorted) {
          final dateKey = _formatDateKey(photo.createdAt);
          grouped.putIfAbsent(dateKey, () => []).add(photo);
        }

        return ListView(
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
            const SectionTitle(title: '时间线'),
            const SizedBox(height: 14),
            ...grouped.entries.map(
              (entry) => _TimelineSection(
                dateLabel: entry.key,
                photos: entry.value,
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
      },
      loading: () => const Center(child: AppLoading(message: '加载中...')),
      error: (e, _) => _buildEmptyState(context, e.toString()),
    );
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final photoDate = DateTime(date.year, date.month, date.day);

    if (photoDate == today) {
      return '今天';
    } else if (photoDate == yesterday) {
      return '昨天';
    } else if (date.year == now.year) {
      return '${date.month}月${date.day}日';
    } else {
      return '${date.year}年${date.month}月${date.day}日';
    }
  }

  Widget _buildStatsCard(
    BuildContext context,
    WidgetRef ref,
    int totalPhotos,
    int journeyCount,
  ) {
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: () => context.push('/journeys'),
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
                      color: AppColors.textHintAdaptive(context)
                          .withValues(alpha: 0.1),
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

/// 筛选选项卡片
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.1)
              : isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.5)
                  : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : AppColors.borderAdaptive(context),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.accent
                  : AppColors.textSecondaryAdaptive(context),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.accent
                    : AppColors.textPrimaryAdaptive(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 时间线分组
class _TimelineSection extends StatelessWidget {
  final String dateLabel;
  final List<Photo> photos;

  const _TimelineSection({
    required this.dateLabel,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期标签
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.borderAdaptive(context),
                    ),
                  ),
                  child: Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryAdaptive(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${photos.length}张',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHintAdaptive(context),
                  ),
                ),
              ],
            ),
          ),
          // 照片网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return GestureDetector(
                onTap: () => context.push('/photo/${photo.id}'),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: AppColors.borderAdaptive(context).withValues(alpha: 0.5),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm - 1),
                    child: Image.network(
                      photo.thumbnailUrl ?? photo.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceVariantAdaptive(context),
                        child: Icon(
                          Icons.photo_rounded,
                          color: AppColors.textHintAdaptive(context),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _JourneyPhotoCard extends StatelessWidget {
  final String journeyId;
  final String journeyName;
  final int photoCount;
  final List<_PhotoItem> photos;
  final VoidCallback onTap;

  const _JourneyPhotoCard({
    required this.journeyId,
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
                    child: GestureDetector(
                      onTap: i < photos.length
                          ? () => context.push('/photo/${photos[i].id}')
                          : null,
                      child: Container(
                        margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                        height: 85,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariantAdaptive(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderAdaptive(context)
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        child: i < photos.length
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.network(
                                  photos[i].imageUrl,
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
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 照片项数据
class _PhotoItem {
  final String id;
  final String imageUrl;

  _PhotoItem({required this.id, required this.imageUrl});
}
