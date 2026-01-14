import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import {
  IsString,
  IsOptional,
  IsNumber,
  IsDateString,
  MaxLength,
  Min,
  Max,
  IsIn,
} from 'class-validator'
import { Type } from 'class-transformer'

export class QuerySplashDto {
  @ApiPropertyOptional({ description: '标题' })
  @IsOptional()
  @IsString()
  title?: string

  @ApiPropertyOptional({ description: '模式 brand/ad' })
  @IsOptional()
  @IsString()
  mode?: string

  @ApiPropertyOptional({ description: '平台 all/ios/android' })
  @IsOptional()
  @IsString()
  platform?: string

  @ApiPropertyOptional({ description: '状态 0启用 1停用' })
  @IsOptional()
  @IsString()
  status?: string

  @ApiPropertyOptional({ description: '页码', default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  pageNum?: number = 1

  @ApiPropertyOptional({ description: '每页数量', default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(100)
  pageSize?: number = 10
}

export class CreateSplashDto {
  @ApiPropertyOptional({ description: '标题' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  title?: string

  @ApiProperty({ description: '模式 brand-品牌启动页 ad-广告启动页', default: 'ad' })
  @IsString()
  @IsIn(['brand', 'ad'])
  mode: string = 'ad'

  // 广告模式字段
  @ApiPropertyOptional({ description: '类型 image/video（广告模式）', default: 'image' })
  @IsOptional()
  @IsString()
  @IsIn(['image', 'video'])
  type?: string = 'image'

  @ApiPropertyOptional({ description: '媒体资源URL（广告模式）' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  mediaUrl?: string

  @ApiPropertyOptional({ description: '跳转类型 none/internal/external' })
  @IsOptional()
  @IsString()
  @IsIn(['none', 'internal', 'external'])
  linkType?: string

  @ApiPropertyOptional({ description: '跳转链接' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  linkUrl?: string

  @ApiPropertyOptional({ description: '跳过按钮延迟显示（秒）', default: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(10)
  skipDelay?: number = 0

  // 品牌模式字段
  @ApiPropertyOptional({ description: 'Logo图片URL（品牌模式）' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  logoImage?: string

  @ApiPropertyOptional({ description: 'Logo文字（无图片时显示）' })
  @IsOptional()
  @IsString()
  @MaxLength(10)
  logoText?: string

  @ApiPropertyOptional({ description: '应用名称' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  appName?: string

  @ApiPropertyOptional({ description: '标语' })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  slogan?: string

  @ApiPropertyOptional({ description: '背景色（品牌模式）' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  backgroundColor?: string

  @ApiPropertyOptional({ description: '文字颜色' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  textColor?: string

  @ApiPropertyOptional({ description: 'Logo背景色（无图片时）' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  logoColor?: string

  // 通用字段
  @ApiPropertyOptional({ description: '展示时长（秒）', default: 3 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(30)
  duration?: number = 3

  @ApiPropertyOptional({ description: '平台 all/ios/android', default: 'all' })
  @IsOptional()
  @IsString()
  @IsIn(['all', 'ios', 'android'])
  platform?: string = 'all'

  @ApiPropertyOptional({ description: '生效开始时间' })
  @IsOptional()
  @IsDateString()
  startTime?: string

  @ApiPropertyOptional({ description: '生效结束时间' })
  @IsOptional()
  @IsDateString()
  endTime?: string

  @ApiPropertyOptional({ description: '排序号', default: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  orderNum?: number = 0

  @ApiPropertyOptional({ description: '状态 0启用 1停用', default: '0' })
  @IsOptional()
  @IsString()
  status?: string = '0'
}

export class UpdateSplashDto {
  @ApiPropertyOptional({ description: '标题' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  title?: string

  @ApiPropertyOptional({ description: '模式 brand-品牌启动页 ad-广告启动页' })
  @IsOptional()
  @IsString()
  @IsIn(['brand', 'ad'])
  mode?: string

  // 广告模式字段
  @ApiPropertyOptional({ description: '类型 image/video（广告模式）' })
  @IsOptional()
  @IsString()
  @IsIn(['image', 'video'])
  type?: string

  @ApiPropertyOptional({ description: '媒体资源URL（广告模式）' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  mediaUrl?: string

  @ApiPropertyOptional({ description: '跳转类型 none/internal/external' })
  @IsOptional()
  @IsString()
  @IsIn(['none', 'internal', 'external'])
  linkType?: string

  @ApiPropertyOptional({ description: '跳转链接' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  linkUrl?: string

  @ApiPropertyOptional({ description: '跳过按钮延迟显示（秒）' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(10)
  skipDelay?: number

  // 品牌模式字段
  @ApiPropertyOptional({ description: 'Logo图片URL（品牌模式）' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  logoImage?: string

  @ApiPropertyOptional({ description: 'Logo文字（无图片时显示）' })
  @IsOptional()
  @IsString()
  @MaxLength(10)
  logoText?: string

  @ApiPropertyOptional({ description: '应用名称' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  appName?: string

  @ApiPropertyOptional({ description: '标语' })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  slogan?: string

  @ApiPropertyOptional({ description: '背景色（品牌模式）' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  backgroundColor?: string

  @ApiPropertyOptional({ description: '文字颜色' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  textColor?: string

  @ApiPropertyOptional({ description: 'Logo背景色（无图片时）' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  logoColor?: string

  // 通用字段
  @ApiPropertyOptional({ description: '展示时长（秒）' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(30)
  duration?: number

  @ApiPropertyOptional({ description: '平台 all/ios/android' })
  @IsOptional()
  @IsString()
  @IsIn(['all', 'ios', 'android'])
  platform?: string

  @ApiPropertyOptional({ description: '生效开始时间' })
  @IsOptional()
  @IsDateString()
  startTime?: string

  @ApiPropertyOptional({ description: '生效结束时间' })
  @IsOptional()
  @IsDateString()
  endTime?: string

  @ApiPropertyOptional({ description: '排序号' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  orderNum?: number

  @ApiPropertyOptional({ description: '状态 0启用 1停用' })
  @IsOptional()
  @IsString()
  status?: string
}

export class UpdateStatusDto {
  @ApiProperty({ description: '状态 0启用 1停用' })
  @IsString()
  status: string
}

export class BatchDeleteDto {
  @ApiProperty({ description: 'ID列表', type: [String] })
  @IsString({ each: true })
  ids: string[]
}
