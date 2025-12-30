import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { BusinessException } from '../../common/exceptions';
import { ErrorCode } from '../../common/enums';
import type {
  QueryAdminJourneyDto,
  CreateJourneyDto,
  UpdateJourneyDto,
} from './dto/admin-journey.dto';

@Injectable()
export class AdminJourneyService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: QueryAdminJourneyDto) {
    const { cityId, name, status, pageNum = 1, pageSize = 10 } = query;

    const where = {
      ...(cityId && { cityId }),
      ...(name && { name: { contains: name } }),
      ...(status && { status }),
    };

    const [list, total] = await Promise.all([
      this.prisma.journey.findMany({
        where,
        include: {
          city: { select: { id: true, name: true } },
          _count: { select: { points: true } },
        },
        orderBy: { orderNum: 'asc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.journey.count({ where }),
    ]);

    return {
      list: list.map((journey) => ({
        ...journey,
        totalDistance: Number(journey.totalDistance),
        cityName: journey.city?.name,
        pointCount: journey._count.points,
        _count: undefined,
      })),
      total,
      pageNum,
      pageSize,
    };
  }

  async findOne(id: string) {
    const journey = await this.prisma.journey.findUnique({
      where: { id },
      include: { city: { select: { id: true, name: true } } },
    });
    if (!journey) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在');
    }
    return {
      ...journey,
      totalDistance: Number(journey.totalDistance),
      cityName: journey.city?.name,
    };
  }

  async create(dto: CreateJourneyDto) {
    // 验证城市存在
    const city = await this.prisma.city.findUnique({
      where: { id: dto.cityId },
    });
    if (!city) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在');
    }
    return this.prisma.journey.create({ data: dto });
  }

  async update(id: string, dto: UpdateJourneyDto) {
    const journey = await this.prisma.journey.findUnique({ where: { id } });
    if (!journey) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在');
    }
    if (dto.cityId) {
      const city = await this.prisma.city.findUnique({
        where: { id: dto.cityId },
      });
      if (!city) {
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在');
      }
    }
    return this.prisma.journey.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    const journey = await this.prisma.journey.findUnique({ where: { id } });
    if (!journey) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在');
    }
    // 检查是否有关联的探索点
    const pointCount = await this.prisma.explorationPoint.count({
      where: { journeyId: id },
    });
    if (pointCount > 0) {
      throw new BusinessException(
        ErrorCode.OPERATION_DENIED,
        '该文化之旅下存在探索点，无法删除',
      );
    }
    await this.prisma.journey.delete({ where: { id } });
  }

  async updateStatus(id: string, status: string) {
    const journey = await this.prisma.journey.findUnique({ where: { id } });
    if (!journey) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在');
    }
    return this.prisma.journey.update({
      where: { id },
      data: { status },
    });
  }
}
