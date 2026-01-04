import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsOptional,
  IsString,
  IsBoolean,
  IsInt,
  Min,
  IsIn,
} from 'class-validator';
import { Type, Transform } from 'class-transformer';

export class QueryUserSealDto {
  @ApiPropertyOptional({ description: '用户ID' })
  @IsOptional()
  @IsString()
  userId?: string;

  @ApiPropertyOptional({ description: '用户昵称' })
  @IsOptional()
  @IsString()
  nickname?: string;

  @ApiPropertyOptional({ description: '印记ID' })
  @IsOptional()
  @IsString()
  sealId?: string;

  @ApiPropertyOptional({ description: '印记名称' })
  @IsOptional()
  @IsString()
  sealName?: string;

  @ApiPropertyOptional({
    description: '印记类型',
    enum: ['route', 'city', 'special'],
  })
  @IsOptional()
  @IsString()
  sealType?: string;

  @ApiPropertyOptional({ description: '是否已上链' })
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  isChained?: boolean;

  @ApiPropertyOptional({ description: '页码', default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  pageNum?: number;

  @ApiPropertyOptional({ description: '每页数量', default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  pageSize?: number;
}

export class UserSealListVo {
  @ApiProperty({ description: '记录ID' })
  id: string;

  @ApiProperty({ description: '用户ID' })
  userId: string;

  @ApiProperty({ description: '用户昵称' })
  nickname: string;

  @ApiProperty({ description: '用户头像' })
  avatar: string;

  @ApiProperty({ description: '印记ID' })
  sealId: string;

  @ApiProperty({ description: '印记名称' })
  sealName: string;

  @ApiProperty({ description: '印记图片' })
  sealImage: string;

  @ApiProperty({ description: '印记类型' })
  sealType: string;

  @ApiProperty({ description: '获得时间' })
  earnedTime: Date;

  @ApiProperty({ description: '花费时间（分钟）' })
  timeSpentMinutes: number | null;

  @ApiProperty({ description: '获得积分' })
  pointsEarned: number;

  @ApiProperty({ description: '是否已上链' })
  isChained: boolean;

  @ApiProperty({ description: '链名称' })
  chainName: string | null;

  @ApiProperty({ description: '交易哈希' })
  txHash: string | null;

  @ApiProperty({ description: '区块高度' })
  blockHeight: string | null;

  @ApiProperty({ description: '上链时间' })
  chainTime: Date | null;
}

export class ChainSealDto {
  @ApiPropertyOptional({
    description: '区块链名称（从字典 xunyin_chain_name 获取）',
    example: 'local',
  })
  @IsOptional()
  @IsString()
  chainName?: string;
}

export class ChainSealVo {
  @ApiProperty({ description: '记录ID' })
  id: string;

  @ApiProperty({ description: '印记ID' })
  sealId: string;

  @ApiProperty({ description: '印记名称' })
  sealName: string;

  @ApiProperty({ description: '用户ID' })
  userId: string;

  @ApiProperty({ description: '用户昵称' })
  nickname: string;

  @ApiProperty({ description: '是否已上链' })
  isChained: boolean;

  @ApiProperty({ description: '链名称' })
  chainName: string;

  @ApiProperty({ description: '交易哈希' })
  txHash: string;

  @ApiProperty({ description: '区块高度' })
  blockHeight: string;

  @ApiProperty({ description: '上链时间' })
  chainTime: Date;
}
