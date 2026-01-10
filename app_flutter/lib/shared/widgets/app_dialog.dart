import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// 统一的对话框组件 - Glassmorphism 风格
class AppDialog extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final String? content;
  final Widget? contentWidget;
  final List<Widget>? actions;
  final IconData? icon;
  final Color? iconColor;
  final bool showCloseButton;

  const AppDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.content,
    this.contentWidget,
    this.actions,
    this.icon,
    this.iconColor,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkSurface.withValues(alpha: 0.98),
                    AppColors.darkSurface.withValues(alpha: 0.95),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.98),
                    Colors.white.withValues(alpha: 0.95),
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
              color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 关闭按钮
            if (showCloseButton)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.textHintAdaptive(context),
                      size: 20,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: showCloseButton ? 0 : 28,
                bottom: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 图标
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.accent).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: iconColor ?? AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  // 标题
                  if (titleWidget != null)
                    titleWidget!
                  else if (title != null)
                    Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryAdaptive(context),
                      ),
                    ),
                  // 内容
                  if (contentWidget != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    contentWidget!,
                  ] else if (content != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      content!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondaryAdaptive(context),
                        height: 1.5,
                      ),
                    ),
                  ],
                  // 操作按钮
                  if (actions != null && actions!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: actions!
                          .map((action) => Expanded(child: action))
                          .toList()
                          .expand((widget) => [widget, const SizedBox(width: 12)])
                          .toList()
                        ..removeLast(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 确认对话框
class AppConfirmDialog extends StatefulWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final Color? confirmColor;
  final IconData? icon;
  final bool isDanger;
  final Future<void> Function()? onConfirm;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText = '取消',
    this.confirmText = '确定',
    this.confirmColor,
    this.icon,
    this.isDanger = false,
    this.onConfirm,
  });

  /// 显示确认对话框
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String cancelText = '取消',
    String confirmText = '确定',
    Color? confirmColor,
    IconData? icon,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AppConfirmDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmColor: confirmColor,
        icon: icon,
        isDanger: isDanger,
        onConfirm: () async => Navigator.pop(ctx, true),
      ),
    );
  }

  @override
  State<AppConfirmDialog> createState() => _AppConfirmDialogState();
}

class _AppConfirmDialogState extends State<AppConfirmDialog> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (widget.onConfirm != null) {
      setState(() => _isLoading = true);
      try {
        await widget.onConfirm!();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    // 危险操作也使用品牌色，保持一致性
    final effectiveColor = widget.confirmColor ?? AppColors.accent;

    return AppDialog(
      icon: widget.icon ??
          (widget.isDanger ? Icons.warning_rounded : Icons.help_outline_rounded),
      iconColor: widget.isDanger ? AppColors.error : effectiveColor,
      title: widget.title,
      content: widget.content,
      actions: [
        // 取消按钮
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondaryAdaptive(context),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              side: BorderSide(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.border.withValues(alpha: 0.8),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.cancelText,
                maxLines: 1,
              ),
            ),
          ),
        ),
        // 确认按钮 - 统一使用品牌色渐变
        SizedBox(
          height: 44,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _handleConfirm,
              borderRadius: BorderRadius.circular(AppRadius.button),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isLoading
                        ? [AppColors.textHint, AppColors.textHint]
                        : [AppColors.accent, AppColors.accentDark],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  boxShadow: _isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.confirmText,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 成功对话框
class AppSuccessDialog extends StatelessWidget {
  final String title;
  final String? content;
  final String buttonText;
  final VoidCallback? onPressed;

  const AppSuccessDialog({
    super.key,
    required this.title,
    this.content,
    this.buttonText = '好的',
    this.onPressed,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    String? content,
    String buttonText = '好的',
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AppSuccessDialog(
        title: title,
        content: content,
        buttonText: buttonText,
        onPressed: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.success,
      title: title,
      content: content,
      actions: [
        SizedBox(
          height: 44,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed ?? () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(AppRadius.button),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentDark],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      buttonText,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 错误对话框
class AppErrorDialog extends StatelessWidget {
  final String title;
  final String? content;
  final String buttonText;
  final VoidCallback? onPressed;

  const AppErrorDialog({
    super.key,
    this.title = '出错了',
    this.content,
    this.buttonText = '知道了',
    this.onPressed,
  });

  static Future<void> show({
    required BuildContext context,
    String title = '出错了',
    String? content,
    String buttonText = '知道了',
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AppErrorDialog(
        title: title,
        content: content,
        buttonText: buttonText,
        onPressed: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.error,
      title: title,
      content: content,
      actions: [
        SizedBox(
          height: 44,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed ?? () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(AppRadius.button),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentDark],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      buttonText,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
