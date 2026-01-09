import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'

/**
 * 用户基本信息 VO
 */
export class ProfileUserVo {
  @ApiProperty({ description: '用户ID' })
  id: string

  @ApiPropertyOptional({ description: '手机号' })
  phone: string | null

  @ApiProperty({ description: '昵称' })
  nickname: string

  @ApiPropertyOptional({ description: '头像' })
  avatar: string | null

  @ApiPropertyOptional({ description: '当前称号' })
  badgeTitle: string | null

  @ApiProperty({ description: '总积分' })
  totalPoints: number

  @ApiProperty({ description: '等级' })
  level: number

  @ApiProperty({ description: '创建时间' })
  createTime: Date
}

/**
 * 用户统计概览 VO
 */
export class UserStatsVo {
  @ApiProperty({ description: '总积分' })
  totalPoints: number

  @ApiPropertyOptional({ description: '当前称号' })
  badgeTitle: string | null

  @ApiProperty({ description: '已解锁城市数' })
  unlockedCities: number

  @ApiProperty({ description: '总城市数' })
  totalCities: number

  @ApiProperty({ description: '已完成旅程数' })
  completedJourneys: number

  @ApiProperty({ description: '进行中旅程数' })
  inProgressJourneys: number

  @ApiProperty({ description: '收集印记数' })
  totalSeals: number

  @ApiProperty({ description: '已上链印记数' })
  chainedSeals: number

  @ApiProperty({ description: '照片数' })
  totalPhotos: number

  @ApiProperty({ description: '总行程距离（米）' })
  totalDistance: number

  @ApiProperty({ description: '总探索时长（分钟）' })
  totalTimeSpentMinutes: number
}

/**
 * 进行中旅程 VO
 */
export class InProgressJourneyVo {
  @ApiProperty({ description: '进度ID' })
  id: string

  @ApiProperty({ description: '旅程ID' })
  journeyId: string

  @ApiProperty({ description: '旅程名称' })
  journeyName: string

  @ApiProperty({ description: '状态' })
  status: string

  @ApiProperty({ description: '开始时间' })
  startTime: Date

  @ApiProperty({ description: '已完成探索点数' })
  completedPoints: number

  @ApiProperty({ description: '总探索点数' })
  totalPoints: number
}

/**
 * 用户动态 VO
 */
export class UserActivityVo {
  @ApiProperty({ description: '动态ID' })
  id: string

  @ApiProperty({ description: '动态类型' })
  type: string

  @ApiProperty({ description: '动态标题' })
  title: string

  @ApiPropertyOptional({ description: '关联ID' })
  relatedId: string | null

  @ApiProperty({ description: '创建时间' })
  createTime: Date
}

/**
 * 个人中心首页聚合数据 VO
 */
export class ProfileHomeVo {
  @ApiProperty({ description: '用户信息', type: ProfileUserVo })
  user: ProfileUserVo

  @ApiProperty({ description: '统计数据', type: UserStatsVo })
  stats: UserStatsVo

  @ApiProperty({ description: '进行中的旅程', type: [InProgressJourneyVo] })
  inProgressJourneys: InProgressJourneyVo[]

  @ApiProperty({ description: '最近动态', type: [UserActivityVo] })
  recentActivities: UserActivityVo[]
}
