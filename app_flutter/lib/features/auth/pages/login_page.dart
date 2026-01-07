import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/api/api_client.dart';
import '../../../services/auth_service.dart';

/// 登录页
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  int _countdown = 0;
  final _authService = AuthService(ApiClient());

  @override
  void initState() {
    super.initState();
    // 开发测试：默认填写测试账号
    _phoneController.text = '13800138000';
    // 自动发送验证码获取测试验证码
    _autoSendCode();
  }

  Future<void> _autoSendCode() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final result = await _authService.sendSmsCode(_phoneController.text);
      // 开发环境后端会返回验证码
      if (result['code'] != null) {
        _codeController.text = result['code'].toString();
      }
    } catch (e) {
      // 忽略错误，用户可以手动发送
      _codeController.text = '123456';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_phoneController.text.length != 11) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入正确的手机号')));
      return;
    }
    try {
      await _authService.sendSmsCode(_phoneController.text);
      setState(() => _countdown = 60);
      _startCountdown();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('验证码已发送（测试环境：123456）')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('发送失败: $e')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入正确的手机号')));
      return;
    }
    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入6位验证码')));
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('登录失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Logo & 标题
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          '印',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '寻印',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '探索城市文化，收集专属印记',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              // 手机号输入
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: const InputDecoration(
                  hintText: '请输入手机号',
                  counterText: '',
                  prefixIcon: Icon(
                    Icons.phone_android,
                    color: AppColors.textHint,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 验证码输入
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        hintText: '请输入验证码',
                        counterText: '',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 110,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _countdown > 0 ? null : _sendCode,
                      child: Text(
                        _countdown > 0 ? '${_countdown}s' : '获取验证码',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // 登录按钮
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('登录'),
              ),
              const SizedBox(height: 24),
              // 其他登录方式
              const Center(
                child: Text(
                  '其他登录方式',
                  style: TextStyle(color: AppColors.textHint, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: 微信登录
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF07C160),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.wechat,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // 协议
              Center(
                child: Text.rich(
                  TextSpan(
                    text: '登录即表示同意',
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: '《用户协议》',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      const TextSpan(text: '和'),
                      TextSpan(
                        text: '《隐私政策》',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
