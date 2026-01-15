import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 相机预览组件（自定义封装）
class AppCameraPreview extends StatelessWidget {
  final CameraController controller;
  final Widget? overlay;
  final BorderRadius? borderRadius;

  const AppCameraPreview({
    super.key,
    required this.controller,
    this.overlay,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 相机预览
          _buildCameraPreview(),
          // 叠加层
          if (overlay != null) overlay!,
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final scale = size.aspectRatio * controller.value.aspectRatio;

        // 如果比例不匹配，需要缩放以填充
        final adjustedScale = scale < 1 ? 1 / scale : scale;

        return Transform.scale(
          scale: adjustedScale,
          child: Center(
            child: CameraPreview(controller),
          ),
        );
      },
    );
  }
}

/// 相机控制按钮
class CameraControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final double size;

  const CameraControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.accent : Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}

/// 拍照按钮
class CaptureButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final double size;

  const CaptureButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isLoading
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, AppColors.accentDark],
                  ),
            color: isLoading ? Colors.grey : null,
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 28,
                ),
        ),
      ),
    );
  }
}

/// 相机网格叠加层
class CameraGridOverlay extends StatelessWidget {
  final Color color;
  final double strokeWidth;

  const CameraGridOverlay({
    super.key,
    this.color = Colors.white24,
    this.strokeWidth = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(color: color, strokeWidth: strokeWidth),
      size: Size.infinite,
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _GridPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    // 三分线
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
