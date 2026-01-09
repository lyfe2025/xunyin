import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/app_info.dart';
import '../../../providers/audio_providers.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/section_title.dart';

/// 设置页面 - Aurora UI + Glassmorphism
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          const AuroraBackground(variant: AuroraVariant.standard),
          SafeArea(
            child: Column(
              children: [
                const AppPageHeader(title: '设置'),
                Expanded(child: _SettingsContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: '清除缓存',
      content: '确定要清除所有缓存数据吗？',
      confirmText: '清除',
      confirmColor: AppColors.warning,
    );

    if (confirmed == true) {
      await ref.read(settingsProvider.notifier).clearCache();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('缓存已清除'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: '退出登录',
      content: '确定要退出登录吗？',
      confirmText: '退出',
      confirmColor: AppColors.error,
    );

    if (confirmed == true && context.mounted) {
      // 清除 Token
      await TokenStorage.clearTokens();
      // 清除用户状态
      ref.read(authStateProvider.notifier).setLoggedOut();
      // 刷新用户信息（使缓存失效）
      ref.invalidate(currentUserProvider);
      ref.invalidate(userStatsProvider);

      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: '注销账户',
      content: '注销后，您的账户数据将被永久删除，包括收集的印记、旅程进度等。此操作不可恢复，确定要继续吗？',
      confirmText: '确认注销',
      confirmColor: AppColors.error,
    );

    if (confirmed == true && context.mounted) {
      try {
        // 调用注销 API
        final userService = ref.read(userServiceProvider);
        await userService.deleteAccount();

        // 清除本地数据
        await TokenStorage.clearTokens();
        ref.read(authStateProvider.notifier).setLoggedOut();
        ref.invalidate(currentUserProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('账户已注销'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('注销失败: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioStateProvider);
    final settings = ref.watch(settingsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    // 手机号脱敏显示
    String? maskedPhone;
    if (user?.phone != null && user!.phone!.length >= 7) {
      maskedPhone =
          '${user.phone!.substring(0, 3)}****${user.phone!.substring(user.phone!.length - 4)}';
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildSection('通用', [
          _SwitchTile(
            icon: Icons.music_note_rounded,
            title: '背景音乐',
            value: audioState.isPlaying,
            onChanged: (_) =>
                ref.read(audioStateProvider.notifier).togglePlay(),
          ),
          _SwitchTile(
            icon: Icons.notifications_rounded,
            title: '消息通知',
            value: settings.notificationEnabled,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setNotificationEnabled(v),
          ),
          _SwitchTile(
            icon: Icons.location_on_rounded,
            title: '自动定位',
            value: settings.autoLocationEnabled,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setAutoLocationEnabled(v),
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('账号', [
          _MenuTile(
            icon: Icons.edit_rounded,
            title: '修改昵称',
            subtitle: user?.nickname,
            onTap: () => context.push('/settings/nickname'),
          ),
          _MenuTile(
            icon: Icons.face_rounded,
            title: '修改头像',
            trailing: user?.avatarUrl != null
                ? CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(user!.avatarUrl!),
                  )
                : null,
            onTap: () => context.push('/settings/avatar'),
          ),
          _MenuTile(
            icon: Icons.phone_rounded,
            title: '绑定手机',
            subtitle: maskedPhone ?? '未绑定',
            onTap: () => context.push('/settings/phone'),
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('其他', [
          _MenuTile(
            icon: Icons.info_rounded,
            title: '关于我们',
            onTap: () => context.push('/agreement/about_us'),
          ),
          _MenuTile(
            icon: Icons.description_rounded,
            title: '用户协议',
            onTap: () => context.push('/agreement/user_agreement'),
          ),
          _MenuTile(
            icon: Icons.privacy_tip_rounded,
            title: '隐私政策',
            onTap: () => context.push('/agreement/privacy_policy'),
          ),
          _MenuTile(
            icon: Icons.cleaning_services_rounded,
            title: '清除缓存',
            subtitle: settings.cacheSize,
            onTap: () => _clearCache(context, ref),
          ),
          _MenuTile(
            icon: Icons.delete_forever_rounded,
            title: '注销账户',
            titleColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: () => _handleDeleteAccount(context, ref),
          ),
        ]),
        const SizedBox(height: 24),
        _LogoutButton(onTap: () => _handleLogout(context, ref)),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '版本 ${AppInfo.version}',
            style: const TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: SectionTitle(title: title, color: AppColors.textSecondary),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                SizedBox(width: 8),
                Text(
                  '退出登录',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.textSecondary),
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
                IgnorePointer(
                  child: Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: value,
                      onChanged: onChanged,
                      activeColor: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.iconColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: trailing!,
                  ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
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
