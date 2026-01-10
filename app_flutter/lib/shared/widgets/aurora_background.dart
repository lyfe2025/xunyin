import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 统一的 Aurora 渐变背景组件
class AuroraBackground extends StatelessWidget {
  /// 背景变体类型
  final AuroraVariant variant;

  const AuroraBackground({super.key, this.variant = AuroraVariant.standard});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: variant.gradientBegin,
          end: variant.gradientEnd,
          colors: isDark ? variant.darkGradientColors : variant.gradientColors,
        ),
      ),
      child: CustomPaint(
        painter: _AuroraPainter(variant: variant, isDark: isDark),
        size: Size.infinite,
      ),
    );
  }
}

/// Aurora 背景变体
enum AuroraVariant {
  /// 标准样式 - 用于大多数页面
  standard,

  /// 暖色调 - 用于登录、个人中心
  warm,

  /// 金色调 - 用于印记相关页面
  golden,

  /// 庆祝样式 - 用于完成页面（金色光晕）
  celebration,

  /// 表单样式 - 用于编辑页面（简洁）
  form,

  /// 导航样式 - 用于导航/进度页面
  navigation,
}

extension AuroraVariantExtension on AuroraVariant {
  Alignment get gradientBegin {
    switch (this) {
      case AuroraVariant.standard:
      case AuroraVariant.golden:
      case AuroraVariant.form:
      case AuroraVariant.navigation:
        return Alignment.topLeft;
      case AuroraVariant.warm:
      case AuroraVariant.celebration:
        return Alignment.topCenter;
    }
  }

  Alignment get gradientEnd {
    switch (this) {
      case AuroraVariant.standard:
      case AuroraVariant.golden:
      case AuroraVariant.form:
      case AuroraVariant.navigation:
        return Alignment.bottomRight;
      case AuroraVariant.warm:
      case AuroraVariant.celebration:
        return Alignment.bottomCenter;
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case AuroraVariant.standard:
      case AuroraVariant.golden:
      case AuroraVariant.form:
      case AuroraVariant.navigation:
        return const [Color(0xFFF8F6F3), Color(0xFFF0EDE8), Color(0xFFE8E4DD)];
      case AuroraVariant.warm:
        return const [Color(0xFFFDF8F5), Color(0xFFF8F5F0), Color(0xFFF5F0EB)];
      case AuroraVariant.celebration:
        return const [
          Color(0xFFFFF8E1), // 淡金
          Color(0xFFF8F6F3), // 宣纸
          Color(0xFFF0EDE8),
        ];
    }
  }

  /// 深色模式渐变色
  List<Color> get darkGradientColors {
    switch (this) {
      case AuroraVariant.standard:
      case AuroraVariant.form:
      case AuroraVariant.navigation:
        return const [Color(0xFF121218), Color(0xFF1A1A22), Color(0xFF1E1E26)];
      case AuroraVariant.warm:
        return const [Color(0xFF1A1518), Color(0xFF181418), Color(0xFF161216)];
      case AuroraVariant.golden:
        return const [Color(0xFF1A1814), Color(0xFF181612), Color(0xFF161410)];
      case AuroraVariant.celebration:
        return const [Color(0xFF1E1A14), Color(0xFF1A1816), Color(0xFF181614)];
    }
  }

  List<AuroraCircle> get circles {
    switch (this) {
      case AuroraVariant.standard:
        return [
          AuroraCircle(0.2, 0.1, 0.35, AppColors.primary, 0.08),
          AuroraCircle(0.85, 0.35, 0.3, AppColors.accent, 0.06),
          AuroraCircle(0.4, 0.85, 0.4, AppColors.tertiary, 0.05),
        ];
      case AuroraVariant.warm:
        return [
          AuroraCircle(0.85, 0.1, 0.5, AppColors.accent, 0.04),
          AuroraCircle(0.15, 0.85, 0.45, AppColors.tertiary, 0.05),
          AuroraCircle(0.5, 0.4, 0.35, AppColors.sealGold, 0.02),
        ];
      case AuroraVariant.golden:
        return [
          AuroraCircle(0.5, 0.12, 0.4, AppColors.sealGold, 0.08),
          AuroraCircle(0.1, 0.5, 0.35, AppColors.primary, 0.06),
          AuroraCircle(0.85, 0.75, 0.3, AppColors.accent, 0.05),
        ];
      case AuroraVariant.celebration:
        return [
          AuroraCircle(0.5, 0.15, 0.5, AppColors.sealGold, 0.12),
          AuroraCircle(0.1, 0.5, 0.35, AppColors.primary, 0.06),
          AuroraCircle(0.9, 0.7, 0.3, AppColors.accent, 0.05),
        ];
      case AuroraVariant.form:
        return [
          AuroraCircle(0.2, 0.15, 0.4, AppColors.primary, 0.08),
          AuroraCircle(0.85, 0.4, 0.35, AppColors.accent, 0.06),
        ];
      case AuroraVariant.navigation:
        return [
          AuroraCircle(0.15, 0.1, 0.4, AppColors.primary, 0.08),
          AuroraCircle(0.9, 0.25, 0.35, AppColors.accent, 0.06),
          AuroraCircle(0.5, 0.9, 0.4, AppColors.tertiary, 0.05),
        ];
    }
  }

  /// 深色模式下的圆形光晕（透明度更低）
  List<AuroraCircle> get darkCircles {
    return circles.map((c) => AuroraCircle(
      c.x,
      c.y,
      c.radiusFactor,
      c.color,
      c.opacity * 0.5, // 深色模式下透明度减半
    )).toList();
  }
}

/// Aurora 背景中的圆形光晕配置
class AuroraCircle {
  final double x;
  final double y;
  final double radiusFactor;
  final Color color;
  final double opacity;

  const AuroraCircle(
    this.x,
    this.y,
    this.radiusFactor,
    this.color,
    this.opacity,
  );
}

class _AuroraPainter extends CustomPainter {
  final AuroraVariant variant;
  final bool isDark;

  _AuroraPainter({required this.variant, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final circles = isDark ? variant.darkCircles : variant.circles;

    for (final circle in circles) {
      paint.color = circle.color.withValues(alpha: circle.opacity);
      canvas.drawCircle(
        Offset(size.width * circle.x, size.height * circle.y),
        size.width * circle.radiusFactor,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
