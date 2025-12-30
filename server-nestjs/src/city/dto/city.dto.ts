import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

// ==================== Query DTOs ====================

export class QueryCityDto {
  @ApiPropertyOptional({ description: '省份名称' })
  @IsOptional()
  @IsString()
  province?: string;
}

export class NearbyCityDto {
  @ApiProperty({ description: '纬度', example: 30.2741 })
  @Type(() => Number)
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @ApiProperty({ description: '经度', example: 120.1551 })
  @Type(() => Number)
  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  @ApiPropertyOptional({ description: '搜索半径(公里)', default: 200 })
  @Type(() => Number)
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(1000)
  radius?: number;

  @ApiPropertyOptional({ description: '返回数量限制', default: 10 })
  @Type(() => Number)
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(50)
  limit?: number;
}

// ==================== Response VOs ====================

export class CityVo {
  @ApiProperty({ description: '城市ID' })
  id: string;

  @ApiProperty({ description: '城市名称' })
  name: string;

  @ApiProperty({ description: '省份' })
  province: string;

  @ApiProperty({ description: '纬度' })
  latitude: number;

  @ApiProperty({ description: '经度' })
  longitude: number;

  @ApiPropertyOptional({ description: '城市图标' })
  iconAsset?: string;

  @ApiPropertyOptional({ description: '封面图片' })
  coverImage?: string;

  @ApiPropertyOptional({ description: '城市描述' })
  description?: string;

  @ApiProperty({ description: '探索人数' })
  explorerCount: number;

  @ApiPropertyOptional({ description: '背景音乐URL' })
  bgmUrl?: string;
}

export class CityDetailVo extends CityVo {
  @ApiProperty({ description: '文化之旅数量' })
  journeyCount: number;
}

export class JourneyBriefVo {
  @ApiProperty({ description: '文化之旅ID' })
  id: string;

  @ApiProperty({ description: '文化之旅名称' })
  name: string;

  @ApiProperty({ description: '主题' })
  theme: string;

  @ApiPropertyOptional({ description: '封面图片' })
  coverImage?: string;

  @ApiProperty({ description: '星级评分 1-5' })
  rating: number;

  @ApiProperty({ description: '预计时长(分钟)' })
  estimatedMinutes: number;

  @ApiProperty({ description: '总距离(米)' })
  totalDistance: number;

  @ApiProperty({ description: '完成人数' })
  completedCount: number;

  @ApiProperty({ description: '是否锁定' })
  isLocked: boolean;

  @ApiPropertyOptional({ description: '解锁条件' })
  unlockCondition?: string;
}

export class NearbyCityVo extends CityVo {
  @ApiProperty({ description: '距离(公里)' })
  distance: number;
}
