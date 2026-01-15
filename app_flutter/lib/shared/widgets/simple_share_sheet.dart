import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/share_service.dart';

/// 简化版分享弹窗（用于没有完整 seal 数据的场景）
class SimpleShareSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String shareLink;
  final Widget? previewWidget;

  const SimpleShareSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.shareLink,
    this.previewWidget,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    required String shareLink,
    Widget? previewWidget,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SimpleShareSheet(
        title: title,
        subtitle: subtitle,
        shareLink: shareLink,
        previewWidget: previewWidget,
      ),
    );
  }

  @override
  State<SimpleShareSheet> createState() => _SimpleShareSheetState();
}

class _SimpleShareSheetState extends State<SimpleShareSheet> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveToAlbum() async {
    if (_isSaving || widget.previewWidget == null) return;
    setState(() => _isSaving = true);
    await ShareService.captureAndSave(context, _cardKey);
    if (mounted) setState(() => _isSaving = false);
  }

  void _copyLink() {
    ShareService.copyLink(context, widget.shareLink);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderAdaptive(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryAdaptive(context),
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryAdaptive(context),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (widget.previewWidget != null)
              RepaintBoundary(key: _cardKey, child: widget.previewWidget),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.previewWidget != null)
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '取消',
                style: TextStyle(
                  color: AppColors.textSecondaryAdaptive(context),
                  fontSize: 16,
                ),
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
              color: AppColors.surfaceVariantAdaptive(context),
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
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryAdaptive(context),
            ),
          ),
        ],
      ),
    );
  }
}
