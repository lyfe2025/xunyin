import { Injectable } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'
import { BusinessException } from '../common/exceptions'
import { ErrorCode } from '../common/enums'
import type { CompleteTaskDto, ValidateLocationDto } from './dto/complete-task.dto'

// 到达探索点的距离阈值（米）
const LOCATION_THRESHOLD = 50

@Injectable()
export class ExplorationPointService {
  constructor(private prisma: PrismaService) {}

  /**
   * 获取探索点详情
   */
  async findOne(id: string) {
    const point = await this.prisma.explorationPoint.findUnique({
      where: { id },
    })

    if (!point || point.status !== '0') {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '探索点不存在')
    }

    return {
      id: point.id,
      journeyId: point.journeyId,
      name: point.name,
      latitude: Number(point.latitude),
      longitude: Number(point.longitude),
      taskType: point.taskType,
      taskDescription: point.taskDescription,
      targetGesture: point.targetGesture,
      arAssetUrl: point.arAssetUrl,
      culturalBackground: point.culturalBackground,
      culturalKnowledge: point.culturalKnowledge,
      pointsReward: point.pointsReward,
    }
  }

  /**
   * 完成探索点任务
   */
  async completeTask(userId: string, pointId: string, dto: CompleteTaskDto) {
    // 获取探索点
    const point = await this.prisma.explorationPoint.findUnique({
      where: { id: pointId },
      include: { journey: true },
    })

    if (!point || point.status !== '0') {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '探索点不存在')
    }

    // 检查用户是否有进行中的文化之旅进度
    const progress = await this.prisma.journeyProgress.findUnique({
      where: {
        userId_journeyId: { userId, journeyId: point.journeyId },
      },
    })

    if (!progress || progress.status !== 'in_progress') {
      throw new BusinessException(ErrorCode.OPERATION_DENIED, '请先开始文化之旅')
    }

    // 检查是否已完成该探索点
    const existingCompletion = await this.prisma.pointCompletion.findUnique({
      where: {
        progressId_pointId: { progressId: progress.id, pointId },
      },
    })

    if (existingCompletion) {
      throw new BusinessException(ErrorCode.DATA_ALREADY_EXISTS, '该探索点已完成')
    }

    // 创建完成记录
    await this.prisma.pointCompletion.create({
      data: {
        progressId: progress.id,
        pointId,
        completeTime: new Date(),
        pointsEarned: point.pointsReward,
        photoUrl: dto.photoUrl,
      },
    })

    // 更新用户积分
    const updatedUser = await this.prisma.appUser.update({
      where: { id: userId },
      data: {
        totalPoints: { increment: point.pointsReward },
      },
    })

    // 检查是否完成整个文化之旅
    const totalPoints = await this.prisma.explorationPoint.count({
      where: { journeyId: point.journeyId, status: '0' },
    })

    const completedPoints = await this.prisma.pointCompletion.count({
      where: { progressId: progress.id },
    })

    let journeyCompleted = false
    let sealId: string | undefined

    if (completedPoints >= totalPoints) {
      // 完成文化之旅
      journeyCompleted = true
      const timeSpent = Math.round((Date.now() - progress.startTime.getTime()) / 60000)

      await this.prisma.journeyProgress.update({
        where: { id: progress.id },
        data: {
          status: 'completed',
          completeTime: new Date(),
          timeSpentMinutes: timeSpent,
        },
      })

      // 增加文化之旅完成人数
      await this.prisma.journey.update({
        where: { id: point.journeyId },
        data: { completedCount: { increment: 1 } },
      })

      // 查找并授予路线印记
      const routeSeal = await this.prisma.seal.findFirst({
        where: {
          journeyId: point.journeyId,
          type: 'route',
          status: '0',
        },
      })

      if (routeSeal) {
        // 检查是否已有该印记
        const existingSeal = await this.prisma.userSeal.findUnique({
          where: {
            userId_sealId: { userId, sealId: routeSeal.id },
          },
        })

        if (!existingSeal) {
          await this.prisma.userSeal.create({
            data: {
              userId,
              sealId: routeSeal.id,
              earnedTime: new Date(),
              timeSpentMinutes: timeSpent,
              pointsEarned: point.pointsReward,
            },
          })
          sealId = routeSeal.id

          // 记录获得印记动态
          await this.prisma.userActivity.create({
            data: {
              userId,
              type: 'seal_earned',
              title: `获得了「${routeSeal.name}」印记`,
              relatedId: routeSeal.id,
            },
          })

          // 如果印记有称号，更新用户称号
          if (routeSeal.badgeTitle) {
            await this.prisma.appUser.update({
              where: { id: userId },
              data: { badgeTitle: routeSeal.badgeTitle },
            })
          }
        }
      }

      // 记录完成文化之旅动态
      await this.prisma.userActivity.create({
        data: {
          userId,
          type: 'journey_completed',
          title: `完成了「${point.journey.name}」文化之旅`,
          relatedId: point.journeyId,
        },
      })
    }

    return {
      pointsEarned: point.pointsReward,
      totalPoints: updatedUser.totalPoints,
      journeyCompleted,
      sealId,
    }
  }

  /**
   * 验证用户位置
   */
  async validateLocation(pointId: string, dto: ValidateLocationDto) {
    const point = await this.prisma.explorationPoint.findUnique({
      where: { id: pointId },
    })

    if (!point || point.status !== '0') {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '探索点不存在')
    }

    const distance = this.calculateDistance(
      dto.latitude,
      dto.longitude,
      Number(point.latitude),
      Number(point.longitude),
    )

    // 转换为米
    const distanceInMeters = distance * 1000

    return {
      isInRange: distanceInMeters <= LOCATION_THRESHOLD,
      distance: Math.round(distanceInMeters * 100) / 100,
      threshold: LOCATION_THRESHOLD,
    }
  }

  /**
   * 计算两点间距离（Haversine 公式）
   * @returns 距离（公里）
   */
  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371
    const dLat = this.toRad(lat2 - lat1)
    const dLon = this.toRad(lon2 - lon1)
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) *
        Math.cos(this.toRad(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    return R * c
  }

  private toRad(deg: number): number {
    return deg * (Math.PI / 180)
  }
}
