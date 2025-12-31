import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { BusinessException } from '../../common/exceptions';
import { ErrorCode } from '../../common/enums';
import type {
  QueryAdminSealDto,
  CreateSealDto,
  UpdateSealDto,
} from './dto/admin-seal.dto';

@Injectable()
export class AdminSealService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: QueryAdminSealDto) {
    const { type, name, status, pageNum = 1, pageSize = 20 } = query;

    const where = {
      ...(type && { type }),
      ...(name && { name: { contains: name } }),
      ...(status && { status }),
    };

    const [list, total] = await Promise.all([
      this.prisma.seal.findMany({
        where,
        include: {
          journey: { select: { id: true, name: true } },
          city: { select: { id: true, name: true } },
        },
        orderBy: { orderNum: 'asc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.seal.count({ where }),
    ]);

    return {
      list: list.map((seal) => ({
        ...seal,
        journeyName: seal.journey?.name,
        cityName: seal.city?.name,
      })),
      total,
      pageNum,
      pageSize,
    };
  }

  async findOne(id: string) {
    const seal = await this.prisma.seal.findUnique({
      where: { id },
      include: {
        journey: { select: { id: true, name: true } },
        city: { select: { id: true, name: true } },
      },
    });
    if (!seal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '印记不存在');
    }
    return {
      ...seal,
      journeyName: seal.journey?.name,
      cityName: seal.city?.name,
    };
  }

  async create(dto: CreateSealDto) {
    if (dto.journeyId) {
      const journey = await this.prisma.journey.findUnique({
        where: { id: dto.journeyId },
      });
      if (!journey) {
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在');
      }
    }
    if (dto.cityId) {
      const city = await this.prisma.city.findUnique({
        where: { id: dto.cityId },
      });
      if (!city) {
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在');
      }
    }
    return this.prisma.seal.create({ data: dto });
  }

  async update(id: string, dto: UpdateSealDto) {
    const seal = await this.prisma.seal.findUnique({ where: { id } });
    if (!seal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '印记不存在');
    }
    if (dto.journeyId) {
      const journey = await this.prisma.journey.findUnique({
        where: { id: dto.journeyId },
      });
      if (!journey) {
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在');
      }
    }
    if (dto.cityId) {
      const city = await this.prisma.city.findUnique({
        where: { id: dto.cityId },
      });
      if (!city) {
        throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '城市不存在');
      }
    }
    return this.prisma.seal.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    const seal = await this.prisma.seal.findUnique({ where: { id } });
    if (!seal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '印记不存在');
    }
    // 检查是否有用户已获得该印记
    const userSealCount = await this.prisma.userSeal.count({
      where: { sealId: id },
    });
    if (userSealCount > 0) {
      throw new BusinessException(
        ErrorCode.OPERATION_DENIED,
        '已有用户获得该印记，无法删除',
      );
    }
    await this.prisma.seal.delete({ where: { id } });
  }

  async updateStatus(id: string, status: string) {
    const seal = await this.prisma.seal.findUnique({ where: { id } });
    if (!seal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '印记不存在');
    }
    return this.prisma.seal.update({
      where: { id },
      data: { status },
    });
  }
}
