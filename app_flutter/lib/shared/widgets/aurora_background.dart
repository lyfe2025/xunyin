import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Aurora 渐变背景组件 - 统一的 Aurora UI 背景
/// 支持多种预设样式和自定义光晕配置
class AuroraBackground extends StatelessWidget {
  /// 背景样式预设
  final AuroraStyle style;

  /// 自定义渐变色（可选，覆盖预设）
  final List<Color>? gradientColors;

  /// 自定义光晕配置（可选，覆盖预设）
  final List<AuroraOrb>? orbs;

  const AuroraBackground({
    super.key,
    this.style = AuroraStyle.standard,
    this.gradientColors,
    this.orbs,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? _getGradientColors(style);
    final orbList = orbs ?? _getOrbs(style);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: CustomPaint(
        painter: _AuroraPainter(orbs: orbList),
        size: Size.infinite,
      ),
    );
  }

  List<Color> _getGradientColors(AuroraStyle style) {
    switch (style) {
      case AuroraStyle.standard:
        return const [Color(0xFFF8F6F3), Color(0xFFF0EDE8), Color(0xFFE8E4DD)];
      case AuroraStyle.warm:
        return const [Color(0xFFFDF8F5), Color(0xFFF8F5F0)];
      case AuroraStyle.celebration:
        return const [Color(0xFFFFF8E1), Color(0xFFF8F6F3), Color(0xFFF0EDE8)];
      case AuroraStyle.login:
        return const [Color(0xFFFDF8F5), Color(0xFFF8F5F0), Color(0xFFF5F0EB)];
      case AuroraStyle.taskComplete:
        return const [
          Color(0xFFF8F5F0),
          Color(0xFFFDF2F8),
          Color(0xFFF0F9FF),
          Color(0xFFF8F5F0),
        ];
    }
  }

  List<AuroraOrb> _getOrbs(AuroraStyle style) {
    switch (style) {
      case AuroraStyle.standard:
        return [
          AuroraOrb(
            color: AppColors.primary,
            alpha: 0.08,
            position: const Offset(0.2, 0.12),
            radiusFactor: 0.4,
          ),
          AuroraOrb(
            color: AppColors.accent,
            alpha: 0.06,
            position: const Offset(0.85, 0.4),
            radiusFactor: 0.35,
          ),
          AuroraOrb(
            color: AppColors.tertiary,
            alpha: 0.05,
            position: const Offset(0.4, 0.85),
            radiusFactor: 0.4,
          ),
        ];
      case AuroraStyle.warm:
        return [
          AuroraOrb(
            color: AppColors.accent,
            alpha: 0.04,
            position: const Offset(0.8, 0.15),
            radiusFactor: 0.4,
          ),
          AuroraOrb(
            color: AppColors.tertiary,
            alpha: 0.03,
            position: const Offset(0.2, 0.6),
            radiusFactor: 0.35,
          ),
        ];
      case AuroraStyle.celebration:
        return [
          AuroraOrb(
            color: AppColors.sealGold,
            alpha: 0.12,
            position: const Offset(0.5, 0.15),
            radiusFactor: 0.5,
          ),
          AuroraOrb(
            color: AppColors.primary,
            alpha: 0.06,
            position: const Offset(0.1, 0.5),
            radiusFactor: 0.35,
          ),
          AuroraOrb(
            color: AppColors.accent,
            alpha: 0.05,
            position: const Offset(0.9, 0.7),
            radiusFactor: 0.3,
          ),
        ];
      case AuroraStyle.login:
        return [
          AuroraOrb(
            color: AppColors.accent,
            alpha: 0.04,
            position: const Offset(0.85, 0.1),
            radiusFactor: 0.5,
          ),
          AuroraOrb(
            color: AppColors.tertiary,
            alpha: 0.05,
            position: const Offset(0.15, 0.85),
            radiusFactor: 0.45,
          ),
          AuroraOrb(
            color: AppColors.sealGold,
            alpha: 0.02,
            position: const Offset(0.5, 0.4),
            radiusFactor: 0.35,
          ),
        ];
      case AuroraStyle.taskComplete:
        return [
          AuroraOrb(
            color: AppColors.accent,
            alpha: 0.03,
            position: const Offset(0.8, 0.2),
            radiusFactor: 0.4,
          ),
          AuroraOrb(
            color: AppColors.tertiary,
            alpha: 0.04,
            position: const Offset(0.2, 0.7),
            radiusFactor: 0.35,
          ),
          AuroraOrb(
            color: AppColors.sealGold,
            alpha: 0.02,
            position: const Offset(0.6, 0.5),
            radiusFactor: 0.3,
          ),
        ];
    }
  }
}

/// Aurora 背景样式预设
enum AuroraStyle {
  /// 标准样式 - 适用于大多数页面
  standard,

  /// 温暖样式 - 适用于个人中心等页面
  warm,

  /// 庆祝样式 - 适用于完成页面
  celebration,

  /// 登录样式 - 适用于登录页面
  login,

  /// 任务完成样式 - 适用于任务完成页面
  taskComplete,
}

/// Aurora 光晕配置
class AuroraOrb {
  final Color color;
  final double alpha;
  final Offset position; // 相对位置 (0-1)
  final double radiusFactor; // 相对于屏幕宽度的半径比例

  const AuroraOrb({
    required this.color,
    required this.alpha,
    required this.position,
    required this.radiusFactor,
  });
}

class _AuroraPainter extends CustomPainter {
  final List<AuroraOrb> orbs;

  _AuroraPainter({required this.orbs});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final orb in orbs) {
      paint.color = orb.color.withValues(alpha: orb.alpha);
      canvas.drawCircle(
        Offset(size.width * orb.position.dx, size.height * orb.position.dy),
        size.width * orb.radiusFactor,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) {
    return orbs != oldDelegate.orbs;
  }
}
