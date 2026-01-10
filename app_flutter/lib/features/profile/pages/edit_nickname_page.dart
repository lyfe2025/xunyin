import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../services/profile_service.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/user_providers.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/app_snackbar.dart';

/// 修改昵称页面 - Aurora UI + Glassmorphism
class EditNicknamePage extends ConsumerStatefulWidget {
  const EditNicknamePage({super.key});

  @override
  ConsumerState<EditNicknamePage> createState() => _EditNicknamePageState();
}

class _EditNicknamePageState extends ConsumerState<EditNicknamePage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _originalNickname = '';

  // 是否可以保存：有修改 + 长度符合要求
  bool get _canSave =>
      !_isLoading &&
      _controller.text.trim() != _originalNickname &&
      _controller.text.trim().length >= 2;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    // 页面创建时立即加载最新数据
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNickname());
  }

  void _loadNickname() {
    final homeDataAsync = ref.read(profileHomeProvider);
    homeDataAsync.whenData((data) {
      if (mounted && data.user != null) {
        final nickname = data.user?.nickname ?? '';
        setState(() {
          _originalNickname = nickname;
          _controller.text = nickname;
        });
      }
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
      // 刷新用户数据和个人中心数据
      ref.invalidate(currentUserProvider);
      ref.invalidate(profileHomeProvider);

      if (mounted) {
        AppSnackBar.success(context, '昵称修改成功');
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

  @override
  Widget build(BuildContext context) {
    // 监听数据变化，但不在这里初始化（已在 initState 中处理）
    ref.watch(profileHomeProvider);

    return Scaffold(
      body: Stack(
        children: [
          const AuroraBackground(variant: AuroraVariant.form),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: _buildForm(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          const AppBackButton(),
          Expanded(
            child: Text(
              '修改昵称',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryAdaptive(context),
              ),
            ),
          ),
          GestureDetector(
            onTap: _canSave ? _save : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: _canSave
                    ? const LinearGradient(
                        colors: [AppColors.accent, Color(0xFFE85A4F)],
                      )
                    : LinearGradient(
                        colors: context.isDarkMode
                            ? [Colors.grey.shade700, Colors.grey.shade800]
                            : [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                borderRadius: BorderRadius.circular(AppRadius.iconButton),
                boxShadow: _canSave ? AppShadow.accent(AppColors.accent) : null,
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
                  : Text(
                      '保存',
                      style: TextStyle(
                        color: _canSave
                            ? Colors.white
                            : (context.isDarkMode
                                ? Colors.grey.shade500
                                : Colors.grey.shade500),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.5),
            ),
            boxShadow: AppShadow.medium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '昵称',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryAdaptive(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controller,
                maxLength: 20,
                style: TextStyle(
                  color: AppColors.textPrimaryAdaptive(context),
                ),
                decoration: InputDecoration(
                  hintText: '请输入昵称',
                  hintStyle: TextStyle(
                    color: AppColors.textHintAdaptive(context),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide.none,
                  ),
                  counterText: '${_controller.text.length}/20',
                  counterStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHintAdaptive(context),
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            size: 20,
                            color: AppColors.textHintAdaptive(context),
                          ),
                          onPressed: () => _controller.clear(),
                        )
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return '请输入昵称';
                  if (value.trim().length < 2) return '昵称至少2个字符';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Text(
                '昵称长度2-20个字符',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHintAdaptive(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
