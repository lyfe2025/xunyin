import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/journey_providers.dart';
import '../../../models/user.dart';
import '../../../models/journey.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/app_loading.dart';

/// 根据字符串生成稳定的颜色
Color _generateColorFromName(String name) {
  if (name.isEmpty) return AppColors.accent;
  final hash = name.codeUnits.fold(0, (prev, curr) => prev + curr);
  final colors = [
    const Color(0xFFE57373), // 红
    const Color(0xFFFFB74D), // 橙
    const Color(0xFFFFD54F), // 黄
    const Color(0xFF81C784), // 绿
    const Color(0xFF4FC3F7), // 蓝
    const Color(0xFF9575CD), // 紫
    const Color(0xFFF06292), // 粉
    const Color(0xFF4DB6AC), // 青
  ];
  return colors[hash % colors.length];
}

/// 个人中心页面 - Aurora UI + Glassmorphism 风格
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    // 刷新所有数据
    ref.invalidate(currentUserProvider);
    ref.invalidate(userStatsProvider);
    ref.invalidate(userActivitiesProvider);
    ref.invalidate(inProgressJourneysProvider);
    // 等待数据加载完成
    await Future.wait([
      ref.read(currentUserProvider.future),
      ref.read(userStatsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final activitiesAsync = ref.watch(userActivitiesProvider);
    final inProgressAsync = ref.watch(inProgressJourneysProvider);

    return Scaffold(
      body: Stack(
        children: [
          const AuroraBackground(variant: AuroraVariant.warm),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _onRefresh(ref),
                    color: AppColors.accent,
                    backgroundColor: Colors.white,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        const SizedBox(height: 8),
                        _UserCard(userAsync: userAsync),
                        const SizedBox(height: 14),
                        statsAsync.when(
                          data: (stats) => _StatsCard(stats: stats),
                          loading: () => const AppLoadingCard(height: 100),
                          error: (e, _) => _StatsCard(stats: UserStats()),
                        ),
                        const SizedBox(height: 14),
                        // 进行中的旅程
                        inProgressAsync.when(
                          data: (journeys) => journeys.isNotEmpty
                              ? _InProgressSection(journeys: journeys)
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 12),
                        _MenuSection(),
                        const SizedBox(height: 14),
                        // 最近动态
                        activitiesAsync.when(
                          data: (activities) =>
                              _ActivitiesSection(activities: activities),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) =>
                              const _ActivitiesSection(activities: []),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
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
          const Expanded(
            child: Text(
              '个人中心',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          AppHeaderAction(
            icon: Icons.settings_rounded,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AsyncValue<AppUser?> userAsync;
  const _UserCard({required this.userAsync});

  Widget _buildAvatar(AppUser? user) {
    final displayName = user?.displayName ?? '旅行者';
    final avatarColor = _generateColorFromName(displayName);

    if (user?.avatarUrl != null) {
      return ClipOval(
        child: Image.network(
          user!.avatarUrl!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _buildTextAvatar(displayName, avatarColor),
        ),
      );
    }
    return _buildTextAvatar(displayName, avatarColor);
  }

  Widget _buildTextAvatar(String name, Color color) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: userAsync.when(
              data: (user) => _buildAvatar(user),
              loading: () => _buildAvatar(null),
              error: (_, __) => _buildAvatar(null),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userAsync.when(
                  data: (user) => Text(
                    user?.displayName ?? '旅行者',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  loading: () => Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  error: (_, __) => const Text(
                    '旅行者',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                // 积分和称号
                userAsync.when(
                  data: (user) => Row(
                    children: [
                      // 积分可点击（暂无积分页面，跳转设置）
                      GestureDetector(
                        onTap: () => context.push('/settings'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sealGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.stars_rounded,
                                size: 12,
                                color: AppColors.sealGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${user?.totalPoints ?? 0}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.sealGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (user?.badgeTitle != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            user!.badgeTitle!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/settings/nickname'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final UserStats stats;
  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // 第一行：城市、印记、上链
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: '${stats.unlockedCities}/${stats.totalCities}',
                  label: '城市解锁',
                  icon: Icons.location_city_rounded,
                  color: AppColors.primary,
                  onTap: () => context.go('/'),
                ),
              ),
              _buildDivider(),
              Expanded(
                child: _StatItem(
                  value: '${stats.collectedSeals}',
                  label: '印记收集',
                  icon: Icons.workspace_premium_rounded,
                  color: AppColors.sealGold,
                  onTap: () => context.push('/seals'),
                ),
              ),
              _buildDivider(),
              Expanded(
                child: _StatItem(
                  value: '${stats.chainedSeals}',
                  label: '已上链',
                  icon: Icons.link_rounded,
                  color: AppColors.tertiary,
                  onTap: () => context.push('/seals?filter=chained'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.divider.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          // 第二行：旅程、距离、时间
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: '${stats.completedJourneys}',
                  label: '完成旅程',
                  icon: Icons.route_rounded,
                  color: AppColors.success,
                  onTap: () => context.push('/journeys?filter=completed'),
                ),
              ),
              _buildDivider(),
              Expanded(
                child: _StatItem(
                  value: stats.formattedDistance,
                  label: '总行程',
                  icon: Icons.straighten_rounded,
                  color: AppColors.info,
                ),
              ),
              _buildDivider(),
              Expanded(
                child: _StatItem(
                  value: stats.formattedTime,
                  label: '探索时长',
                  icon: Icons.timer_rounded,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.divider.withValues(alpha: 0.5),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textHint.withValues(alpha: 0.8),
          ),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}

/// 进行中的旅程 - 横向滑动卡片
class _InProgressSection extends StatelessWidget {
  final List<JourneyProgress> journeys;
  const _InProgressSection({required this.journeys});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                '进行中的旅程',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${journeys.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 88,
          child: Stack(
            children: [
              ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 20),
                itemCount: journeys.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) =>
                    _InProgressCard(journey: journeys[index]),
              ),
              // 右侧渐变提示可滑动
              if (journeys.length > 1)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 24,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFFF8F5F0).withValues(alpha: 0),
                            const Color(0xFFF8F5F0).withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InProgressCard extends StatelessWidget {
  final JourneyProgress journey;
  const _InProgressCard({required this.journey});

  @override
  Widget build(BuildContext context) {
    final progress = journey.totalPoints > 0
        ? journey.completedPoints / journey.totalPoints
        : 0.0;

    return GestureDetector(
      onTap: () => context.push('/journey/${journey.journeyId}/progress'),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_rounded,
                  size: 16,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    journey.journeyName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.divider.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.accent,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${journey.completedPoints}/${journey.totalPoints}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textHint,
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

class _MenuSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.workspace_premium_rounded,
            iconColor: AppColors.sealGold,
            title: '我的印记集',
            onTap: () => context.push('/seals'),
          ),
          _buildDivider(),
          _MenuItem(
            icon: Icons.photo_library_rounded,
            iconColor: AppColors.tertiary,
            title: '我的相册',
            onTap: () => context.push('/album'),
          ),
          _buildDivider(),
          _MenuItem(
            icon: Icons.route_rounded,
            iconColor: AppColors.primary,
            title: '我的旅程',
            onTap: () => context.push('/journeys'),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 48),
      child: Divider(
        height: 1,
        color: AppColors.divider.withValues(alpha: 0.5),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 最近动态
class _ActivitiesSection extends StatelessWidget {
  final List<UserActivity> activities;
  const _ActivitiesSection({required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            '最近动态',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.tertiary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: activities.isEmpty
              ? _buildEmptyState(context)
              : Column(
                  children: activities.take(5).map((activity) {
                    final index = activities.indexOf(activity);
                    return Column(
                      children: [
                        if (index > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 48),
                            child: Divider(
                              height: 1,
                              color: AppColors.divider.withValues(alpha: 0.5),
                            ),
                          ),
                        _ActivityItem(activity: activity),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        children: [
          Icon(
            Icons.explore_outlined,
            size: 48,
            color: AppColors.textHint.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            '暂无动态',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '开始你的第一段旅程吧',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHint.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '探索城市',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final UserActivity activity;
  const _ActivityItem({required this.activity});

  IconData get _icon {
    switch (activity.type) {
      case 'journey_started':
        return Icons.play_arrow_rounded;
      case 'journey_completed':
        return Icons.check_circle_rounded;
      case 'seal_earned':
        return Icons.workspace_premium_rounded;
      case 'seal_chained':
        return Icons.link_rounded;
      case 'photo_taken':
        return Icons.photo_camera_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  Color get _iconColor {
    switch (activity.type) {
      case 'journey_started':
        return AppColors.info;
      case 'journey_completed':
        return AppColors.success;
      case 'seal_earned':
        return AppColors.sealGold;
      case 'seal_chained':
        return AppColors.tertiary;
      case 'photo_taken':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _timeAgo {
    final now = DateTime.now();
    final diff = now.difference(activity.createTime);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${activity.createTime.month}/${activity.createTime.day}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(_icon, size: 20, color: _iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                activity.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _timeAgo,
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
