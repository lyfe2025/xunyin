import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { BusinessException } from '../../common/exceptions';
import { ErrorCode } from '../../common/enums';
import type {
  QueryAdminCityDto,
  CreateCityDto,
  UpdateCityDto,
} from './dto/admin-city.dto';

@Injectable()
export class AdminCityService {
  constructor(private prisma: PrismaService) { }

  async findAll(query: QueryAdminCityDto) {
    const { name, province, status, pageNum = 1, pageSize = 20 } = query;

    const where = {
      ...(name && { name: { contains: name } }),
      ...(province && { province: { contains: province } }),
      ...(status && { status }),
    };

    const [list, total] = await Promise.all([
      this.prisma.city.findMany({
        where,
        orderBy: { orderNum: 'asc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
        include: {
          _count: {
            select: { journeys: true },
          },
        },
      }),
      this.prisma.city.count({ where }),
    ]);

    return {
      list: list.map((city) => ({
        ...city,
        latitude: Number(city.latitude),
        longitude: Number(city.longitude),
        journeyCount: city._count.journeys,
        _count: undefined,
      })),
      total,
      pageNum,
      pageSize,
    };
  }

  async findOne(id: string) {
    const city = await this.prisma.city.findUnique({ where: { id } });
    if (!city) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在');
    }
    return {
      ...city,
      latitude: Number(city.latitude),
      longitude: Number(city.longitude),
    };
  }

  async create(dto: CreateCityDto) {
    return this.prisma.city.create({
      data: dto,
    });
  }

  async update(id: string, dto: UpdateCityDto) {
    const city = await this.prisma.city.findUnique({ where: { id } });
    if (!city) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在');
    }
    return this.prisma.city.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: string) {
    const city = await this.prisma.city.findUnique({ where: { id } });
    if (!city) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在');
    }
    // 检查是否有关联的文化之旅
    const journeyCount = await this.prisma.journey.count({
      where: { cityId: id },
    });
    if (journeyCount > 0) {
      throw new BusinessException(
        ErrorCode.OPERATION_DENIED,
        '该城市下存在文化之旅，无法删除',
      );
    }
    await this.prisma.city.delete({ where: { id } });
  }

  async updateStatus(id: string, status: string) {
    const city = await this.prisma.city.findUnique({ where: { id } });
    if (!city) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在');
    }
    return this.prisma.city.update({
      where: { id },
      data: { status },
    });
  }

  async batchDelete(ids: string[]) {
    // 检查是否有关联的文化之旅
    const journeyCount = await this.prisma.journey.count({
      where: { cityId: { in: ids } },
    });
    if (journeyCount > 0) {
      throw new BusinessException(
        ErrorCode.OPERATION_DENIED,
        '选中的城市下存在文化之旅，无法删除',
      );
    }
    const result = await this.prisma.city.deleteMany({
      where: { id: { in: ids } },
    });
    return { deleted: result.count };
  }

  async batchUpdateStatus(ids: string[], status: string) {
    const result = await this.prisma.city.updateMany({
      where: { id: { in: ids } },
      data: { status },
    });
    return { updated: result.count };
  }
}
