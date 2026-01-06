import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'

export class ChainSealVo {
  @ApiProperty({ description: '印记ID' })
  sealId: string

  @ApiProperty({ description: '交易哈希' })
  txHash: string

  @ApiProperty({ description: '区块高度' })
  blockHeight: string

  @ApiProperty({ description: '上链时间' })
  chainTime: Date

  @ApiProperty({ description: '链名称' })
  chainName: string
}

export class VerifyChainVo {
  @ApiProperty({ description: '是否有效' })
  valid: boolean

  @ApiProperty({ description: '交易哈希' })
  txHash: string

  @ApiProperty({ description: '区块高度' })
  blockHeight: string

  @ApiProperty({ description: '上链时间' })
  chainTime: Date

  @ApiProperty({ description: '链名称' })
  chainName: string

  @ApiProperty({ description: '印记名称' })
  sealName: string

  @ApiProperty({ description: '拥有者昵称' })
  ownerNickname: string

  @ApiProperty({ description: '获得时间' })
  earnedTime: Date
}

export class ChainStatusVo {
  @ApiProperty({ description: '印记ID' })
  sealId: string

  @ApiProperty({ description: '是否已上链' })
  isChained: boolean

  @ApiPropertyOptional({ description: '链名称' })
  chainName?: string

  @ApiPropertyOptional({ description: '交易哈希' })
  txHash?: string

  @ApiPropertyOptional({ description: '区块高度' })
  blockHeight?: string

  @ApiPropertyOptional({ description: '上链时间' })
  chainTime?: Date
}
