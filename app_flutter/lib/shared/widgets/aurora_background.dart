import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 统一的 Aurora 渐变背景组件
class AuroraBackground extends StatelessWidget {
  /// 背景变体类型
  final AuroraVariant variant;

  const AuroraBackground({super.key, this.variant = AuroraVariant.standard});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: variant.gradientBegin,
          end: variant.gradientEnd,
          colors: variant.gradientColors,
        ),
      ),
      child: CustomPaint(
        painter: _AuroraPainter(variant: variant),
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

  _AuroraPainter({required this.variant});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final circle in variant.circles) {
      paint.color = circle.color.withValues(alpha: circle.opacity);
      canvas.drawCircle(
        Offset(size.width * circle.x, size.height * circle.y),
        size.width * circle.radiusFactor,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
