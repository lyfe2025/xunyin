import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/seal.dart';
import '../../services/share_service.dart';
import 'seal_share_card.dart';

/// 分享底部弹窗
class ShareBottomSheet extends StatefulWidget {
  final SealDetail seal;
  final String? userName;

  const ShareBottomSheet({super.key, required this.seal, this.userName});

  static Future<void> show(
    BuildContext context, {
    required SealDetail seal,
    String? userName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBottomSheet(seal: seal, userName: userName),
    );
  }

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveToAlbum() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    await ShareService.captureAndSave(_cardKey);

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  void _copyLink() {
    // 使用 userSealId 生成分享链接，如果没有则使用 sealId
    final shareId = widget.seal.userSealId ?? widget.seal.id;
    final link = ShareService.generateSealShareLink(shareId);
    ShareService.copyLink(link);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖动条
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // 标题
            const Text(
              '分享印记',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            // 预览卡片
            RepaintBoundary(
              key: _cardKey,
              child: SealShareCard(
                seal: widget.seal,
                userName: widget.userName,
              ),
            ),
            const SizedBox(height: 24),
            // 分享选项
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShareOption(
                    icon: Icons.save_alt,
                    label: '保存图片',
                    isLoading: _isSaving,
                    onTap: _saveToAlbum,
                  ),
                  _ShareOption(
                    icon: Icons.link,
                    label: '复制链接',
                    onTap: _copyLink,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 取消按钮
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '取消',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Icon(icon, size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
