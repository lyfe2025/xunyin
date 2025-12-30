import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UserStatsService {
  constructor(private prisma: PrismaService) {}

  /**
   * 获取用户统计概览
   */
  async getOverview(userId: string) {
    const [
      user,
      completedJourneys,
      inProgressJourneys,
      totalSeals,
      chainedSeals,
      totalPhotos,
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
    ]);

    // 计算总行程距离
    const completedJourneyIds = await this.prisma.journeyProgress.findMany({
      where: { userId, status: 'completed' },
      select: { journeyId: true },
    });

    let totalDistance = 0;
    if (completedJourneyIds.length > 0) {
      const journeys = await this.prisma.journey.findMany({
        where: { id: { in: completedJourneyIds.map((j) => j.journeyId) } },
        select: { totalDistance: true },
      });
      totalDistance = journeys.reduce(
        (sum, j) => sum + Number(j.totalDistance),
        0,
      );
    }

    // 计算总花费时间
    const totalTimeSpent = await this.prisma.journeyProgress.aggregate({
      where: { userId, status: 'completed' },
      _sum: { timeSpentMinutes: true },
    });

    return {
      totalPoints: user?.totalPoints || 0,
      badgeTitle: user?.badgeTitle,
      completedJourneys,
      inProgressJourneys,
      totalSeals,
      chainedSeals,
      totalPhotos,
      totalDistance: Math.round(totalDistance),
      totalTimeSpentMinutes: totalTimeSpent._sum.timeSpentMinutes || 0,
    };
  }

  /**
   * 获取用户最近动态
   */
  async getActivities(userId: string, limit = 20) {
    const activities = await this.prisma.userActivity.findMany({
      where: { userId },
      orderBy: { createTime: 'desc' },
      take: limit,
    });

    return activities.map((activity) => ({
      id: activity.id,
      type: activity.type,
      title: activity.title,
      relatedId: activity.relatedId,
      createTime: activity.createTime,
    }));
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
    });

    const cityStats = new Map<
      string,
      {
        cityId: string;
        cityName: string;
        journeyCount: number;
        totalTime: number;
      }
    >();

    for (const progress of journeyProgresses) {
      const cityId = progress.journey.cityId;
      const cityName = progress.journey.city.name;
      const existing = cityStats.get(cityId);

      if (existing) {
        existing.journeyCount += 1;
        existing.totalTime += progress.timeSpentMinutes || 0;
      } else {
        cityStats.set(cityId, {
          cityId,
          cityName,
          journeyCount: 1,
          totalTime: progress.timeSpentMinutes || 0,
        });
      }
    }

    // 按月统计
    const monthlyStats = new Map<string, number>();
    for (const progress of journeyProgresses) {
      if (progress.completeTime) {
        const month = progress.completeTime.toISOString().slice(0, 7);
        monthlyStats.set(month, (monthlyStats.get(month) || 0) + 1);
      }
    }

    return {
      byCity: Array.from(cityStats.values()),
      byMonth: Array.from(monthlyStats.entries()).map(([month, count]) => ({
        month,
        count,
      })),
    };
  }
}
