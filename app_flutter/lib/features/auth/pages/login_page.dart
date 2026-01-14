import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../services/auth_service.dart';
import '../../../shared/widgets/aurora_background.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../providers/login_config_providers.dart';
import '../../../models/login_config.dart';

/// 登录页 - Aurora UI + Glassmorphism 风格
/// 支持从后台动态获取配置（背景、Logo、颜色、登录方式等）
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
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _logoAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // 开发测试：默认填写测试账号
    _phoneController.text = '13600136000';
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
      if (mounted) _showSnackBar('验证码已发送');
    } catch (e) {
      if (mounted) _showSnackBar('发送失败: $e');
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
    AppSnackBar.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(loginConfigProvider);
    // 根据 Logo 尺寸动态调整间距
    final isLargeLogo = config.logoSize == 'large';
    final topSpacing = isLargeLogo ? 40.0 : 60.0;
    final logoBottomSpacing = isLargeLogo ? 32.0 : 48.0;
    final sectionSpacing = isLargeLogo ? 24.0 : 32.0;

    return Scaffold(
      body: Stack(
        children: [
          // 背景（根据配置选择类型）
          _buildBackground(config),
          // 主内容
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 上半部分：Logo + 表单 + 按钮
                    Column(
                      children: [
                        SizedBox(height: topSpacing),
                        _buildLogo(config),
                        SizedBox(height: logoBottomSpacing),
                        if (config.phoneLoginEnabled) ...[
                          _buildLoginForm(config),
                          SizedBox(height: sectionSpacing),
                          _buildLoginButton(config),
                          SizedBox(height: sectionSpacing),
                        ],
                        _buildOtherLogin(config),
                      ],
                    ),
                    // 下半部分：协议（始终在底部）
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 24),
                      child: _buildAgreement(config),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建背景（支持 Aurora/图片/纯色/渐变）
  Widget _buildBackground(LoginConfig config) {
    final isDark = context.isDarkMode;

    // 如果禁用 Aurora 或使用图片背景
    if (!config.auroraEnabled || config.backgroundType == 'image') {
      if (config.backgroundType == 'image' && config.backgroundImage != null) {
        // 图片背景
        final baseUrl = AppConfig.baseUrl.replaceAll('/api/app', '');
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider('$baseUrl${config.backgroundImage}'),
              fit: BoxFit.cover,
            ),
          ),
        );
      } else if (config.backgroundType == 'color' && config.backgroundColor != null) {
        // 纯色背景
        return Container(color: _parseColor(config.backgroundColor!, isDark));
      } else if (config.backgroundType == 'gradient') {
        // 自定义渐变背景（无 Aurora 光晕）
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF1A1518), const Color(0xFF161216)]
                  : [
                      _parseColor(config.gradientStart ?? '#FDF8F5', isDark),
                      if (config.gradientMiddle != null)
                        _parseColor(config.gradientMiddle!, isDark),
                      _parseColor(config.gradientEnd ?? '#F5F0EB', isDark),
                    ],
            ),
          ),
        );
      }
    }

    // 默认使用 Aurora 背景
    return AuroraBackground(variant: _getAuroraVariant(config));
  }

  /// 解析颜色字符串
  Color _parseColor(String colorStr, bool isDark) {
    // 深色模式下返回深色
    if (isDark) return const Color(0xFF1A1518);
    
    try {
      if (colorStr.startsWith('#')) {
        final hex = colorStr.replaceFirst('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      } else if (colorStr.startsWith('rgba')) {
        // 解析 rgba(r, g, b, a) 格式
        final match = RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+),?\s*([\d.]+)?\)').firstMatch(colorStr);
        if (match != null) {
          final r = int.parse(match.group(1)!);
          final g = int.parse(match.group(2)!);
          final b = int.parse(match.group(3)!);
          final a = match.group(4) != null ? double.parse(match.group(4)!) : 1.0;
          return Color.fromRGBO(r, g, b, a);
        }
      }
    } catch (_) {}
    return const Color(0xFFFDF8F5); // 默认色
  }

  /// 根据配置获取 Aurora 变体
  AuroraVariant _getAuroraVariant(LoginConfig config) {
    switch (config.auroraPreset) {
      case 'standard':
        return AuroraVariant.standard;
      case 'golden':
        return AuroraVariant.golden;
      case 'warm':
      default:
        return AuroraVariant.warm;
    }
  }

  /// Logo 区域
  Widget _buildLogo(LoginConfig config) {
    final showAnimation = config.logoAnimationEnabled;
    
    Widget content = Column(
      children: [
        _buildLogoImage(config),
        const SizedBox(height: 20),
        // 应用名称（使用配置的颜色）
        Text(
          config.appName ?? '寻印',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: _parseColor(
              config.appNameColor ?? '#2D2D2D',
              context.isDarkMode,
            ),
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        // 标语（使用配置的颜色）
        Text(
          config.slogan ?? '探索城市文化，收集专属印记',
          style: TextStyle(
            fontSize: 14,
            color: _parseColor(
              config.sloganColor ?? '#666666',
              context.isDarkMode,
            ).withValues(alpha: 0.8),
            letterSpacing: 1,
          ),
        ),
      ],
    );

    if (!showAnimation) return content;

    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _logoAnimation.value),
        child: child,
      ),
      child: content,
    );
  }

  /// 构建 Logo 图片（支持配置尺寸）
  Widget _buildLogoImage(LoginConfig config) {
    // 根据 logoSize 配置确定尺寸
    final double size = switch (config.logoSize) {
      'small' => 68,
      'large' => 108,
      _ => 88, // normal
    };
    final double borderRadius = size * 0.25;

    final logoImage = config.logoImage;
    
    if (logoImage != null && logoImage.isNotEmpty) {
      final baseUrl = AppConfig.baseUrl.replaceAll('/api/app', '');
      final fullUrl = '$baseUrl$logoImage';
      
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: _getButtonPrimaryColor(config).withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: CachedNetworkImage(
            imageUrl: fullUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildDefaultLogo(config, size, borderRadius),
            errorWidget: (context, url, error) => _buildDefaultLogo(config, size, borderRadius),
          ),
        ),
      );
    }
    
    return _buildDefaultLogo(config, size, borderRadius);
  }

  /// 默认印章 Logo（使用配置的按钮颜色）
  Widget _buildDefaultLogo(LoginConfig config, double size, double borderRadius) {
    final primaryColor = _getButtonPrimaryColor(config);
    final gradientEndColor = _getButtonGradientEndColor(config);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, gradientEndColor],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '印',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }

  /// 获取按钮主色
  Color _getButtonPrimaryColor(LoginConfig config) {
    if (config.buttonPrimaryColor != null) {
      return _parseColor(config.buttonPrimaryColor!, false);
    }
    return AppColors.accent;
  }

  /// 获取按钮渐变结束色
  Color _getButtonGradientEndColor(LoginConfig config) {
    if (config.buttonGradientEndColor != null) {
      return _parseColor(config.buttonGradientEndColor!, false);
    }
    return AppColors.accentDark;
  }

  /// 获取按钮圆角
  double _getButtonRadius(LoginConfig config) {
    return switch (config.buttonRadius) {
      'none' => 0,
      'sm' => 6,
      'md' => 10,
      'full' => 26,
      _ => 14, // lg (default)
    };
  }

  /// 登录表单
  Widget _buildLoginForm(LoginConfig config) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInputField(
            config: config,
            controller: _phoneController,
            hintText: '请输入手机号',
            keyboardType: TextInputType.phone,
            maxLength: 11,
            prefixIcon: Icons.smartphone_rounded,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  config: config,
                  controller: _codeController,
                  hintText: '请输入验证码',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  prefixIcon: Icons.lock_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              _buildCodeButton(config),
            ],
          ),
        ],
      ),
    );
  }

  /// 输入框
  Widget _buildInputField({
    required LoginConfig config,
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required int maxLength,
    required IconData prefixIcon,
  }) {
    final primaryColor = _getButtonPrimaryColor(config);
    
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: TextStyle(
        fontSize: 16,
        color: AppColors.textPrimaryAdaptive(context),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textHintAdaptive(context)),
        counterText: '',
        filled: true,
        fillColor: AppColors.surfaceVariantAdaptive(context).withValues(alpha: 0.5),
        prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.textHintAdaptive(context)),
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
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  /// 获取验证码按钮
  Widget _buildCodeButton(LoginConfig config) {
    final isDisabled = _countdown > 0;
    final isDark = context.isDarkMode;
    final primaryColor = _getButtonPrimaryColor(config);

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
                ? AppColors.surfaceVariantAdaptive(context)
                : primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDisabled
                  ? AppColors.borderAdaptive(context)
                  : primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              _countdown > 0 ? '${_countdown}s' : '获取验证码',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDisabled ? AppColors.textHintAdaptive(context) : primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 登录按钮（使用配置的颜色、圆角和样式）
  Widget _buildLoginButton(LoginConfig config) {
    final primaryColor = _getButtonPrimaryColor(config);
    final gradientEndColor = _getButtonGradientEndColor(config);
    final radius = _getButtonRadius(config);
    final buttonStyle = config.buttonStyle ?? 'filled';

    // 根据 buttonStyle 构建不同的装饰
    BoxDecoration decoration;
    Color textColor;

    if (_isLoading) {
      // 加载中状态
      decoration = BoxDecoration(
        color: AppColors.textHint,
        borderRadius: BorderRadius.circular(radius),
      );
      textColor = Colors.white;
    } else {
      switch (buttonStyle) {
        case 'outlined':
          // 描边样式
          decoration = BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: primaryColor, width: 2),
          );
          textColor = primaryColor;
          break;
        case 'glass':
          // 玻璃态样式
          decoration = BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          );
          textColor = primaryColor;
          break;
        case 'filled':
        default:
          // 填充渐变样式（默认）
          decoration = BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, gradientEndColor],
            ),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          );
          textColor = Colors.white;
          break;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _login,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: decoration,
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: textColor,
                    ),
                  )
                : Text(
                    '登录',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: 2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// 其他登录方式
  Widget _buildOtherLogin(LoginConfig config) {
    final socialButtons = <Widget>[];
    
    if (config.wechatLoginEnabled) {
      socialButtons.add(_buildSocialButton(
        svgPath: 'assets/icons/wechat_logo.svg',
        label: '微信',
        onTap: () => _showSnackBar('微信登录开发中'),
      ));
    }
    
    if (config.appleLoginEnabled) {
      if (socialButtons.isNotEmpty) socialButtons.add(const SizedBox(width: 24));
      socialButtons.add(_buildSocialButton(
        svgPath: 'assets/icons/apple_logo.svg',
        label: 'Apple',
        onTap: () => _showSnackBar('Apple 登录开发中'),
        useThemeColor: true,
      ));
    }
    
    if (config.googleLoginEnabled) {
      if (socialButtons.isNotEmpty) socialButtons.add(const SizedBox(width: 24));
      socialButtons.add(_buildSocialButton(
        svgPath: 'assets/icons/google_logo.svg',
        label: 'Google',
        onTap: () => _showSnackBar('Google 登录开发中'),
      ));
    }

    if (socialButtons.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.borderAdaptive(context).withValues(alpha: 0.6))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '其他登录方式',
                style: TextStyle(
                  color: AppColors.textHintAdaptive(context).withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.borderAdaptive(context).withValues(alpha: 0.6))),
          ],
        ),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: socialButtons),
      ],
    );
  }

  /// 社交登录按钮
  Widget _buildSocialButton({
    required String svgPath,
    required String label,
    required VoidCallback onTap,
    bool useThemeColor = false,
  }) {
    final isDark = context.isDarkMode;
    final themeColor = isDark ? Colors.white : Colors.black87;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.15),
                ),
              ),
              child: Center(
                child: useThemeColor
                    ? SvgPicture.asset(svgPath, width: 24, height: 24,
                        colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn))
                    : SvgPicture.asset(svgPath, width: 24, height: 24),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondaryAdaptive(context).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 用户协议（链接使用配置的主色，支持点击跳转）
  Widget _buildAgreement(LoginConfig config) {
    final primaryColor = _getButtonPrimaryColor(config);

    return Text.rich(
      TextSpan(
        text: '登录即表示同意',
        style: TextStyle(
          color: AppColors.textHintAdaptive(context).withValues(alpha: 0.8),
          fontSize: 12,
        ),
        children: [
          WidgetSpan(
            child: GestureDetector(
              onTap: () => _openAgreement(config, 'user_agreement'),
              child: Text(
                '《用户协议》',
                style: TextStyle(
                  color: primaryColor.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const TextSpan(text: '和'),
          WidgetSpan(
            child: GestureDetector(
              onTap: () => _openAgreement(config, 'privacy_policy'),
              child: Text(
                '《隐私政策》',
                style: TextStyle(
                  color: primaryColor.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 打开协议页面
  void _openAgreement(LoginConfig config, String type) {
    if (config.agreementSource == 'external') {
      // 外部链接
      final url = type == 'user_agreement'
          ? config.userAgreementUrl
          : config.privacyPolicyUrl;
      if (url != null && url.isNotEmpty) {
        // TODO: 使用 url_launcher 打开外部链接
        _showSnackBar('即将打开外部链接');
        return;
      }
    }
    // 内置协议 - 跳转到协议页面
    context.push('/agreement/$type');
  }
}
