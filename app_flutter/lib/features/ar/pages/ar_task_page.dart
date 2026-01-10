import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../providers/journey_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../shared/widgets/app_buttons.dart';

/// AR 任务页面 - Aurora UI + Glassmorphism
class ARTaskPage extends ConsumerStatefulWidget {
  final String pointId;
  const ARTaskPage({super.key, required this.pointId});

  @override
  ConsumerState<ARTaskPage> createState() => _ARTaskPageState();
}

class _ARTaskPageState extends ConsumerState<ARTaskPage>
    with TickerProviderStateMixin {
  double _progress = 0;
  bool _isCompleted = false;
  bool _isSubmitting = false;
  String _selectedFilter = '古风';

  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // 扫描线动画
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_scanController);

    // 脉冲动画
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _simulateRecognition();
  }

  void _simulateRecognition() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted || _isCompleted) return false;
      setState(() => _progress = (_progress + 0.02).clamp(0, 1));
      return _progress < 0.8;
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentJourneyProvider);
    final point = state.currentPoint;
    final totalPoints = state.points.length;
    final currentIndex = state.currentPointIndex;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, currentIndex, totalPoints, point?.taskType ?? 'photo'),
            Expanded(child: _buildCameraPreview(point?.taskType ?? 'photo')),
            _buildTaskInfo(point?.name ?? '', point?.taskDescription ?? ''),
            _buildControls(point?.taskType ?? 'photo'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    int currentIndex,
    int totalPoints,
    String taskType,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Row(
        children: [
          AppCloseButtonDark(onTap: () => context.pop()),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.iconButton),
              ),
              child: Text(
                '探索点 ${currentIndex + 1}/$totalPoints',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _TaskTypeBadge(taskType: taskType),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(String taskType) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          // 网格背景
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: _CameraGridPainter(),
          ),
          // 扫描线动画
          if (!_isCompleted)
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, _) => Positioned(
                top: _scanAnimation.value * 300,
                left: 20,
                right: 20,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.accent.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // 中心占位
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: child,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      taskType == 'gesture'
                          ? Icons.pan_tool_rounded
                          : taskType == 'treasure'
                              ? Icons.search_rounded
                              : Icons.camera_alt_rounded,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      taskType == 'gesture'
                          ? '对准手势'
                          : taskType == 'treasure'
                              ? '寻找目标'
                              : '对准拍摄',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 任务特定 UI
          if (taskType == 'gesture') _buildGestureOverlay(),
          if (taskType == 'photo') _buildPhotoOverlay(),
          // 四角标记
          ..._buildCornerMarkers(),
          // 底部提示
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videocam_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AR 相机集成后显示实际画面',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerMarkers() {
    return [
      Positioned(top: 20, left: 20, child: _CornerMarker(corner: 'tl')),
      Positioned(top: 20, right: 20, child: _CornerMarker(corner: 'tr')),
      Positioned(bottom: 50, left: 20, child: _CornerMarker(corner: 'bl')),
      Positioned(bottom: 50, right: 20, child: _CornerMarker(corner: 'br')),
    ];
  }

  Widget _buildGestureOverlay() {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.sealGold.withValues(alpha: 0.3),
                      AppColors.sealGold.withValues(alpha: 0.15),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.sealGold.withValues(alpha: 0.5)),
                ),
                child: const Icon(
                  Icons.nights_stay_rounded,
                  size: 32,
                  color: AppColors.sealGold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '目标手势：赏月手势',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOverlay() {
    return Positioned(
      top: 50,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.3),
                    AppColors.accent.withValues(alpha: 0.15),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 24,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '白娘子',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfo(String name, String description) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.pageHorizontal),
      padding: const EdgeInsets.all(AppSpacing.xl - 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          if (_progress > 0 && _progress < 1) ...[
            const SizedBox(height: 14),
            // 渐变进度条
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.sealGold],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '识别中...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControls(String taskType) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.pageHorizontal,
        right: AppSpacing.pageHorizontal,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: Column(
        children: [
          if (taskType == 'photo') _buildFilterSelector(),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: AppSize.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _completeTask,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      taskType == 'photo' ? Icons.camera_alt_rounded : Icons.check_rounded,
                      size: AppSize.appBarIconSize,
                    ),
              label: Text(
                taskType == 'photo' ? '拍照' : '确认完成',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final filter in ['古风', '水墨', '原图'])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: _selectedFilter == filter
                        ? const LinearGradient(colors: [AppColors.accent, Color(0xFFE85A4F)])
                        : null,
                    color: _selectedFilter != filter
                        ? Colors.white.withValues(alpha: 0.1)
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedFilter == filter
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: _selectedFilter == filter ? Colors.white : Colors.white70,
                      fontWeight: _selectedFilter == filter ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _completeTask() async {
    setState(() {
      _isCompleted = true;
      _isSubmitting = true;
    });

    try {
      final journeyService = ref.read(journeyServiceProvider);
      final result = await journeyService.completePoint(
        pointId: widget.pointId,
        photoUrl: null,
      );

      if (!mounted) return;

      context.push(
        '/task-complete/${widget.pointId}'
        '?pointsEarned=${result.pointsEarned}'
        '&totalPoints=${result.totalPoints}'
        '&journeyCompleted=${result.journeyCompleted}'
        '${result.sealId != null ? '&sealId=${result.sealId}' : ''}',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _completeTaskWithMockData();
    }
  }

  void _completeTaskWithMockData() {
    final state = ref.read(currentJourneyProvider);
    final point = state.currentPoint;
    final isLastPoint = !state.hasNextPoint;

    context.push(
      '/task-complete/${widget.pointId}'
      '?pointsEarned=${point?.pointsReward ?? 50}'
      '&totalPoints=100'
      '&journeyCompleted=$isLastPoint',
    );
  }
}

/// 任务类型徽章
class _TaskTypeBadge extends StatelessWidget {
  final String taskType;
  const _TaskTypeBadge({required this.taskType});

  String get _label {
    switch (taskType) {
      case 'gesture':
        return 'AR手势';
      case 'photo':
        return '拍照';
      case 'treasure':
        return 'AR寻宝';
      default:
        return '任务';
    }
  }

  IconData get _icon {
    switch (taskType) {
      case 'gesture':
        return Icons.pan_tool_rounded;
      case 'photo':
        return Icons.camera_alt_rounded;
      case 'treasure':
        return Icons.search_rounded;
      default:
        return Icons.explore_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.sealGold.withValues(alpha: 0.3),
            AppColors.sealGold.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.iconButton),
        border: Border.all(color: AppColors.sealGold.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: AppColors.sealGold),
          const SizedBox(width: 4),
          Text(
            _label,
            style: const TextStyle(
              color: AppColors.sealGold,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 相机网格绘制
class _CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

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

/// 角标记
class _CornerMarker extends StatelessWidget {
  final String corner;
  const _CornerMarker({required this.corner});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _CornerPainter(corner: corner),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final String corner;
  _CornerPainter({required this.corner});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    switch (corner) {
      case 'tl':
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case 'tr':
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case 'bl':
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case 'br':
        path.moveTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, 0);
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
