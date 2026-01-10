import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 统一的分组标题组件 - 简洁风格
class SectionTitle extends StatelessWidget {
  final String title;
  final Color? color;
  final IconData? icon;
  final Widget? trailing;

  const SectionTitle({
    super.key,
    required this.title,
    this.color,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textPrimaryAdaptive(context);

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: effectiveColor),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: effectiveColor,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// 带数量徽章的分组标题 - 简洁风格
class SectionTitleWithBadge extends StatelessWidget {
  final String title;
  final int count;
  final Color? color;

  const SectionTitleWithBadge({
    super.key,
    required this.title,
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textPrimaryAdaptive(context);

    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: effectiveColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}
