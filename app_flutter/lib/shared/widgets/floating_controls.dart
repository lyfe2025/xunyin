import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/audio_providers.dart';

/// 右侧浮动控件（我的、印记、相册、音乐、定位）
class FloatingControls extends ConsumerWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onSealsTap;
  final VoidCallback onAlbumTap;
  final VoidCallback onLocationTap;

  const FloatingControls({
    super.key,
    required this.onProfileTap,
    required this.onSealsTap,
    required this.onAlbumTap,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioStateProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FloatingButton(
              icon: Icons.person_outline,
              label: '我的',
              onTap: onProfileTap,
            ),
            const _Divider(),
            _FloatingButton(
              icon: Icons.emoji_events_outlined,
              label: '印记',
              onTap: onSealsTap,
            ),
            const _Divider(),
            _FloatingButton(
              icon: Icons.photo_library_outlined,
              label: '相册',
              onTap: onAlbumTap,
            ),
            const _Divider(),
            _FloatingButton(
              icon: audioState.isPlaying
                  ? Icons.music_note
                  : Icons.music_off_outlined,
              label: '音乐',
              isActive: audioState.isPlaying,
              onTap: () {
                ref.read(audioStateProvider.notifier).togglePlay();
              },
            ),
            const _Divider(),
            _FloatingButton(
              icon: Icons.my_location,
              label: '定位',
              onTap: onLocationTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _FloatingButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 32, height: 1, color: AppColors.divider);
  }
}
