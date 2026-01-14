import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../prisma/prisma.service'

@Injectable()
export class AppLoginConfigService {
  constructor(private prisma: PrismaService) {}

  // 默认配置 - 与 Flutter App 登录页硬编码值一致
  private readonly defaultConfig = {
    // 背景配置
    backgroundType: 'gradient',
    gradientStart: '#FDF8F5',
    gradientMiddle: '#F8F5F0',
    gradientEnd: '#F5F0EB',
    gradientDirection: 'to bottom',
    // Aurora 光晕
    auroraEnabled: true,
    auroraPreset: 'warm',
    // Logo
    logoSize: 'normal',
    logoAnimationEnabled: true,
    // 应用名称
    appName: '寻印',
    appNameColor: '#2D2D2D',
    // 标语
    slogan: '探索城市文化，收集专属印记',
    sloganColor: '#666666',
    // 按钮样式
    buttonStyle: 'filled',
    buttonPrimaryColor: '#C41E3A',
    buttonGradientEndColor: '#9A1830',
    buttonSecondaryColor: 'rgba(196,30,58,0.08)',
    buttonRadius: 'lg',
    // 登录方式
    wechatLoginEnabled: true,
    appleLoginEnabled: true,
    googleLoginEnabled: true,
    phoneLoginEnabled: true,
  }

  async getConfig() {
    const config = await this.prisma.appLoginConfig.findFirst({
      where: { status: '0' },
    })

    if (!config) {
      return this.defaultConfig
    }

    // 只返回 App 需要的字段，排除系统字段
    return {
      backgroundType: config.backgroundType,
      backgroundImage: config.backgroundImage,
      backgroundColor: config.backgroundColor,
      gradientStart: config.gradientStart,
      gradientMiddle: config.gradientMiddle,
      gradientEnd: config.gradientEnd,
      gradientDirection: config.gradientDirection,
      auroraEnabled: config.auroraEnabled,
      auroraPreset: config.auroraPreset,
      logoImage: config.logoImage,
      logoSize: config.logoSize,
      logoAnimationEnabled: config.logoAnimationEnabled,
      appName: config.appName,
      appNameColor: config.appNameColor,
      slogan: config.slogan,
      sloganColor: config.sloganColor,
      buttonStyle: config.buttonStyle,
      buttonPrimaryColor: config.buttonPrimaryColor,
      buttonGradientEndColor: config.buttonGradientEndColor,
      buttonSecondaryColor: config.buttonSecondaryColor,
      buttonRadius: config.buttonRadius,
      wechatLoginEnabled: config.wechatLoginEnabled,
      appleLoginEnabled: config.appleLoginEnabled,
      googleLoginEnabled: config.googleLoginEnabled,
      phoneLoginEnabled: config.phoneLoginEnabled,
      // 协议配置
      agreementSource: config.agreementSource,
      userAgreementUrl: config.userAgreementUrl,
      privacyPolicyUrl: config.privacyPolicyUrl,
    }
  }
}
