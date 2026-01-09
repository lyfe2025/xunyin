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
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
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
                  color: AppColors.border.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 内容
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    if (widget.city.description != null) ...[
                      _buildDescription(),
                      const SizedBox(height: 20),
                    ],
                    _buildSectionTitle('文化之旅'),
                    const SizedBox(height: 14),
                    journeysAsync.when(
                      data: (journeys) => _buildJourneyList(journeys),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                      error: (e, _) => _buildErrorState(e.toString()),
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
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
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
                    Icons.people_outline_rounded,
                    '${widget.city.explorerCount}人探索',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.location_on_outlined,
                    widget.city.province,
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildSearchButton(),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
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
            color: AppColors.surfaceVariant.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceVariant.withValues(alpha: 0.5),
            AppColors.surfaceVariant.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
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
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image_rounded,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            widget.city.description!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildJourneyList(List<JourneyBrief> journeys) {
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
              const Text(
                '暂无文化之旅',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '敬请期待更多精彩内容',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: journeys
          .map((journey) => _JourneyCard(journey: journey))
          .toList(),
    );
  }

  Widget _buildErrorState(String error) {
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
            const Text(
              '加载失败',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '请检查网络后重试',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textHint.withValues(alpha: 0.7),
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
                  ? AppColors.surfaceVariant.withValues(alpha: 0.5)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isLocked
                    ? AppColors.border.withValues(alpha: 0.3)
                    : AppColors.border.withValues(alpha: 0.5),
              ),
              boxShadow: isLocked
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // 封面图
                _buildCoverImage(),
                const SizedBox(width: 14),
                // 信息
                Expanded(child: _buildInfo()),
                // 箭头
                if (!isLocked)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textHint.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: journey.coverImage != null
            ? Image.network(
                UrlUtils.getFullImageUrl(journey.coverImage),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        journey.isLocked ? Icons.lock_rounded : Icons.landscape_rounded,
        size: 28,
        color: AppColors.textHint.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildInfo() {
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
                  color: AppColors.textHint.withValues(alpha: 0.6),
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
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // 星级
            _buildRating(),
            const SizedBox(width: 12),
            // 距离
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(journey.totalDistance / 1000).toStringAsFixed(1)}km',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
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
              color: AppColors.textHint.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < journey.rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: i < journey.rating
              ? AppColors.sealGold
              : AppColors.textHint.withValues(alpha: 0.3),
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
      backgroundColor: Colors.white,
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
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // 搜索框
            TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: '输入名称或主题',
                filled: true,
                fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
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
                          const Text(
                            '没有找到匹配的文化之旅',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '换个关键词试试吧',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredJourneys.length,
                      separatorBuilder: (_, __) => Divider(
                        color: AppColors.divider.withValues(alpha: 0.5),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final journey = _filteredJourneys[index];
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
                              color: AppColors.surfaceVariant,
                              child: journey.coverImage != null
                                  ? Image.network(
                                      UrlUtils.getFullImageUrl(
                                        journey.coverImage,
                                      ),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.landscape_rounded,
                                        size: 20,
                                        color: AppColors.textHint,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.landscape_rounded,
                                      size: 20,
                                      color: AppColors.textHint,
                                    ),
                            ),
                          ),
                          title: Text(
                            journey.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            journey.theme,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: journey.isLocked
                              ? Icon(
                                  Icons.lock_rounded,
                                  size: 16,
                                  color: AppColors.textHint.withValues(
                                    alpha: 0.5,
                                  ),
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
}
