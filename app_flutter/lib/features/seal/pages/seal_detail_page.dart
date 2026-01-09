import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/seal_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../shared/widgets/share_bottom_sheet.dart';

/// 印记详情页
class SealDetailPage extends ConsumerWidget {
  final String sealId;
  const SealDetailPage({super.key, required this.sealId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sealAsync = ref.watch(sealDetailProvider(sealId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '印记详情',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: sealAsync.when(
        data: (seal) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.verified,
                  size: 64,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                seal.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                seal.type.label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            if (seal.earnedTime != null)
              Center(
                child: Text(
                  '获得时间：${seal.earnedTime.toString().substring(0, 16)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _buildInfoSection(seal),
            const SizedBox(height: 24),
            if (seal.isChained == true)
              _buildChainSection(seal.txHash)
            else
              _buildChainButton(context, ref),
            const SizedBox(height: 24),
            _buildShareButton(context, seal),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Widget _buildInfoSection(seal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('完成信息', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (seal.timeSpentMinutes != null)
            _infoRow('用时', '${seal.timeSpentMinutes}分钟'),
          if (seal.pointsEarned != null)
            _infoRow('获得积分', '${seal.pointsEarned}'),
          if (seal.journeyName != null) _infoRow('关联文化之旅', seal.journeyName!),
          if (seal.cityName != null) _infoRow('关联城市', seal.cityName!),
          if (seal.badgeTitle != null) _infoRow('解锁称号', seal.badgeTitle!),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildChainSection(String? txHash) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sealGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified, color: AppColors.sealGold, size: 16),
              SizedBox(width: 4),
              Text(
                '已上链',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.sealGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('链', 'Polygon'),
          _infoRow(
            '交易哈希',
            txHash != null && txHash.length > 16
                ? '${txHash.substring(0, 8)}...${txHash.substring(txHash.length - 6)}'
                : txHash ?? '',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (txHash != null) {
                      Clipboard.setData(ClipboardData(text: txHash));
                    }
                  },
                  child: const Text('复制哈希'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('链上查看'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChainButton(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.link, color: AppColors.primary, size: 16),
              SizedBox(width: 4),
              Text('上链存证', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '将此印记永久记录到区块链',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(sealServiceProvider).chainSeal(sealId);
                  ref.invalidate(sealDetailProvider(sealId));
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('上链成功')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('上链失败: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('立即上链'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, seal) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => ShareBottomSheet.show(context, seal: seal),
        icon: const Icon(Icons.share),
        label: const Text('分享印记'),
      ),
    );
  }
}
