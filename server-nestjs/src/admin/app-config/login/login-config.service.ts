import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../prisma/prisma.service'
import type { UpdateLoginConfigDto } from './dto/login-config.dto'

@Injectable()
export class LoginConfigService {
  constructor(private prisma: PrismaService) {}

  // 默认配置 - 完全匹配 Flutter App 登录页参数
  private readonly defaultConfig = {
    // 背景配置 - Aurora warm 变体（3色渐变）
    backgroundType: 'gradient',
    gradientStart: '#FDF8F5', // Aurora warm 浅色起始
    gradientMiddle: '#F8F5F0', // Aurora warm 中间色
    gradientEnd: '#F5F0EB', // Aurora warm 浅色结束
    gradientDirection: 'to bottom', // 从上到下
    // Aurora 底纹配置
    auroraEnabled: true, // 启用 Aurora 光晕
    auroraPreset: 'warm', // 暖色调预设
    // Logo配置 - Flutter: 88x88px, 圆角22px
    logoSize: 'normal',
    logoAnimationEnabled: true, // 启用浮动动画
    // 应用名称配置 - Flutter: fontSize 32, letterSpacing 4, textPrimary
    appName: '寻印',
    appNameColor: '#2D2D2D', // Flutter AppColors.textPrimary
    // 标语配置 - Flutter: fontSize 14, letterSpacing 1, textSecondary 0.8
    slogan: '探索城市文化，收集专属印记',
    sloganColor: '#666666', // Flutter AppColors.textSecondary
    // 按钮样式 - Flutter: accent gradient, 圆角14px
    buttonStyle: 'filled',
    buttonPrimaryColor: '#C41E3A', // Flutter AppColors.accent
    buttonGradientEndColor: '#9A1830', // Flutter AppColors.accentDark
    buttonSecondaryColor: 'rgba(196,30,58,0.08)', // accent with 0.08 opacity
    buttonRadius: 'lg', // Flutter 用 14px 圆角
    // 登录方式 - 匹配 App 当前配置
    wechatLoginEnabled: true,
    appleLoginEnabled: true,
    googleLoginEnabled: true,
    phoneLoginEnabled: true,
    emailLoginEnabled: false,
    guestModeEnabled: false,
    // 协议配置
    agreementSource: 'builtin',
  }

  async findOne() {
    let config = await this.prisma.appLoginConfig.findFirst()

    // 如果没有配置，创建默认配置
    if (!config) {
      config = await this.prisma.appLoginConfig.create({
        data: this.defaultConfig,
      })
    }

    return config
  }

  async update(dto: UpdateLoginConfigDto, updateBy?: string) {
    const existing = await this.prisma.appLoginConfig.findFirst()

    if (existing) {
      return this.prisma.appLoginConfig.update({
        where: { id: existing.id },
        data: { ...dto, updateBy },
      })
    }

    // 不存在则创建（合并默认值）
    return this.prisma.appLoginConfig.create({
      data: {
        ...this.defaultConfig,
        ...dto,
        createBy: updateBy,
      },
    })
  }
}
