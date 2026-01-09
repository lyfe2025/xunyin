import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/journey_providers.dart';
import '../../../providers/service_providers.dart';

/// AR 任务页面 - Aurora UI + Glassmorphism
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
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(
              context,
              currentIndex,
              totalPoints,
              point?.taskType ?? 'photo',
            ),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '探索点 ${currentIndex + 1}/$totalPoints',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.sealGold.withValues(alpha: 0.3),
                  AppColors.sealGold.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.sealGold.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              taskType == 'gesture'
                  ? 'AR手势'
                  : taskType == 'photo'
                  ? '拍照'
                  : 'AR寻宝',
              style: const TextStyle(
                color: AppColors.sealGold,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(String taskType) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_rounded, size: 56, color: Colors.white24),
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
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.sealGold.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.nights_stay_rounded,
                          size: 40,
                          color: AppColors.sealGold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '目标手势：赏月手势',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (taskType == 'photo')
            Positioned(
              top: 60,
              right: 30,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '识别中 ${(_progress * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
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
      child: Column(
        children: [
          if (taskType == 'photo')
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final filter in ['古风', '水墨', '原图'])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: _selectedFilter == filter
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.accent,
                                      Color(0xFFE85A4F),
                                    ],
                                  )
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
                              color: _selectedFilter == filter
                                  ? Colors.white
                                  : Colors.white70,
                              fontWeight: _selectedFilter == filter
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _completeTask,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      taskType == 'photo'
                          ? Icons.camera_alt_rounded
                          : Icons.check_rounded,
                      size: 22,
                    ),
              label: Text(
                taskType == 'photo' ? '拍照' : '确认完成',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
