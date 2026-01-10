import { Injectable } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'
import { BusinessException } from '../common/exceptions'
import { ErrorCode } from '../common/enums'
import type { QuerySealDto } from './dto/seal.dto'
import type { UserBadgeVo } from './dto/badge.dto'

@Injectable()
export class SealService {
  constructor(private prisma: PrismaService) {}

  /**
   * 获取用户已解锁的所有称号
   */
  async getUserBadges(userId: string): Promise<UserBadgeVo[]> {
    // 获取当前用户的称号
    const user = await this.prisma.appUser.findUnique({
      where: { id: userId },
      select: { badgeTitle: true },
    })

    // 获取用户所有带称号的印记
    const userSeals = await this.prisma.userSeal.findMany({
      where: {
        userId,
        seal: {
          status: '0',
          badgeTitle: { not: null },
        },
      },
      include: {
        seal: {
          select: {
            id: true,
            name: true,
            badgeTitle: true,
            rarity: true,
          },
        },
      },
      orderBy: { earnedTime: 'desc' },
    })

    return userSeals
      .filter((us) => us.seal.badgeTitle)
      .map((us) => ({
        badgeTitle: us.seal.badgeTitle!,
        sealId: us.seal.id,
        sealName: us.seal.name,
        rarity: us.seal.rarity,
        earnedTime: us.earnedTime,
        isActive: us.seal.badgeTitle === user?.badgeTitle,
      }))
  }

  /**
   * 设置用户当前称号
   */
  async setBadgeTitle(userId: string, badgeTitle: string): Promise<void> {
    // 验证用户是否拥有该称号
    const userSeal = await this.prisma.userSeal.findFirst({
      where: {
        userId,
        seal: {
          status: '0',
          badgeTitle,
        },
      },
    })

    if (!userSeal) {
      throw new BusinessException(ErrorCode.FORBIDDEN, '您尚未解锁该称号')
    }

    await this.prisma.appUser.update({
      where: { id: userId },
      data: { badgeTitle },
    })
  }

  /**
   * 清除用户当前称号
   */
  async clearBadgeTitle(userId: string): Promise<void> {
    await this.prisma.appUser.update({
      where: { id: userId },
      data: { badgeTitle: null },
    })
  }

  /**
   * 获取用户印记列表
   */
  async findUserSeals(userId: string, query: QuerySealDto) {
    const { type } = query

    const userSeals = await this.prisma.userSeal.findMany({
      where: {
        userId,
        seal: {
          status: '0',
          ...(type && { type }),
        },
      },
      include: {
        seal: true,
      },
      orderBy: { earnedTime: 'desc' },
    })

    return userSeals.map((us) => ({
      id: us.id,
      sealId: us.sealId,
      type: us.seal.type,
      rarity: us.seal.rarity,
      name: us.seal.name,
      imageAsset: us.seal.imageAsset,
      description: us.seal.description,
      badgeTitle: us.seal.badgeTitle,
      earnedTime: us.earnedTime,
      timeSpentMinutes: us.timeSpentMinutes,
      pointsEarned: us.pointsEarned,
      isChained: us.isChained,
      txHash: us.txHash,
    }))
  }

  /**
   * 获取印记详情
   */
  async findOne(userId: string, sealId: string) {
    const seal = await this.prisma.seal.findUnique({
      where: { id: sealId },
      include: {
        journey: true,
        city: true,
      },
    })

    if (!seal || seal.status !== '0') {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '印记不存在')
    }

    // 查询用户是否拥有该印记
    const userSeal = await this.prisma.userSeal.findUnique({
      where: {
        userId_sealId: { userId, sealId },
      },
    })

    return {
      id: seal.id,
      userSealId: userSeal?.id,
      type: seal.type,
      rarity: seal.rarity,
      name: seal.name,
      imageAsset: seal.imageAsset,
      description: seal.description,
      unlockCondition: seal.unlockCondition,
      badgeTitle: seal.badgeTitle,
      journeyId: seal.journeyId,
      journeyName: seal.journey?.name,
      cityId: seal.cityId,
      cityName: seal.city?.name,
      owned: !!userSeal,
      earnedTime: userSeal?.earnedTime,
      timeSpentMinutes: userSeal?.timeSpentMinutes,
      pointsEarned: userSeal?.pointsEarned,
      isChained: userSeal?.isChained,
      txHash: userSeal?.txHash,
      chainTime: userSeal?.chainTime,
    }
  }

  /**
   * 获取印记收集进度
   */
  async getProgress(userId: string) {
    // 获取所有可收集印记数量（按类型）
    const allSeals = await this.prisma.seal.groupBy({
      by: ['type'],
      where: { status: '0' },
      _count: { id: true },
    })

    // 获取用户已收集印记数量（按类型）
    const userSeals = await this.prisma.userSeal.findMany({
      where: { userId },
      include: { seal: true },
    })

    const userSealsByType = userSeals.reduce(
      (acc, us) => {
        const type = us.seal.type
        acc[type] = (acc[type] || 0) + 1
        return acc
      },
      {} as Record<string, number>,
    )

    const progress = allSeals.map((s) => ({
      type: s.type,
      total: s._count.id,
      collected: userSealsByType[s.type] || 0,
    }))

    const totalSeals = allSeals.reduce((sum, s) => sum + s._count.id, 0)
    const collectedSeals = userSeals.length

    return {
      total: totalSeals,
      collected: collectedSeals,
      percentage: totalSeals > 0 ? Math.round((collectedSeals / totalSeals) * 100) : 0,
      byType: progress,
    }
  }

  /**
   * 获取所有可收集印记（含锁定状态）
   */
  async findAvailable(userId: string, query: QuerySealDto) {
    const { type } = query

    const seals = await this.prisma.seal.findMany({
      where: {
        status: '0',
        ...(type && { type }),
      },
      include: {
        journey: true,
        city: true,
      },
      orderBy: { orderNum: 'asc' },
    })

    // 获取用户已拥有的印记（包含获得时间）
    const userSeals = await this.prisma.userSeal.findMany({
      where: { userId },
      select: { sealId: true, earnedTime: true },
    })
    const userSealMap = new Map(userSeals.map((us) => [us.sealId, us.earnedTime]))

    return seals.map((seal) => ({
      id: seal.id,
      type: seal.type,
      rarity: seal.rarity,
      name: seal.name,
      imageAsset: seal.imageAsset,
      description: seal.description,
      unlockCondition: seal.unlockCondition,
      badgeTitle: seal.badgeTitle,
      journeyId: seal.journeyId,
      journeyName: seal.journey?.name,
      cityId: seal.cityId,
      cityName: seal.city?.name,
      owned: userSealMap.has(seal.id),
      earnedTime: userSealMap.get(seal.id) ?? null,
    }))
  }
}
