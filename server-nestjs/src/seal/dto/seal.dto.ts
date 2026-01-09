import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, IsIn } from 'class-validator'

export class QuerySealDto {
  @ApiPropertyOptional({
    description: '印记类型',
    enum: ['route', 'city', 'special'],
  })
  @IsOptional()
  @IsString()
  @IsIn(['route', 'city', 'special'])
  type?: string
}

// ==================== Response VOs ====================

export class UserSealVo {
  @ApiProperty({ description: '用户印记ID' })
  id: string

  @ApiProperty({ description: '印记ID' })
  sealId: string

  @ApiProperty({ description: '印记类型', enum: ['route', 'city', 'special'] })
  type: string

  @ApiProperty({ description: '印记名称' })
  name: string

  @ApiProperty({ description: '印记图片' })
  imageAsset: string

  @ApiPropertyOptional({ description: '印记描述' })
  description?: string

  @ApiPropertyOptional({ description: '解锁的称号' })
  badgeTitle?: string

  @ApiProperty({ description: '获得时间' })
  earnedTime: Date

  @ApiPropertyOptional({ description: '花费时间(分钟)' })
  timeSpentMinutes?: number

  @ApiProperty({ description: '获得积分' })
  pointsEarned: number

  @ApiProperty({ description: '是否已上链' })
  isChained: boolean

  @ApiPropertyOptional({ description: '交易哈希' })
  txHash?: string
}

export class SealDetailVo {
  @ApiProperty({ description: '印记ID' })
  id: string

  @ApiPropertyOptional({ description: '用户印记ID（用于分享）' })
  userSealId?: string

  @ApiProperty({ description: '印记类型', enum: ['route', 'city', 'special'] })
  type: string

  @ApiProperty({ description: '印记名称' })
  name: string

  @ApiProperty({ description: '印记图片' })
  imageAsset: string

  @ApiPropertyOptional({ description: '印记描述' })
  description?: string

  @ApiPropertyOptional({ description: '解锁条件' })
  unlockCondition?: string

  @ApiPropertyOptional({ description: '解锁的称号' })
  badgeTitle?: string

  @ApiPropertyOptional({ description: '关联文化之旅ID' })
  journeyId?: string

  @ApiPropertyOptional({ description: '关联文化之旅名称' })
  journeyName?: string

  @ApiPropertyOptional({ description: '关联城市ID' })
  cityId?: string

  @ApiPropertyOptional({ description: '关联城市名称' })
  cityName?: string

  @ApiProperty({ description: '是否已拥有' })
  owned: boolean

  @ApiPropertyOptional({ description: '获得时间' })
  earnedTime?: Date

  @ApiPropertyOptional({ description: '花费时间(分钟)' })
  timeSpentMinutes?: number

  @ApiPropertyOptional({ description: '获得积分' })
  pointsEarned?: number

  @ApiPropertyOptional({ description: '是否已上链' })
  isChained?: boolean

  @ApiPropertyOptional({ description: '交易哈希' })
  txHash?: string

  @ApiPropertyOptional({ description: '上链时间' })
  chainTime?: Date
}

export class SealProgressVo {
  @ApiProperty({ description: '总印记数' })
  total: number

  @ApiProperty({ description: '已收集数' })
  collected: number

  @ApiProperty({ description: '收集百分比' })
  percentage: number

  @ApiProperty({ description: '按类型统计' })
  byType: SealTypeProgressVo[]
}

export class SealTypeProgressVo {
  @ApiProperty({ description: '印记类型' })
  type: string

  @ApiProperty({ description: '总数' })
  total: number

  @ApiProperty({ description: '已收集数' })
  collected: number
}

export class AvailableSealVo {
  @ApiProperty({ description: '印记ID' })
  id: string

  @ApiProperty({ description: '印记类型', enum: ['route', 'city', 'special'] })
  type: string

  @ApiProperty({ description: '印记名称' })
  name: string

  @ApiProperty({ description: '印记图片' })
  imageAsset: string

  @ApiPropertyOptional({ description: '印记描述' })
  description?: string

  @ApiPropertyOptional({ description: '解锁条件' })
  unlockCondition?: string

  @ApiPropertyOptional({ description: '解锁的称号' })
  badgeTitle?: string

  @ApiPropertyOptional({ description: '关联文化之旅ID' })
  journeyId?: string

  @ApiPropertyOptional({ description: '关联文化之旅名称' })
  journeyName?: string

  @ApiPropertyOptional({ description: '关联城市ID' })
  cityId?: string

  @ApiPropertyOptional({ description: '关联城市名称' })
  cityName?: string

  @ApiProperty({ description: '是否已拥有' })
  owned: boolean
}
