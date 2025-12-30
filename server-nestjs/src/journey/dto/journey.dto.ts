import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

// ==================== Response VOs ====================

export class ExplorationPointVo {
  @ApiProperty({ description: '探索点ID' })
  id: string;

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

  @ApiPropertyOptional({ description: '距上一点距离(米)' })
  distanceFromPrev?: number;

  @ApiProperty({ description: '积分奖励' })
  pointsReward: number;

  @ApiProperty({ description: '顺序' })
  orderNum: number;
}

export class JourneyDetailVo {
  @ApiProperty({ description: '文化之旅ID' })
  id: string;

  @ApiProperty({ description: '城市ID' })
  cityId: string;

  @ApiProperty({ description: '文化之旅名称' })
  name: string;

  @ApiProperty({ description: '主题' })
  theme: string;

  @ApiPropertyOptional({ description: '封面图片' })
  coverImage?: string;

  @ApiPropertyOptional({ description: '描述' })
  description?: string;

  @ApiProperty({ description: '星级评分 1-5' })
  rating: number;

  @ApiProperty({ description: '预计时长(分钟)' })
  estimatedMinutes: number;

  @ApiProperty({ description: '总距离(米)' })
  totalDistance: number;

  @ApiProperty({ description: '完成人数' })
  completedCount: number;

  @ApiProperty({ description: '是否锁定' })
  isLocked: boolean;

  @ApiPropertyOptional({ description: '解锁条件' })
  unlockCondition?: string;

  @ApiPropertyOptional({ description: '背景音乐URL' })
  bgmUrl?: string;

  @ApiProperty({ description: '探索点数量' })
  pointCount: number;
}

export class JourneyProgressVo {
  @ApiProperty({ description: '进度ID' })
  id: string;

  @ApiProperty({ description: '文化之旅ID' })
  journeyId: string;

  @ApiProperty({ description: '文化之旅名称' })
  journeyName: string;

  @ApiProperty({
    description: '状态',
    enum: ['in_progress', 'completed', 'abandoned'],
  })
  status: string;

  @ApiProperty({ description: '开始时间' })
  startTime: Date;

  @ApiPropertyOptional({ description: '完成时间' })
  completeTime?: Date;

  @ApiPropertyOptional({ description: '花费时间(分钟)' })
  timeSpentMinutes?: number;

  @ApiProperty({ description: '已完成探索点数' })
  completedPoints: number;

  @ApiProperty({ description: '总探索点数' })
  totalPoints: number;
}

export class StartJourneyVo {
  @ApiProperty({ description: '进度ID' })
  progressId: string;

  @ApiProperty({ description: '文化之旅ID' })
  journeyId: string;

  @ApiProperty({ description: '开始时间' })
  startTime: Date;
}
