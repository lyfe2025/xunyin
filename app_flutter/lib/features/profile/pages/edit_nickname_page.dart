import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/profile_service.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/user_providers.dart';

/// 修改昵称页面
class EditNicknamePage extends ConsumerStatefulWidget {
  const EditNicknamePage({super.key});

  @override
  ConsumerState<EditNicknamePage> createState() => _EditNicknamePageState();
}

class _EditNicknamePageState extends ConsumerState<EditNicknamePage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 初始化当前昵称 - 延迟获取
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userAsync = ref.read(currentUserProvider);
      userAsync.whenData((user) {
        if (user != null && mounted) {
          _controller.text = user.nickname ?? '';
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final api = ref.read(apiClientProvider);
      final service = ProfileService(api);
      await service.updateNickname(_controller.text.trim());

      // 刷新用户信息
      ref.invalidate(currentUserProvider);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('昵称修改成功')));
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
          '修改昵称',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '昵称',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _controller,
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: '请输入昵称',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  counterText: '',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () => _controller.clear(),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入昵称';
                  }
                  if (value.trim().length < 2) {
                    return '昵称至少2个字符';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                '昵称长度2-20个字符',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
