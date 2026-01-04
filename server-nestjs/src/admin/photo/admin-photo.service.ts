import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { BusinessException } from '../../common/exceptions';
import { ErrorCode } from '../../common/enums';
import type { QueryPhotoDto } from './dto/admin-photo.dto';

@Injectable()
export class AdminPhotoService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: QueryPhotoDto) {
    const {
      userId,
      nickname,
      journeyId,
      pointId,
      cityId,
      filter,
      startDate,
      endDate,
      pageNum = 1,
      pageSize = 20,
    } = query;

    const where: Prisma.ExplorationPhotoWhereInput = {};

    if (userId) where.userId = userId;
    if (journeyId) where.journeyId = journeyId;
    if (pointId) where.pointId = pointId;
    if (filter) where.filter = filter;

    // 按用户昵称模糊搜索
    if (nickname) {
      where.user = { nickname: { contains: nickname } };
    }

    // 按城市筛选（通过 journey 关联）
    if (cityId) {
      where.journey = { cityId };
    }

    // 时间范围筛选
    if (startDate || endDate) {
      where.takenTime = {};
      if (startDate) where.takenTime.gte = new Date(startDate);
      if (endDate) where.takenTime.lte = new Date(endDate + 'T23:59:59');
    }

    const [list, total] = await Promise.all([
      this.prisma.explorationPhoto.findMany({
        where,
        orderBy: { createTime: 'desc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
        include: {
          user: {
            select: { id: true, nickname: true, avatar: true, phone: true },
          },
          journey: {
            select: {
              id: true,
              name: true,
              cityId: true,
              city: { select: { name: true } },
            },
          },
          point: {
            select: { id: true, name: true },
          },
        },
      }),
      this.prisma.explorationPhoto.count({ where }),
    ]);

    return { list, total, pageNum, pageSize };
  }

  async findOne(id: string) {
    const photo = await this.prisma.explorationPhoto.findUnique({
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
        journey: {
          select: {
            id: true,
            name: true,
            cityId: true,
            city: { select: { name: true } },
          },
        },
        point: {
          select: { id: true, name: true, latitude: true, longitude: true },
        },
      },
    });

    if (!photo) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '照片不存在');
    }

    return photo;
  }

  async remove(id: string) {
    const photo = await this.prisma.explorationPhoto.findUnique({
      where: { id },
    });
    if (!photo) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '照片不存在');
    }

    await this.prisma.explorationPhoto.delete({ where: { id } });
    return { success: true };
  }

  async getStats() {
    const now = new Date();
    const todayStart = new Date(now.setHours(0, 0, 0, 0));
    const weekStart = new Date(now);
    weekStart.setDate(weekStart.getDate() - 7);

    const [totalPhotos, todayPhotos, weekPhotos, activeUsers] =
      await Promise.all([
        this.prisma.explorationPhoto.count(),
        this.prisma.explorationPhoto.count({
          where: {
            createTime: {
              gte: todayStart,
            },
          },
        }),
        this.prisma.explorationPhoto.count({
          where: {
            createTime: {
              gte: weekStart,
            },
          },
        }),
        this.prisma.explorationPhoto.groupBy({
          by: ['userId'],
          _count: true,
        }),
      ]);

    return {
      totalPhotos,
      todayPhotos,
      weekPhotos,
      activeUsers: activeUsers.length,
    };
  }
}
