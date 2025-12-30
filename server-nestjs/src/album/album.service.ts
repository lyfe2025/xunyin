import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { BusinessException } from '../common/exceptions';
import { ErrorCode } from '../common/enums';
import type { QueryPhotoDto, CreatePhotoDto } from './dto/photo.dto';

@Injectable()
export class AlbumService {
  constructor(private prisma: PrismaService) {}

  /**
   * 获取照片列表
   */
  async findAll(userId: string, query: QueryPhotoDto) {
    const { journeyId, startDate, endDate } = query;

    const photos = await this.prisma.explorationPhoto.findMany({
      where: {
        userId,
        ...(journeyId && { journeyId }),
        ...(startDate &&
          endDate && {
            takenTime: {
              gte: new Date(startDate),
              lte: new Date(endDate),
            },
          }),
      },
      include: {
        journey: true,
        point: true,
      },
      orderBy: { takenTime: 'desc' },
    });

    return photos.map((photo) => ({
      id: photo.id,
      journeyId: photo.journeyId,
      journeyName: photo.journey.name,
      pointId: photo.pointId,
      pointName: photo.point.name,
      photoUrl: photo.photoUrl,
      thumbnailUrl: photo.thumbnailUrl,
      filter: photo.filter,
      latitude: photo.latitude ? Number(photo.latitude) : null,
      longitude: photo.longitude ? Number(photo.longitude) : null,
      takenTime: photo.takenTime,
      createTime: photo.createTime,
    }));
  }

  /**
   * 获取相册统计
   */
  async getStats(userId: string) {
    const [totalPhotos, journeyCount, pointCount] = await Promise.all([
      this.prisma.explorationPhoto.count({ where: { userId } }),
      this.prisma.explorationPhoto.groupBy({
        by: ['journeyId'],
        where: { userId },
      }),
      this.prisma.explorationPhoto.groupBy({
        by: ['pointId'],
        where: { userId },
      }),
    ]);

    return {
      totalPhotos,
      journeyCount: journeyCount.length,
      pointCount: pointCount.length,
    };
  }

  /**
   * 获取文化之旅照片
   */
  async findByJourney(userId: string, journeyId: string) {
    const photos = await this.prisma.explorationPhoto.findMany({
      where: { userId, journeyId },
      include: {
        journey: true,
        point: true,
      },
      orderBy: { takenTime: 'desc' },
    });

    return photos.map((photo) => ({
      id: photo.id,
      journeyId: photo.journeyId,
      journeyName: photo.journey.name,
      pointId: photo.pointId,
      pointName: photo.point.name,
      photoUrl: photo.photoUrl,
      thumbnailUrl: photo.thumbnailUrl,
      filter: photo.filter,
      latitude: photo.latitude ? Number(photo.latitude) : null,
      longitude: photo.longitude ? Number(photo.longitude) : null,
      takenTime: photo.takenTime,
      createTime: photo.createTime,
    }));
  }

  /**
   * 上传照片
   */
  async create(userId: string, dto: CreatePhotoDto) {
    // 验证文化之旅和探索点存在
    const [journey, point] = await Promise.all([
      this.prisma.journey.findUnique({ where: { id: dto.journeyId } }),
      this.prisma.explorationPoint.findUnique({ where: { id: dto.pointId } }),
    ]);

    if (!journey || journey.status !== '0') {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '文化之旅不存在');
    }

    if (!point || point.status !== '0') {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '探索点不存在');
    }

    const photo = await this.prisma.explorationPhoto.create({
      data: {
        userId,
        journeyId: dto.journeyId,
        pointId: dto.pointId,
        photoUrl: dto.photoUrl,
        thumbnailUrl: dto.thumbnailUrl,
        filter: dto.filter,
        latitude: dto.latitude,
        longitude: dto.longitude,
        takenTime: new Date(dto.takenTime),
      },
      include: {
        journey: true,
        point: true,
      },
    });

    return {
      id: photo.id,
      journeyId: photo.journeyId,
      journeyName: photo.journey.name,
      pointId: photo.pointId,
      pointName: photo.point.name,
      photoUrl: photo.photoUrl,
      thumbnailUrl: photo.thumbnailUrl,
      filter: photo.filter,
      latitude: photo.latitude ? Number(photo.latitude) : null,
      longitude: photo.longitude ? Number(photo.longitude) : null,
      takenTime: photo.takenTime,
      createTime: photo.createTime,
    };
  }

  /**
   * 删除照片
   */
  async remove(userId: string, id: string) {
    const photo = await this.prisma.explorationPhoto.findUnique({
      where: { id },
    });

    if (!photo) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '照片不存在');
    }

    if (photo.userId !== userId) {
      throw new BusinessException(ErrorCode.FORBIDDEN, '无权删除该照片');
    }

    await this.prisma.explorationPhoto.delete({ where: { id } });

    return { message: '删除成功' };
  }
}
