import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../prisma/prisma.service'
import { BusinessException } from '../../common/exceptions'
import { ErrorCode } from '../../common/enums'
import type { QueryProgressDto } from './dto/admin-progress.dto'
import { Prisma } from '@prisma/client'

@Injectable()
export class AdminProgressService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: QueryProgressDto) {
    const {
      userId,
      nickname,
      journeyId,
      journeyName,
      cityId,
      status,
      pageNum = 1,
      pageSize = 20,
    } = query

    const where: Prisma.JourneyProgressWhereInput = {}
    if (userId) where.userId = userId
    if (journeyId) where.journeyId = journeyId
    if (status) where.status = status
    if (nickname) {
      where.user = { nickname: { contains: nickname } }
    }
    if (journeyName) {
      where.journey = { name: { contains: journeyName } }
    }
    if (cityId) {
      where.journey = { ...(where.journey as object), cityId }
    }

    const [list, total] = await Promise.all([
      this.prisma.journeyProgress.findMany({
        where,
        orderBy: { createTime: 'desc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
        include: {
          user: {
            select: { id: true, nickname: true, avatar: true, phone: true },
          },
          journey: {
            include: {
              city: { select: { name: true } },
              points: { select: { id: true } },
            },
          },
          pointCompletions: { select: { id: true } },
        },
      }),
      this.prisma.journeyProgress.count({ where }),
    ])

    return {
      list: list.map((p) => ({
        id: p.id,
        userId: p.userId,
        nickname: p.user.nickname,
        avatar: p.user.avatar,
        phone: p.user.phone,
        journeyId: p.journeyId,
        journeyName: p.journey.name,
        cityName: p.journey.city?.name,
        status: p.status,
        startTime: p.startTime,
        completeTime: p.completeTime,
        timeSpentMinutes: p.timeSpentMinutes,
        completedPoints: p.pointCompletions.length,
        totalPoints: p.journey.points?.length || 0,
        createTime: p.createTime,
      })),
      total,
      pageNum,
      pageSize,
    }
  }

  async findOne(id: string) {
    const progress = await this.prisma.journeyProgress.findUnique({
      where: { id },
      include: {
        user: {
          select: { id: true, nickname: true, avatar: true, phone: true },
        },
        journey: {
          include: {
            city: { select: { name: true } },
            points: { orderBy: { orderNum: 'asc' } },
          },
        },
        pointCompletions: {
          include: { point: true },
          orderBy: { completeTime: 'asc' },
        },
      },
    })

    if (!progress) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '进度记录不存在')
    }

    return {
      ...progress,
      nickname: progress.user.nickname,
      avatar: progress.user.avatar,
      journeyName: progress.journey.name,
      cityName: progress.journey.city?.name,
      completedPoints: progress.pointCompletions.length,
      totalPoints: progress.journey.points.length,
    }
  }

  async getStats() {
    const [total, inProgress, completed, abandoned] = await Promise.all([
      this.prisma.journeyProgress.count(),
      this.prisma.journeyProgress.count({ where: { status: 'in_progress' } }),
      this.prisma.journeyProgress.count({ where: { status: 'completed' } }),
      this.prisma.journeyProgress.count({ where: { status: 'abandoned' } }),
    ])

    return { total, inProgress, completed, abandoned }
  }
}
