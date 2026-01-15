import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../prisma/prisma.service'

@Injectable()
export class AppSplashService {
  constructor(private prisma: PrismaService) {}

  // 默认配置 - 与 Flutter App 启动页硬编码值一致
  private readonly defaultConfig = {
    mode: 'brand',
    // 品牌模式字段
    logoImage: '/uploads/images/logo.png',
    logoText: '印',
    appName: '寻印',
    slogan: '探索城市文化，收集专属印记',
    backgroundColor: '#F8F5F0',
    textColor: '#2D2D2D',
    logoColor: '#C41E3A',
    // 广告模式字段
    type: 'image',
    mediaUrl: null,
    linkType: 'none',
    linkUrl: null,
    skipDelay: 0,
    // 通用字段
    duration: 2,
  }

  /**
   * 获取当前生效的启动页配置
   * 根据平台和时间筛选，返回优先级最高的配置
   */
  async getCurrentConfig(platform: 'ios' | 'android' | 'all' = 'all') {
    const now = new Date()

    // 查询条件：启用状态、平台匹配、时间范围内
    const config = await this.prisma.appSplashConfig.findFirst({
      where: {
        status: '0',
        OR: [{ platform: 'all' }, { platform }],
        AND: [
          { OR: [{ startTime: null }, { startTime: { lte: now } }] },
          { OR: [{ endTime: null }, { endTime: { gte: now } }] },
        ],
      },
      orderBy: [{ orderNum: 'asc' }, { createTime: 'desc' }],
    })

    if (!config) {
      return this.defaultConfig
    }

    // 返回 App 需要的字段
    return {
      mode: config.mode,
      // 品牌模式字段
      logoImage: config.logoImage,
      logoText: config.logoText,
      appName: config.appName,
      slogan: config.slogan,
      backgroundColor: config.backgroundColor,
      textColor: config.textColor,
      logoColor: config.logoColor,
      // 广告模式字段
      type: config.type,
      mediaUrl: config.mediaUrl,
      linkType: config.linkType,
      linkUrl: config.linkUrl,
      skipDelay: config.skipDelay,
      // 通用字段
      duration: config.duration,
    }
  }
}
