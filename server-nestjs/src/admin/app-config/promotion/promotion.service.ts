import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../prisma/prisma.service'
import { BusinessException } from '../../../common/exceptions'
import { ErrorCode } from '../../../common/enums'
import type {
  QueryChannelDto,
  CreateChannelDto,
  UpdateChannelDto,
  QueryStatsDto,
} from './dto/promotion.dto'

@Injectable()
export class PromotionService {
  constructor(private prisma: PrismaService) {}

  // ========== 渠道管理 ==========

  async findAllChannels(query: QueryChannelDto) {
    const { channelName, channelType, status, pageNum = 1, pageSize = 10 } = query

    const where = {
      ...(channelName && { channelName: { contains: channelName } }),
      ...(channelType && { channelType }),
      ...(status && { status }),
    }

    const [list, total] = await Promise.all([
      this.prisma.appPromotionChannel.findMany({
        where,
        orderBy: { createTime: 'desc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.appPromotionChannel.count({ where }),
    ])

    return { list, total, pageNum, pageSize }
  }

  async findOneChannel(id: string) {
    const channel = await this.prisma.appPromotionChannel.findUnique({ where: { id } })
    if (!channel) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '推广渠道不存在')
    }
    return channel
  }

  async createChannel(dto: CreateChannelDto, createBy?: string) {
    // 检查渠道编码是否已存在
    const existing = await this.prisma.appPromotionChannel.findUnique({
      where: { channelCode: dto.channelCode },
    })
    if (existing) {
      throw new BusinessException(ErrorCode.DATA_ALREADY_EXISTS, '渠道编码已存在')
    }

    return this.prisma.appPromotionChannel.create({
      data: { ...dto, createBy },
    })
  }

  async updateChannel(id: string, dto: UpdateChannelDto, updateBy?: string) {
    const channel = await this.prisma.appPromotionChannel.findUnique({ where: { id } })
    if (!channel) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '推广渠道不存在')
    }

    return this.prisma.appPromotionChannel.update({
      where: { id },
      data: { ...dto, updateBy },
    })
  }

  async removeChannel(id: string) {
    const channel = await this.prisma.appPromotionChannel.findUnique({ where: { id } })
    if (!channel) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '推广渠道不存在')
    }

    // 删除关联的统计数据
    await this.prisma.appPromotionStats.deleteMany({ where: { channelId: id } })
    await this.prisma.appPromotionChannel.delete({ where: { id } })
  }

  async batchDeleteChannels(ids: string[]) {
    // 删除关联的统计数据
    await this.prisma.appPromotionStats.deleteMany({
      where: { channelId: { in: ids } },
    })
    const result = await this.prisma.appPromotionChannel.deleteMany({
      where: { id: { in: ids } },
    })
    return { deleted: result.count }
  }

  // ========== 统计数据 ==========

  async findStats(query: QueryStatsDto) {
    const { channelId, startDate, endDate, pageNum = 1, pageSize = 10 } = query

    const where: any = {}
    if (channelId) where.channelId = channelId
    if (startDate || endDate) {
      where.statDate = {}
      if (startDate) where.statDate.gte = new Date(startDate)
      if (endDate) where.statDate.lte = new Date(endDate)
    }

    const [list, total] = await Promise.all([
      this.prisma.appPromotionStats.findMany({
        where,
        orderBy: { statDate: 'desc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
        include: {
          channel: {
            select: { channelCode: true, channelName: true },
          },
        },
      }),
      this.prisma.appPromotionStats.count({ where }),
    ])

    return { list, total, pageNum, pageSize }
  }

  async getStatsSummary(query: QueryStatsDto) {
    const { channelId, startDate, endDate } = query

    const where: any = {}
    if (channelId) where.channelId = channelId
    if (startDate || endDate) {
      where.statDate = {}
      if (startDate) where.statDate.gte = new Date(startDate)
      if (endDate) where.statDate.lte = new Date(endDate)
    }

    const result = await this.prisma.appPromotionStats.aggregate({
      where,
      _sum: {
        pageViews: true,
        downloadClicks: true,
        installCount: true,
        registerCount: true,
        activeCount: true,
      },
    })

    return {
      totalPageViews: result._sum.pageViews || 0,
      totalDownloadClicks: result._sum.downloadClicks || 0,
      totalInstallCount: result._sum.installCount || 0,
      totalRegisterCount: result._sum.registerCount || 0,
      totalActiveCount: result._sum.activeCount || 0,
    }
  }

  async getChannelRanking(query: QueryStatsDto) {
    const { startDate, endDate } = query

    const where: any = {}
    if (startDate || endDate) {
      where.statDate = {}
      if (startDate) where.statDate.gte = new Date(startDate)
      if (endDate) where.statDate.lte = new Date(endDate)
    }

    const result = await this.prisma.appPromotionStats.groupBy({
      by: ['channelId'],
      where,
      _sum: {
        pageViews: true,
        downloadClicks: true,
        installCount: true,
        registerCount: true,
      },
      orderBy: {
        _sum: { installCount: 'desc' },
      },
      take: 10,
    })

    // 获取渠道信息
    const channelIds = result.map((r) => r.channelId)
    const channels = await this.prisma.appPromotionChannel.findMany({
      where: { id: { in: channelIds } },
      select: { id: true, channelCode: true, channelName: true },
    })
    const channelMap = new Map(channels.map((c) => [c.id, c]))

    return result.map((r) => ({
      channel: channelMap.get(r.channelId),
      pageViews: r._sum.pageViews || 0,
      downloadClicks: r._sum.downloadClicks || 0,
      installCount: r._sum.installCount || 0,
      registerCount: r._sum.registerCount || 0,
    }))
  }
}
