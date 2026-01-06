import { Injectable, Logger } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'

@Injectable()
export class AmapProvider {
  private readonly logger = new Logger(AmapProvider.name)
  private readonly apiKey: string
  private readonly baseUrl = 'https://restapi.amap.com/v3'

  constructor(private configService: ConfigService) {
    this.apiKey = this.configService.get<string>('AMAP_API_KEY') || ''
  }

  /**
   * 步行路径规划
   */
  async walkingRoute(originLat: number, originLng: number, destLat: number, destLng: number) {
    // TODO: 调用高德 API
    // const url = `${this.baseUrl}/direction/walking`;
    // const params = {
    //   key: this.apiKey,
    //   origin: `${originLng},${originLat}`,
    //   destination: `${destLng},${destLat}`,
    // };

    // 模拟返回
    const distance = this.calculateDistance(originLat, originLng, destLat, destLng)
    const distanceMeters = Math.round(distance * 1000)
    const duration = Math.round(distanceMeters / 80) // 假设步行速度 80m/min

    this.logger.log(`步行路径规划: ${distanceMeters}m, ${duration}min`)

    return {
      distance: distanceMeters,
      duration,
      polyline: '',
      steps: [{ instruction: '向前步行', distance: distanceMeters }],
    }
  }

  /**
   * POI 搜索
   */
  async searchPoi(keyword: string, city?: string) {
    // TODO: 调用高德 API
    // const url = `${this.baseUrl}/place/text`;
    // const params = {
    //   key: this.apiKey,
    //   keywords: keyword,
    //   city: city || '',
    //   types: '风景名胜',
    // };

    this.logger.log(`POI搜索: ${keyword}, 城市: ${city || '全国'}`)

    // 模拟返回
    return {
      pois: [],
    }
  }

  /**
   * 计算两点间距离（Haversine 公式）
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
