import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/storage/token_storage.dart';
import '../../../providers/audio_providers.dart';

/// 设置页面
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioStateProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('设置', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection('通用', [
            _SwitchTile(
              title: '背景音乐',
              value: audioState.isPlaying,
              onChanged: (v) =>
                  ref.read(audioStateProvider.notifier).togglePlay(),
            ),
            _SwitchTile(title: '消息通知', value: true, onChanged: (v) {}),
            _SwitchTile(title: '自动定位', value: true, onChanged: (v) {}),
          ]),
          _buildSection('账号', [
            _MenuTile(title: '修改昵称', onTap: () {}),
            _MenuTile(title: '修改头像', onTap: () {}),
            _MenuTile(title: '绑定手机', onTap: () {}),
          ]),
          _buildSection('其他', [
            _MenuTile(
              title: '关于我们',
              onTap: () => context.push('/agreement/about_us'),
            ),
            _MenuTile(
              title: '用户协议',
              onTap: () => context.push('/agreement/user_agreement'),
            ),
            _MenuTile(
              title: '隐私政策',
              onTap: () => context.push('/agreement/privacy_policy'),
            ),
            _MenuTile(
              title: '清除缓存',
              onTap: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('缓存已清除'))),
            ),
          ]),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => _showLogoutDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              child: const Text('退出登录'),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '版本 1.0.0',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accent,
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _MenuTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
