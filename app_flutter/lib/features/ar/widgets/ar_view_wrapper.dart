import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// AR 视图包装器
/// 由于 ar_flutter_plugin 需要真机运行，这里提供一个模拟视图用于开发
class ARViewWrapper extends StatefulWidget {
  final Function(ARViewWrapperController)? onARViewCreated;
  final bool showPlaneIndicator;
  final Widget? overlay;

  const ARViewWrapper({
    super.key,
    this.onARViewCreated,
    this.showPlaneIndicator = true,
    this.overlay,
  });

  @override
  State<ARViewWrapper> createState() => ARViewWrapperState();
}

class ARViewWrapperState extends State<ARViewWrapper>
    with SingleTickerProviderStateMixin {
  late ARViewWrapperController _controller;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  bool _planeDetected = false;

  @override
  void initState() {
    super.initState();
    _controller = ARViewWrapperController._(this);

    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_scanController);

    // 模拟平面检测
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _planeDetected = true);
      }
    });

    widget.onARViewCreated?.call(_controller);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Stack(
        children: [
          // AR 背景（模拟）
          _buildARBackground(),
          // 平面检测指示器
          if (widget.showPlaneIndicator && !_planeDetected)
            _buildPlaneDetectionIndicator(),
          // 已检测到的平面
          if (_planeDetected) _buildDetectedPlane(),
          // 叠加层
          if (widget.overlay != null) widget.overlay!,
        ],
      ),
    );
  }

  Widget _buildARBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _ARGridPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildPlaneDetectionIndicator() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _scanAnimation.value * 2 * 3.14159,
                child: child,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.crop_free_rounded,
                size: 40,
                color: AppColors.accent.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '正在检测平面...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedPlane() {
    return Positioned(
      bottom: 100,
      left: 40,
      right: 40,
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.success.withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  void _setPlaneDetected(bool detected) {
    setState(() => _planeDetected = detected);
  }
}

/// AR 视图控制器
class ARViewWrapperController {
  final ARViewWrapperState _state;

  ARViewWrapperController._(this._state);

  /// 放置物体
  Future<void> placeObject(String modelUrl, {double scale = 1.0}) async {
    // 在真实实现中，这里会调用 ar_flutter_plugin 的 API
    debugPrint('放置 AR 物体: $modelUrl, scale: $scale');
  }

  /// 移除所有物体
  Future<void> removeAllObjects() async {
    debugPrint('移除所有 AR 物体');
  }

  /// 截图
  Future<String?> takeScreenshot() async {
    // 在真实实现中，这里会截取 AR 视图
    return null;
  }

  /// 重置会话
  Future<void> resetSession() async {
    _state._setPlaneDetected(false);
    await Future.delayed(const Duration(seconds: 2));
    _state._setPlaneDetected(true);
  }
}

/// AR 网格绘制
class _ARGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    // 垂直线
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 水平线
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
