import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/api/api_client.dart';
import '../../../services/auth_service.dart';

/// 登录页 - Aurora UI + Glassmorphism 风格
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  int _countdown = 0;
  final _authService = AuthService(ApiClient());

  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    // Logo 动画
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _logoAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // 开发测试：默认填写测试账号
    _phoneController.text = '13800138000';
    _autoSendCode();
  }

  Future<void> _autoSendCode() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final result = await _authService.sendSmsCode(_phoneController.text);
      if (result['code'] != null) {
        _codeController.text = result['code'].toString();
      }
    } catch (e) {
      _codeController.text = '123456';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_phoneController.text.length != 11) {
      _showSnackBar('请输入正确的手机号');
      return;
    }
    try {
      await _authService.sendSmsCode(_phoneController.text);
      setState(() => _countdown = 60);
      _startCountdown();
      if (mounted) {
        _showSnackBar('验证码已发送');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('发送失败: $e');
      }
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_countdown > 0 && mounted) {
        setState(() => _countdown--);
        _startCountdown();
      }
    });
  }

  Future<void> _login() async {
    if (_phoneController.text.length != 11) {
      _showSnackBar('请输入正确的手机号');
      return;
    }
    if (_codeController.text.length != 6) {
      _showSnackBar('请输入6位验证码');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.loginWithPhone(
        phone: _phoneController.text,
        code: _codeController.text,
      );
      if (mounted) context.go('/');
    } on ApiException catch (e) {
      if (mounted) _showSnackBar(e.message);
    } catch (e) {
      if (mounted) _showSnackBar('登录失败: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), margin: const EdgeInsets.all(16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Aurora 渐变背景
          _buildAuroraBackground(),
          // 主内容
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildLogo(),
                  const SizedBox(height: 48),
                  _buildLoginForm(),
                  const SizedBox(height: 32),
                  _buildLoginButton(),
                  const SizedBox(height: 40),
                  _buildOtherLogin(),
                  const SizedBox(height: 40),
                  _buildAgreement(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Aurora 渐变背景
  Widget _buildAuroraBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFDF8F5), // 暖白
            Color(0xFFF8F5F0), // 宣纸色
            Color(0xFFF5F0EB), // 米色
          ],
        ),
      ),
      child: CustomPaint(
        painter: _AuroraBackgroundPainter(),
        size: Size.infinite,
      ),
    );
  }

  /// Logo 区域
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _logoAnimation.value),
          child: child,
        );
      },
      child: Column(
        children: [
          // 印章 Logo
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, AppColors.accentDark],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '印',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '寻印',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '探索城市文化，收集专属印记',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// 登录表单
  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 手机号输入
          _buildInputField(
            controller: _phoneController,
            hintText: '请输入手机号',
            keyboardType: TextInputType.phone,
            maxLength: 11,
            prefixIcon: Icons.smartphone_rounded,
          ),
          const SizedBox(height: 16),
          // 验证码输入
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _codeController,
                  hintText: '请输入验证码',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  prefixIcon: Icons.lock_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              _buildCodeButton(),
            ],
          ),
        ],
      ),
    );
  }

  /// 输入框
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required int maxLength,
    required IconData prefixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        filled: true,
        fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
        prefixIcon: Icon(prefixIcon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  /// 获取验证码按钮
  Widget _buildCodeButton() {
    final isDisabled = _countdown > 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : _sendCode,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          height: 48,
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColors.surfaceVariant
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDisabled
                  ? AppColors.border
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              _countdown > 0 ? '${_countdown}s' : '获取验证码',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDisabled ? AppColors.textHint : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 登录按钮
  Widget _buildLoginButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _login,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isLoading
                  ? [AppColors.textHint, AppColors.textHint]
                  : [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isLoading
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '登录',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// 其他登录方式
  Widget _buildOtherLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: AppColors.border.withValues(alpha: 0.6)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '其他登录方式',
                style: TextStyle(
                  color: AppColors.textHint.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: AppColors.border.withValues(alpha: 0.6)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.wechat,
              color: const Color(0xFF07C160),
              onTap: () {
                // TODO: 微信登录
              },
            ),
          ],
        ),
      ],
    );
  }

  /// 社交登录按钮
  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  /// 用户协议
  Widget _buildAgreement() {
    return Text.rich(
      TextSpan(
        text: '登录即表示同意',
        style: TextStyle(
          color: AppColors.textHint.withValues(alpha: 0.8),
          fontSize: 12,
        ),
        children: [
          TextSpan(
            text: '《用户协议》',
            style: TextStyle(color: AppColors.primary.withValues(alpha: 0.9)),
          ),
          const TextSpan(text: '和'),
          TextSpan(
            text: '《隐私政策》',
            style: TextStyle(color: AppColors.primary.withValues(alpha: 0.9)),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Aurora 背景绘制
class _AuroraBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 右上角光晕
    paint.color = AppColors.accent.withValues(alpha: 0.04);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.1),
      size.width * 0.5,
      paint,
    );

    // 左下角光晕
    paint.color = AppColors.tertiary.withValues(alpha: 0.05);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.85),
      size.width * 0.45,
      paint,
    );

    // 中间光晕
    paint.color = AppColors.sealGold.withValues(alpha: 0.02);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      size.width * 0.35,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
