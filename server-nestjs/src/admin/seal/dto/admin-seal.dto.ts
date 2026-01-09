import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, IsNumber, MaxLength, Min, Max } from 'class-validator'
import { Type } from 'class-transformer'

export class QueryAdminSealDto {
  @ApiPropertyOptional({ description: '印记类型 route/city/special' })
  @IsOptional()
  @IsString()
  type?: string

  @ApiPropertyOptional({ description: '稀有度 common/rare/legendary' })
  @IsOptional()
  @IsString()
  rarity?: string

  @ApiPropertyOptional({ description: '印记名称' })
  @IsOptional()
  @IsString()
  name?: string

  @ApiPropertyOptional({ description: '状态 0正常 1停用' })
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
  pageSize?: number = 20
}

export class CreateSealDto {
  @ApiProperty({ description: '印记类型 route/city/special' })
  @IsString()
  @MaxLength(20)
  type: string

  @ApiPropertyOptional({ description: '稀有度 common/rare/legendary', default: 'common' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  rarity?: string = 'common'

  @ApiProperty({ description: '印记名称' })
  @IsString()
  @MaxLength(100)
  name: string

  @ApiProperty({ description: '图片资源' })
  @IsString()
  imageAsset: string

  @ApiPropertyOptional({ description: '描述' })
  @IsOptional()
  @IsString()
  description?: string

  @ApiPropertyOptional({ description: '解锁条件' })
  @IsOptional()
  @IsString()
  unlockCondition?: string

  @ApiPropertyOptional({ description: '解锁的称号' })
  @IsOptional()
  @IsString()
  badgeTitle?: string

  @ApiPropertyOptional({ description: '关联文化之旅ID（路线印记）' })
  @IsOptional()
  @IsString()
  journeyId?: string

  @ApiPropertyOptional({ description: '关联城市ID（城市印记）' })
  @IsOptional()
  @IsString()
  cityId?: string

  @ApiPropertyOptional({ description: '排序号', default: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  orderNum?: number = 0

  @ApiPropertyOptional({ description: '状态 0正常 1停用', default: '0' })
  @IsOptional()
  @IsString()
  status?: string = '0'
}

export class UpdateSealDto {
  @ApiPropertyOptional({ description: '印记类型 route/city/special' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  type?: string

  @ApiPropertyOptional({ description: '稀有度 common/rare/legendary' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  rarity?: string

  @ApiPropertyOptional({ description: '印记名称' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  name?: string

  @ApiPropertyOptional({ description: '图片资源' })
  @IsOptional()
  @IsString()
  imageAsset?: string

  @ApiPropertyOptional({ description: '描述' })
  @IsOptional()
  @IsString()
  description?: string

  @ApiPropertyOptional({ description: '解锁条件' })
  @IsOptional()
  @IsString()
  unlockCondition?: string

  @ApiPropertyOptional({ description: '解锁的称号' })
  @IsOptional()
  @IsString()
  badgeTitle?: string

  @ApiPropertyOptional({ description: '关联文化之旅ID' })
  @IsOptional()
  @IsString()
  journeyId?: string

  @ApiPropertyOptional({ description: '关联城市ID' })
  @IsOptional()
  @IsString()
  cityId?: string

  @ApiPropertyOptional({ description: '排序号' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  orderNum?: number

  @ApiPropertyOptional({ description: '状态 0正常 1停用' })
  @IsOptional()
  @IsString()
  status?: string
}

export class UpdateStatusDto {
  @ApiProperty({ description: '状态 0正常 1停用' })
  @IsString()
  status: string
}

export class BatchDeleteDto {
  @ApiProperty({ description: 'ID列表', type: [String] })
  @IsString({ each: true })
  ids: string[]
}

export class BatchUpdateStatusDto {
  @ApiProperty({ description: 'ID列表', type: [String] })
  @IsString({ each: true })
  ids: string[]

  @ApiProperty({ description: '状态 0正常 1停用' })
  @IsString()
  status: string
}
