import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../prisma/prisma.service'

@Injectable()
export class PublicConfigService {
  constructor(private prisma: PrismaService) {}

  /**
   * 获取下载页配置（公开接口）
   */
  async getDownloadConfig() {
    const config = await this.prisma.appDownloadConfig.findFirst()

    if (!config) {
      // 返回默认配置
      return {
        appName: '寻印',
        appSlogan: '城市文化探索与数字印记收藏',
        backgroundType: 'gradient',
        gradientStart: '#8B4513',
        gradientEnd: '#2C2C2C',
        gradientDirection: '135deg',
        buttonRadius: 'full',
        buttonPrimaryColor: '#C53D43',
      }
    }

    return config
  }
}
