import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// 统一的 SnackBar 工具类 - Glassmorphism 风格
///
/// 设计原则：
/// - 统一使用玻璃态背景，融入 App 整体视觉
/// - 通过图标颜色区分语义（成功绿、错误红、普通灰）
/// - 不使用多种背景色，保持视觉一致性
class AppSnackBar {
  AppSnackBar._();

  /// 成功提示 - 绿色图标
  static void success(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.success,
      duration: duration,
    );
  }

  /// 错误提示 - 红色图标
  static void error(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.cancel_rounded,
      iconColor: AppColors.error,
      duration: duration,
    );
  }

  /// 警告提示 - 橙色图标（语义上归类为普通提示）
  static void warning(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.warning,
      duration: duration,
    );
  }

  /// 信息提示 - 普通图标
  static void info(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      duration: duration,
    );
  }

  /// 普通提示
  static void show(BuildContext context, String message, {Duration? duration, IconData? icon}) {
    _show(
      context,
      message: message,
      icon: icon,
      duration: duration,
    );
  }

  /// 带操作按钮的提示
  static void withAction(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    Duration? duration,
  }) {
    _showWithAction(
      context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// 加载中提示（不自动消失）
  static void loading(BuildContext context, String message) {
    _show(
      context,
      message: message,
      isLoading: true,
      duration: const Duration(minutes: 5),
    );
  }

  /// 隐藏当前 SnackBar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// 内部显示方法 - 玻璃态风格
  static void _show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? iconColor,
    Duration? duration,
    bool isLoading = false,
  }) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final defaultIconColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  if (isLoading) ...[
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: iconColor ?? defaultIconColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ] else if (icon != null) ...[
                    Icon(icon, color: iconColor ?? defaultIconColor, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(color: textColor, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: isDark
            ? AppColors.darkSurface.withValues(alpha: AppOpacity.glassCard)
            : Colors.white.withValues(alpha: AppOpacity.glassCard),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: AppOpacity.glassBorder)
                : AppColors.border.withValues(alpha: AppOpacity.glassBorder),
          ),
        ),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// 带操作按钮的显示方法
  static void _showWithAction(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    Duration? duration,
  }) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                message,
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ),
          ),
        ),
        backgroundColor: isDark
            ? AppColors.darkSurface.withValues(alpha: AppOpacity.glassCard)
            : Colors.white.withValues(alpha: AppOpacity.glassCard),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: AppOpacity.glassBorder)
                : AppColors.border.withValues(alpha: AppOpacity.glassBorder),
          ),
        ),
        duration: duration ?? const Duration(seconds: 4),
        action: SnackBarAction(
          label: actionLabel,
          textColor: AppColors.accent,
          onPressed: onAction,
        ),
      ),
    );
  }
}

/// Toast 风格的轻量提示（居中显示，自动消失）- Glassmorphism 风格
class AppToast {
  AppToast._();

  static OverlayEntry? _currentToast;

  /// 显示 Toast
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    IconData? icon,
    Color? iconColor,
  }) {
    _currentToast?.remove();

    final overlay = Overlay.of(context);
    final isDark = context.isDarkMode;

    _currentToast = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        icon: icon,
        iconColor: iconColor,
        isDark: isDark,
        onDismiss: () {
          _currentToast?.remove();
          _currentToast = null;
        },
        duration: duration,
      ),
    );

    overlay.insert(_currentToast!);
  }

  /// 成功 Toast - 绿色图标
  static void success(BuildContext context, String message) {
    show(
      context,
      message,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.success,
    );
  }

  /// 错误 Toast - 红色图标
  static void error(BuildContext context, String message) {
    show(
      context,
      message,
      icon: Icons.cancel_rounded,
      iconColor: AppColors.error,
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final bool isDark;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    this.icon,
    this.iconColor,
    required this.isDark,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final defaultIconColor = widget.isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.15,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? AppColors.darkSurface.withValues(alpha: AppOpacity.glassCard)
                      : Colors.white.withValues(alpha: AppOpacity.glassCard),
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  border: Border.all(
                    color: widget.isDark
                        ? AppColors.darkBorder.withValues(alpha: AppOpacity.glassBorder)
                        : AppColors.border.withValues(alpha: AppOpacity.glassBorder),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.iconColor ?? defaultIconColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.message,
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
