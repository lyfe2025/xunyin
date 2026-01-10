import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// 统一的加载组件 - 带品牌呼吸动画
class AppLoading extends StatefulWidget {
  final String? message;
  final double size;
  final Color? color;

  const AppLoading({super.key, this.message, this.size = 32, this.color});

  @override
  State<AppLoading> createState() => _AppLoadingState();
}

class _AppLoadingState extends State<AppLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.accent;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) => Container(
              width: widget.size + 16,
              height: widget.size + 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: _glowAnimation.value * 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: child,
            ),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: color,
              ),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.message!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryAdaptive(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 简单加载指示器（无动画，用于小空间）
class AppLoadingSimple extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const AppLoadingSimple({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? AppColors.accent,
      ),
    );
  }
}

/// 带卡片容器的加载组件
class AppLoadingCard extends StatelessWidget {
  final String? message;
  final double height;

  const AppLoadingCard({super.key, this.message, this.height = 150});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.5),
        ),
      ),
      child: AppLoading(message: message),
    );
  }
}

/// 全屏加载遮罩
class AppLoadingOverlay extends StatelessWidget {
  final String? message;

  const AppLoadingOverlay({super.key, this.message});

  /// 显示全屏加载遮罩
  static Future<T> show<T>({
    required BuildContext context,
    required Future<T> Function() task,
    String? message,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) => AppLoadingOverlay(message: message),
    );
    try {
      final result = await task();
      if (context.mounted) Navigator.of(context).pop();
      return result;
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkSurface.withValues(alpha: 0.95),
                      AppColors.darkSurface.withValues(alpha: 0.9),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.9),
                    ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.cardLarge),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLoading(size: 40),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondaryAdaptive(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 页面级加载状态（用于整页加载）
class AppPageLoading extends StatelessWidget {
  final String? message;

  const AppPageLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLoading(size: 40),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              message!,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondaryAdaptive(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
