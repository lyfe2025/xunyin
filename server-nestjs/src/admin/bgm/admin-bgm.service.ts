import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { BusinessException } from '../../common/exceptions';
import { ErrorCode } from '../../common/enums';
import type {
  QueryBgmDto,
  CreateBgmDto,
  UpdateBgmDto,
} from './dto/admin-bgm.dto';

@Injectable()
export class AdminBgmService {
  constructor(private prisma: PrismaService) { }

  async findAll(query: QueryBgmDto) {
    const { name, context, status, pageNum = 1, pageSize = 20 } = query;

    const where: Prisma.BackgroundMusicWhereInput = {};
    if (name) where.name = { contains: name };
    if (context) where.context = context;
    if (status) where.status = status;

    const [list, total] = await Promise.all([
      this.prisma.backgroundMusic.findMany({
        where,
        orderBy: [{ context: 'asc' }, { orderNum: 'asc' }],
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.backgroundMusic.count({ where }),
    ]);

    // 获取关联名称
    const cityIds = list
      .filter((b) => b.context === 'city' && b.contextId)
      .map((b) => b.contextId!);
    const journeyIds = list
      .filter((b) => b.context === 'journey' && b.contextId)
      .map((b) => b.contextId!);
    const pointIds = list
      .filter((b) => b.context === 'point' && b.contextId)
      .map((b) => b.contextId!);

    const [cities, journeys, points] = await Promise.all([
      cityIds.length > 0
        ? this.prisma.city.findMany({
          where: { id: { in: cityIds } },
          select: { id: true, name: true },
        })
        : [],
      journeyIds.length > 0
        ? this.prisma.journey.findMany({
          where: { id: { in: journeyIds } },
          select: { id: true, name: true, city: { select: { name: true } } },
        })
        : [],
      pointIds.length > 0
        ? this.prisma.explorationPoint.findMany({
          where: { id: { in: pointIds } },
          select: {
            id: true,
            name: true,
            journey: {
              select: { name: true, city: { select: { name: true } } },
            },
          },
        })
        : [],
    ]);

    const cityMap = new Map(cities.map((c) => [c.id, c.name]));
    const journeyMap = new Map(
      journeys.map((j) => [j.id, { name: j.name, cityName: j.city?.name }]),
    );
    const pointMap = new Map(
      points.map((p) => [
        p.id,
        {
          name: p.name,
          journeyName: p.journey?.name,
          cityName: p.journey?.city?.name,
        },
      ]),
    );

    return {
      list: list.map((b) => {
        const journeyInfo = journeyMap.get(b.contextId!);
        const pointInfo = pointMap.get(b.contextId!);
        return {
          ...b,
          contextName:
            b.context === 'city'
              ? cityMap.get(b.contextId!) || null
              : b.context === 'journey'
                ? journeyInfo?.name || null
                : b.context === 'point'
                  ? pointInfo?.name || null
                  : null,
          contextCityName:
            b.context === 'journey'
              ? journeyInfo?.cityName || null
              : b.context === 'point'
                ? pointInfo?.cityName || null
                : null,
          contextJourneyName:
            b.context === 'point' ? pointInfo?.journeyName || null : null,
        };
      }),
      total,
      pageNum,
      pageSize,
    };
  }

  async findOne(id: string) {
    const bgm = await this.prisma.backgroundMusic.findUnique({ where: { id } });
    if (!bgm) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '背景音乐不存在');
    }

    let contextName: string | null = null;
    let contextCityName: string | null = null;

    if (bgm.context === 'city' && bgm.contextId) {
      const city = await this.prisma.city.findUnique({
        where: { id: bgm.contextId },
        select: { name: true },
      });
      contextName = city?.name || null;
    } else if (bgm.context === 'journey' && bgm.contextId) {
      const journey = await this.prisma.journey.findUnique({
        where: { id: bgm.contextId },
        select: { name: true, city: { select: { name: true } } },
      });
      contextName = journey?.name || null;
      contextCityName = journey?.city?.name || null;
    }

    return { ...bgm, contextName, contextCityName };
  }

  async create(dto: CreateBgmDto) {
    // 验证关联ID
    if (dto.context === 'city' && dto.contextId) {
      const city = await this.prisma.city.findUnique({
        where: { id: dto.contextId },
      });
      if (!city)
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在');
    } else if (dto.context === 'journey' && dto.contextId) {
      const journey = await this.prisma.journey.findUnique({
        where: { id: dto.contextId },
      });
      if (!journey)
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在');
    } else if (dto.context === 'point' && dto.contextId) {
      const point = await this.prisma.explorationPoint.findUnique({
        where: { id: dto.contextId },
      });
      if (!point)
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '探索点不存在');
    }

    return this.prisma.backgroundMusic.create({
      data: {
        name: dto.name,
        url: dto.url,
        context: dto.context,
        contextId: dto.contextId || null,
        duration: dto.duration || null,
        orderNum: dto.orderNum ?? 0,
        status: dto.status ?? '0',
      },
    });
  }

  async update(id: string, dto: UpdateBgmDto) {
    const bgm = await this.prisma.backgroundMusic.findUnique({ where: { id } });
    if (!bgm) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '背景音乐不存在');
    }

    // 验证关联ID
    const context = dto.context ?? bgm.context;
    const contextId =
      dto.contextId !== undefined ? dto.contextId : bgm.contextId;

    if (context === 'city' && contextId) {
      const city = await this.prisma.city.findUnique({
        where: { id: contextId },
      });
      if (!city)
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在');
    } else if (context === 'journey' && contextId) {
      const journey = await this.prisma.journey.findUnique({
        where: { id: contextId },
      });
      if (!journey)
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在');
    } else if (context === 'point' && contextId) {
      const point = await this.prisma.explorationPoint.findUnique({
        where: { id: contextId },
      });
      if (!point)
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '探索点不存在');
    }

    return this.prisma.backgroundMusic.update({
      where: { id },
      data: {
        name: dto.name,
        url: dto.url,
        context: dto.context,
        contextId: dto.contextId,
        duration: dto.duration,
        orderNum: dto.orderNum,
        status: dto.status,
      },
    });
  }

  async remove(id: string) {
    const bgm = await this.prisma.backgroundMusic.findUnique({ where: { id } });
    if (!bgm) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '背景音乐不存在');
    }

    await this.prisma.backgroundMusic.delete({ where: { id } });
    return { success: true };
  }

  async getStats() {
    const [total, home, city, journey, point] = await Promise.all([
      this.prisma.backgroundMusic.count(),
      this.prisma.backgroundMusic.count({ where: { context: 'home' } }),
      this.prisma.backgroundMusic.count({ where: { context: 'city' } }),
      this.prisma.backgroundMusic.count({ where: { context: 'journey' } }),
      this.prisma.backgroundMusic.count({ where: { context: 'point' } }),
    ]);

    return { total, home, city, journey, point };
  }

  async updateStatus(id: string, status: string) {
    const bgm = await this.prisma.backgroundMusic.findUnique({ where: { id } });
    if (!bgm) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '背景音乐不存在');
    }

    return this.prisma.backgroundMusic.update({
      where: { id },
      data: { status },
    });
  }

  async batchDelete(ids: string[]) {
    const result = await this.prisma.backgroundMusic.deleteMany({
      where: { id: { in: ids } },
    });
    return { deleted: result.count };
  }

  async batchUpdateStatus(ids: string[], status: string) {
    const result = await this.prisma.backgroundMusic.updateMany({
      where: { id: { in: ids } },
      data: { status },
    });
    return { updated: result.count };
  }
}
