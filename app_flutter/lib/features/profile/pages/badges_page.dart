import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/badge.dart';
import '../../../providers/seal_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/user_providers.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_back_button.dart';

/// 我的称号页面
class BadgesPage extends ConsumerWidget {
  const BadgesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(userBadgesProvider);

    return Scaffold(
      body: Stack(
        children: [
          const AuroraBackground(variant: AuroraVariant.warm),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: badgesAsync.when(
                    data: (badges) => _buildContent(context, ref, badges),
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                    error: (e, _) => _buildErrorState(context, ref),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const AppBackButton(),
          Expanded(
            child: Text(
              '我的称号',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryAdaptive(context),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<UserBadge> badges,
  ) {
    if (badges.isEmpty) {
      return _buildEmptyState(context);
    }

    final activeBadge = badges.where((b) => b.isActive).firstOrNull;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        _buildHeader(context, badges, activeBadge),
        const SizedBox(height: 20),
        ...badges.map((badge) => _BadgeCard(badge: badge)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, List<UserBadge> badges, UserBadge? activeBadge) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.accent.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.1),
                ]
              : [
                  AppColors.accent.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.military_tech_rounded,
              size: 28,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '已解锁 ${badges.length} 个称号',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryAdaptive(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activeBadge != null
                      ? '当前展示：${activeBadge.badgeTitle}'
                      : '点击称号可设为展示',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryAdaptive(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/illustrations/empty_seal.svg',
            width: 180,
            height: 135,
          ),
          const SizedBox(height: 24),
          Text(
            '暂无称号',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryAdaptive(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '完成文化之旅获得印记，解锁专属称号',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondaryAdaptive(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.textHintAdaptive(context).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondaryAdaptive(context)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(userBadgesProvider),
            child: const Text('点击重试', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}


/// 称号卡片
class _BadgeCard extends ConsumerStatefulWidget {
  final UserBadge badge;
  const _BadgeCard({required this.badge});

  @override
  ConsumerState<_BadgeCard> createState() => _BadgeCardState();
}

class _BadgeCardState extends ConsumerState<_BadgeCard> {
  bool _isLoading = false;

  Color get _rarityColor {
    switch (widget.badge.rarity) {
      case 'legendary':
        return AppColors.sealGold;
      case 'rare':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _rarityIcon {
    switch (widget.badge.rarity) {
      case 'legendary':
        return Icons.auto_awesome_rounded;
      case 'rare':
        return Icons.diamond_rounded;
      default:
        return Icons.military_tech_rounded;
    }
  }

  Future<void> _toggleBadge() async {
    if (_isLoading) return;

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final service = ref.read(sealServiceProvider);
      if (widget.badge.isActive) {
        await service.clearBadgeTitle();
      } else {
        await service.setBadgeTitle(widget.badge.badgeTitle);
      }
      ref.invalidate(userBadgesProvider);
      ref.invalidate(currentUserProvider);
      ref.invalidate(profileHomeProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.badge.isActive ? '已取消展示称号' : '已设置为展示称号',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final badge = widget.badge;
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badge.isActive
              ? AppColors.accent.withValues(alpha: 0.5)
              : isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.5),
          width: badge.isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: badge.isActive
                ? AppColors.accent.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleBadge,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 称号图标 - 根据稀有度显示不同图标
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _rarityColor.withValues(alpha: 0.25),
                        _rarityColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: badge.rarity == 'legendary'
                        ? Border.all(
                            color: _rarityColor.withValues(alpha: 0.3),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Icon(
                    _rarityIcon,
                    size: 28,
                    color: _rarityColor,
                  ),
                ),
                const SizedBox(width: 14),
                // 称号信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              badge.badgeTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryAdaptive(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badge.isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '展示中',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 来源印记 - 可点击跳转
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/seal/${badge.sealId}');
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.workspace_premium_rounded,
                              size: 14,
                              color: AppColors.textHintAdaptive(context),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                badge.sealName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.info,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.info,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 获得时间和稀有度
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.textHintAdaptive(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(badge.earnedTime),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textHintAdaptive(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _rarityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge.rarityLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _rarityColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 选中状态
                _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      )
                    : Icon(
                        badge.isActive
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 24,
                        color: badge.isActive
                            ? AppColors.accent
                            : AppColors.textHintAdaptive(context),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
