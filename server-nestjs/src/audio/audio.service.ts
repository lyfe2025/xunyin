import { Injectable } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'

@Injectable()
export class AudioService {
  constructor(private prisma: PrismaService) {}

  /**
   * 获取首页背景音乐
   */
  async getHomeAudio() {
    const music = await this.prisma.backgroundMusic.findFirst({
      where: { context: 'home', status: '0' },
      orderBy: { orderNum: 'asc' },
    })

    if (!music) {
      return null
    }

    return {
      id: music.id,
      name: music.name,
      url: music.url,
      duration: music.duration,
    }
  }

  /**
   * 获取城市背景音乐
   */
  async getCityAudio(cityId: string) {
    // 先查找城市专属音乐
    let music = await this.prisma.backgroundMusic.findFirst({
      where: { context: 'city', contextId: cityId, status: '0' },
      orderBy: { orderNum: 'asc' },
    })

    // 如果没有专属音乐，查找城市的 bgmUrl
    if (!music) {
      const city = await this.prisma.city.findUnique({
        where: { id: cityId },
        select: { bgmUrl: true, name: true },
      })

      if (city?.bgmUrl) {
        return {
          id: null,
          name: `${city.name}背景音乐`,
          url: city.bgmUrl,
          duration: null,
        }
      }

      // 返回默认城市音乐
      music = await this.prisma.backgroundMusic.findFirst({
        where: { context: 'city', contextId: null, status: '0' },
        orderBy: { orderNum: 'asc' },
      })
    }

    if (!music) {
      return null
    }

    return {
      id: music.id,
      name: music.name,
      url: music.url,
      duration: music.duration,
    }
  }

  /**
   * 获取文化之旅背景音乐
   */
  async getJourneyAudio(journeyId: string) {
    // 先查找文化之旅专属音乐
    let music = await this.prisma.backgroundMusic.findFirst({
      where: { context: 'journey', contextId: journeyId, status: '0' },
      orderBy: { orderNum: 'asc' },
    })

    // 如果没有专属音乐，查找文化之旅的 bgmUrl
    if (!music) {
      const journey = await this.prisma.journey.findUnique({
        where: { id: journeyId },
        select: { bgmUrl: true, name: true },
      })

      if (journey?.bgmUrl) {
        return {
          id: null,
          name: `${journey.name}背景音乐`,
          url: journey.bgmUrl,
          duration: null,
        }
      }

      // 返回默认文化之旅音乐
      music = await this.prisma.backgroundMusic.findFirst({
        where: { context: 'journey', contextId: null, status: '0' },
        orderBy: { orderNum: 'asc' },
      })
    }

    if (!music) {
      return null
    }

    return {
      id: music.id,
      name: music.name,
      url: music.url,
      duration: music.duration,
    }
  }
}
