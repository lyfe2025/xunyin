import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../prisma/prisma.service'
import type { UpdateLoginConfigDto } from './dto/login-config.dto'

@Injectable()
export class LoginConfigService {
  constructor(private prisma: PrismaService) {}

  // 默认配置 - 寻印主题色：朱砂红+墨色，体现传统印章文化
  private readonly defaultConfig = {
    // 背景配置
    backgroundType: 'gradient',
    gradientStart: '#8B4513', // 赭石色（古朴）
    gradientEnd: '#2C2C2C', // 墨色
    gradientDirection: '135deg', // 左上到右下
    // Logo配置
    logoSize: 'normal',
    // 标语配置
    sloganColor: '#F5F5DC', // 米白色（古纸色）
    // 按钮样式
    buttonStyle: 'filled',
    buttonPrimaryColor: '#C53D43', // 朱砂红
    buttonSecondaryColor: 'rgba(255,255,255,0.2)',
    buttonRadius: 'full',
    // 登录方式
    wechatLoginEnabled: true,
    appleLoginEnabled: true,
    googleLoginEnabled: false,
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
