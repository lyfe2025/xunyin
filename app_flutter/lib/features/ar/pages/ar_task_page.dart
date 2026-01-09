import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/journey_providers.dart';
import '../../../providers/service_providers.dart';

/// AR 任务页面（模拟实现）
class ARTaskPage extends ConsumerStatefulWidget {
  final String pointId;
  const ARTaskPage({super.key, required this.pointId});

  @override
  ConsumerState<ARTaskPage> createState() => _ARTaskPageState();
}

class _ARTaskPageState extends ConsumerState<ARTaskPage> {
  double _progress = 0;
  bool _isCompleted = false;
  bool _isSubmitting = false;
  String _selectedFilter = '古风';

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final state = ref.watch(currentJourneyProvider);
    final point = state.currentPoint;
    final totalPoints = state.points.length;
    final currentIndex = state.currentPointIndex;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text('探索点 ${currentIndex + 1}/$totalPoints'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                point?.taskType == 'gesture'
                    ? 'AR手势'
                    : point?.taskType == 'photo'
                    ? '拍照'
                    : 'AR寻宝',
                style: const TextStyle(color: AppColors.sealGold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildCameraPreview(point?.taskType ?? 'photo')),
          _buildTaskInfo(point?.name ?? '', point?.taskDescription ?? ''),
          _buildControls(point?.taskType ?? 'photo'),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(String taskType) {
    return Container(
      color: Colors.grey[900],
      child: Stack(
        children: [
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt, size: 64, color: Colors.white24),
                SizedBox(height: 8),
                Text('AR 相机预览', style: TextStyle(color: Colors.white24)),
                Text(
                  '（集成后显示实际相机）',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ],
            ),
          ),
          if (taskType == 'gesture')
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text('🌙', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 8),
                      Text('目标手势：赏月手势', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          if (taskType == 'photo')
            Positioned(
              top: 80,
              right: 40,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text('👘', style: TextStyle(fontSize: 32)),
                    Text(
                      '白娘子',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskInfo(String name, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
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
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 12),
          if (_progress > 0 && _progress < 1)
            Column(
              children: [
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
                const SizedBox(height: 4),
                Text(
                  '识别中 ${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildControls(String taskType) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      color: Colors.grey[900],
      child: Column(
        children: [
          if (taskType == 'photo')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final filter in ['古风', '水墨', '原图'])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (v) =>
                          setState(() => _selectedFilter = filter),
                      selectedColor: AppColors.accent,
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter
                            ? Colors.white
                            : Colors.white70,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _completeTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(taskType == 'photo' ? '拍照' : '确认完成'),
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
      // 调用后端 API 完成探索点
      final journeyService = ref.read(journeyServiceProvider);
      final result = await journeyService.completePoint(
        pointId: widget.pointId,
        photoUrl: null, // 模拟拍照，实际应该上传照片后获取 URL
      );

      if (!mounted) return;

      // 跳转到任务完成页，传递后端返回的数据
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

      // 开发模式：API 失败时使用模拟数据继续流程
      _completeTaskWithMockData();
    }
  }

  /// 使用模拟数据完成任务（开发测试用）
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
