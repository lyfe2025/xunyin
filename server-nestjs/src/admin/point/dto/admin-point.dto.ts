import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsNumber,
  MaxLength,
  Min,
  Max,
} from 'class-validator';
import { Type } from 'class-transformer';

export class QueryAdminPointDto {
  @ApiPropertyOptional({ description: '文化之旅ID' })
  @IsOptional()
  @IsString()
  journeyId?: string;

  @ApiPropertyOptional({ description: '探索点名称' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ description: '任务类型 gesture/photo/treasure' })
  @IsOptional()
  @IsString()
  taskType?: string;

  @ApiPropertyOptional({ description: '状态 0正常 1停用' })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ description: '页码', default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  pageNum?: number = 1;

  @ApiPropertyOptional({ description: '每页数量', default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(100)
  pageSize?: number = 10;
}

export class CreatePointDto {
  @ApiProperty({ description: '文化之旅ID' })
  @IsString()
  journeyId: string;

  @ApiProperty({ description: '探索点名称' })
  @IsString()
  @MaxLength(100)
  name: string;

  @ApiProperty({ description: '纬度' })
  @Type(() => Number)
  @IsNumber()
  latitude: number;

  @ApiProperty({ description: '经度' })
  @Type(() => Number)
  @IsNumber()
  longitude: number;

  @ApiProperty({ description: '任务类型 gesture/photo/treasure' })
  @IsString()
  @MaxLength(20)
  taskType: string;

  @ApiProperty({ description: '任务描述' })
  @IsString()
  @MaxLength(255)
  taskDescription: string;

  @ApiPropertyOptional({ description: '目标手势' })
  @IsOptional()
  @IsString()
  targetGesture?: string;

  @ApiPropertyOptional({ description: 'AR资源URL' })
  @IsOptional()
  @IsString()
  arAssetUrl?: string;

  @ApiPropertyOptional({ description: '文化背景' })
  @IsOptional()
  @IsString()
  culturalBackground?: string;

  @ApiPropertyOptional({ description: '文化小知识' })
  @IsOptional()
  @IsString()
  culturalKnowledge?: string;

  @ApiPropertyOptional({ description: '距上一点距离(米)' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  distanceFromPrev?: number;

  @ApiPropertyOptional({ description: '积分奖励', default: 50 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  pointsReward?: number = 50;

  @ApiProperty({ description: '排序号' })
  @Type(() => Number)
  @IsNumber()
  orderNum: number;

  @ApiPropertyOptional({ description: '状态 0正常 1停用', default: '0' })
  @IsOptional()
  @IsString()
  status?: string = '0';
}

export class UpdatePointDto {
  @ApiPropertyOptional({ description: '文化之旅ID' })
  @IsOptional()
  @IsString()
  journeyId?: string;

  @ApiPropertyOptional({ description: '探索点名称' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  name?: string;

  @ApiPropertyOptional({ description: '纬度' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  latitude?: number;

  @ApiPropertyOptional({ description: '经度' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  longitude?: number;

  @ApiPropertyOptional({ description: '任务类型 gesture/photo/treasure' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  taskType?: string;

  @ApiPropertyOptional({ description: '任务描述' })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  taskDescription?: string;

  @ApiPropertyOptional({ description: '目标手势' })
  @IsOptional()
  @IsString()
  targetGesture?: string;

  @ApiPropertyOptional({ description: 'AR资源URL' })
  @IsOptional()
  @IsString()
  arAssetUrl?: string;

  @ApiPropertyOptional({ description: '文化背景' })
  @IsOptional()
  @IsString()
  culturalBackground?: string;

  @ApiPropertyOptional({ description: '文化小知识' })
  @IsOptional()
  @IsString()
  culturalKnowledge?: string;

  @ApiPropertyOptional({ description: '距上一点距离(米)' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  distanceFromPrev?: number;

  @ApiPropertyOptional({ description: '积分奖励' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  pointsReward?: number;

  @ApiPropertyOptional({ description: '排序号' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  orderNum?: number;

  @ApiPropertyOptional({ description: '状态 0正常 1停用' })
  @IsOptional()
  @IsString()
  status?: string;
}

export class UpdateStatusDto {
  @ApiProperty({ description: '状态 0正常 1停用' })
  @IsString()
  status: string;
}
