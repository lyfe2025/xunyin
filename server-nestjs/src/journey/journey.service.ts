import { Injectable } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'
import { BusinessException } from '../common/exceptions'
import { ErrorCode } from '../common/enums'

@Injectable()
export class JourneyService {
  constructor(private prisma: PrismaService) {}

  /**
   * 获取文化之旅详情
   */
  async findOne(id: string) {
    const journey = await this.prisma.journey.findUnique({
      where: { id },
      include: {
        _count: {
          select: { points: { where: { status: '0' } } },
        },
      },
    })

    if (!journey || journey.status !== '0') {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在')
    }

    return {
      id: journey.id,
      cityId: journey.cityId,
      name: journey.name,
      theme: journey.theme,
      coverImage: journey.coverImage,
      description: journey.description,
      rating: journey.rating,
      estimatedMinutes: journey.estimatedMinutes,
      totalDistance: Number(journey.totalDistance),
      completedCount: journey.completedCount,
      isLocked: journey.isLocked,
      unlockCondition: journey.unlockCondition,
      bgmUrl: journey.bgmUrl,
      pointCount: journey._count.points,
    }
  }

  /**
   * 获取文化之旅的探索点列表
   */
  async findPoints(journeyId: string) {
    const journey = await this.prisma.journey.findUnique({
      where: { id: journeyId },
    })

    if (!journey || journey.status !== '0') {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在')
    }

    const points = await this.prisma.explorationPoint.findMany({
      where: {
        journeyId,
        status: '0',
      },
      orderBy: { orderNum: 'asc' },
    })

    return points.map((point) => ({
      id: point.id,
      name: point.name,
      latitude: Number(point.latitude),
      longitude: Number(point.longitude),
      taskType: point.taskType,
      taskDescription: point.taskDescription,
      targetGesture: point.targetGesture,
      arAssetUrl: point.arAssetUrl,
      culturalBackground: point.culturalBackground,
      culturalKnowledge: point.culturalKnowledge,
      distanceFromPrev: point.distanceFromPrev ? Number(point.distanceFromPrev) : null,
      pointsReward: point.pointsReward,
      orderNum: point.orderNum,
    }))
  }

  /**
   * 开始文化之旅
   */
  async startJourney(userId: string, journeyId: string) {
    // 验证文化之旅存在
    const journey = await this.prisma.journey.findUnique({
      where: { id: journeyId },
    })

    if (!journey || journey.status !== '0') {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在')
    }

    // 检查是否已锁定
    if (journey.isLocked) {
      throw new BusinessException(ErrorCode.OPERATION_DENIED, '文化之旅尚未解锁')
    }

    // 检查是否已有进行中的进度
    const existingProgress = await this.prisma.journeyProgress.findUnique({
      where: {
        userId_journeyId: { userId, journeyId },
      },
    })

    if (existingProgress) {
      if (existingProgress.status === 'in_progress') {
        // 已有进行中的进度，直接返回
        return {
          progressId: existingProgress.id,
          journeyId: existingProgress.journeyId,
          startTime: existingProgress.startTime,
        }
      }
      // 如果之前放弃或完成，重新开始
      const updated = await this.prisma.journeyProgress.update({
        where: { id: existingProgress.id },
        data: {
          status: 'in_progress',
          startTime: new Date(),
          completeTime: null,
          timeSpentMinutes: null,
        },
      })

      return {
        progressId: updated.id,
        journeyId: updated.journeyId,
        startTime: updated.startTime,
      }
    }

    // 创建新进度
    const progress = await this.prisma.journeyProgress.create({
      data: {
        userId,
        journeyId,
        status: 'in_progress',
        startTime: new Date(),
      },
    })

    // 记录用户动态
    await this.prisma.userActivity.create({
      data: {
        userId,
        type: 'journey_started',
        title: `开始了「${journey.name}」文化之旅`,
        relatedId: journeyId,
      },
    })

    return {
      progressId: progress.id,
      journeyId: progress.journeyId,
      startTime: progress.startTime,
    }
  }

  /**
   * 获取用户进行中的文化之旅
   */
  async findUserProgress(userId: string) {
    const progresses = await this.prisma.journeyProgress.findMany({
      where: {
        userId,
        status: 'in_progress',
      },
      include: {
        journey: true,
        pointCompletions: true,
      },
      orderBy: { startTime: 'desc' },
    })

    // 获取每个文化之旅的总探索点数
    const journeyIds = progresses.map((p) => p.journeyId)
    const pointCounts = await this.prisma.explorationPoint.groupBy({
      by: ['journeyId'],
      where: {
        journeyId: { in: journeyIds },
        status: '0',
      },
      _count: { id: true },
    })

    const pointCountMap = new Map(pointCounts.map((pc) => [pc.journeyId, pc._count.id]))

    return progresses.map((progress) => ({
      id: progress.id,
      journeyId: progress.journeyId,
      journeyName: progress.journey.name,
      status: progress.status,
      startTime: progress.startTime,
      completeTime: progress.completeTime,
      timeSpentMinutes: progress.timeSpentMinutes,
      completedPoints: progress.pointCompletions.length,
      totalPoints: pointCountMap.get(progress.journeyId) || 0,
    }))
  }

  /**
   * 放弃文化之旅
   */
  async abandonJourney(userId: string, journeyId: string) {
    const progress = await this.prisma.journeyProgress.findUnique({
      where: {
        userId_journeyId: { userId, journeyId },
      },
    })

    if (!progress) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '未找到文化之旅进度')
    }

    if (progress.status !== 'in_progress') {
      throw new BusinessException(ErrorCode.OPERATION_DENIED, '只能放弃进行中的文化之旅')
    }

    const timeSpent = Math.round((Date.now() - progress.startTime.getTime()) / 60000)

    await this.prisma.journeyProgress.update({
      where: { id: progress.id },
      data: {
        status: 'abandoned',
        timeSpentMinutes: timeSpent,
      },
    })

    return { message: '已放弃文化之旅' }
  }
}
