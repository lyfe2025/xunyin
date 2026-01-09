import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/user_providers.dart';
import '../../../models/user.dart';
import '../../../models/journey.dart';
import '../../../models/profile_home.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/app_page_header.dart';

/// 根据字符串生成稳定的颜色
Color _generateColorFromName(String name) {
  if (name.isEmpty) return AppColors.accent;
  final hash = name.codeUnits.fold(0, (prev, curr) => prev + curr);
  final colors = [
    const Color(0xFFE57373),
    const Color(0xFFFFB74D),
    const Color(0xFFFFD54F),
    const Color(0xFF81C784),
    const Color(0xFF4FC3F7),
    const Color(0xFF9575CD),
    const Color(0xFFF06292),
    const Color(0xFF4DB6AC),
  ];
  return colors[hash % colors.length];
}

/// 个人中心页面 - 完整优化版本
/// 布局顺序：身份 → 行动 → 成就 → 反馈 → 探索
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    // 触感反馈
    HapticFeedback.mediumImpact();
    ref.invalidate(profileHomeProvider);
    await ref.read(profileHomeProvider.future);
    // 刷新成功反馈
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(profileHomeProvider);

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
                    child: homeDataAsync.when(
                      data: (data) => _buildContent(context, data),
                      loading: () => _buildSkeletonState(),
                      error: (e, _) => _buildErrorState(context, ref, e),
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

  /// 判断是否为新用户
  bool _isNewUser(ProfileHomeData data) {
    final stats = data.stats;
    return stats.completedJourneys == 0 &&
        stats.collectedSeals == 0 &&
        stats.unlockedCities == 0 &&
        data.inProgressJourneys.isEmpty;
  }

  Widget _buildContent(BuildContext context, ProfileHomeData data) {
    final isNew = _isNewUser(data);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        // 1. 用户卡片
        _UserCard(user: data.user),
        const SizedBox(height: 16),

        // 2. 进行中的旅程 / 新用户引导
        if (data.inProgressJourneys.isNotEmpty)
          _InProgressSection(journeys: data.inProgressJourneys)
        else
          _StartJourneyCard(isNewUser: isNew),
        const SizedBox(height: 16),

        // 3. 成就概览（新用户隐藏）
        if (!isNew) ...[
          _AchievementCard(stats: data.stats),
          const SizedBox(height: 16),
        ],

        // 4. 最近动态
        if (data.recentActivities.isNotEmpty || !isNew) ...[
          _ActivitiesSection(
            activities: data.recentActivities,
            isNewUser: isNew,
          ),
          const SizedBox(height: 16),
        ],

        // 5. 快捷操作
        _QuickActions(),
        const SizedBox(height: 24),
      ],
    );
  }

  /// 骨架屏 - 与实际布局一致
  Widget _buildSkeletonState() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        // 用户卡片骨架
        _SkeletonCard(
          height: 100,
          child: Row(
            children: [
              _SkeletonCircle(size: 68),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SkeletonBox(width: 100, height: 20),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _SkeletonBox(width: 60, height: 24, radius: 12),
                        const SizedBox(width: 8),
                        _SkeletonBox(width: 50, height: 24, radius: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 进行中旅程骨架
        _SkeletonBox(width: 80, height: 16),
        const SizedBox(height: 10),
        SizedBox(
          height: 95,
          child: Row(
            children: [
              Expanded(child: _SkeletonCard(height: 95)),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonCard(height: 95)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 成就卡片骨架
        _SkeletonCard(height: 90),
        const SizedBox(height: 16),
        // 动态骨架
        _SkeletonBox(width: 60, height: 16),
        const SizedBox(height: 10),
        _SkeletonCard(height: 150),
        const SizedBox(height: 16),
        // 快捷操作骨架
        _SkeletonBox(width: 40, height: 16),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _SkeletonCard(height: 90)),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonCard(height: 90)),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonCard(height: 90)),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.textHint.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _onRefresh(ref),
            child: Text('点击重试', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}


// ==================== 骨架屏组件 ====================

class _SkeletonCard extends StatelessWidget {
  final double height;
  final Widget? child;
  const _SkeletonCard({required this.height, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: child != null ? const EdgeInsets.all(16) : null,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  final double size;
  const _SkeletonCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ==================== 用户卡片 ====================

class _UserCard extends StatelessWidget {
  final AppUser? user;
  const _UserCard({this.user});

  Widget _buildAvatar(BuildContext context) {
    final displayName = user?.displayName ?? '旅行者';
    final avatarColor = _generateColorFromName(displayName);

    Widget avatar;
    if (user?.avatarUrl != null) {
      avatar = ClipOval(
        child: Image.network(
          user!.avatarUrl!,
          width: 68,
          height: 68,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _buildTextAvatar(displayName, avatarColor),
        ),
      );
    } else {
      avatar = _buildTextAvatar(displayName, avatarColor);
    }

    // 头像可点击修改
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/settings/avatar');
      },
      child: Container(
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
        child: avatar,
      ),
    );
  }

  Widget _buildTextAvatar(String name, Color color) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 68,
      height: 68,
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
            fontSize: 26,
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
      padding: const EdgeInsets.all(18),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
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
          _buildAvatar(context),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? '旅行者',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // 积分徽章
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sealGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            size: 14,
                            color: AppColors.sealGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${user?.totalPoints ?? 0}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.sealGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (user?.badgeTitle != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user!.badgeTitle!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/settings/nickname');
            },
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


// ==================== 新用户引导卡片 ====================

class _StartJourneyCard extends StatelessWidget {
  final bool isNewUser;
  const _StartJourneyCard({this.isNewUser = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go('/');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accent.withValues(alpha: 0.08),
              AppColors.primary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            // 新用户显示欢迎插画
            if (isNewUser)
              SvgPicture.asset(
                'assets/illustrations/welcome_new_user.svg',
                width: 80,
                height: 60,
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.explore_rounded,
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
                    isNewUser ? '开始你的第一段旅程' : '继续探索新城市',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isNewUser ? '发现城市文化，收集专属印记' : '更多精彩旅程等你解锁',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 进行中的旅程 ====================

class _InProgressSection extends StatelessWidget {
  final List<JourneyProgress> journeys;
  const _InProgressSection({required this.journeys});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Text(
                '继续探索',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${journeys.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: journeys.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _InProgressCard(journey: journeys[index]),
          ),
        ),
      ],
    );
  }
}

/// 进行中旅程卡片 - 显示城市名称
class _InProgressCard extends StatefulWidget {
  final JourneyProgress journey;
  const _InProgressCard({required this.journey});

  @override
  State<_InProgressCard> createState() => _InProgressCardState();
}

class _InProgressCardState extends State<_InProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journey = widget.journey;
    final progress = journey.totalPoints > 0
        ? journey.completedPoints / journey.totalPoints
        : 0.0;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        context.push('/journey/${journey.journeyId}/progress');
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: 175,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 14,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
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
              // 城市名称
              if (journey.cityName != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Text(
                    journey.cityName!,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const Spacer(),
              // 进度条
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.divider.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                  Text(
                    '${journey.completedPoints}/${journey.totalPoints}',
                    style: TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ==================== 成就概览卡片 ====================

class _AchievementCard extends StatelessWidget {
  final UserStats stats;
  const _AchievementCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _AchievementItem(
              icon: Icons.location_city_rounded,
              color: AppColors.primary,
              value: stats.totalCities > 0
                  ? '${stats.unlockedCities}/${stats.totalCities}'
                  : '0',
              label: '城市',
              onTap: () {
                HapticFeedback.lightImpact();
                context.go('/');
              },
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _AchievementItem(
              icon: Icons.workspace_premium_rounded,
              color: AppColors.sealGold,
              value: '${stats.collectedSeals}',
              label: '印记',
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/seals');
              },
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _AchievementItem(
              icon: Icons.route_rounded,
              color: AppColors.success,
              value: '${stats.completedJourneys}',
              label: '旅程',
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/journeys');
              },
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _AchievementItem(
              icon: Icons.straighten_rounded,
              color: AppColors.info,
              value: stats.totalDistance > 0 ? stats.formattedDistance : '0',
              label: '行程',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.divider.withValues(alpha: 0.4),
    );
  }
}

/// 成就项 - 带点击缩放动画
class _AchievementItem extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _AchievementItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  State<_AchievementItem> createState() => _AchievementItemState();
}

class _AchievementItemState extends State<_AchievementItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, size: 20, color: widget.color),
        const SizedBox(height: 6),
        Text(
          widget.value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.label,
          style: TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _controller.reverse(),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: content,
        ),
      );
    }
    return content;
  }
}


// ==================== 最近动态 ====================

class _ActivitiesSection extends StatelessWidget {
  final List<UserActivity> activities;
  final bool isNewUser;
  const _ActivitiesSection({
    required this.activities,
    this.isNewUser = false,
  });

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
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
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
                  children: activities.take(3).indexed.map((item) {
                    final (index, activity) = item;
                    return Column(
                      children: [
                        if (index > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 48),
                            child: Divider(
                              height: 1,
                              color: AppColors.divider.withValues(alpha: 0.4),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/illustrations/empty_activity.svg',
            width: 140,
            height: 105,
          ),
          const SizedBox(height: 12),
          const Text(
            '暂无动态',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '完成探索后，你的足迹会显示在这里',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 动态项
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
      case 'point_completed':
        return Icons.flag_rounded;
      case 'level_up':
        return Icons.trending_up_rounded;
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
      case 'point_completed':
        return AppColors.primary;
      case 'level_up':
        return AppColors.warning;
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
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(_icon, size: 18, color: _iconColor),
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
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 快捷操作 ====================

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            '更多',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _QuickActionItem(
                icon: Icons.workspace_premium_rounded,
                color: AppColors.sealGold,
                label: '印记集',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/seals');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionItem(
                icon: Icons.photo_library_rounded,
                color: AppColors.tertiary,
                label: '相册',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/album');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionItem(
                icon: Icons.route_rounded,
                color: AppColors.primary,
                label: '旅程',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/journeys');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 快捷操作项 - 带点击缩放动画
class _QuickActionItem extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  State<_QuickActionItem> createState() => _QuickActionItemState();
}

class _QuickActionItemState extends State<_QuickActionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, size: 22, color: widget.color),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
