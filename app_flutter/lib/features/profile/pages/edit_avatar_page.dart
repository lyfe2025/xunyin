import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/url_utils.dart';
import '../../../services/upload_service.dart';
import '../../../services/profile_service.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/user_providers.dart';
import '../../../shared/widgets/app_snackbar.dart';

/// 修改头像页面 - Aurora UI + Glassmorphism
class EditAvatarPage extends ConsumerStatefulWidget {
  const EditAvatarPage({super.key});

  @override
  ConsumerState<EditAvatarPage> createState() => _EditAvatarPageState();
}

class _EditAvatarPageState extends ConsumerState<EditAvatarPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    debugPrint('📷 开始选择图片，来源: $source');
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        // iOS 14+ 使用旧版选择器，避免模拟器 PHPicker 问题
        requestFullMetadata: false,
      );
      debugPrint('📷 选择结果: ${image?.path ?? "取消"}');
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      debugPrint('📷 选择图片异常: $e');
      if (mounted) {
        AppSnackBar.error(context, '选择图片失败: $e');
      }
    }
  }

  Future<void> _uploadAndSave() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      final api = ref.read(apiClientProvider);
      final uploadService = UploadService(api);
      final profileService = ProfileService(api);

      final avatarUrl = await uploadService.uploadAvatar(_selectedImage!);
      await profileService.updateAvatar(avatarUrl);
      ref.invalidate(currentUserProvider);

      if (mounted) {
        AppSnackBar.success(context, '头像修改成功');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, '修改失败: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showImageSourceDialog() {
    final isDark = context.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.accent,
                  ),
                ),
                title: Text(
                  '拍照',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  '从相册选择',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AuroraBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimaryAdaptive(context),
                size: 22,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '修改头像',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryAdaptive(context),
              ),
            ),
          ),
          // 右侧占位或保存按钮
          if (_selectedImage != null)
            GestureDetector(
              onTap: _isLoading ? null : _uploadAndSave,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentDark],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '保存',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            )
          else
            // 占位，保持标题居中
            const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    final displayName = user?.displayName ?? '旅行者';
    final avatarUrl = user?.avatarUrl;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),
          // 头像区域 - 更大更醒目
          Center(
            child: GestureDetector(
              onTap: _showImageSourceDialog,
              child: Stack(
                children: [
                  // 外圈装饰
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accent.withValues(alpha: 0.1),
                          AppColors.primary.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Center(
                      child: _buildAvatarContent(avatarUrl, displayName),
                    ),
                  ),
                  // 相机图标 - 更大更醒目
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.accent, AppColors.accentDark],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            '点击头像更换',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryAdaptive(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '支持 jpg、png、gif、webp 格式，最大 2MB',
            style: TextStyle(fontSize: 13, color: AppColors.textHintAdaptive(context)),
          ),
          const SizedBox(height: 48),
          // 操作按钮区域
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // 拍照按钮
                Expanded(
                  child: _ActionButton(
                    icon: Icons.camera_alt_rounded,
                    label: '拍照',
                    color: AppColors.accent,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                // 相册按钮
                Expanded(
                  child: _ActionButton(
                    icon: Icons.photo_library_rounded,
                    label: '相册',
                    color: AppColors.primary,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 提示卡片
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Builder(
              builder: (context) {
                final isDark = context.isDarkMode;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder.withValues(alpha: 0.5)
                          : AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Column(
                    children: [
                      _TipItem(
                        icon: Icons.lightbulb_outline_rounded,
                        text: '建议使用正方形图片，效果更佳',
                      ),
                      SizedBox(height: 12),
                      _TipItem(
                        icon: Icons.face_rounded,
                        text: '清晰的正面照片更容易被朋友认出',
                      ),
                      SizedBox(height: 12),
                      _TipItem(
                        icon: Icons.palette_outlined,
                        text: '选择有特色的照片展示你的个性',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 构建头像内容（选中的图片 > 网络头像 > 昵称首字母）
  Widget _buildAvatarContent(String? avatarUrl, String displayName) {
    // 如果选择了新图片
    if (_selectedImage != null) {
      return Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          image: DecorationImage(
            image: FileImage(_selectedImage!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // 如果有网络头像
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            UrlUtils.getFullImageUrl(avatarUrl),
            width: 180,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildTextAvatar(displayName),
          ),
        ),
      );
    }

    // 显示昵称首字母（和个人中心一致）
    return _buildTextAvatar(displayName);
  }

  /// 构建文字头像（昵称首字母）
  Widget _buildTextAvatar(String displayName) {
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final avatarColor = _generateColorFromName(displayName);

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [avatarColor, avatarColor.withValues(alpha: 0.7)],
        ),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: avatarColor.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// 根据字符串生成稳定的颜色
  Color _generateColorFromName(String name) {
    if (name.isEmpty) return AppColors.accent;
    final hash = name.codeUnits.fold(0, (prev, curr) => prev + curr);
    final colors = [
      const Color(0xFFE57373),
      const Color(0xFFFFB74D),
      const Color(0xFFFFD54F),
      const Color(0xFF81C784),
      const Color(0xFF4FC3F7),
      const Color(0xFF9575CD),
      const Color(0xFFF06292),
      const Color(0xFF4DB6AC),
    ];
    return colors[hash % colors.length];
  }
}

/// 操作按钮组件
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 提示项组件
class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textHintAdaptive(context)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryAdaptive(context),
            ),
          ),
        ),
      ],
    );
  }
}

/// Aurora 背景
class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.darkBackground, const Color(0xFF1A1A22), const Color(0xFF151518)]
              : [const Color(0xFFF8F6F3), const Color(0xFFF0EDE8), const Color(0xFFE8E4DD)],
        ),
      ),
      child: CustomPaint(painter: _AuroraPainter(isDark: isDark), size: Size.infinite),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final bool isDark;
  _AuroraPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.08);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.15),
      size.width * 0.45,
      paint,
    );
    paint.color = AppColors.accent.withValues(alpha: isDark ? 0.1 : 0.06);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.5),
      size.width * 0.35,
      paint,
    );
    paint.color = AppColors.tertiary.withValues(alpha: isDark ? 0.08 : 0.05);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.75),
      size.width * 0.3,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) => oldDelegate.isDark != isDark;
}
