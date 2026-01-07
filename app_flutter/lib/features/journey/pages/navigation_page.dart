import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/journey_providers.dart';

/// 导航页面 - 模拟高德地图导航
class NavigationPage extends ConsumerStatefulWidget {
  final String journeyId;
  final String pointId;

  const NavigationPage({
    super.key,
    required this.journeyId,
    required this.pointId,
  });

  @override
  ConsumerState<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<NavigationPage> {
  bool _isArrived = false;
  double _remainingDistance = 350;

  @override
  void initState() {
    super.initState();
    _simulateNavigation();
  }

  void _simulateNavigation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _remainingDistance = 150);
    });
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _remainingDistance = 0;
          _isArrived = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentJourneyProvider);
    final point = state.currentPoint;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '导航到：${point?.name ?? "探索点"}',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Expanded(flex: 2, child: _buildMapPlaceholder()),
          _buildNavigationInfo(),
          if (_isArrived) _buildArrivedCard() else _buildNavigatingCard(),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      color: const Color(0xFFF5F0E6),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.navigation, size: 64, color: AppColors.textHint),
            SizedBox(height: 8),
            Text('高德地图 - 导航视图', style: TextStyle(color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.arrow_upward, size: 32, color: AppColors.accent),
              SizedBox(width: 12),
              Text(
                '前方 100米 右转',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    '剩余距离',
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                  Text(
                    '${_remainingDistance.toInt()}m',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    '预计到达',
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                  Text(
                    '${(_remainingDistance / 80).ceil()}分钟',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigatingCard() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: () => context.pop(),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.accent),
          ),
          child: const Text('结束导航', style: TextStyle(color: AppColors.accent)),
        ),
      ),
    );
  }

  Widget _buildArrivedCard() {
    final state = ref.watch(currentJourneyProvider);
    final point = state.currentPoint;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 48, color: AppColors.accent),
          const SizedBox(height: 8),
          const Text(
            '你已到达探索点！',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            point?.name ?? '',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('稍后再来'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/ar-task/${widget.pointId}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('开始任务'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
