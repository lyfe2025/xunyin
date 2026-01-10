import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/audio_providers.dart';

/// 右侧浮动控件 - Glassmorphism 风格
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
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FloatingButton(
              icon: Icons.person_outline_rounded,
              label: '我的',
              onTap: onProfileTap,
            ),
            _buildDivider(context),
            _FloatingButton(
              icon: Icons.workspace_premium_rounded,
              label: '印记',
              onTap: onSealsTap,
            ),
            _buildDivider(context),
            _FloatingButton(
              icon: Icons.photo_library_outlined,
              label: '相册',
              onTap: onAlbumTap,
            ),
            _buildDivider(context),
            _FloatingButton(
              icon: audioState.isPlaying
                  ? Icons.music_note_rounded
                  : Icons.music_off_rounded,
              label: '音乐',
              isActive: audioState.isPlaying,
              onTap: () {
                ref.read(audioStateProvider.notifier).togglePlay();
              },
            ),
            _buildDivider(context),
            _FloatingButton(
              icon: Icons.my_location_rounded,
              label: '定位',
              onTap: onLocationTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: 28,
      height: 1,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBorder.withValues(alpha: 0.6)
            : AppColors.divider.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(1),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isActive
                      ? AppColors.accent
                      : AppColors.textSecondaryAdaptive(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? AppColors.accent
                      : AppColors.textHintAdaptive(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
