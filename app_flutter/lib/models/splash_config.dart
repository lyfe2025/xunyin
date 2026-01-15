/// 启动页配置模型
class SplashConfig {
  final String mode; // brand-品牌启动页 ad-广告启动页
  // 品牌模式字段
  final String? logoImage;
  final String? logoText;
  final String? appName;
  final String? slogan;
  final String? backgroundColor;
  final String? textColor;
  final String? logoColor;
  // 广告模式字段
  final String? type; // image/video
  final String? mediaUrl;
  final String? linkType;
  final String? linkUrl;
  final int skipDelay;
  // 通用字段
  final int duration;

  const SplashConfig({
    this.mode = 'brand',
    this.logoImage,
    this.logoText = '印',
    this.appName = '寻印',
    this.slogan = '探索城市文化，收集专属印记',
    this.backgroundColor = '#F8F5F0',
    this.textColor = '#2D2D2D',
    this.logoColor = '#C41E3A',
    this.type = 'image',
    this.mediaUrl,
    this.linkType = 'none',
    this.linkUrl,
    this.skipDelay = 0,
    this.duration = 2,
  });

  factory SplashConfig.fromJson(Map<String, dynamic> json) {
    return SplashConfig(
      mode: json['mode'] as String? ?? 'brand',
      logoImage: json['logoImage'] as String?,
      logoText: json['logoText'] as String? ?? '印',
      appName: json['appName'] as String? ?? '寻印',
      slogan: json['slogan'] as String? ?? '探索城市文化，收集专属印记',
      backgroundColor: json['backgroundColor'] as String? ?? '#F8F5F0',
      textColor: json['textColor'] as String? ?? '#2D2D2D',
      logoColor: json['logoColor'] as String? ?? '#C41E3A',
      type: json['type'] as String? ?? 'image',
      mediaUrl: json['mediaUrl'] as String?,
      linkType: json['linkType'] as String? ?? 'none',
      linkUrl: json['linkUrl'] as String?,
      skipDelay: json['skipDelay'] as int? ?? 0,
      duration: json['duration'] as int? ?? 2,
    );
  }

  bool get isBrandMode => mode == 'brand';
  bool get isAdMode => mode == 'ad';
}
