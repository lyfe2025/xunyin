import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { BusinessException } from '../../common/exceptions';
import { ErrorCode } from '../../common/enums';
import type {
  QueryAdminPointDto,
  CreatePointDto,
  UpdatePointDto,
} from './dto/admin-point.dto';

@Injectable()
export class AdminPointService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: QueryAdminPointDto) {
    const {
      journeyId,
      name,
      taskType,
      status,
      pageNum = 1,
      pageSize = 20,
    } = query;

    const where = {
      ...(journeyId && { journeyId }),
      ...(name && { name: { contains: name } }),
      ...(taskType && { taskType }),
      ...(status && { status }),
    };

    const [list, total] = await Promise.all([
      this.prisma.explorationPoint.findMany({
        where,
        include: {
          journey: {
            select: { id: true, name: true, city: { select: { name: true } } },
          },
          bgm: {
            select: { id: true, name: true, url: true },
          },
        },
        orderBy: { orderNum: 'asc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.explorationPoint.count({ where }),
    ]);

    return {
      list: list.map((point) => ({
        ...point,
        latitude: Number(point.latitude),
        longitude: Number(point.longitude),
        distanceFromPrev: point.distanceFromPrev
          ? Number(point.distanceFromPrev)
          : null,
        journeyName: point.journey?.name,
        cityName: point.journey?.city?.name,
        bgmName: point.bgm?.name,
        bgmUrl: point.bgm?.url,
      })),
      total,
      pageNum,
      pageSize,
    };
  }

  async findOne(id: string) {
    const point = await this.prisma.explorationPoint.findUnique({
      where: { id },
      include: {
        journey: {
          select: { id: true, name: true, city: { select: { name: true } } },
        },
        bgm: {
          select: { id: true, name: true, url: true },
        },
      },
    });
    if (!point) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '探索点不存在');
    }
    return {
      ...point,
      latitude: Number(point.latitude),
      longitude: Number(point.longitude),
      distanceFromPrev: point.distanceFromPrev
        ? Number(point.distanceFromPrev)
        : null,
      journeyName: point.journey?.name,
      cityName: point.journey?.city?.name,
      bgmName: point.bgm?.name,
      bgmUrl: point.bgm?.url,
    };
  }

  async create(dto: CreatePointDto) {
    const journey = await this.prisma.journey.findUnique({
      where: { id: dto.journeyId },
    });
    if (!journey) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在');
    }
    return this.prisma.explorationPoint.create({ data: dto });
  }

  async update(id: string, dto: UpdatePointDto) {
    const point = await this.prisma.explorationPoint.findUnique({
      where: { id },
    });
    if (!point) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '探索点不存在');
    }
    if (dto.journeyId) {
      const journey = await this.prisma.journey.findUnique({
        where: { id: dto.journeyId },
      });
      if (!journey) {
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在');
      }
    }
    return this.prisma.explorationPoint.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    const point = await this.prisma.explorationPoint.findUnique({
      where: { id },
    });
    if (!point) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '探索点不存在');
    }
    await this.prisma.explorationPoint.delete({ where: { id } });
  }

  async updateStatus(id: string, status: string) {
    const point = await this.prisma.explorationPoint.findUnique({
      where: { id },
    });
    if (!point) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '探索点不存在');
    }
    return this.prisma.explorationPoint.update({
      where: { id },
      data: { status },
    });
  }

  async batchUpdateStatus(ids: string[], status: string) {
    return this.prisma.explorationPoint.updateMany({
      where: { id: { in: ids } },
      data: { status },
    });
  }
}
