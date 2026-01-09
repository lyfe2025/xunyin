import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../prisma/prisma.service'
import { BusinessException } from '../../common/exceptions'
import { ErrorCode } from '../../common/enums'
import type { QueryAdminSealDto, CreateSealDto, UpdateSealDto } from './dto/admin-seal.dto'

@Injectable()
export class AdminSealService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: QueryAdminSealDto) {
    const { type, rarity, name, status, pageNum = 1, pageSize = 20 } = query

    const where = {
      ...(type && { type }),
      ...(rarity && { rarity }),
      ...(name && { name: { contains: name } }),
      ...(status && { status }),
    }

    const [list, total] = await Promise.all([
      this.prisma.seal.findMany({
        where,
        include: {
          journey: { select: { id: true, name: true } },
          city: { select: { id: true, name: true } },
          _count: { select: { userSeals: true } },
        },
        orderBy: { orderNum: 'asc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.seal.count({ where }),
    ])

    return {
      list: list.map((seal) => ({
        ...seal,
        journeyName: seal.journey?.name,
        cityName: seal.city?.name,
        collectedCount: seal._count.userSeals,
      })),
      total,
      pageNum,
      pageSize,
    }
  }

  async getStats() {
    const [total, byType, byRarity, byStatus, topCollected] = await Promise.all([
      // 总数
      this.prisma.seal.count(),
      // 按类型统计
      this.prisma.seal.groupBy({
        by: ['type'],
        _count: { id: true },
      }),
      // 按稀有度统计
      this.prisma.seal.groupBy({
        by: ['rarity'],
        _count: { id: true },
      }),
      // 按状态统计
      this.prisma.seal.groupBy({
        by: ['status'],
        _count: { id: true },
      }),
      // 收集人数最多的印记
      this.prisma.seal.findMany({
        include: {
          _count: { select: { userSeals: true } },
        },
        orderBy: {
          userSeals: { _count: 'desc' },
        },
        take: 5,
      }),
    ])

    const typeStats = { route: 0, city: 0, special: 0 }
    byType.forEach((item) => {
      if (item.type in typeStats) {
        typeStats[item.type as keyof typeof typeStats] = item._count.id
      }
    })

    const rarityStats = { common: 0, rare: 0, legendary: 0 }
    byRarity.forEach((item) => {
      if (item.rarity in rarityStats) {
        rarityStats[item.rarity as keyof typeof rarityStats] = item._count.id
      }
    })

    const statusStats = { enabled: 0, disabled: 0 }
    byStatus.forEach((item) => {
      if (item.status === '0') statusStats.enabled = item._count.id
      else if (item.status === '1') statusStats.disabled = item._count.id
    })

    return {
      total,
      byType: typeStats,
      byRarity: rarityStats,
      byStatus: statusStats,
      topCollected: topCollected.map((seal) => ({
        id: seal.id,
        name: seal.name,
        type: seal.type,
        rarity: seal.rarity,
        imageAsset: seal.imageAsset,
        collectedCount: seal._count.userSeals,
      })),
    }
  }

  async findOne(id: string) {
    const seal = await this.prisma.seal.findUnique({
      where: { id },
      include: {
        journey: { select: { id: true, name: true } },
        city: { select: { id: true, name: true } },
      },
    })
    if (!seal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '印记不存在')
    }
    return {
      ...seal,
      journeyName: seal.journey?.name,
      cityName: seal.city?.name,
    }
  }

  async create(dto: CreateSealDto) {
    if (dto.journeyId) {
      const journey = await this.prisma.journey.findUnique({
        where: { id: dto.journeyId },
      })
      if (!journey) {
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在')
      }
    }
    if (dto.cityId) {
      const city = await this.prisma.city.findUnique({
        where: { id: dto.cityId },
      })
      if (!city) {
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在')
      }
    }
    return this.prisma.seal.create({ data: dto })
  }

  async update(id: string, dto: UpdateSealDto) {
    const seal = await this.prisma.seal.findUnique({ where: { id } })
    if (!seal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '印记不存在')
    }
    if (dto.journeyId) {
      const journey = await this.prisma.journey.findUnique({
        where: { id: dto.journeyId },
      })
      if (!journey) {
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在')
      }
    }
    if (dto.cityId) {
      const city = await this.prisma.city.findUnique({
        where: { id: dto.cityId },
      })
      if (!city) {
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在')
      }
    }
    return this.prisma.seal.update({ where: { id }, data: dto })
  }

  async remove(id: string) {
    const seal = await this.prisma.seal.findUnique({ where: { id } })
    if (!seal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '印记不存在')
    }
    // 检查是否有用户已获得该印记
    const userSealCount = await this.prisma.userSeal.count({
      where: { sealId: id },
    })
    if (userSealCount > 0) {
      throw new BusinessException(ErrorCode.OPERATION_DENIED, '已有用户获得该印记，无法删除')
    }
    await this.prisma.seal.delete({ where: { id } })
  }

  async updateStatus(id: string, status: string) {
    const seal = await this.prisma.seal.findUnique({ where: { id } })
    if (!seal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '印记不存在')
    }
    return this.prisma.seal.update({
      where: { id },
      data: { status },
    })
  }

  async batchDelete(ids: string[]) {
    // 检查是否有用户已获得这些印记
    const userSealCount = await this.prisma.userSeal.count({
      where: { sealId: { in: ids } },
    })
    if (userSealCount > 0) {
      throw new BusinessException(ErrorCode.OPERATION_DENIED, '选中的印记已有用户获得，无法删除')
    }
    const result = await this.prisma.seal.deleteMany({
      where: { id: { in: ids } },
    })
    return { deleted: result.count }
  }

  async batchUpdateStatus(ids: string[], status: string) {
    const result = await this.prisma.seal.updateMany({
      where: { id: { in: ids } },
      data: { status },
    })
    return { updated: result.count }
  }
}
