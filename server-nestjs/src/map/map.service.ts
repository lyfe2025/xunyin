import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { BusinessException } from '../common/exceptions';
import { ErrorCode } from '../common/enums';
import { AmapProvider } from './providers/amap.provider';
import type { ValidateLocationDto } from './dto/location.dto';
import type { WalkingRouteDto, SearchPoiDto } from './dto/route.dto';

const LOCATION_THRESHOLD = 50; // 米

@Injectable()
export class MapService {
  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
    private amapProvider: AmapProvider,
  ) {}

  /**
   * 获取地图配置
   */
  async getConfig() {
    const cities = await this.prisma.city.findMany({
      where: { status: '0' },
      orderBy: { orderNum: 'asc' },
    });

    return {
      provider: 'amap',
      amap: {
        key: this.configService.get<string>('AMAP_WEB_KEY') || '',
        securityCode:
          this.configService.get<string>('AMAP_SECURITY_CODE') || '',
      },
      maptiler: {
        key: this.configService.get<string>('MAPTILER_KEY') || '',
        styleUrl: this.configService.get<string>('MAPTILER_STYLE_URL') || '',
      },
      cityMarkers: cities.map((city) => ({
        cityId: city.id,
        iconAsset: city.iconAsset || 'assets/icons/default-city.png',
        position: {
          lat: Number(city.latitude),
          lng: Number(city.longitude),
        },
      })),
    };
  }

  /**
   * 验证用户位置
   */
  async validateLocation(dto: ValidateLocationDto) {
    const point = await this.prisma.explorationPoint.findUnique({
      where: { id: dto.pointId },
    });

    if (!point || point.status !== '0') {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '探索点不存在');
    }

    const distance = this.calculateDistance(
      dto.userLat,
      dto.userLng,
      Number(point.latitude),
      Number(point.longitude),
    );

    const distanceInMeters = distance * 1000;

    return {
      isInRange: distanceInMeters <= LOCATION_THRESHOLD,
      distance: Math.round(distanceInMeters * 100) / 100,
      threshold: LOCATION_THRESHOLD,
    };
  }

  /**
   * 步行路径规划
   */
  async walkingRoute(dto: WalkingRouteDto) {
    return this.amapProvider.walkingRoute(
      dto.origin.lat,
      dto.origin.lng,
      dto.destination.lat,
      dto.destination.lng,
    );
  }

  /**
   * POI 搜索
   */
  async searchPoi(dto: SearchPoiDto) {
    return this.amapProvider.searchPoi(dto.keyword, dto.city);
  }

  /**
   * 计算两点间距离（Haversine 公式）
   */
  private calculateDistance(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number,
  ): number {
    const R = 6371;
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) *
        Math.cos(this.toRad(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private toRad(deg: number): number {
    return deg * (Math.PI / 180);
  }
}
