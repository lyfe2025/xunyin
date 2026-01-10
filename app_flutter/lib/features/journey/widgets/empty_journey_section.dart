import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 空状态分组提示组件 - 精致虚线边框
class EmptyJourneySection extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const EmptyJourneySection({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  /// 进行中为空
  factory EmptyJourneySection.inProgress() {
    return const EmptyJourneySection(
      title: '暂无进行中的旅程',
      message: '去探索城市，开启新的文化之旅吧',
      icon: Icons.explore_outlined,
      color: AppColors.accent,
    );
  }

  /// 已完成为空
  factory EmptyJourneySection.completed() {
    return const EmptyJourneySection(
      title: '还没有完成任何旅程',
      message: '完成探索后，旅程会显示在这里',
      icon: Icons.emoji_events_outlined,
      color: AppColors.sealGold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return CustomPaint(
      painter: _DashedBorderPainter(color: color.withValues(alpha: 0.25)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.12),
                    color.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color.withValues(alpha: 0.5),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryAdaptive(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHintAdaptive(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 虚线边框绘制器
class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    const radius = 12.0;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(radius),
      ));

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
