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

  @ApiProperty({ description: '类型 image/video', default: 'image' })
  @IsString()
  @IsIn(['image', 'video'])
  type: string = 'image'

  @ApiProperty({ description: '媒体资源URL' })
  @IsString()
  @MaxLength(500)
  mediaUrl: string

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

  @ApiPropertyOptional({ description: '展示时长（秒）', default: 3 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(30)
  duration?: number = 3

  @ApiPropertyOptional({ description: '跳过按钮延迟显示（秒）', default: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(10)
  skipDelay?: number = 0

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

  @ApiPropertyOptional({ description: '类型 image/video' })
  @IsOptional()
  @IsString()
  @IsIn(['image', 'video'])
  type?: string

  @ApiPropertyOptional({ description: '媒体资源URL' })
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

  @ApiPropertyOptional({ description: '展示时长（秒）' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(30)
  duration?: number

  @ApiPropertyOptional({ description: '跳过按钮延迟显示（秒）' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(10)
  skipDelay?: number

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
