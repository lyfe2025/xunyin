import { Injectable } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'

@Injectable()
export class AudioService {
  constructor(private prisma: PrismaService) { }

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

  /**
   * 获取探索点背景音乐
   */
  async getExplorationPointAudio(pointId: string) {
    // 先查找探索点专属音乐（通过 bgmId 关联）
    const point = await this.prisma.explorationPoint.findUnique({
      where: { id: pointId },
      select: {
        name: true,
        journeyId: true,
        bgm: {
          select: {
            id: true,
            name: true,
            url: true,
            duration: true,
          },
        },
      },
    })

    // 如果探索点有关联的背景音乐
    if (point?.bgm) {
      return {
        id: point.bgm.id,
        name: point.bgm.name,
        url: point.bgm.url,
        duration: point.bgm.duration,
      }
    }

    // 查找 BackgroundMusic 表中专属于该探索点的音乐
    let music = await this.prisma.backgroundMusic.findFirst({
      where: { context: 'exploration_point', contextId: pointId, status: '0' },
      orderBy: { orderNum: 'asc' },
    })

    if (music) {
      return {
        id: music.id,
        name: music.name,
        url: music.url,
        duration: music.duration,
      }
    }

    // 如果探索点没有专属音乐，回退到文化之旅的音乐
    if (point?.journeyId) {
      return this.getJourneyAudio(point.journeyId)
    }

    // 返回默认探索点音乐
    music = await this.prisma.backgroundMusic.findFirst({
      where: { context: 'exploration_point', contextId: null, status: '0' },
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
}
