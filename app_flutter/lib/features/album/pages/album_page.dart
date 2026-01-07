import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/photo_providers.dart';

/// 相册页面
class AlbumPage extends ConsumerWidget {
  const AlbumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(photoStatsProvider);
    final journeyPhotosAsync = ref.watch(photosByJourneyProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '我的相册',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          statsAsync.when(
            data: (stats) =>
                _buildStatsCard(stats.totalPhotos, stats.journeyCount),
            loading: () => const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => _buildStatsCard(0, 0),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('按文化之旅分类'),
          const SizedBox(height: 12),
          journeyPhotosAsync.when(
            data: (journeyPhotos) => journeyPhotos.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        '暂无照片',
                        style: TextStyle(color: AppColors.textHint),
                      ),
                    ),
                  )
                : Column(
                    children: journeyPhotos
                        .map(
                          (jp) => _JourneyPhotoCard(
                            journeyName: jp.journeyName,
                            photoCount: jp.photoCount,
                            photos: jp.photos
                                .take(3)
                                .map((p) => p.thumbnailUrl ?? p.imageUrl)
                                .toList(),
                            onTap: () {},
                          ),
                        )
                        .toList(),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildEmptyState(e.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int totalPhotos, int journeyCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          const Icon(Icons.photo_library, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            '总照片: $totalPhotos',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          Text(
            '文化之旅: $journeyCount',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String error) {
    // 判断是否需要登录
    final needLogin = error.contains('请先登录') || error.contains('20001');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              needLogin ? Icons.lock_outline : Icons.photo_library_outlined,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              needLogin ? '请先登录' : '暂无照片',
              style: const TextStyle(color: AppColors.textHint),
            ),
          ],
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  journeyName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(
                      '$photoCount张',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textHint,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < 3; i++)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: i < photos.length
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                photos[i],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.photo),
                              ),
                            )
                          : const Icon(Icons.photo, color: AppColors.textHint),
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
