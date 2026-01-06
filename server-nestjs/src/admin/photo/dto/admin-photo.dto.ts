import { ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, IsNumber, Min, Max, IsDateString } from 'class-validator'
import { Type } from 'class-transformer'

export class QueryPhotoDto {
  @ApiPropertyOptional({ description: '用户ID' })
  @IsOptional()
  @IsString()
  userId?: string

  @ApiPropertyOptional({ description: '用户昵称' })
  @IsOptional()
  @IsString()
  nickname?: string

  @ApiPropertyOptional({ description: '文化之旅ID' })
  @IsOptional()
  @IsString()
  journeyId?: string

  @ApiPropertyOptional({ description: '探索点ID' })
  @IsOptional()
  @IsString()
  pointId?: string

  @ApiPropertyOptional({ description: '城市ID' })
  @IsOptional()
  @IsString()
  cityId?: string

  @ApiPropertyOptional({ description: '滤镜类型' })
  @IsOptional()
  @IsString()
  filter?: string

  @ApiPropertyOptional({ description: '开始时间' })
  @IsOptional()
  @IsDateString()
  startDate?: string

  @ApiPropertyOptional({ description: '结束时间' })
  @IsOptional()
  @IsDateString()
  endDate?: string

  @ApiPropertyOptional({ description: '页码', default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  pageNum?: number = 1

  @ApiPropertyOptional({ description: '每页数量', default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(100)
  pageSize?: number = 20
}
