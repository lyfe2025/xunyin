import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../providers/service_providers.dart';
import '../../../services/sms_service.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_snackbar.dart';

/// 绑定手机页面 - Aurora UI + Glassmorphism
class BindPhonePage extends ConsumerStatefulWidget {
  const BindPhonePage({super.key});

  @override
  ConsumerState<BindPhonePage> createState() => _BindPhonePageState();
}

class _BindPhonePageState extends ConsumerState<BindPhonePage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isSending = false;
  int _countdown = 0;
  Timer? _timer;

  late final SmsService _smsService;

  @override
  void initState() {
    super.initState();
    final apiClient = ref.read(apiClientProvider);
    _smsService = SmsService(apiClient);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppSnackBar.error(context, '请输入手机号');
      return;
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      AppSnackBar.error(context, '请输入正确的手机号');
      return;
    }

    setState(() => _isSending = true);

    try {
      final message = await _smsService.sendCode(phone);
      _startCountdown();
      if (mounted) {
        AppSnackBar.success(context, message);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _bindPhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _smsService.bindPhone(
        _phoneController.text.trim(),
        _codeController.text.trim(),
      );

      if (mounted) {
        AppSnackBar.success(context, '绑定成功');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AuroraBackground(variant: AuroraVariant.form),
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Row(
        children: [
          AppBackButton(onTap: () => Navigator.of(context).pop()),
          Expanded(
            child: Text(
              '绑定手机号',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryAdaptive(context),
              ),
            ),
          ),
          const SizedBox(width: AppSize.iconButtonSize),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_android_rounded,
                size: 56,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              '绑定手机号',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryAdaptive(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '绑定手机号后可用于账号安全验证',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryAdaptive(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            _buildFormCard(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '验证码将发送到您的手机，5分钟内有效',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHintAdaptive(context),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFormCard() {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: AppOpacity.glassCard)
            : Colors.white.withValues(alpha: AppOpacity.glassCard),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: AppOpacity.glassBorder)
              : Colors.white.withValues(alpha: AppOpacity.glassBorder),
        ),
        boxShadow: AppShadow.glass,
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            decoration: InputDecoration(
              labelText: '手机号',
              hintText: '请输入手机号',
              prefixIcon: Icon(
                Icons.phone_rounded,
                color: AppColors.textHintAdaptive(context),
              ),
              filled: true,
              fillColor: AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return '请输入手机号';
              if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                return '请输入正确的手机号';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    labelText: '验证码',
                    hintText: '请输入验证码',
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.textHintAdaptive(context),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '请输入验证码';
                    if (value.length != 6) return '验证码为6位数字';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _buildCodeButton(),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppPrimaryButton(
            onPressed: _isLoading ? null : _bindPhone,
            isLoading: _isLoading,
            child: const Text('确认绑定'),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeButton() {
    final isDisabled = _isSending || _countdown > 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : _sendCode,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Container(
          width: 100,
          height: AppSize.buttonHeight,
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColors.surfaceVariantAdaptive(context)
                : AppColors.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
              color: isDisabled
                  ? AppColors.borderAdaptive(context)
                  : AppColors.accent.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  )
                : Text(
                    _countdown > 0 ? '${_countdown}s' : '获取验证码',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDisabled
                          ? AppColors.textHintAdaptive(context)
                          : AppColors.accent,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
