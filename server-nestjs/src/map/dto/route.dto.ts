import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { IsNumber, IsString, IsOptional, Min, Max, ValidateNested } from 'class-validator'
import { Type } from 'class-transformer'

class LatLngDto {
  @ApiProperty({ description: '纬度' })
  @Type(() => Number)
  @IsNumber()
  @Min(-90)
  @Max(90)
  lat: number

  @ApiProperty({ description: '经度' })
  @Type(() => Number)
  @IsNumber()
  @Min(-180)
  @Max(180)
  lng: number
}

export class WalkingRouteDto {
  @ApiProperty({ description: '起点' })
  @ValidateNested()
  @Type(() => LatLngDto)
  origin: LatLngDto

  @ApiProperty({ description: '终点' })
  @ValidateNested()
  @Type(() => LatLngDto)
  destination: LatLngDto
}

export class SearchPoiDto {
  @ApiProperty({ description: '关键词' })
  @IsString()
  keyword: string

  @ApiPropertyOptional({ description: '城市' })
  @IsOptional()
  @IsString()
  city?: string
}

export class WalkingRouteVo {
  @ApiProperty({ description: '距离(米)' })
  distance: number

  @ApiProperty({ description: '时长(分钟)' })
  duration: number

  @ApiPropertyOptional({ description: '编码后的路径' })
  polyline?: string

  @ApiProperty({ description: '导航步骤' })
  steps: RouteStepVo[]
}

export class RouteStepVo {
  @ApiProperty({ description: '步骤说明' })
  instruction: string

  @ApiProperty({ description: '距离(米)' })
  distance: number
}

export class PoiVo {
  @ApiProperty({ description: '名称' })
  name: string

  @ApiProperty({ description: '地址' })
  address: string

  @ApiProperty({ description: '纬度' })
  lat: number

  @ApiProperty({ description: '经度' })
  lng: number
}

export class MapConfigVo {
  @ApiProperty({ description: '地图方案' })
  provider: string

  @ApiProperty({ description: '高德配置' })
  amap: {
    key: string
    securityCode: string
  }

  @ApiPropertyOptional({ description: 'MapTiler配置' })
  maptiler?: {
    key: string
    styleUrl: string
  }

  @ApiProperty({ description: '城市标记' })
  cityMarkers: CityMarkerVo[]
}

export class CityMarkerVo {
  @ApiProperty({ description: '城市ID' })
  cityId: string

  @ApiProperty({ description: '图标资源' })
  iconAsset: string

  @ApiProperty({ description: '位置' })
  position: { lat: number; lng: number }
}
