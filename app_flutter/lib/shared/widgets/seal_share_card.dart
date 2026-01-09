import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/url_utils.dart';
import '../../models/seal.dart';

/// 印记分享卡片（用于截图分享）
class SealShareCard extends StatelessWidget {
  final SealDetail seal;
  final String? userName;

  const SealShareCard({super.key, required this.seal, this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF6E3), Color(0xFFF5E6D3)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Text(
            '寻印 · 文化之旅',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          // 印记图片
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sealGold.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildSealImage(),
            ),
          ),
          const SizedBox(height: 16),
          // 印记名称
          Text(
            seal.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (seal.badgeTitle != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sealGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                seal.badgeTitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.sealGold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // 类型和城市
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTag(seal.type.label),
              if (seal.cityName != null) ...[
                const SizedBox(width: 8),
                _buildTag(seal.cityName!),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // 分割线
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          // 获得信息
          if (seal.earnedTime != null)
            Text(
              '${userName ?? '探索者'} 于 ${_formatDate(seal.earnedTime!)} 获得',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          const SizedBox(height: 8),
          // 区块链存证标识
          if (seal.isChained == true)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  '已上链存证',
                  style: TextStyle(fontSize: 12, color: AppColors.success),
                ),
              ],
            ),
          const SizedBox(height: 16),
          // 二维码提示
          Text(
            '扫码下载「寻印」App 开启你的文化之旅',
            style: TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildSealImage() {
    if (seal.imageAsset.startsWith('assets/')) {
      return Image.asset(
        seal.imageAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return CachedNetworkImage(
      imageUrl: UrlUtils.getFullImageUrl(seal.imageAsset),
      fit: BoxFit.cover,
      placeholder: (_, __) => _buildPlaceholder(),
      errorWidget: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Icon(Icons.emoji_events, size: 64, color: AppColors.sealGold),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
