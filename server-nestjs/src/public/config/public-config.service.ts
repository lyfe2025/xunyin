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
        footerText: '© 2025 寻印 · 让每一次探索都值得珍藏',
      }
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

    // 将文件名转换为完整 URL（如果 androidApkUrl 只是文件名）
    const result = { ...config, androidApkUrl: effectiveApkUrl }

    // 处理 Android APK URL - 如果不是完整 URL，则补全路径
    if (result.androidApkUrl && !result.androidApkUrl.startsWith('http')) {
      // 如果是文件名（不含路径），补全为 /uploads/apk/xxx
      if (!result.androidApkUrl.startsWith('/')) {
        result.androidApkUrl = `/uploads/apk/${result.androidApkUrl}`
      }
    }

    // 处理其他可能的文件字段
    if (config.appIcon && !config.appIcon.startsWith('http')) {
      result.appIcon = config.appIcon.startsWith('/') ? config.appIcon : `/${config.appIcon}`
    }

    if (config.backgroundImage && !config.backgroundImage.startsWith('http')) {
      result.backgroundImage = config.backgroundImage.startsWith('/')
        ? config.backgroundImage
        : `/${config.backgroundImage}`
    }

    if (config.favicon && !config.favicon.startsWith('http')) {
      result.favicon = config.favicon.startsWith('/') ? config.favicon : `/${config.favicon}`
    }

    return result
  }
}
