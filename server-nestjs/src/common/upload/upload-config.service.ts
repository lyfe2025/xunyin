import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../prisma/prisma.service'

export interface UploadLimits {
  apkMaxSize: number // bytes
  imageMaxSize: number // bytes
  audioMaxSize: number // bytes
}

@Injectable()
export class UploadConfigService {
  // 默认值（MB）
  private readonly defaults = {
    apk: 200,
    image: 5,
    audio: 20,
  }

  constructor(private prisma: PrismaService) {}

  /**
   * 获取上传限制配置
   */
  async getUploadLimits(): Promise<UploadLimits> {
    const configs = await this.prisma.sysConfig.findMany({
      where: {
        configKey: { startsWith: 'sys.upload.' },
      },
    })

    const configMap: Record<string, string> = {}
    configs.forEach((c) => {
      if (c.configKey) {
        configMap[c.configKey] = c.configValue ?? ''
      }
    })

    const apkMB = parseInt(configMap['sys.upload.apk.maxSize']) || this.defaults.apk
    const imageMB = parseInt(configMap['sys.upload.image.maxSize']) || this.defaults.image
    const audioMB = parseInt(configMap['sys.upload.audio.maxSize']) || this.defaults.audio

    return {
      apkMaxSize: apkMB * 1024 * 1024,
      imageMaxSize: imageMB * 1024 * 1024,
      audioMaxSize: audioMB * 1024 * 1024,
    }
  }

  /**
   * 获取 APK 最大上传大小（bytes）
   */
  async getApkMaxSize(): Promise<number> {
    const limits = await this.getUploadLimits()
    return limits.apkMaxSize
  }
}
