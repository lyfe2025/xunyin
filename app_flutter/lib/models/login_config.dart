/// 登录页配置模型
class LoginConfig {
  // 背景配置
  final String backgroundType;
  final String? backgroundImage;
  final String? backgroundColor;
  final String? gradientStart;
  final String? gradientMiddle;
  final String? gradientEnd;
  final String? gradientDirection;

  // Aurora 光晕
  final bool auroraEnabled;
  final String? auroraPreset;

  // Logo
  final String? logoImage;
  final String? logoSize;
  final bool logoAnimationEnabled;

  // 应用名称
  final String? appName;
  final String? appNameColor;

  // 标语
  final String? slogan;
  final String? sloganColor;

  // 按钮样式
  final String? buttonStyle;
  final String? buttonPrimaryColor;
  final String? buttonGradientEndColor;
  final String? buttonSecondaryColor;
  final String? buttonRadius;

  // 登录方式开关
  final bool wechatLoginEnabled;
  final bool appleLoginEnabled;
  final bool googleLoginEnabled;
  final bool phoneLoginEnabled;

  const LoginConfig({
    this.backgroundType = 'gradient',
    this.backgroundImage,
    this.backgroundColor,
    this.gradientStart = '#FDF8F5',
    this.gradientMiddle = '#F8F5F0',
    this.gradientEnd = '#F5F0EB',
    this.gradientDirection = 'to bottom',
    this.auroraEnabled = true,
    this.auroraPreset = 'warm',
    this.logoImage,
    this.logoSize = 'normal',
    this.logoAnimationEnabled = true,
    this.appName = '寻印',
    this.appNameColor = '#2D2D2D',
    this.slogan = '探索城市文化，收集专属印记',
    this.sloganColor = '#666666',
    this.buttonStyle = 'filled',
    this.buttonPrimaryColor = '#C41E3A',
    this.buttonGradientEndColor = '#9A1830',
    this.buttonSecondaryColor = 'rgba(196,30,58,0.08)',
    this.buttonRadius = 'lg',
    this.wechatLoginEnabled = true,
    this.appleLoginEnabled = true,
    this.googleLoginEnabled = true,
    this.phoneLoginEnabled = true,
  });

  /// 默认配置（硬编码，确保离线可用）
  static const LoginConfig defaultConfig = LoginConfig();

  factory LoginConfig.fromJson(Map<String, dynamic> json) {
    return LoginConfig(
      backgroundType: json['backgroundType'] as String? ?? 'gradient',
      backgroundImage: json['backgroundImage'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      gradientStart: json['gradientStart'] as String? ?? '#FDF8F5',
      gradientMiddle: json['gradientMiddle'] as String?,
      gradientEnd: json['gradientEnd'] as String? ?? '#F5F0EB',
      gradientDirection: json['gradientDirection'] as String? ?? 'to bottom',
      auroraEnabled: json['auroraEnabled'] as bool? ?? true,
      auroraPreset: json['auroraPreset'] as String? ?? 'warm',
      logoImage: json['logoImage'] as String?,
      logoSize: json['logoSize'] as String? ?? 'normal',
      logoAnimationEnabled: json['logoAnimationEnabled'] as bool? ?? true,
      appName: json['appName'] as String? ?? '寻印',
      appNameColor: json['appNameColor'] as String? ?? '#2D2D2D',
      slogan: json['slogan'] as String? ?? '探索城市文化，收集专属印记',
      sloganColor: json['sloganColor'] as String? ?? '#666666',
      buttonStyle: json['buttonStyle'] as String? ?? 'filled',
      buttonPrimaryColor: json['buttonPrimaryColor'] as String? ?? '#C41E3A',
      buttonGradientEndColor: json['buttonGradientEndColor'] as String? ?? '#9A1830',
      buttonSecondaryColor: json['buttonSecondaryColor'] as String? ?? 'rgba(196,30,58,0.08)',
      buttonRadius: json['buttonRadius'] as String? ?? 'lg',
      wechatLoginEnabled: json['wechatLoginEnabled'] as bool? ?? true,
      appleLoginEnabled: json['appleLoginEnabled'] as bool? ?? true,
      googleLoginEnabled: json['googleLoginEnabled'] as bool? ?? true,
      phoneLoginEnabled: json['phoneLoginEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backgroundType': backgroundType,
      'backgroundImage': backgroundImage,
      'backgroundColor': backgroundColor,
      'gradientStart': gradientStart,
      'gradientMiddle': gradientMiddle,
      'gradientEnd': gradientEnd,
      'gradientDirection': gradientDirection,
      'auroraEnabled': auroraEnabled,
      'auroraPreset': auroraPreset,
      'logoImage': logoImage,
      'logoSize': logoSize,
      'logoAnimationEnabled': logoAnimationEnabled,
      'appName': appName,
      'appNameColor': appNameColor,
      'slogan': slogan,
      'sloganColor': sloganColor,
      'buttonStyle': buttonStyle,
      'buttonPrimaryColor': buttonPrimaryColor,
      'buttonGradientEndColor': buttonGradientEndColor,
      'buttonSecondaryColor': buttonSecondaryColor,
      'buttonRadius': buttonRadius,
      'wechatLoginEnabled': wechatLoginEnabled,
      'appleLoginEnabled': appleLoginEnabled,
      'googleLoginEnabled': googleLoginEnabled,
      'phoneLoginEnabled': phoneLoginEnabled,
    };
  }
}
