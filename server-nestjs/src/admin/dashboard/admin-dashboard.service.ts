import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../prisma/prisma.service'
import type { TrendQueryDto } from './dto/admin-dashboard.dto'

@Injectable()
export class AdminDashboardService {
  constructor(private prisma: PrismaService) {}

  async getStats() {
    const [
      totalUsers,
      totalCities,
      totalJourneys,
      totalSeals,
      totalCompletedJourneys,
      totalChainedSeals,
    ] = await Promise.all([
      this.prisma.appUser.count(),
      this.prisma.city.count({ where: { status: '0' } }),
      this.prisma.journey.count({ where: { status: '0' } }),
      this.prisma.seal.count({ where: { status: '0' } }),
      this.prisma.journeyProgress.count({ where: { status: 'completed' } }),
      this.prisma.userSeal.count({ where: { isChained: true } }),
    ])

    // 今日新增用户
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const todayNewUsers = await this.prisma.appUser.count({
      where: { createTime: { gte: today } },
    })

    // 今日完成文化之旅数
    const todayCompletedJourneys = await this.prisma.journeyProgress.count({
      where: { status: 'completed', completeTime: { gte: today } },
    })

    return {
      totalUsers,
      totalCities,
      totalJourneys,
      totalSeals,
      totalCompletedJourneys,
      totalChainedSeals,
      todayNewUsers,
      todayCompletedJourneys,
    }
  }

  async getTrends(query: TrendQueryDto) {
    const { days = 7 } = query
    const startDate = new Date()
    startDate.setDate(startDate.getDate() - days)
    startDate.setHours(0, 0, 0, 0)

    // 获取每日新增用户
    const userTrends = await this.prisma.$queryRaw<{ date: string; count: bigint }[]>`
      SELECT DATE(create_time) as date, COUNT(*) as count
      FROM app_user
      WHERE create_time >= ${startDate}
      GROUP BY DATE(create_time)
      ORDER BY date
    `

    // 获取每日完成文化之旅数
    const journeyTrends = await this.prisma.$queryRaw<{ date: string; count: bigint }[]>`
      SELECT DATE(complete_time) as date, COUNT(*) as count
      FROM journey_progress
      WHERE status = 'completed' AND complete_time >= ${startDate}
      GROUP BY DATE(complete_time)
      ORDER BY date
    `

    // 获取每日上链印记数
    const chainTrends = await this.prisma.$queryRaw<{ date: string; count: bigint }[]>`
      SELECT DATE(chain_time) as date, COUNT(*) as count
      FROM user_seal
      WHERE is_chained = true AND chain_time >= ${startDate}
      GROUP BY DATE(chain_time)
      ORDER BY date
    `

    return {
      userTrends: userTrends.map((t) => ({
        date: t.date,
        count: Number(t.count),
      })),
      journeyTrends: journeyTrends.map((t) => ({
        date: t.date,
        count: Number(t.count),
      })),
      chainTrends: chainTrends.map((t) => ({
        date: t.date,
        count: Number(t.count),
      })),
    }
  }
}
