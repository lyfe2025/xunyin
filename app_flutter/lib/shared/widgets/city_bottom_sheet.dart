import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/url_utils.dart';
import '../../models/city.dart';
import '../../models/journey.dart';
import '../../providers/city_providers.dart';

/// 城市底部面板
class CityBottomSheet extends ConsumerStatefulWidget {
  final City city;
  final VoidCallback? onClose;

  const CityBottomSheet({super.key, required this.city, this.onClose});

  @override
  ConsumerState<CityBottomSheet> createState() => _CityBottomSheetState();
}

class _CityBottomSheetState extends ConsumerState<CityBottomSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journeysAsync = ref.watch(cityJourneysProvider(widget.city.id));

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.4, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 拖动条
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 内容
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // 城市标题
                    _buildHeader(),
                    const SizedBox(height: 16),
                    // 城市描述（展开时显示）
                    if (widget.city.description != null) ...[
                      _buildDescription(),
                      const SizedBox(height: 16),
                    ],
                    // 文化之旅列表
                    _buildSectionTitle('文化之旅'),
                    const SizedBox(height: 12),
                    journeysAsync.when(
                      data: (journeys) => _buildJourneyList(journeys),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text('加载失败: $e'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.city.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '· 文化之书',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 14,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.city.explorerCount}人探索过',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.city.province,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          color: AppColors.textSecondary,
          onPressed: () {
            // TODO: 搜索景点
          },
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.city.coverImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                UrlUtils.getFullImageUrl(widget.city.coverImage),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: AppColors.border,
                  child: const Icon(Icons.image, size: 48),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            widget.city.description!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyList(List<JourneyBrief> journeys) {
    if (journeys.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('暂无文化之旅', style: TextStyle(color: AppColors.textHint)),
        ),
      );
    }

    return Column(
      children: journeys
          .map((journey) => _JourneyCard(journey: journey))
          .toList(),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  final JourneyBrief journey;

  const _JourneyCard({required this.journey});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!journey.isLocked) {
          context.push('/journey/${journey.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: journey.isLocked ? AppColors.surfaceVariant : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // 封面图
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.surfaceVariant,
                child: journey.coverImage != null
                    ? Image.network(
                        UrlUtils.getFullImageUrl(journey.coverImage),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.landscape, size: 32),
                      )
                    : Icon(
                        journey.isLocked ? Icons.lock : Icons.landscape,
                        size: 32,
                        color: AppColors.textHint,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (journey.isLocked)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.lock,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          journey.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: journey.isLocked
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    journey.theme,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // 星级
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < journey.rating ? Icons.star : Icons.star_border,
                          size: 14,
                          color: AppColors.sealGold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(journey.totalDistance / 1000).toStringAsFixed(1)}km',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  if (journey.isLocked && journey.unlockCondition != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      journey.unlockCondition!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
