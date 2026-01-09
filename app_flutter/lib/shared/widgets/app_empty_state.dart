import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// 统一的空状态组件（支持图标或插画）
class AppEmptyState extends StatelessWidget {
  final IconData? icon;
  final String? illustrationPath;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    this.icon,
    this.illustrationPath,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  }) : assert(icon != null || illustrationPath != null);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: AppOpacity.glassCard),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustrationPath != null)
              SvgPicture.asset(
                illustrationPath!,
                width: 160,
                height: 120,
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.textHint.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: AppColors.textHint.withValues(alpha: 0.4),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint.withValues(alpha: 0.7),
                ),
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                  ),
                  child: Text(
                    actionText!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 需要登录的空状态
class AppLoginRequiredState extends StatelessWidget {
  final VoidCallback? onLogin;

  const AppLoginRequiredState({super.key, this.onLogin});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.lock_outline_rounded,
      title: '请先登录',
      subtitle: '登录后即可查看内容',
      actionText: '去登录',
      onAction: onLogin,
    );
  }
}

/// 加载失败/网络错误的空状态（使用插画）
class AppErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const AppErrorState({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      illustrationPath: 'assets/illustrations/error_network.svg',
      title: '加载失败',
      subtitle: message ?? '请检查网络后重试',
      actionText: onRetry != null ? '重试' : null,
      onAction: onRetry,
    );
  }
}

/// 搜索无结果的空状态（使用插画）
class AppNoResultState extends StatelessWidget {
  final String? keyword;

  const AppNoResultState({super.key, this.keyword});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      illustrationPath: 'assets/illustrations/no_search_result.svg',
      title: '没有找到结果',
      subtitle: keyword != null ? '没有找到与"$keyword"相关的内容' : '换个关键词试试吧',
    );
  }
}

/// 城市无文化之旅的空状态（使用插画）
class AppEmptyCityState extends StatelessWidget {
  final String? cityName;

  const AppEmptyCityState({super.key, this.cityName});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      illustrationPath: 'assets/illustrations/empty_city.svg',
      title: '暂无文化之旅',
      subtitle: cityName != null ? '$cityName暂时没有开放的文化之旅' : '敬请期待更多精彩内容',
    );
  }
}
