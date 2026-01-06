import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, IsNumber, IsDateString, Min, Max } from 'class-validator'
import { Type } from 'class-transformer'

export class QueryPhotoDto {
  @ApiPropertyOptional({ description: '文化之旅ID' })
  @IsOptional()
  @IsString()
  journeyId?: string

  @ApiPropertyOptional({ description: '开始日期' })
  @IsOptional()
  @IsDateString()
  startDate?: string

  @ApiPropertyOptional({ description: '结束日期' })
  @IsOptional()
  @IsDateString()
  endDate?: string
}

export class CreatePhotoDto {
  @ApiProperty({ description: '文化之旅ID' })
  @IsString()
  journeyId: string

  @ApiProperty({ description: '探索点ID' })
  @IsString()
  pointId: string

  @ApiProperty({ description: '照片URL' })
  @IsString()
  photoUrl: string

  @ApiPropertyOptional({ description: '缩略图URL' })
  @IsOptional()
  @IsString()
  thumbnailUrl?: string

  @ApiPropertyOptional({ description: '滤镜' })
  @IsOptional()
  @IsString()
  filter?: string

  @ApiPropertyOptional({ description: '纬度' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude?: number

  @ApiPropertyOptional({ description: '经度' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude?: number

  @ApiProperty({ description: '拍摄时间' })
  @IsDateString()
  takenTime: string
}

// ==================== Response VOs ====================

export class PhotoVo {
  @ApiProperty({ description: '照片ID' })
  id: string

  @ApiProperty({ description: '文化之旅ID' })
  journeyId: string

  @ApiProperty({ description: '文化之旅名称' })
  journeyName: string

  @ApiProperty({ description: '探索点ID' })
  pointId: string

  @ApiProperty({ description: '探索点名称' })
  pointName: string

  @ApiProperty({ description: '照片URL' })
  photoUrl: string

  @ApiPropertyOptional({ description: '缩略图URL' })
  thumbnailUrl?: string

  @ApiPropertyOptional({ description: '滤镜' })
  filter?: string

  @ApiPropertyOptional({ description: '纬度' })
  latitude?: number

  @ApiPropertyOptional({ description: '经度' })
  longitude?: number

  @ApiProperty({ description: '拍摄时间' })
  takenTime: Date

  @ApiProperty({ description: '创建时间' })
  createTime: Date
}

export class PhotoStatsVo {
  @ApiProperty({ description: '总照片数' })
  totalPhotos: number

  @ApiProperty({ description: '文化之旅数' })
  journeyCount: number

  @ApiProperty({ description: '探索点数' })
  pointCount: number
}
