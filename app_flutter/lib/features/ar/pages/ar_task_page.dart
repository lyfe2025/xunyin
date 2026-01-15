import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/image_filter_utils.dart';
import '../../../providers/journey_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../services/photo_service.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../services/camera_service.dart';
import '../services/gesture_recognition_service.dart';
import '../widgets/camera_preview.dart' show AppCameraPreview, CameraControlButton, CameraGridOverlay;
import '../widgets/gesture_overlay.dart';
import '../widgets/ar_view_wrapper.dart';
import '../widgets/photo_filter.dart';

/// AR 任务页面 - 集成相机、手势识别、AR 功能
class ARTaskPage extends ConsumerStatefulWidget {
  final String pointId;
  const ARTaskPage({super.key, required this.pointId});

  @override
  ConsumerState<ARTaskPage> createState() => _ARTaskPageState();
}

class _ARTaskPageState extends ConsumerState<ARTaskPage>
    with TickerProviderStateMixin {
  // 服务
  final CameraService _cameraService = CameraService();
  final GestureRecognitionService _gestureService = GestureRecognitionService();

  // 状态
  bool _isInitializing = true;
  bool _isCompleted = false;
  bool _isSubmitting = false;
  bool _gestureMatched = false;
  String? _capturedPhotoPath;
  PhotoFilter _selectedFilter = PhotoFilter.guFeng;
  GestureResult? _currentGestureResult;
  double _recognitionProgress = 0;
  FlashMode _flashMode = FlashMode.off;

  // 动画
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // 手势识别计时器
  Timer? _gestureTimer;
  int _matchedFrames = 0;
  static const int _requiredMatchedFrames = 10; // 需要连续匹配的帧数

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initServices();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initServices() async {
    try {
      final state = ref.read(currentJourneyProvider);
      final taskType = state.currentPoint?.taskType ?? 'photo';

      // 初始化相机
      await _cameraService.initialize();

      // 如果是手势任务，初始化手势识别
      if (taskType == 'gesture') {
        await _gestureService.initialize();
        _startGestureRecognition();
      }

      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
        AppSnackBar.error(context, '相机初始化失败: $e');
      }
    }
  }

  void _startGestureRecognition() {
    if (_cameraService.controller == null) return;

    _cameraService.startImageStream((image) async {
      if (_gestureMatched || _isCompleted) return;

      final result = await _gestureService.recognizeFromCameraImage(
        image,
        _cameraService.controller!.description,
      );

      if (!mounted) return;

      setState(() => _currentGestureResult = result);

      // 检查是否匹配目标手势
      final state = ref.read(currentJourneyProvider);
      final targetGestureKey = state.currentPoint?.targetGesture;
      // 如果没有指定手势，默认使用"挥手"
      final targetGesture = (targetGestureKey == null || targetGestureKey.isEmpty)
          ? GestureType.wave
          : GestureTypeExtension.fromKey(targetGestureKey);

      if (result.gesture == targetGesture && result.confidence > 0.7) {
        _matchedFrames++;
        setState(() {
          _recognitionProgress = _matchedFrames / _requiredMatchedFrames;
        });

        if (_matchedFrames >= _requiredMatchedFrames) {
          _onGestureMatched();
        }
      } else {
        _matchedFrames = 0;
        setState(() => _recognitionProgress = 0);
      }
    });
  }

  void _onGestureMatched() {
    HapticFeedback.heavyImpact();
    setState(() => _gestureMatched = true);
    _cameraService.stopImageStream();

    // 延迟后自动完成
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_isCompleted) {
        _completeTask();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _gestureTimer?.cancel();
    _cameraService.dispose();
    _gestureService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentJourneyProvider);
    final point = state.currentPoint;
    final totalPoints = state.points.length;
    final currentIndex = state.currentPointIndex;
    final taskType = point?.taskType ?? 'photo';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, currentIndex, totalPoints, taskType),
            Expanded(child: _buildMainContent(taskType, point)),
            _buildTaskInfo(point?.name ?? '', point?.taskDescription ?? ''),
            _buildControls(taskType),
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 10,
              ),
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

  Widget _buildMainContent(String taskType, dynamic point) {
    if (_isInitializing) {
      return _buildLoadingView();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 根据任务类型显示不同视图
          if (taskType == 'treasure')
            _buildARView(point)
          else
            _buildCameraView(taskType, point),
          // 四角标记
          ..._buildCornerMarkers(),
          // 底部提示
          _buildBottomHint(taskType),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            SizedBox(height: 16),
            Text(
              '正在初始化相机...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView(String taskType, dynamic point) {
    if (_cameraService.controller == null || !_cameraService.isInitialized) {
      return _buildCameraError();
    }

    final targetGestureKey = point?.targetGesture as String?;
    // 如果是手势任务但没有指定手势，默认使用"挥手"
    final targetGesture = taskType == 'gesture' && (targetGestureKey == null || targetGestureKey.isEmpty)
        ? GestureType.wave
        : GestureTypeExtension.fromKey(targetGestureKey);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 相机预览 + 实时滤镜
        FilteredCameraPreview(
          filter: taskType == 'photo' ? _selectedFilter : PhotoFilter.original,
          child: AppCameraPreview(
            controller: _cameraService.controller!,
            borderRadius: BorderRadius.circular(AppRadius.cardLarge),
          ),
        ),
        // 网格叠加
        const CameraGridOverlay(),
        // 手势识别叠加层
        if (taskType == 'gesture')
          GestureOverlay(
            targetGesture: targetGesture,
            currentResult: _currentGestureResult,
            isMatched: _gestureMatched,
          ),
        // 拍照任务的滤镜指示器
        if (taskType == 'photo') _buildPhotoOverlay(point),
        // 识别进度
        if (taskType == 'gesture' && !_gestureMatched)
          _buildRecognitionProgress(),
      ],
    );
  }

  Widget _buildCameraError() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_off_rounded,
              size: 48,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '相机不可用',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _initServices,
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildARView(dynamic point) {
    return ARViewWrapper(
      showPlaneIndicator: true,
      onARViewCreated: (controller) {
        // AR 视图创建后，放置寻宝物体
        final assetUrl = point?.arAssetUrl as String?;
        if (assetUrl != null) {
          controller.placeObject(assetUrl, scale: 0.5);
        }
      },
      overlay: _buildTreasureOverlay(point),
    );
  }

  Widget _buildTreasureOverlay(dynamic point) {
    return Stack(
      children: [
        // 寻宝提示
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: AppColors.sealGold.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppColors.sealGold,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '移动手机寻找隐藏的宝物',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // 中心准星
        Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            ),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.sealGold.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.center_focus_strong_rounded,
                color: AppColors.sealGold.withValues(alpha: 0.8),
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoOverlay(dynamic point) {
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
                Icons.filter_vintage_rounded,
                size: 24,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              PhotoFilters.getConfig(_selectedFilter).name,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecognitionProgress() {
    if (_recognitionProgress <= 0) return const SizedBox.shrink();

    return Positioned(
      left: 20,
      right: 20,
      bottom: 60,
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _recognitionProgress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.sealGold],
                  ),
                  borderRadius: BorderRadius.circular(2),
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
          const SizedBox(height: 8),
          Text(
            '保持手势 ${(_recognitionProgress * 100).toInt()}%',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
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

  Widget _buildBottomHint(String taskType) {
    String hint;
    IconData icon;

    switch (taskType) {
      case 'gesture':
        hint = '对准目标手势';
        icon = Icons.pan_tool_rounded;
        break;
      case 'treasure':
        hint = '移动手机寻找宝物';
        icon = Icons.search_rounded;
        break;
      default:
        hint = '对准目标拍照';
        icon = Icons.camera_alt_rounded;
    }

    return Positioned(
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
              Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(
                hint,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
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
          Row(
            children: [
              // 切换摄像头
              if (taskType != 'treasure')
                CameraControlButton(
                  icon: Icons.flip_camera_ios_rounded,
                  onPressed: _switchCamera,
                ),
              const SizedBox(width: AppSpacing.md),
              // 主按钮
              Expanded(
                child: SizedBox(
                  height: AppSize.buttonHeight,
                  child: AppPrimaryButton(
                    onPressed: _isSubmitting || _gestureMatched
                        ? null
                        : () => _handleMainAction(taskType),
                    isLoading: _isSubmitting,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getActionIcon(taskType),
                          size: AppSize.appBarIconSize,
                        ),
                        const SizedBox(width: 8),
                        Text(_getActionText(taskType)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // 闪光灯
              if (taskType == 'photo')
                CameraControlButton(
                  icon: _getFlashIcon(),
                  onPressed: _toggleFlash,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: FilterSelector(
        selectedFilter: _selectedFilter,
        onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
      ),
    );
  }

  IconData _getActionIcon(String taskType) {
    switch (taskType) {
      case 'gesture':
        return Icons.check_rounded;
      case 'treasure':
        return Icons.check_circle_rounded;
      default:
        return Icons.camera_alt_rounded;
    }
  }

  String _getActionText(String taskType) {
    switch (taskType) {
      case 'gesture':
        return '确认完成';
      case 'treasure':
        return '找到了！';
      default:
        return '拍照';
    }
  }

  Future<void> _switchCamera() async {
    await _cameraService.switchCamera();
    setState(() {});
  }

  Future<void> _toggleFlash() async {
    // 循环切换: off → auto → always → torch → off
    FlashMode newMode;
    switch (_flashMode) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        newMode = FlashMode.off;
        break;
    }

    try {
      await _cameraService.setFlashMode(newMode);
      setState(() => _flashMode = newMode);

      // 显示当前模式提示
      if (mounted) {
        final modeText = _getFlashModeText(newMode);
        AppSnackBar.show(context, '闪光灯: $modeText', icon: _getFlashIcon());
      }
    } catch (e) {
      debugPrint('设置闪光灯失败: $e');
      if (mounted) {
        AppSnackBar.error(context, '闪光灯设置失败');
      }
    }
  }

  String _getFlashModeText(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return '关闭';
      case FlashMode.auto:
        return '自动';
      case FlashMode.always:
        return '开启';
      case FlashMode.torch:
        return '常亮';
    }
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off_rounded;
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.torch:
        return Icons.flashlight_on_rounded;
    }
  }

  void _handleMainAction(String taskType) {
    switch (taskType) {
      case 'photo':
        _takePicture();
        break;
      case 'gesture':
      case 'treasure':
        _completeTask();
        break;
    }
  }

  Future<void> _takePicture() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    try {
      // 1. 拍照并保存到本地
      final result = await _cameraService.takePictureAndSaveToGallery(
        saveToGallery: false, // 先不保存到相册，等应用滤镜后再保存
        albumName: '寻印',
      );

      if (result == null) {
        if (mounted) {
          AppSnackBar.error(context, '拍照失败，请重试');
          setState(() => _isSubmitting = false);
        }
        return;
      }

      // 2. 应用滤镜效果到图片
      String filteredPath = result.localPath;
      if (_selectedFilter != PhotoFilter.original) {
        try {
          filteredPath = await ImageFilterUtils.applyFilterToFile(
            result.localPath,
            _selectedFilter,
          );
        } catch (e) {
          debugPrint('滤镜应用失败: $e');
          // 滤镜失败时使用原图继续
        }
      }

      // 3. 保存滤镜后的图片到相册
      try {
        await _cameraService.saveToGallery(filteredPath, albumName: '寻印');
        if (mounted) {
          AppSnackBar.success(context, '照片已保存到相册');
        }
      } catch (e) {
        debugPrint('保存到相册失败: $e');
      }

      // 4. 上传照片到服务器
      String? serverPhotoUrl;
      final state = ref.read(currentJourneyProvider);
      final journeyId = state.detail?.id;
      final pointId = widget.pointId;

      if (journeyId != null) {
        try {
          final uploadService = ref.read(uploadServiceProvider);
          final photoService = ref.read(photoServiceProvider);

          // 上传滤镜后的文件
          final uploadResult = await uploadService.uploadPhoto(File(filteredPath));
          serverPhotoUrl = uploadResult.url;

          // 创建照片记录
          await photoService.createPhoto(CreatePhotoParams(
            journeyId: journeyId,
            pointId: pointId,
            photoUrl: serverPhotoUrl,
            filter: _selectedFilter.name,
            takenTime: DateTime.now(),
          ));

          if (mounted) {
            AppSnackBar.success(context, '照片已同步到云端');
          }
        } catch (e) {
          // 上传失败但本地保存成功，继续流程
          debugPrint('照片上传失败: $e');
          if (mounted) {
            AppSnackBar.warning(context, '云端同步失败，照片已保存到本地');
          }
        }
      }

      // 使用服务器URL或本地路径
      _capturedPhotoPath = serverPhotoUrl ?? filteredPath;
      await _completeTask();
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, '拍照失败: $e');
        setState(() => _isSubmitting = false);
      }
    }
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
        photoUrl: _capturedPhotoPath,
      );

      if (!mounted) return;

      context.push(
        '/task-complete/${widget.pointId}'
        '?pointsEarned=${result.pointsEarned}'
        '&totalPoints=${result.totalPoints}'
        '&journeyCompleted=${result.journeyCompleted}'
        '${result.userSealId != null ? '&userSealId=${result.userSealId}' : ''}'
        '${result.sealId != null ? '&sealId=${result.sealId}' : ''}'
        '${_capturedPhotoPath != null ? '&photoPath=$_capturedPhotoPath' : ''}',
      );
    } catch (e) {
      if (!mounted) return;
      // API 失败时使用模拟数据
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
      '&journeyCompleted=$isLastPoint'
      '${_capturedPhotoPath != null ? '&photoPath=$_capturedPhotoPath' : ''}',
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

/// 角标记
class _CornerMarker extends StatelessWidget {
  final String corner;
  const _CornerMarker({required this.corner});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _CornerPainter(corner: corner)),
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
