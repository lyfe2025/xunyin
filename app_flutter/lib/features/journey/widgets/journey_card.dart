import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/journey.dart';

/// 旅程卡片组件 - 精致质感设计
class JourneyCard extends StatefulWidget {
  final JourneyProgress journey;
  final VoidCallback? onDismissed;
  final bool enableDismiss;

  const JourneyCard({
    super.key,
    required this.journey,
    this.onDismissed,
    this.enableDismiss = true,
  });

  @override
  State<JourneyCard> createState() => _JourneyCardState();
}

class _JourneyCardState extends State<JourneyCard>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    // 进度条动画
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.journey.progressPercent,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    // 已完成卡片的呼吸动画
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _breathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _progressController.forward();
    });

    if (widget.journey.isCompleted) {
      _breathController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(JourneyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.journey.progressPercent != widget.journey.progressPercent) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.journey.progressPercent,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = _buildCard(context);

    if (!widget.enableDismiss) {
      return card;
    }

    return Dismissible(
      key: Key(widget.journey.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (direction) => _confirmDismiss(context),
      onDismissed: (_) => widget.onDismissed?.call(),
      child: card,
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(
        Icons.archive_outlined,
        color: AppColors.error,
        size: 24,
      ),
    );
  }

  Future<bool> _confirmDismiss(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('归档旅程'),
            content: Text('确定要归档「${widget.journey.journeyName}」吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  '归档',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildCard(BuildContext context) {
    final isCompleted = widget.journey.isCompleted;
    final isDark = context.isDarkMode;

    return AnimatedBuilder(
      animation: _breathAnimation,
      builder: (context, child) {
        final breathValue = _breathAnimation.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: isCompleted ? 0.95 : 0.9)
                : Colors.white.withValues(alpha: isCompleted ? 0.92 : 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? AppColors.sealGold.withValues(alpha: 0.4 + breathValue * 0.2)
                  : isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.5),
              width: isCompleted ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isCompleted
                    ? AppColors.sealGold.withValues(alpha: 0.08 + breathValue * 0.06)
                    : isDark
                        ? Colors.black.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.06),
                blurRadius: isCompleted ? 16 + breathValue * 4 : 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.journey.isInProgress) {
              context.push('/journey/${widget.journey.journeyId}/progress');
            } else {
              context.push('/journey/${widget.journey.journeyId}');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _buildThumbnail(),
                const SizedBox(width: 14),
                Expanded(child: _buildContent(context)),
                const SizedBox(width: 8),
                _buildTrailing(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 左侧缩略图/图标
  Widget _buildThumbnail() {
    final journey = widget.journey;
    final isCompleted = journey.isCompleted;
    final coverImage = journey.coverImage;
    final isDark = context.isDarkMode;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppColors.sealGold.withValues(alpha: 0.3)
              : isDark
                  ? AppColors.darkBorder
                  : AppColors.divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: coverImage != null && coverImage.isNotEmpty
          ? Image.network(
              coverImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholderIcon(isCompleted),
            )
          : _buildPlaceholderIcon(isCompleted),
    );
  }

  Widget _buildPlaceholderIcon(bool isCompleted) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCompleted
              ? [
                  AppColors.sealGold.withValues(alpha: 0.15),
                  AppColors.sealGold.withValues(alpha: 0.08),
                ]
              : [
                  AppColors.accent.withValues(alpha: 0.12),
                  AppColors.accent.withValues(alpha: 0.06),
                ],
        ),
      ),
      child: Icon(
        isCompleted ? Icons.emoji_events_rounded : Icons.explore_rounded,
        color: isCompleted ? AppColors.sealGold : AppColors.accent,
        size: 26,
      ),
    );
  }

  /// 中间内容区
  Widget _buildContent(BuildContext context) {
    final journey = widget.journey;
    final isCompleted = journey.isCompleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题行
        Row(
          children: [
            Flexible(
              child: Text(
                journey.journeyName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? AppColors.textSecondaryAdaptive(context)
                      : AppColors.textPrimaryAdaptive(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (journey.cityName != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  journey.cityName!,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondaryAdaptive(context),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        // 时间信息
        Text(
          _formatTime(journey),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textHintAdaptive(context),
          ),
        ),
        const SizedBox(height: 10),
        // 进度条
        _buildProgressBar(context),
      ],
    );
  }

  /// 渐变进度条
  Widget _buildProgressBar(BuildContext context) {
    final journey = widget.journey;
    final isCompleted = journey.isCompleted;
    final isDark = context.isDarkMode;

    return Row(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, _) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.4)
                      : AppColors.divider.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCompleted
                            ? [
                                AppColors.sealGold.withValues(alpha: 0.8),
                                AppColors.sealGold,
                              ]
                            : [
                                AppColors.accent.withValues(alpha: 0.7),
                                AppColors.accent,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: (isCompleted ? AppColors.sealGold : AppColors.accent)
                              .withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${journey.completedPoints}/${journey.totalPoints}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isCompleted ? AppColors.sealGold : AppColors.accent,
          ),
        ),
      ],
    );
  }

  /// 右侧尾部（印记徽章或箭头）
  Widget _buildTrailing(BuildContext context) {
    final isCompleted = widget.journey.isCompleted;

    if (isCompleted) {
      // 已完成显示金色印记徽章
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.sealGold.withValues(alpha: 0.2),
              AppColors.sealGold.withValues(alpha: 0.1),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.sealGold.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.workspace_premium_rounded,
          color: AppColors.sealGold,
          size: 18,
        ),
      );
    }

    return Icon(
      Icons.chevron_right_rounded,
      color: AppColors.textHintAdaptive(context).withValues(alpha: 0.7),
      size: 22,
    );
  }

  String _formatTime(JourneyProgress journey) {
    if (journey.isCompleted && journey.completeTime != null) {
      return '完成于 ${_formatRelativeDate(journey.completeTime!)}';
    }
    return '开始于 ${_formatRelativeDate(journey.startTime)}';
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '今天';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}周前';
    } else {
      return '${date.month}月${date.day}日';
    }
  }
}
