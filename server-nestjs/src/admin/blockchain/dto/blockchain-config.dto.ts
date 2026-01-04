import { ApiProperty } from '@nestjs/swagger';

export class ChainProviderOption {
  @ApiProperty({ description: '链服务标识', example: 'antchain' })
  value: string;

  @ApiProperty({ description: '链服务名称', example: '蚂蚁链' })
  label: string;

  @ApiProperty({ description: '链服务描述', example: '蚂蚁集团区块链平台' })
  description: string;

  @ApiProperty({ description: '是否已配置', example: true })
  isConfigured: boolean;

  @ApiProperty({ description: '是否当前选中', example: false })
  isCurrent: boolean;
}

export class ChainProviderInfoVo {
  @ApiProperty({ description: '当前链服务提供者', example: 'antchain' })
  currentProvider: string;

  @ApiProperty({ description: '当前链服务名称', example: '蚂蚁链' })
  currentProviderName: string;

  @ApiProperty({ description: '当前链服务是否已配置', example: true })
  isConfigured: boolean;

  @ApiProperty({
    description: '所有可用的链服务选项',
    type: [ChainProviderOption],
  })
  options: ChainProviderOption[];
}
