import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/journey.dart';
import '../../../providers/journey_providers.dart';

/// 文化之旅进行中页面
class JourneyProgressPage extends ConsumerStatefulWidget {
  final String journeyId;

  const JourneyProgressPage({super.key, required this.journeyId});

  @override
  ConsumerState<JourneyProgressPage> createState() =>
      _JourneyProgressPageState();
}

class _JourneyProgressPageState extends ConsumerState<JourneyProgressPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final detail = await ref.read(
      journeyDetailProvider(widget.journeyId).future,
    );
    final points = await ref.read(
      journeyPointsProvider(widget.journeyId).future,
    );
    ref.read(currentJourneyProvider.notifier).setDetail(detail);
    ref.read(currentJourneyProvider.notifier).setPoints(points);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentJourneyProvider);
    final detail = state.detail;
    final points = state.points;
    final currentIndex = state.currentPointIndex;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => _showExitDialog(context),
        ),
        title: Text(
          detail?.name ?? '文化之旅',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '进度 ${currentIndex + 1}/${points.length}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 进度条
          LinearProgressIndicator(
            value: points.isEmpty ? 0 : (currentIndex + 1) / points.length,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
          ),
          // 地图区域（占位）
          Expanded(flex: 2, child: _buildMapPlaceholder(points, currentIndex)),
          // 当前探索点信息
          if (state.currentPoint != null)
            _buildCurrentPointCard(state.currentPoint!),
          // 探索点列表
          Expanded(flex: 1, child: _buildPointsList(points, currentIndex)),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder(List<ExplorationPoint> points, int currentIndex) {
    return Container(
      color: const Color(0xFFF5F0E6),
      child: Stack(
        children: [
          // 地图占位
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, size: 64, color: AppColors.textHint),
                SizedBox(height: 8),
                Text(
                  '高德地图 - 路线视图',
                  style: TextStyle(color: AppColors.textHint),
                ),
                Text(
                  '（集成后显示实际地图）',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ],
            ),
          ),
          // 模拟探索点标记
          ...points.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            final isCompleted = index < currentIndex;
            final isCurrent = index == currentIndex;

            return Positioned(
              left: 50.0 + index * 60,
              top: 100.0 + (index % 2) * 40,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success
                          : isCurrent
                          ? AppColors.accent
                          : AppColors.textHint,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    point.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrent ? AppColors.accent : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCurrentPointCard(ExplorationPoint point) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '下一个探索点',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
          const SizedBox(height: 8),
          Text(
            point.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (point.distanceFromPrev != null) ...[
                Text(
                  '距离：${point.distanceFromPrev!.toInt()}m',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Text(
                '步行约${((point.distanceFromPrev ?? 500) / 80).ceil()}分钟',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  '/journey/${widget.journeyId}/navigate/${point.id}',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('开始导航'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsList(List<ExplorationPoint> points, int currentIndex) {
    return Container(
      color: AppColors.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              '探索点列表',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: points.length,
              itemBuilder: (context, index) {
                final point = points[index];
                final isCompleted = index < currentIndex;
                final isCurrent = index == currentIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.success
                              : isCurrent
                              ? AppColors.accent
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.success
                                : isCurrent
                                ? AppColors.accent
                                : AppColors.textHint,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${index + 1}. ${point.name}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isCompleted
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      if (point.distanceFromPrev != null)
                        Text(
                          '${(point.distanceFromPrev! / 1000).toStringAsFixed(1)}km',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出文化之旅？'),
        content: const Text('当前进度将被保存，你可以稍后继续。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}
