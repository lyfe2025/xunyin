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
  Matches,
} from 'class-validator'
import { Type } from 'class-transformer'

export class QueryChannelDto {
  @ApiPropertyOptional({ description: '渠道名称' })
  @IsOptional()
  @IsString()
  channelName?: string

  @ApiPropertyOptional({ description: '渠道类型 social/ad/offline/other' })
  @IsOptional()
  @IsString()
  channelType?: string

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

export class CreateChannelDto {
  @ApiProperty({ description: '渠道编码（唯一）' })
  @IsString()
  @MaxLength(50)
  @Matches(/^[a-zA-Z0-9_-]+$/, { message: '渠道编码只能包含字母、数字、下划线和中划线' })
  channelCode: string

  @ApiProperty({ description: '渠道名称' })
  @IsString()
  @MaxLength(100)
  channelName: string

  @ApiPropertyOptional({ description: '渠道类型 social/ad/offline/other' })
  @IsOptional()
  @IsString()
  @IsIn(['social', 'ad', 'offline', 'other'])
  channelType?: string

  @ApiPropertyOptional({ description: '渠道描述' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string

  @ApiPropertyOptional({ description: '专属下载链接' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  downloadUrl?: string

  @ApiPropertyOptional({ description: '专属二维码' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  qrcodeImage?: string

  @ApiPropertyOptional({ description: '状态 0启用 1停用', default: '0' })
  @IsOptional()
  @IsString()
  status?: string = '0'
}

export class UpdateChannelDto {
  @ApiPropertyOptional({ description: '渠道名称' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  channelName?: string

  @ApiPropertyOptional({ description: '渠道类型 social/ad/offline/other' })
  @IsOptional()
  @IsString()
  @IsIn(['social', 'ad', 'offline', 'other'])
  channelType?: string

  @ApiPropertyOptional({ description: '渠道描述' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string

  @ApiPropertyOptional({ description: '专属下载链接' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  downloadUrl?: string

  @ApiPropertyOptional({ description: '专属二维码' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  qrcodeImage?: string

  @ApiPropertyOptional({ description: '状态 0启用 1停用' })
  @IsOptional()
  @IsString()
  status?: string
}

export class QueryStatsDto {
  @ApiPropertyOptional({ description: '渠道ID' })
  @IsOptional()
  @IsString()
  channelId?: string

  @ApiPropertyOptional({ description: '开始日期 YYYY-MM-DD' })
  @IsOptional()
  @IsDateString()
  startDate?: string

  @ApiPropertyOptional({ description: '结束日期 YYYY-MM-DD' })
  @IsOptional()
  @IsDateString()
  endDate?: string

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

export class BatchDeleteDto {
  @ApiProperty({ description: 'ID列表', type: [String] })
  @IsString({ each: true })
  ids: string[]
}
