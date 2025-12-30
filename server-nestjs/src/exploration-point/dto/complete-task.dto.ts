import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

export class CompleteTaskDto {
  @ApiPropertyOptional({ description: '照片URL（拍照任务）' })
  @IsOptional()
  @IsString()
  photoUrl?: string;
}

export class ValidateLocationDto {
  @ApiProperty({ description: '用户纬度', example: 30.2741 })
  @Type(() => Number)
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @ApiProperty({ description: '用户经度', example: 120.1551 })
  @Type(() => Number)
  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;
}

// ==================== Response VOs ====================

export class PointDetailVo {
  @ApiProperty({ description: '探索点ID' })
  id: string;

  @ApiProperty({ description: '文化之旅ID' })
  journeyId: string;

  @ApiProperty({ description: '探索点名称' })
  name: string;

  @ApiProperty({ description: '纬度' })
  latitude: number;

  @ApiProperty({ description: '经度' })
  longitude: number;

  @ApiProperty({
    description: '任务类型',
    enum: ['gesture', 'photo', 'treasure'],
  })
  taskType: string;

  @ApiProperty({ description: '任务描述' })
  taskDescription: string;

  @ApiPropertyOptional({ description: '目标手势' })
  targetGesture?: string;

  @ApiPropertyOptional({ description: 'AR资源URL' })
  arAssetUrl?: string;

  @ApiPropertyOptional({ description: '文化背景' })
  culturalBackground?: string;

  @ApiPropertyOptional({ description: '文化小知识' })
  culturalKnowledge?: string;

  @ApiProperty({ description: '积分奖励' })
  pointsReward: number;
}

export class CompleteTaskVo {
  @ApiProperty({ description: '获得积分' })
  pointsEarned: number;

  @ApiProperty({ description: '用户总积分' })
  totalPoints: number;

  @ApiProperty({ description: '是否完成文化之旅' })
  journeyCompleted: boolean;

  @ApiPropertyOptional({ description: '获得的印记ID' })
  sealId?: string;
}

export class ValidateLocationVo {
  @ApiProperty({ description: '是否在范围内' })
  isInRange: boolean;

  @ApiProperty({ description: '距离(米)' })
  distance: number;

  @ApiProperty({ description: '阈值(米)' })
  threshold: number;
}
