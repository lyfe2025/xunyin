import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../services/gesture_recognition_service.dart';

/// 手势识别叠加层
class GestureOverlay extends StatelessWidget {
  final GestureType targetGesture;
  final GestureResult? currentResult;
  final bool isMatched;

  const GestureOverlay({
    super.key,
    required this.targetGesture,
    this.currentResult,
    this.isMatched = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 目标手势提示
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(child: _buildTargetGestureCard()),
        ),
        // 当前识别状态
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(child: _buildRecognitionStatus()),
        ),
        // 匹配成功动画
        if (isMatched) _buildSuccessOverlay(),
      ],
    );
  }

  Widget _buildTargetGestureCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.sealGold.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.sealGold.withValues(alpha: 0.3),
                  AppColors.sealGold.withValues(alpha: 0.15),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getGestureIcon(targetGesture),
              size: 28,
              color: AppColors.sealGold,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '目标手势',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                targetGesture.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecognitionStatus() {
    final hasResult = currentResult != null && currentResult!.gesture != GestureType.none;
    final confidence = currentResult?.confidence ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasResult
                  ? (isMatched ? AppColors.success : AppColors.warning)
                  : Colors.grey,
              boxShadow: hasResult
                  ? [
                      BoxShadow(
                        color: (isMatched ? AppColors.success : AppColors.warning)
                            .withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            hasResult
                ? '检测到: ${currentResult!.gesture.displayName} (${(confidence * 100).toInt()}%)'
                : '等待手势...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: AppColors.success.withValues(alpha: 0.2),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
    );
  }

  IconData _getGestureIcon(GestureType gesture) {
    switch (gesture) {
      case GestureType.wave:
        return Icons.waving_hand_rounded;
      case GestureType.thumbsUp:
        return Icons.thumb_up_rounded;
      case GestureType.peace:
        return Icons.back_hand_rounded;
      case GestureType.heart:
        return Icons.favorite_rounded;
      case GestureType.moonGaze:
        return Icons.nights_stay_rounded;
      case GestureType.prayerHands:
        return Icons.self_improvement_rounded;
      case GestureType.pointUp:
        return Icons.arrow_upward_rounded;
      case GestureType.openPalm:
        return Icons.pan_tool_rounded;
      default:
        return Icons.gesture_rounded;
    }
  }
}

/// 手势引导动画
class GestureGuideAnimation extends StatefulWidget {
  final GestureType gesture;

  const GestureGuideAnimation({super.key, required this.gesture});

  @override
  State<GestureGuideAnimation> createState() => _GestureGuideAnimationState();
}

class _GestureGuideAnimationState extends State<GestureGuideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
        child: Icon(
          _getGestureIcon(widget.gesture),
          size: 60,
          color: AppColors.accent.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  IconData _getGestureIcon(GestureType gesture) {
    switch (gesture) {
      case GestureType.moonGaze:
        return Icons.nights_stay_rounded;
      case GestureType.prayerHands:
        return Icons.self_improvement_rounded;
      case GestureType.wave:
        return Icons.waving_hand_rounded;
      case GestureType.thumbsUp:
        return Icons.thumb_up_rounded;
      default:
        return Icons.gesture_rounded;
    }
  }
}
