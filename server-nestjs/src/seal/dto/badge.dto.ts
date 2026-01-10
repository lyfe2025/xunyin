import { ApiProperty } from '@nestjs/swagger'
import { IsString } from 'class-validator'

// ==================== Request DTOs ====================

export class SetBadgeTitleDto {
  @ApiProperty({ description: '称号名称' })
  @IsString()
  badgeTitle: string
}

// ==================== Response VOs ====================

export class UserBadgeVo {
  @ApiProperty({ description: '称号名称' })
  badgeTitle: string

  @ApiProperty({ description: '来源印记ID' })
  sealId: string

  @ApiProperty({ description: '来源印记名称' })
  sealName: string

  @ApiProperty({ description: '印记稀有度', enum: ['common', 'rare', 'legendary'] })
  rarity: string

  @ApiProperty({ description: '获得时间' })
  earnedTime: Date

  @ApiProperty({ description: '是否为当前使用的称号' })
  isActive: boolean
}
