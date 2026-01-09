import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/seal.dart';
import '../../../providers/seal_providers.dart';

/// 印记集页面 - Aurora UI + Glassmorphism 风格
class SealListPage extends ConsumerWidget {
  const SealListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(sealProgressProvider);
    final sealsAsync = ref.watch(allSealsProvider);
    final selectedType = ref.watch(selectedSealTypeProvider);

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, ref),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      const SizedBox(height: 8),
                      progressAsync.when(
                        data: (progress) => _ProgressCard(progress: progress),
                        loading: () => _buildProgressLoading(),
                        error: (e, _) => _buildErrorCard('加载失败'),
                      ),
                      const SizedBox(height: 24),
                      for (final type in SealType.values) ...[
                        if (selectedType == null || selectedType == type) ...[
                          _buildSectionTitle(type.label, type),
                          const SizedBox(height: 14),
                          sealsAsync.when(
                            data: (seals) => _SealGrid(
                              seals: seals
                                  .where((s) => s.type == type)
                                  .toList(),
                            ),
                            loading: () => _buildGridLoading(),
                            error: (e, _) => _buildErrorCard('加载失败'),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDF8F5), Color(0xFFF8F5F0)],
        ),
      ),
      child: CustomPaint(
        painter: _SealBackgroundPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              '我的印记集',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.filter_list_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, SealType type) {
    final iconData = _getTypeIcon(type);
    final color = _getTypeColor(type);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(iconData, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(SealType type) {
    switch (type) {
      case SealType.route:
        return Icons.route_rounded;
      case SealType.city:
        return Icons.location_city_rounded;
      case SealType.special:
        return Icons.star_rounded;
    }
  }

  Color _getTypeColor(SealType type) {
    switch (type) {
      case SealType.route:
        return AppColors.primary;
      case SealType.city:
        return AppColors.tertiary;
      case SealType.special:
        return AppColors.sealGold;
    }
  }

  Widget _buildProgressLoading() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }

  Widget _buildGridLoading() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: AppColors.textHint)),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '筛选印记类型',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              _FilterOption(
                title: '全部',
                icon: Icons.grid_view_rounded,
                isSelected: ref.watch(selectedSealTypeProvider) == null,
                onTap: () {
                  ref.read(selectedSealTypeProvider.notifier).state = null;
                  Navigator.pop(ctx);
                },
              ),
              for (final type in SealType.values)
                _FilterOption(
                  title: type.label,
                  icon: _getTypeIcon(type),
                  iconColor: _getTypeColor(type),
                  isSelected: ref.watch(selectedSealTypeProvider) == type,
                  onTap: () {
                    ref.read(selectedSealTypeProvider.notifier).state = type;
                    Navigator.pop(ctx);
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SealBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = AppColors.sealGold.withValues(alpha: 0.04);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.1),
      size.width * 0.4,
      paint,
    );

    paint.color = AppColors.accent.withValues(alpha: 0.03);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.5),
      size.width * 0.35,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressCard extends StatelessWidget {
  final SealProgress progress;
  const _ProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.sealGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  size: 18,
                  color: AppColors.sealGold,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '收集进度',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 14,
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '已上链 ${progress.collected}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          for (final tp in progress.byType) ...[
            _ProgressItem(typeProgress: tp),
            if (tp != progress.byType.last) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final SealTypeProgress typeProgress;
  const _ProgressItem({required this.typeProgress});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            typeProgress.type.label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: typeProgress.percentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${typeProgress.collected}/${typeProgress.total}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textHint.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _SealGrid extends StatelessWidget {
  final List<SealDetail> seals;
  const _SealGrid({required this.seals});

  @override
  Widget build(BuildContext context) {
    if (seals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 40,
              color: AppColors.textHint.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            const Text('暂无印记', style: TextStyle(color: AppColors.textHint)),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: seals.length,
      itemBuilder: (ctx, i) => _SealCard(seal: seals[i]),
    );
  }
}

class _SealCard extends StatelessWidget {
  final SealDetail seal;
  const _SealCard({required this.seal});

  @override
  Widget build(BuildContext context) {
    final isLocked = !seal.owned;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked ? null : () => context.push('/seal/${seal.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: isLocked
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.7),
                    ],
                  ),
            color: isLocked
                ? AppColors.surfaceVariant.withValues(alpha: 0.5)
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLocked
                  ? AppColors.border.withValues(alpha: 0.3)
                  : AppColors.border.withValues(alpha: 0.5),
            ),
            boxShadow: isLocked
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLocked
                      ? AppColors.textHint.withValues(alpha: 0.1)
                      : AppColors.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLocked
                      ? Icons.lock_rounded
                      : Icons.workspace_premium_rounded,
                  size: 28,
                  color: isLocked
                      ? AppColors.textHint.withValues(alpha: 0.5)
                      : AppColors.accent,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  isLocked ? '???' : seal.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isLocked
                        ? AppColors.textHint
                        : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (seal.isChained == true) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sealGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 10,
                        color: AppColors.sealGold,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '上链',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.sealGold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.title,
    required this.icon,
    this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: isSelected ? AppColors.accent.withValues(alpha: 0.05) : null,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.textSecondary).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: AppColors.accent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
