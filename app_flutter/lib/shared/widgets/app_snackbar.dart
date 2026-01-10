import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// 统一的 SnackBar 工具类 - 带图标和品牌色
class AppSnackBar {
  AppSnackBar._();

  /// 成功提示
  static void success(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: AppColors.success,
      duration: duration,
    );
  }

  /// 错误提示
  static void error(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: AppColors.error,
      duration: duration,
    );
  }

  /// 警告提示
  static void warning(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: AppColors.warning,
      textColor: Colors.black87,
      duration: duration,
    );
  }

  /// 信息提示
  static void info(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: AppColors.info,
      duration: duration,
    );
  }

  /// 普通提示（品牌色）
  static void show(BuildContext context, String message, {Duration? duration}) {
    final isDark = context.isDarkMode;
    _show(
      context,
      message: message,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.textPrimary,
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
    final isDark = context.isDarkMode;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
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

  /// 加载中提示（不自动消失）
  static void loading(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        duration: const Duration(minutes: 5), // 长时间，需手动关闭
      ),
    );
  }

  /// 隐藏当前 SnackBar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// 内部显示方法
  static void _show(
    BuildContext context, {
    required String message,
    IconData? icon,
    required Color backgroundColor,
    Color textColor = Colors.white,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
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
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}

/// Toast 风格的轻量提示（居中显示，自动消失）
class AppToast {
  AppToast._();

  static OverlayEntry? _currentToast;

  /// 显示 Toast
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    IconData? icon,
  }) {
    _currentToast?.remove();

    final overlay = Overlay.of(context);
    final isDark = context.isDarkMode;

    _currentToast = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        icon: icon,
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

  /// 成功 Toast
  static void success(BuildContext context, String message) {
    show(context, message, icon: Icons.check_circle_rounded);
  }

  /// 错误 Toast
  static void error(BuildContext context, String message) {
    show(context, message, icon: Icons.error_rounded);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final bool isDark;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    this.icon,
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.95)
                  : Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
