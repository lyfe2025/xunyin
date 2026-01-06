import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../prisma/prisma.service'
import { Prisma } from '@prisma/client'
import type { UpdateDownloadConfigDto } from './dto/download-config.dto'

@Injectable()
export class DownloadConfigService {
  constructor(private prisma: PrismaService) {}

  // 默认配置 - 寻印主题色
  private readonly defaultConfig = {
    // 背景配置
    backgroundType: 'gradient',
    gradientStart: '#8B4513', // 赭石色
    gradientEnd: '#2C2C2C', // 墨色
    gradientDirection: '135deg',
    // APP信息
    appName: '寻印',
    appSlogan: '城市文化探索与数字印记收藏',
    sloganColor: '#F5F5DC', // 米白色
    // 按钮样式
    buttonStyle: 'filled',
    buttonPrimaryColor: '#C53D43', // 朱砂红
    buttonSecondaryColor: 'rgba(255,255,255,0.2)',
    buttonRadius: 'full',
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
