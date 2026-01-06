import { Injectable, Logger } from '@nestjs/common'
import { Prisma } from '@prisma/client'
import { PrismaService } from '../../prisma/prisma.service'
import { BusinessException } from '../../common/exceptions'
import { ErrorCode } from '../../common/enums'
import { BlockchainService } from '../../blockchain/blockchain.service'
import type { QueryUserSealDto } from './dto/admin-user-seal.dto'

@Injectable()
export class AdminUserSealService {
  private readonly logger = new Logger(AdminUserSealService.name)
  constructor(
    private prisma: PrismaService,
    private blockchainService: BlockchainService,
  ) {}

  async findAll(query: QueryUserSealDto) {
    const {
      userId,
      nickname,
      sealId,
      sealName,
      sealType,
      isChained,
      pageNum = 1,
      pageSize = 20,
    } = query

    const where: Prisma.UserSealWhereInput = {}
    if (userId) where.userId = userId
    if (sealId) where.sealId = sealId
    if (isChained !== undefined) where.isChained = isChained
    if (nickname) {
      where.user = { nickname: { contains: nickname } }
    }
    if (sealName || sealType) {
      where.seal = {
        ...(sealName && { name: { contains: sealName } }),
        ...(sealType && { type: sealType }),
      }
    }

    const [list, total] = await Promise.all([
      this.prisma.userSeal.findMany({
        where,
        orderBy: { earnedTime: 'desc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
        include: {
          user: {
            select: { id: true, nickname: true, avatar: true, phone: true },
          },
          seal: {
            select: { id: true, name: true, imageAsset: true, type: true },
          },
        },
      }),
      this.prisma.userSeal.count({ where }),
    ])

    return {
      list: list.map((us) => ({
        id: us.id,
        userId: us.userId,
        nickname: us.user.nickname,
        avatar: us.user.avatar,
        phone: us.user.phone,
        sealId: us.sealId,
        sealName: us.seal.name,
        sealImage: us.seal.imageAsset,
        sealType: us.seal.type,
        earnedTime: us.earnedTime,
        timeSpentMinutes: us.timeSpentMinutes,
        pointsEarned: us.pointsEarned,
        isChained: us.isChained,
        chainName: us.chainName,
        txHash: us.txHash,
        blockHeight: us.blockHeight?.toString(),
        chainTime: us.chainTime,
      })),
      total,
      pageNum,
      pageSize,
    }
  }

  async findOne(id: string) {
    const userSeal = await this.prisma.userSeal.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            nickname: true,
            avatar: true,
            phone: true,
            email: true,
          },
        },
        seal: true,
      },
    })

    if (!userSeal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '用户印记不存在')
    }

    return {
      ...userSeal,
      nickname: userSeal.user.nickname,
      avatar: userSeal.user.avatar,
      sealName: userSeal.seal.name,
      sealImage: userSeal.seal.imageAsset,
      sealType: userSeal.seal.type,
      blockHeight: userSeal.blockHeight?.toString(),
    }
  }

  async getStats() {
    const [total, chained, unchained] = await Promise.all([
      this.prisma.userSeal.count(),
      this.prisma.userSeal.count({ where: { isChained: true } }),
      this.prisma.userSeal.count({ where: { isChained: false } }),
    ])

    // 按印记类型统计
    const byType = await this.prisma.userSeal.groupBy({
      by: ['sealId'],
      _count: true,
    })

    // 获取印记类型信息
    const sealIds = byType.map((b) => b.sealId)
    const seals = await this.prisma.seal.findMany({
      where: { id: { in: sealIds } },
      select: { id: true, type: true },
    })

    const typeMap = new Map(seals.map((s) => [s.id, s.type]))
    const typeStats = { route: 0, city: 0, special: 0 }
    byType.forEach((b) => {
      const type = typeMap.get(b.sealId) as keyof typeof typeStats
      if (type && typeStats[type] !== undefined) {
        typeStats[type] += b._count
      }
    })

    return { total, chained, unchained, byType: typeStats }
  }

  /**
   * 手动上链
   */
  async chainSeal(id: string) {
    const userSeal = await this.prisma.userSeal.findUnique({
      where: { id },
      include: { seal: true, user: true },
    })

    if (!userSeal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '用户印记不存在')
    }

    if (userSeal.isChained) {
      throw new BusinessException(ErrorCode.DATA_ALREADY_EXISTS, '印记已上链')
    }

    // 调用区块链服务上链（使用系统配置的链服务）
    const result = await this.blockchainService.chainSeal(userSeal.userId, userSeal.sealId)

    this.logger.log(
      `管理员手动上链成功: ${id}, chain=${result.chainName}, txHash: ${result.txHash}`,
    )

    return {
      id: userSeal.id,
      sealId: userSeal.sealId,
      sealName: userSeal.seal.name,
      userId: userSeal.userId,
      nickname: userSeal.user.nickname,
      isChained: true,
      chainName: result.chainName,
      txHash: result.txHash,
      blockHeight: result.blockHeight,
      chainTime: result.chainTime,
    }
  }
}
