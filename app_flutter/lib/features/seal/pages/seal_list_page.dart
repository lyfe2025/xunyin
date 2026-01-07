import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/seal.dart';
import '../../../providers/seal_providers.dart';

/// 印记集页面
class SealListPage extends ConsumerWidget {
  const SealListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(sealProgressProvider);
    final sealsAsync = ref.watch(allSealsProvider);
    final selectedType = ref.watch(selectedSealTypeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '我的印记集',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          progressAsync.when(
            data: (progress) => _buildProgressCard(progress),
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('$e'),
          ),
          const SizedBox(height: 24),
          for (final type in SealType.values) ...[
            if (selectedType == null || selectedType == type) ...[
              _buildSectionTitle(type.label),
              const SizedBox(height: 12),
              sealsAsync.when(
                data: (seals) => _buildSealGrid(
                  context,
                  seals.where((s) => s.type == type).toList(),
                ),
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('$e'),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard(SealProgress progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, size: 16, color: AppColors.primary),
              SizedBox(width: 4),
              Text('收集进度', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          for (final tp in progress.byType) ...[
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    tp.type.label,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: tp.percentage,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${tp.collected}/${tp.total}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('已上链', style: TextStyle(fontSize: 12)),
              Text(
                '${progress.collected}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSealGrid(BuildContext context, List<SealDetail> seals) {
    if (seals.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('暂无印记', style: TextStyle(color: AppColors.textHint)),
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
        childAspectRatio: 0.8,
      ),
      itemCount: seals.length,
      itemBuilder: (ctx, i) => _SealCard(
        seal: seals[i],
        onTap: () => context.push('/seal/${seals[i].id}'),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('全部'),
              onTap: () {
                ref.read(selectedSealTypeProvider.notifier).state = null;
                Navigator.pop(ctx);
              },
            ),
            for (final type in SealType.values)
              ListTile(
                title: Text(type.label),
                onTap: () {
                  ref.read(selectedSealTypeProvider.notifier).state = type;
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SealCard extends StatelessWidget {
  final SealDetail seal;
  final VoidCallback onTap;
  const _SealCard({required this.seal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLocked = !seal.owned;
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isLocked ? AppColors.surfaceVariant : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLocked ? Icons.lock : Icons.verified,
              size: 32,
              color: isLocked ? AppColors.textHint : AppColors.accent,
            ),
            const SizedBox(height: 8),
            Text(
              isLocked ? '???' : seal.name,
              style: TextStyle(
                fontSize: 12,
                color: isLocked ? AppColors.textHint : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            if (seal.isChained == true)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.link, size: 12, color: AppColors.sealGold),
              ),
          ],
        ),
      ),
    );
  }
}
