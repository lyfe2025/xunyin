import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'

export class PublicSealDetailVo {
  @ApiProperty({ description: '印记ID' })
  id: string

  @ApiProperty({ description: '印记类型', enum: ['route', 'city', 'special'] })
  type: string

  @ApiProperty({ description: '印记名称' })
  name: string

  @ApiProperty({ description: '印记图片' })
  imageAsset: string

  @ApiPropertyOptional({ description: '印记描述' })
  description?: string | null

  @ApiPropertyOptional({ description: '解锁称号' })
  badgeTitle?: string | null

  @ApiPropertyOptional({ description: '关联文化之旅名称' })
  journeyName?: string | null

  @ApiPropertyOptional({ description: '关联城市名称' })
  cityName?: string | null

  @ApiPropertyOptional({ description: '获得时间' })
  earnedTime?: Date | null

  @ApiPropertyOptional({ description: '是否已上链' })
  isChained?: boolean

  @ApiPropertyOptional({ description: '上链哈希' })
  txHash?: string | null

  @ApiPropertyOptional({ description: '上链时间' })
  chainTime?: Date | null

  @ApiPropertyOptional({ description: '用户昵称（脱敏）' })
  userNickname?: string | null
}
