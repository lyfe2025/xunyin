import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/upload_service.dart';
import '../../../services/profile_service.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/user_providers.dart';

/// 修改头像页面
class EditAvatarPage extends ConsumerStatefulWidget {
  const EditAvatarPage({super.key});

  @override
  ConsumerState<EditAvatarPage> createState() => _EditAvatarPageState();
}

class _EditAvatarPageState extends ConsumerState<EditAvatarPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentAvatar();
  }

  void _loadCurrentAvatar() {
    final userAsync = ref.read(currentUserProvider);
    userAsync.whenData((user) {
      if (user != null && mounted) {
        setState(() {
          _currentAvatarUrl = user.avatarUrl;
        });
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
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

      // 上传图片
      final avatarUrl = await uploadService.uploadAvatar(_selectedImage!);

      // 更新用户头像
      await profileService.updateAvatar(avatarUrl);

      // 刷新用户信息
      ref.invalidate(currentUserProvider);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('头像修改成功')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('修改失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('取消'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '修改头像',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          if (_selectedImage != null)
            TextButton(
              onPressed: _isLoading ? null : _uploadAndSave,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // 头像预览
          Center(
            child: GestureDetector(
              onTap: _showImageSourceDialog,
              child: Stack(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : _currentAvatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_currentAvatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null && _currentAvatarUrl == null
                        ? const Icon(Icons.person, size: 80, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 提示文字
          const Text(
            '点击头像更换',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            '支持 jpg、png、gif、webp 格式，最大 2MB',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
          const Spacer(),
          // 选择按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showImageSourceDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('选择图片'),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
