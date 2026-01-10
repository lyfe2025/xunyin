import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// 主要操作按钮 - 渐变背景
class AppPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final double? width;
  final double height;

  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.width,
    this.height = AppSize.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isLoading || onPressed == null
                    ? [AppColors.textHint, AppColors.textHint]
                    : [AppColors.accent, AppColors.accentDark],
              ),
              borderRadius: BorderRadius.circular(AppRadius.button),
              boxShadow: isLoading || onPressed == null
                  ? []
                  : AppShadow.accent(AppColors.accent),
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      child: IconTheme(
                        data: const IconThemeData(color: Colors.white, size: 20),
                        child: child,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 次要操作按钮 - 玻璃态/描边
class AppSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? borderColor;
  final Color? textColor;

  const AppSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.width,
    this.height = AppSize.buttonHeight,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.accent;
    final effectiveTextColor = textColor ?? AppColors.accent;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: AppOpacity.glassCard),
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: Border.all(color: effectiveBorderColor),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: effectiveTextColor,
                      ),
                    )
                  : DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: effectiveTextColor,
                      ),
                      child: IconTheme(
                        data: IconThemeData(color: effectiveTextColor, size: 18),
                        child: child,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 玻璃态按钮 - 用于分享等次要操作
class AppGlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double height;

  const AppGlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = AppSize.buttonHeightSmall,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.darkSurface.withValues(alpha: 0.9),
                        AppColors.darkSurface.withValues(alpha: 0.7),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.5),
                      ],
              ),
              border: Border.all(color: AppColors.borderAdaptive(context)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryAdaptive(context),
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: AppColors.textPrimaryAdaptive(context),
                    size: 18,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 关闭按钮 - 用于退出/关闭场景
class AppCloseButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const AppCloseButton({
    super.key,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.9)),
          borderRadius: BorderRadius.circular(AppRadius.iconButton),
          boxShadow: AppShadow.light,
        ),
        child: Icon(
          Icons.close_rounded,
          color: iconColor ?? AppColors.textPrimaryAdaptive(context),
          size: AppSize.appBarIconSize,
        ),
      ),
    );
  }
}

/// 深色背景下的关闭按钮
class AppCloseButtonDark extends StatelessWidget {
  final VoidCallback? onTap;

  const AppCloseButtonDark({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.iconButton),
        ),
        child: const Icon(
          Icons.close_rounded,
          color: Colors.white,
          size: AppSize.appBarIconSize,
        ),
      ),
    );
  }
}


/// 返回按钮 - 用于页面导航
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const AppBackButton({
    super.key,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.9)),
          borderRadius: BorderRadius.circular(AppRadius.iconButton),
          boxShadow: AppShadow.light,
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: iconColor ?? AppColors.textPrimaryAdaptive(context),
          size: AppSize.appBarIconSize,
        ),
      ),
    );
  }
}
