import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../prisma/prisma.service'
import { BusinessException } from '../../../common/exceptions'
import { ErrorCode } from '../../../common/enums'
import type { QueryVersionDto, CreateVersionDto, UpdateVersionDto } from './dto/version.dto'

@Injectable()
export class VersionService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: QueryVersionDto) {
    const { platform, status, pageNum = 1, pageSize = 10 } = query

    const where = {
      ...(platform && { platform }),
      ...(status && { status }),
    }

    const [list, total] = await Promise.all([
      this.prisma.appVersion.findMany({
        where,
        orderBy: { createTime: 'desc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.appVersion.count({ where }),
    ])

    return { list, total, pageNum, pageSize }
  }

  async findOne(id: string) {
    const version = await this.prisma.appVersion.findUnique({ where: { id } })
    if (!version) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '版本不存在')
    }
    return version
  }

  async findLatest(platform: string) {
    const version = await this.prisma.appVersion.findFirst({
      where: { platform, status: '0' },
      orderBy: { createTime: 'desc' },
    })
    return version
  }

  async create(dto: CreateVersionDto, createBy?: string) {
    return this.prisma.appVersion.create({
      data: {
        ...dto,
        publishTime: dto.publishTime ? new Date(dto.publishTime) : null,
        createBy,
      },
    })
  }

  async update(id: string, dto: UpdateVersionDto, updateBy?: string) {
    const version = await this.prisma.appVersion.findUnique({ where: { id } })
    if (!version) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '版本不存在')
    }

    return this.prisma.appVersion.update({
      where: { id },
      data: {
        ...dto,
        publishTime: dto.publishTime ? new Date(dto.publishTime) : undefined,
        updateBy,
      },
    })
  }

  async updateStatus(id: string, status: string, updateBy?: string) {
    const version = await this.prisma.appVersion.findUnique({ where: { id } })
    if (!version) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '版本不存在')
    }
    return this.prisma.appVersion.update({
      where: { id },
      data: { status, updateBy },
    })
  }

  async remove(id: string) {
    const version = await this.prisma.appVersion.findUnique({ where: { id } })
    if (!version) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '版本不存在')
    }
    await this.prisma.appVersion.delete({ where: { id } })
  }

  async batchDelete(ids: string[]) {
    const result = await this.prisma.appVersion.deleteMany({
      where: { id: { in: ids } },
    })
    return { deleted: result.count }
  }
}
