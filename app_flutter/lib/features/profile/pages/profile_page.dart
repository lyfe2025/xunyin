import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/user_providers.dart';
import '../../../models/user.dart';

/// 个人中心页面
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '个人中心',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textSecondary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _UserCard(userAsync: userAsync),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => _StatsCard(stats: stats),
            loading: () => const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => _StatsCard(stats: UserStats()),
          ),
          const SizedBox(height: 24),
          _MenuSection(),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AsyncValue<AppUser?> userAsync;
  const _UserCard({required this.userAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 32,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userAsync.when(
                  data: (user) => Text(
                    user?.displayName ?? '旅行者',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const Text('加载中...'),
                  error: (_, __) => const Text('旅行者'),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ID: 12345678',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
              ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: '${stats.unlockedCities}/${stats.totalCities}',
            label: '城市解锁',
          ),
          _StatItem(value: '${stats.collectedSeals}', label: '印记收集'),
          _StatItem(value: '${stats.chainedSeals}', label: '已上链'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Text('🏆', style: TextStyle(fontSize: 20)),
            title: const Text('我的印记集'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
            ),
            onTap: () => context.push('/seals'),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Text('📸', style: TextStyle(fontSize: 20)),
            title: const Text('我的相册'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
            ),
            onTap: () => context.push('/album'),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Text('⚙️', style: TextStyle(fontSize: 20)),
            title: const Text('设置'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
            ),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}
