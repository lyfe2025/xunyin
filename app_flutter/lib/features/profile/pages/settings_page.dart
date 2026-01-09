import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/storage/settings_storage.dart';
import '../../../providers/audio_providers.dart';

/// 设置页面 - Aurora UI + Glassmorphism
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationEnabled = true;
  bool _autoLocationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notification = await SettingsStorage.getNotificationEnabled();
    final location = await SettingsStorage.getAutoLocationEnabled();
    if (mounted) {
      setState(() {
        _notificationEnabled = notification;
        _autoLocationEnabled = location;
      });
    }
  }

  Future<void> _clearCache() async {
    await SettingsStorage.clearCache();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('缓存已清除'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioStateProvider);

    return Scaffold(
      body: Stack(
        children: [
          const _AuroraBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(child: _buildContent(audioState)),
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
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            '设置',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(audioState) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildSection('通用', Icons.settings_rounded, AppColors.primary, [
          _SwitchTile(
            icon: Icons.music_note_rounded,
            title: '背景音乐',
            value: audioState.isPlaying,
            onChanged: (v) =>
                ref.read(audioStateProvider.notifier).togglePlay(),
          ),
          _SwitchTile(
            icon: Icons.notifications_rounded,
            title: '消息通知',
            value: _notificationEnabled,
            onChanged: (v) async {
              setState(() => _notificationEnabled = v);
              await SettingsStorage.setNotificationEnabled(v);
            },
          ),
          _SwitchTile(
            icon: Icons.location_on_rounded,
            title: '自动定位',
            value: _autoLocationEnabled,
            onChanged: (v) async {
              setState(() => _autoLocationEnabled = v);
              await SettingsStorage.setAutoLocationEnabled(v);
            },
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('账号', Icons.person_rounded, AppColors.accent, [
          _MenuTile(
            icon: Icons.edit_rounded,
            title: '修改昵称',
            onTap: () => context.push('/settings/nickname'),
          ),
          _MenuTile(
            icon: Icons.face_rounded,
            title: '修改头像',
            onTap: () => context.push('/settings/avatar'),
          ),
          _MenuTile(
            icon: Icons.phone_rounded,
            title: '绑定手机',
            onTap: () => context.push('/settings/phone'),
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('其他', Icons.more_horiz_rounded, AppColors.tertiary, [
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
            onTap: _clearCache,
          ),
        ]),
        const SizedBox(height: 24),
        _buildLogoutButton(),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            '版本 1.0.0',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
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

  Widget _buildLogoutButton() {
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
          onTap: () => _showLogoutDialog(context),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await TokenStorage.clearTokens();
              if (context.mounted) {
                Navigator.pop(ctx);
                context.go('/login');
              }
            },
            child: const Text('退出', style: TextStyle(color: AppColors.error)),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aurora 背景
class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F6F3), Color(0xFFF0EDE8), Color(0xFFE8E4DD)],
        ),
      ),
      child: CustomPaint(painter: _AuroraPainter(), size: Size.infinite),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = AppColors.primary.withValues(alpha: 0.08);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.1),
      size.width * 0.35,
      paint,
    );
    paint.color = AppColors.accent.withValues(alpha: 0.06);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.35),
      size.width * 0.3,
      paint,
    );
    paint.color = AppColors.tertiary.withValues(alpha: 0.05);
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.85),
      size.width * 0.4,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
