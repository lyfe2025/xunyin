import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../prisma/prisma.service'
import { Prisma } from '@prisma/client'
import type { UpdateDownloadConfigDto } from './dto/download-config.dto'

@Injectable()
export class DownloadConfigService {
  constructor(private prisma: PrismaService) {}

  // 默认配置 - 品牌主色渐变背景
  private readonly defaultConfig: Prisma.AppDownloadConfigCreateInput = {
    // 页面信息
    pageTitle: '寻印 - 城市文化探索',
    pageDescription: '发现城市文化之旅，收集专属数字印记，用区块链永久珍藏你的探索足迹',
    // 背景配置 - 品牌红斜向渐变（亮红到深红，更有层次感）
    backgroundType: 'gradient',
    gradientStart: '#E04358', // 品牌亮红 accentLight
    gradientEnd: '#9A1830', // 品牌深红 accentDark
    gradientDirection: '135deg', // 左上到右下斜向渐变
    // APP信息
    appName: '寻印',
    appSlogan: '探索城市文化，收集专属印记',
    sloganColor: '#FFFFFFCC', // 白色80%透明度
    // 按钮样式 - 与登录页一致的品牌色
    buttonStyle: 'filled',
    buttonPrimaryColor: '#C41E3A', // 品牌红 AppColors.accent
    buttonSecondaryColor: 'rgba(196,30,58,0.08)', // 与登录页一致
    buttonRadius: 'lg', // 与登录页一致的 14px 圆角
    // 按钮文本
    iosButtonText: 'App Store 下载',
    androidButtonText: 'Android 下载',
    // 功能特点 - 突出产品核心价值
    featureList: [
      { icon: 'compass', title: '发现城市文化之旅' },
      { icon: 'stamp', title: '收集专属数字印记' },
      { icon: 'shield-check', title: '区块链永久存证' },
    ] as Prisma.InputJsonValue,
    // 页脚
    footerText: '© 2025 寻印 · 让每一次探索都值得珍藏',
  }

  async findOne() {
    let config = await this.prisma.appDownloadConfig.findFirst()

    // 如果没有配置，创建默认配置
    if (!config) {
      config = await this.prisma.appDownloadConfig.create({
        data: this.defaultConfig,
      })
    }

    // 如果 androidApkUrl 为空，自动获取最新 Android 版本的下载链接
    let effectiveApkUrl = config.androidApkUrl
    if (!effectiveApkUrl) {
      const latestVersion = await this.prisma.appVersion.findFirst({
        where: { platform: 'android', status: '0' },
        orderBy: { createTime: 'desc' },
        select: { downloadUrl: true },
      })
      effectiveApkUrl = latestVersion?.downloadUrl || null
    }

    return {
      ...config,
      androidApkUrl: effectiveApkUrl,
    }
  }

  async update(dto: UpdateDownloadConfigDto, updateBy?: string) {
    const existing = await this.prisma.appDownloadConfig.findFirst()

    // 处理 featureList 为 Prisma JSON 类型
    const data: Prisma.AppDownloadConfigUpdateInput = {
      ...dto,
      featureList: dto.featureList
        ? (dto.featureList as unknown as Prisma.InputJsonValue)
        : undefined,
      updateBy,
    }

    if (existing) {
      return this.prisma.appDownloadConfig.update({
        where: { id: existing.id },
        data,
      })
    }

    // 不存在则创建（合并默认值）
    const createData: Prisma.AppDownloadConfigCreateInput = {
      ...this.defaultConfig,
      ...dto,
      featureList: dto.featureList
        ? (dto.featureList as unknown as Prisma.InputJsonValue)
        : undefined,
      createBy: updateBy,
    }
    return this.prisma.appDownloadConfig.create({
      data: createData,
    })
  }
}
