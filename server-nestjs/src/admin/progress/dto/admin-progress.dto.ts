import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class QueryProgressDto {
  @ApiPropertyOptional({ description: '用户ID' })
  @IsOptional()
  @IsString()
  userId?: string;

  @ApiPropertyOptional({ description: '用户昵称' })
  @IsOptional()
  @IsString()
  nickname?: string;

  @ApiPropertyOptional({ description: '文化之旅ID' })
  @IsOptional()
  @IsString()
  journeyId?: string;

  @ApiPropertyOptional({ description: '文化之旅名称' })
  @IsOptional()
  @IsString()
  journeyName?: string;

  @ApiPropertyOptional({ description: '城市ID' })
  @IsOptional()
  @IsString()
  cityId?: string;

  @ApiPropertyOptional({
    description: '状态',
    enum: ['in_progress', 'completed', 'abandoned'],
  })
  @IsOptional()
  @IsString()
  status?: string;

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

export class ProgressListVo {
  @ApiProperty({ description: '进度ID' })
  id: string;

  @ApiProperty({ description: '用户ID' })
  userId: string;

  @ApiProperty({ description: '用户昵称' })
  nickname: string;

  @ApiProperty({ description: '用户头像' })
  avatar: string;

  @ApiProperty({ description: '文化之旅ID' })
  journeyId: string;

  @ApiProperty({ description: '文化之旅名称' })
  journeyName: string;

  @ApiProperty({ description: '城市名称' })
  cityName: string;

  @ApiProperty({ description: '状态' })
  status: string;

  @ApiProperty({ description: '开始时间' })
  startTime: Date;

  @ApiProperty({ description: '完成时间' })
  completeTime: Date | null;

  @ApiProperty({ description: '花费时间（分钟）' })
  timeSpentMinutes: number | null;

  @ApiProperty({ description: '已完成探索点数' })
  completedPoints: number;

  @ApiProperty({ description: '总探索点数' })
  totalPoints: number;

  @ApiProperty({ description: '创建时间' })
  createTime: Date;
}
