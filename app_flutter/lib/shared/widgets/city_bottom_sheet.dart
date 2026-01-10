import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/url_utils.dart';
import '../../models/city.dart';
import '../../models/journey.dart';
import '../../providers/city_providers.dart';

/// 城市底部面板 - Glassmorphism 风格
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
    final journeysAsync = ref.watch(cityJourneysWithProgressProvider(widget.city.id));
    final isDark = context.isDarkMode;

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.4, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.98)
                : Colors.white.withValues(alpha: 0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
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
                  color: AppColors.borderAdaptive(context).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 内容
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    if (widget.city.description != null) ...[
                      _buildDescription(context),
                      const SizedBox(height: 20),
                    ],
                    _buildSectionTitle(context),
                    const SizedBox(height: 14),
                    journeysAsync.when(
                      data: (journeys) => _buildJourneyList(context, journeys),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                      error: (e, _) => _buildErrorState(context, e.toString()),
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

  Widget _buildHeader(BuildContext context) {
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
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryAdaptive(context),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '文化之书',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    Icons.people_outline_rounded,
                    '${widget.city.explorerCount}人探索',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    context,
                    Icons.location_on_outlined,
                    widget.city.province,
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildSearchButton(context),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textHintAdaptive(context)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textHintAdaptive(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final journeysAsync = ref.read(cityJourneysProvider(widget.city.id));
          journeysAsync.whenData((journeys) {
            showDialog(
              context: context,
              builder: (context) => _JourneySearchDialog(
                cityName: widget.city.name,
                journeys: journeys,
              ),
            );
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.search_rounded,
            color: AppColors.textSecondaryAdaptive(context),
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkSurfaceVariant.withValues(alpha: 0.6),
                  AppColors.darkSurfaceVariant.withValues(alpha: 0.4),
                ]
              : [
                  AppColors.surfaceVariant.withValues(alpha: 0.5),
                  AppColors.surfaceVariant.withValues(alpha: 0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderAdaptive(context).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.city.coverImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                UrlUtils.getFullImageUrl(widget.city.coverImage),
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariantAdaptive(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.image_rounded,
                    size: 48,
                    color: AppColors.textHintAdaptive(context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            widget.city.description!,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryAdaptive(context),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Text(
      '文化之旅',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryAdaptive(context),
      ),
    );
  }

  Widget _buildJourneyList(BuildContext context, List<JourneyBrief> journeys) {
    if (journeys.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/illustrations/empty_city.svg',
                width: 140,
                height: 105,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无文化之旅',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryAdaptive(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '敬请期待更多精彩内容',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textHintAdaptive(context).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 按状态排序：进行中 > 已完成 > 未开始 > 锁定
    final sortedJourneys = List<JourneyBrief>.from(journeys)
      ..sort((a, b) {
        int getPriority(JourneyBrief j) {
          if (j.isLocked) return 4;
          switch (j.userStatus) {
            case JourneyUserStatus.inProgress:
              return 1;
            case JourneyUserStatus.completed:
              return 2;
            case JourneyUserStatus.notStarted:
              return 3;
          }
        }
        return getPriority(a).compareTo(getPriority(b));
      });

    return Column(
      children: sortedJourneys
          .map((journey) => _JourneyCard(journey: journey))
          .toList(),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/illustrations/error_network.svg',
              width: 140,
              height: 105,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryAdaptive(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '请检查网络后重试',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textHintAdaptive(context).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 文化之旅卡片 - 现代卡片风格
class _JourneyCard extends StatelessWidget {
  final JourneyBrief journey;

  const _JourneyCard({required this.journey});

  @override
  Widget build(BuildContext context) {
    final isLocked = journey.isLocked;
    final isDark = context.isDarkMode;
    final isCompleted = journey.userStatus == JourneyUserStatus.completed;
    final isInProgress = journey.userStatus == JourneyUserStatus.inProgress;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : () => context.push('/journey/${journey.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isLocked
                  ? AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.5)
                  : AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted
                    ? AppColors.sealGold.withValues(alpha: 0.4)
                    : isInProgress
                        ? AppColors.accent.withValues(alpha: 0.3)
                        : isLocked
                            ? AppColors.borderAdaptive(context).withValues(alpha: 0.3)
                            : AppColors.borderAdaptive(context).withValues(alpha: 0.5),
                width: isCompleted || isInProgress ? 1.5 : 1,
              ),
              boxShadow: isLocked
                  ? []
                  : [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : AppColors.primary.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // 封面图（带状态徽章）
                _buildCoverImage(context),
                const SizedBox(width: 14),
                // 信息
                Expanded(child: _buildInfo(context)),
                // 箭头
                if (!isLocked)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textHintAdaptive(context).withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    final isCompleted = journey.userStatus == JourneyUserStatus.completed;
    final isInProgress = journey.userStatus == JourneyUserStatus.inProgress;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariantAdaptive(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: journey.coverImage != null
                ? Image.network(
                    UrlUtils.getFullImageUrl(journey.coverImage),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                  )
                : _buildPlaceholder(context),
          ),
        ),
        // 状态徽章
        if (isCompleted || isInProgress)
          Positioned(
            top: 4,
            left: 4,
            child: _buildStatusBadge(context),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final isCompleted = journey.userStatus == JourneyUserStatus.completed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.sealGold : AppColors.accent,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: (isCompleted ? AppColors.sealGold : AppColors.accent)
                .withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.play_circle_rounded,
            size: 10,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            isCompleted ? '已完成' : '进行中',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Icon(
        journey.isLocked ? Icons.lock_rounded : Icons.landscape_rounded,
        size: 28,
        color: AppColors.textHintAdaptive(context).withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final isCompleted = journey.userStatus == JourneyUserStatus.completed;
    final isInProgress = journey.userStatus == JourneyUserStatus.inProgress;
    final hasProgress = isCompleted || isInProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (journey.isLocked)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.lock_rounded,
                  size: 14,
                  color: AppColors.textHintAdaptive(context).withValues(alpha: 0.6),
                ),
              ),
            Expanded(
              child: Text(
                journey.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: journey.isLocked
                      ? AppColors.textHintAdaptive(context)
                      : AppColors.textPrimaryAdaptive(context),
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
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondaryAdaptive(context).withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 10),
        // 进度条（已完成或进行中时显示）
        if (hasProgress) ...[
          _buildProgressBar(context),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            // 星级
            _buildRating(context),
            const SizedBox(width: 12),
            // 距离
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(journey.totalDistance / 1000).toStringAsFixed(1)}km',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondaryAdaptive(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (journey.isLocked && journey.unlockCondition != null) ...[
          const SizedBox(height: 8),
          Text(
            journey.unlockCondition!,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textHintAdaptive(context).withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final isCompleted = journey.userStatus == JourneyUserStatus.completed;
    final progress = journey.userProgress;
    final progressColor = isCompleted ? AppColors.sealGold : AppColors.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${journey.completedPoints}/${journey.totalPoints} 探索点',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondaryAdaptive(context),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: AppColors.surfaceVariantAdaptive(context),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }

  Widget _buildRating(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < journey.rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: i < journey.rating
              ? AppColors.sealGold
              : AppColors.textHintAdaptive(context).withValues(alpha: 0.3),
        );
      }),
    );
  }
}

/// 文化之旅搜索对话框
class _JourneySearchDialog extends StatefulWidget {
  final String cityName;
  final List<JourneyBrief> journeys;

  const _JourneySearchDialog({required this.cityName, required this.journeys});

  @override
  State<_JourneySearchDialog> createState() => _JourneySearchDialogState();
}

class _JourneySearchDialogState extends State<_JourneySearchDialog> {
  final _searchController = TextEditingController();
  List<JourneyBrief> _filteredJourneys = [];

  @override
  void initState() {
    super.initState();
    _filteredJourneys = widget.journeys;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredJourneys = widget.journeys;
      } else {
        _filteredJourneys = widget.journeys
            .where(
              (j) =>
                  j.name.toLowerCase().contains(query.toLowerCase()) ||
                  j.theme.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground(context),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 420),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '搜索 ${widget.cityName} 的文化之旅',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryAdaptive(context),
              ),
            ),
            const SizedBox(height: 16),
            // 搜索框
            TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimaryAdaptive(context),
              ),
              decoration: InputDecoration(
                hintText: '输入名称或主题',
                hintStyle: TextStyle(
                  color: AppColors.textHintAdaptive(context),
                ),
                filled: true,
                fillColor: AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.5),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.textHintAdaptive(context),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: AppColors.textHintAdaptive(context),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            // 结果列表
            Flexible(
              child: _filteredJourneys.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/illustrations/no_search_result.svg',
                            width: 120,
                            height: 90,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '没有找到匹配的文化之旅',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryAdaptive(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '换个关键词试试吧',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textHintAdaptive(context).withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredJourneys.length,
                      separatorBuilder: (_, __) => Divider(
                        color: AppColors.borderAdaptive(context).withValues(alpha: 0.5),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final journey = _filteredJourneys[index];
                        final isCompleted =
                            journey.userStatus == JourneyUserStatus.completed;
                        final isInProgress =
                            journey.userStatus == JourneyUserStatus.inProgress;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 44,
                              height: 44,
                              color: AppColors.surfaceVariantAdaptive(context),
                              child: journey.coverImage != null
                                  ? Image.network(
                                      UrlUtils.getFullImageUrl(
                                        journey.coverImage,
                                      ),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.landscape_rounded,
                                        size: 20,
                                        color: AppColors.textHintAdaptive(context),
                                      ),
                                    )
                                  : Icon(
                                      Icons.landscape_rounded,
                                      size: 20,
                                      color: AppColors.textHintAdaptive(context),
                                    ),
                            ),
                          ),
                          title: Text(
                            journey.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimaryAdaptive(context),
                            ),
                          ),
                          subtitle: Text(
                            journey.theme,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryAdaptive(context),
                            ),
                          ),
                          trailing: journey.isLocked
                              ? Icon(
                                  Icons.lock_rounded,
                                  size: 16,
                                  color: AppColors.textHintAdaptive(context).withValues(
                                    alpha: 0.5,
                                  ),
                                )
                              : isCompleted
                                  ? _buildSearchStatusBadge(
                                      context,
                                      '已完成',
                                      AppColors.sealGold,
                                    )
                                  : isInProgress
                                      ? _buildSearchStatusBadge(
                                          context,
                                          '进行中',
                                          AppColors.accent,
                                        )
                                      : null,
                          onTap: () {
                            Navigator.of(context).pop();
                            if (!journey.isLocked) {
                              context.push('/journey/${journey.id}');
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchStatusBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
