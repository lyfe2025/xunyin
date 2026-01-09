import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/seal_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../shared/widgets/share_bottom_sheet.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/app_loading.dart';

/// 印记详情页 - Aurora UI + Glassmorphism
class SealDetailPage extends ConsumerWidget {
  final String sealId;
  const SealDetailPage({super.key, required this.sealId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sealAsync = ref.watch(sealDetailProvider(sealId));

    return Scaffold(
      body: Stack(
        children: [
          const AuroraBackground(variant: AuroraVariant.golden),
          SafeArea(
            child: Column(
              children: [
                const AppPageHeader(title: '印记详情'),
                Expanded(
                  child: sealAsync.when(
                    data: (seal) => _buildContent(context, ref, seal),
                    loading: () => const AppLoading(message: '加载中...'),
                    error: (e, _) => _buildErrorState(e.toString()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, seal) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 印记图标
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 64,
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // 印记名称
        Center(
          child: Text(
            seal.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              seal.type.label,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (seal.earnedTime != null) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              '获得时间：${seal.earnedTime.toString().substring(0, 16)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ),
        ],
        const SizedBox(height: 28),
        _buildInfoSection(seal),
        const SizedBox(height: 20),
        if (seal.isChained == true)
          _buildChainedSection(seal.txHash)
        else
          _buildChainButton(context, ref),
        const SizedBox(height: 20),
        _buildShareButton(context, seal),
      ],
    );
  }

  Widget _buildInfoSection(seal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '完成信息',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (seal.timeSpentMinutes != null)
            _infoRow(Icons.timer_rounded, '用时', '${seal.timeSpentMinutes}分钟'),
          if (seal.pointsEarned != null)
            _infoRow(Icons.stars_rounded, '获得积分', '${seal.pointsEarned}'),
          if (seal.journeyName != null)
            _infoRow(Icons.route_rounded, '关联文化之旅', seal.journeyName!),
          if (seal.cityName != null)
            _infoRow(Icons.location_city_rounded, '关联城市', seal.cityName!),
          if (seal.badgeTitle != null)
            _infoRow(Icons.military_tech_rounded, '解锁称号', seal.badgeTitle!),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildChainedSection(String? txHash) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.sealGold.withValues(alpha: 0.15),
            AppColors.sealGold.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sealGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_rounded, size: 18, color: AppColors.sealGold),
              const SizedBox(width: 8),
              const Text(
                '已上链',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.sealGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.link_rounded, '链', 'Polygon'),
          _infoRow(
            Icons.tag_rounded,
            '交易哈希',
            txHash != null && txHash.length > 16
                ? '${txHash.substring(0, 8)}...${txHash.substring(txHash.length - 6)}'
                : txHash ?? '',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (txHash != null) {
                        Clipboard.setData(ClipboardData(text: txHash));
                      }
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('复制哈希'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.sealGold,
                      side: const BorderSide(color: AppColors.sealGold),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('链上查看'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.sealGold,
                      side: const BorderSide(color: AppColors.sealGold),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link_rounded, size: 18, color: AppColors.tertiary),
              const SizedBox(width: 8),
              Text(
                '上链存证',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '将此印记永久记录到区块链',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await ref.read(sealServiceProvider).chainSeal(sealId);
                  ref.invalidate(sealDetailProvider(sealId));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('上链成功'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('上链失败: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.rocket_launch_rounded, size: 18),
              label: const Text(
                '立即上链',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, seal) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => ShareBottomSheet.show(context, seal: seal),
        icon: const Icon(Icons.share_rounded, size: 20),
        label: const Text(
          '分享印记',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
