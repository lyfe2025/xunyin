import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/url_utils.dart';
import '../../../models/journey.dart';
import '../../../providers/journey_providers.dart';
import '../../../providers/service_providers.dart';

/// 文化之旅详情页
class JourneyDetailPage extends ConsumerWidget {
  final String journeyId;
  const JourneyDetailPage({super.key, required this.journeyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyAsync = ref.watch(journeyDetailProvider(journeyId));
    final pointsAsync = ref.watch(journeyPointsProvider(journeyId));
    return Scaffold(
      body: journeyAsync.when(
        data: (journey) => _JourneyContent(
          journey: journey,
          journeyId: journeyId,
          pointsAsync: pointsAsync,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
      bottomNavigationBar: _StartButton(journeyId: journeyId),
    );
  }
}

class _JourneyContent extends StatelessWidget {
  final JourneyDetail journey;
  final String journeyId;
  final AsyncValue<List<ExplorationPoint>> pointsAsync;

  const _JourneyContent({
    required this.journey,
    required this.journeyId,
    required this.pointsAsync,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(journey.name, style: const TextStyle(fontSize: 16)),
            background: journey.coverImage != null
                ? Image.network(
                    UrlUtils.getFullImageUrl(journey.coverImage),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primary,
                      child: const Icon(
                        Icons.landscape,
                        size: 64,
                        color: Colors.white54,
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.primary,
                    child: const Icon(
                      Icons.landscape,
                      size: 64,
                      color: Colors.white54,
                    ),
                  ),
          ),
        ),
        SliverToBoxAdapter(child: _buildInfoSection()),
        pointsAsync.when(
          data: (points) => SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _PointCard(
                point: points[i],
                index: i,
                isLast: i == points.length - 1,
              ),
              childCount: points.length,
            ),
          ),
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('$e'))),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _InfoItem(
                      icon: Icons.location_on,
                      label: '主题',
                      value: journey.theme,
                    ),
                    _InfoItem(
                      icon: Icons.schedule,
                      label: '时长',
                      value: '${journey.estimatedMinutes}分钟',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoItem(
                      icon: Icons.straighten,
                      label: '距离',
                      value:
                          '${(journey.totalDistance / 1000).toStringAsFixed(1)}km',
                    ),
                    _InfoItem(
                      icon: Icons.people,
                      label: '完成',
                      value: '${journey.completedCount}人',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (journey.description != null) ...[
            const SizedBox(height: 16),
            Text(
              journey.description!,
              style: const TextStyle(
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
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
              const Text(
                '探索点列表',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: AppColors.textHint),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  final ExplorationPoint point;
  final int index;
  final bool isLast;
  const _PointCard({
    required this.point,
    required this.index,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: AppColors.border)),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      point.taskDescription,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends ConsumerWidget {
  final String journeyId;
  const _StartButton({required this.journeyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () => _startJourney(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            '开始这条文化之旅',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Future<void> _startJourney(BuildContext context, WidgetRef ref) async {
    try {
      final service = ref.read(journeyServiceProvider);
      await service.startJourney(journeyId);
      // 成功开始后跳转到进度页面，进度页面会加载详情和探索点
      if (context.mounted) context.push('/journey/$journeyId/progress');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('开始失败: $e')));
      }
    }
  }
}
