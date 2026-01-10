import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// 统一的返回按钮组件 - Glassmorphism 风格
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? iconColor;

  const AppBackButton({super.key, this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: onTap ?? () => context.pop(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: iconColor ?? AppColors.textPrimaryAdaptive(context),
          size: 22,
        ),
      ),
    );
  }
}
