import { Injectable } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'
import { BusinessException } from '../common/exceptions'
import { ErrorCode } from '../common/enums'
import type { QueryCityDto, NearbyCityDto } from './dto/city.dto'

@Injectable()
export class CityService {
  constructor(private prisma: PrismaService) {}

  /**
   * 获取城市列表
   */
  async findAll(query: QueryCityDto) {
    const { province } = query

    const cities = await this.prisma.city.findMany({
      where: {
        status: '0',
        ...(province && { province }),
      },
      orderBy: { orderNum: 'asc' },
    })

    return cities.map((city) => ({
      id: city.id,
      name: city.name,
      province: city.province,
      latitude: Number(city.latitude),
      longitude: Number(city.longitude),
      iconAsset: city.iconAsset,
      coverImage: city.coverImage,
      description: city.description,
      explorerCount: city.explorerCount,
      bgmUrl: city.bgmUrl,
    }))
  }

  /**
   * 获取城市详情
   */
  async findOne(id: string) {
    const city = await this.prisma.city.findUnique({
      where: { id },
      include: {
        _count: {
          select: { journeys: { where: { status: '0' } } },
        },
      },
    })

    if (!city || city.status !== '0') {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在')
    }

    return {
      id: city.id,
      name: city.name,
      province: city.province,
      latitude: Number(city.latitude),
      longitude: Number(city.longitude),
      iconAsset: city.iconAsset,
      coverImage: city.coverImage,
      description: city.description,
      explorerCount: city.explorerCount,
      bgmUrl: city.bgmUrl,
      journeyCount: city._count.journeys,
    }
  }

  /**
   * 获取城市的文化之旅列表
   */
  async findJourneys(cityId: string) {
    const city = await this.prisma.city.findUnique({
      where: { id: cityId },
    })

    if (!city || city.status !== '0') {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在')
    }

    const journeys = await this.prisma.journey.findMany({
      where: {
        cityId,
        status: '0',
      },
      orderBy: { orderNum: 'asc' },
    })

    return journeys.map((journey) => ({
      id: journey.id,
      name: journey.name,
      theme: journey.theme,
      coverImage: journey.coverImage,
      rating: journey.rating,
      estimatedMinutes: journey.estimatedMinutes,
      totalDistance: Number(journey.totalDistance),
      completedCount: journey.completedCount,
      isLocked: journey.isLocked,
      unlockCondition: journey.unlockCondition,
    }))
  }

  /**
   * 获取附近城市
   */
  async findNearby(query: NearbyCityDto) {
    const { latitude, longitude, radius = 200, limit = 10 } = query

    const cities = await this.prisma.city.findMany({
      where: { status: '0' },
    })

    const nearbyCities = cities
      .map((city) => {
        const distance = this.calculateDistance(
          latitude,
          longitude,
          Number(city.latitude),
          Number(city.longitude),
        )
        return { city, distance }
      })
      .filter((item) => item.distance <= radius)
      .sort((a, b) => a.distance - b.distance)
      .slice(0, limit)

    return nearbyCities.map(({ city, distance }) => ({
      id: city.id,
      name: city.name,
      province: city.province,
      latitude: Number(city.latitude),
      longitude: Number(city.longitude),
      iconAsset: city.iconAsset,
      coverImage: city.coverImage,
      description: city.description,
      explorerCount: city.explorerCount,
      bgmUrl: city.bgmUrl,
      distance: Math.round(distance * 100) / 100,
    }))
  }

  /**
   * 计算两点间距离（Haversine 公式）
   * @returns 距离（公里）
   */
  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371
    const dLat = this.toRad(lat2 - lat1)
    const dLon = this.toRad(lon2 - lon1)
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) *
        Math.cos(this.toRad(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    return R * c
  }

  private toRad(deg: number): number {
    return deg * (Math.PI / 180)
  }
}
