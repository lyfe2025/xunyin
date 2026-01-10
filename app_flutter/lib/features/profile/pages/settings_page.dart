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
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_snackbar.dart';
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
  void _showThemeModeSheet(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode currentMode,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground(ctx),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderAdaptive(ctx),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '选择主题模式',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryAdaptive(ctx),
                ),
              ),
              const SizedBox(height: 16),
              _ThemeModeOption(
                icon: Icons.brightness_auto_rounded,
                title: '跟随系统',
                subtitle: '自动切换浅色/深色模式',
                isSelected: currentMode == AppThemeMode.system,
                onTap: () {
                  ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.system);
                  Navigator.pop(ctx);
                },
              ),
              _ThemeModeOption(
                icon: Icons.light_mode_rounded,
                title: '浅色模式',
                subtitle: '始终使用浅色主题',
                isSelected: currentMode == AppThemeMode.light,
                onTap: () {
                  ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.light);
                  Navigator.pop(ctx);
                },
              ),
              _ThemeModeOption(
                icon: Icons.dark_mode_rounded,
                title: '深色模式',
                subtitle: '始终使用深色主题',
                isSelected: currentMode == AppThemeMode.dark,
                onTap: () {
                  ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.dark);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: '清除缓存',
      content: '确定要清除所有缓存数据吗？',
      confirmText: '清除',
      icon: Icons.cleaning_services_rounded,
    );

    if (confirmed == true) {
      await ref.read(settingsProvider.notifier).clearCache();
      if (context.mounted) {
        AppSnackBar.success(context, '缓存已清除');
      }
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: '退出登录',
      content: '确定要退出登录吗？',
      confirmText: '退出',
      isDanger: true,
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
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: '注销账户',
      content: '注销后，您的账户数据将被永久删除，包括收集的印记、旅程进度等。此操作不可恢复，确定要继续吗？',
      confirmText: '确认注销',
      isDanger: true,
      icon: Icons.delete_forever_rounded,
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
          AppSnackBar.success(context, '账户已注销');
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackBar.error(context, '注销失败: $e');
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
        _buildSection(context, '通用', [
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
          _MenuTile(
            icon: Icons.dark_mode_rounded,
            title: '深色模式',
            subtitle: settings.themeModeLabel,
            onTap: () => _showThemeModeSheet(context, ref, settings.themeMode),
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection(context, '账号', [
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
        _buildSection(context, '其他', [
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
            showDivider: false,
            backgroundColor: AppColors.error.withValues(alpha: 0.05),
            onTap: () => _handleDeleteAccount(context, ref),
          ),
        ]),
        const SizedBox(height: 24),
        _LogoutButton(onTap: () => _handleLogout(context, ref)),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '版本 ${AppInfo.version}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHintAdaptive(context),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final isDark = context.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: SectionTitle(title: title),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.06),
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
    final isDark = context.isDarkMode;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.88),
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
                Icon(icon, size: 20, color: AppColors.textSecondaryAdaptive(context)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimaryAdaptive(context),
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
  final Color? backgroundColor;
  final Widget? trailing;
  final bool showDivider;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.iconColor,
    this.backgroundColor,
    this.trailing,
    this.showDivider = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
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
                  color: iconColor ?? AppColors.textSecondaryAdaptive(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: titleColor ?? AppColors.textPrimaryAdaptive(context),
                    ),
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textHintAdaptive(context),
                      ),
                    ),
                  ),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: trailing!,
                  ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHintAdaptive(context),
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

/// 主题模式选项
class _ThemeModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent.withValues(alpha: 0.08) : null,
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderAdaptive(context).withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : AppColors.surfaceVariantAdaptive(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppColors.accent : AppColors.textSecondaryAdaptive(context),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.accent : AppColors.textPrimaryAdaptive(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHintAdaptive(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
