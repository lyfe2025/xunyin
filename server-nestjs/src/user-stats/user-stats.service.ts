import { Injectable } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'

/**
 * 用户动态类型枚举
 */
export enum ActivityType {
  JOURNEY_STARTED = 'journey_started',
  JOURNEY_COMPLETED = 'journey_completed',
  SEAL_EARNED = 'seal_earned',
  SEAL_CHAINED = 'seal_chained',
  POINT_COMPLETED = 'point_completed',
  PHOTO_TAKEN = 'photo_taken',
  LEVEL_UP = 'level_up',
}

@Injectable()
export class UserStatsService {
  constructor(private prisma: PrismaService) {}

  /**
   * 获取个人中心首页聚合数据（一次请求返回所有数据）
   */
  async getHomeData(userId: string) {
    const [user, stats, inProgressJourneys, recentActivities] = await Promise.all([
      this.getUserInfo(userId),
      this.getOverview(userId),
      this.getInProgressJourneys(userId, 5),
      this.getActivities(userId, 5),
    ])

    return {
      user,
      stats,
      inProgressJourneys,
      recentActivities,
    }
  }

  /**
   * 获取用户基本信息
   */
  private async getUserInfo(userId: string) {
    const user = await this.prisma.appUser.findUnique({
      where: { id: userId },
      select: {
        id: true,
        phone: true,
        nickname: true,
        avatar: true,
        badgeTitle: true,
        totalPoints: true,
        level: true,
        createTime: true,
      },
    })

    return user
      ? {
          id: user.id,
          phone: user.phone,
          nickname: user.nickname,
          avatar: user.avatar,
          badgeTitle: user.badgeTitle,
          totalPoints: user.totalPoints,
          level: user.level,
          createTime: user.createTime,
        }
      : null
  }

  /**
   * 获取进行中的旅程列表（包含城市名称）
   */
  async getInProgressJourneys(userId: string, limit = 5) {
    const progresses = await this.prisma.journeyProgress.findMany({
      where: { userId, status: 'in_progress' },
      include: {
        journey: {
          select: {
            id: true,
            name: true,
            cityId: true,
            city: { select: { name: true } },
          },
        },
        _count: {
          select: { pointCompletions: true },
        },
      },
      orderBy: { startTime: 'desc' },
      take: limit,
    })

    // 获取每个旅程的总探索点数
    const journeyIds = progresses.map((p) => p.journeyId)
    const pointCounts = await this.prisma.explorationPoint.groupBy({
      by: ['journeyId'],
      where: { journeyId: { in: journeyIds } },
      _count: { id: true },
    })
    const pointCountMap = new Map(pointCounts.map((p) => [p.journeyId, p._count.id]))

    // 过滤掉已完成所有探索点的旅程（状态可能未及时更新）
    return progresses
      .map((p) => {
        const totalPoints = pointCountMap.get(p.journeyId) || 0
        const completedPoints = p._count.pointCompletions
        return {
          id: p.id,
          journeyId: p.journeyId,
          journeyName: p.journey.name,
          cityName: p.journey.city.name,
          status: p.status,
          startTime: p.startTime,
          completedPoints,
          totalPoints,
        }
      })
      .filter((p) => p.completedPoints < p.totalPoints || p.totalPoints === 0)
  }

  /**
   * 获取用户统计概览（包含城市解锁统计）
   */
  async getOverview(userId: string) {
    const [
      user,
      completedJourneys,
      inProgressJourneys,
      totalSeals,
      chainedSeals,
      totalPhotos,
      totalCities,
      userJourneyProgresses,
    ] = await Promise.all([
      this.prisma.appUser.findUnique({ where: { id: userId } }),
      this.prisma.journeyProgress.count({
        where: { userId, status: 'completed' },
      }),
      this.prisma.journeyProgress.count({
        where: { userId, status: 'in_progress' },
      }),
      this.prisma.userSeal.count({ where: { userId } }),
      this.prisma.userSeal.count({ where: { userId, isChained: true } }),
      this.prisma.explorationPhoto.count({ where: { userId } }),
      this.prisma.city.count({ where: { status: '0' } }),
      // 获取用户所有进行中或已完成的旅程，用于计算解锁城市
      this.prisma.journeyProgress.findMany({
        where: { userId, status: { in: ['in_progress', 'completed'] } },
        select: { journey: { select: { cityId: true } } },
      }),
    ])

    // 计算已解锁城市数（去重）
    const unlockedCityIds = new Set(userJourneyProgresses.map((p) => p.journey.cityId))
    const unlockedCities = unlockedCityIds.size

    // 计算总行程距离
    const completedJourneyIds = await this.prisma.journeyProgress.findMany({
      where: { userId, status: 'completed' },
      select: { journeyId: true },
    })

    let totalDistance = 0
    if (completedJourneyIds.length > 0) {
      const journeys = await this.prisma.journey.findMany({
        where: { id: { in: completedJourneyIds.map((j) => j.journeyId) } },
        select: { totalDistance: true },
      })
      totalDistance = journeys.reduce((sum, j) => sum + Number(j.totalDistance), 0)
    }

    // 计算总花费时间
    const totalTimeSpent = await this.prisma.journeyProgress.aggregate({
      where: { userId, status: 'completed' },
      _sum: { timeSpentMinutes: true },
    })

    return {
      totalPoints: user?.totalPoints || 0,
      badgeTitle: user?.badgeTitle,
      unlockedCities,
      totalCities,
      completedJourneys,
      inProgressJourneys,
      totalSeals,
      chainedSeals,
      totalPhotos,
      totalDistance: Math.round(totalDistance),
      totalTimeSpentMinutes: totalTimeSpent._sum.timeSpentMinutes || 0,
    }
  }

  /**
   * 获取用户最近动态
   */
  async getActivities(userId: string, limit = 20) {
    const activities = await this.prisma.userActivity.findMany({
      where: { userId },
      orderBy: { createTime: 'desc' },
      take: limit,
    })

    return activities.map((activity) => ({
      id: activity.id,
      type: activity.type,
      title: activity.title,
      relatedId: activity.relatedId,
      createTime: activity.createTime,
    }))
  }

  /**
   * 获取旅行统计详情
   */
  async getTravelStats(userId: string) {
    // 按城市统计
    const journeyProgresses = await this.prisma.journeyProgress.findMany({
      where: { userId, status: 'completed' },
      include: {
        journey: {
          include: { city: true },
        },
      },
    })

    const cityStats = new Map<
      string,
      {
        cityId: string
        cityName: string
        journeyCount: number
        totalTime: number
      }
    >()

    for (const progress of journeyProgresses) {
      const cityId = progress.journey.cityId
      const cityName = progress.journey.city.name
      const existing = cityStats.get(cityId)

      if (existing) {
        existing.journeyCount += 1
        existing.totalTime += progress.timeSpentMinutes || 0
      } else {
        cityStats.set(cityId, {
          cityId,
          cityName,
          journeyCount: 1,
          totalTime: progress.timeSpentMinutes || 0,
        })
      }
    }

    // 按月统计
    const monthlyStats = new Map<string, number>()
    for (const progress of journeyProgresses) {
      if (progress.completeTime) {
        const month = progress.completeTime.toISOString().slice(0, 7)
        monthlyStats.set(month, (monthlyStats.get(month) || 0) + 1)
      }
    }

    return {
      byCity: Array.from(cityStats.values()),
      byMonth: Array.from(monthlyStats.entries()).map(([month, count]) => ({
        month,
        count,
      })),
    }
  }
}
