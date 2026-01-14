import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../prisma/prisma.service'
import { BusinessException } from '../../../common/exceptions'
import { ErrorCode } from '../../../common/enums'
import type { QuerySplashDto, CreateSplashDto, UpdateSplashDto } from './dto/splash.dto'

@Injectable()
export class SplashService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: QuerySplashDto) {
    const { title, mode, platform, status, pageNum = 1, pageSize = 10 } = query

    const where = {
      ...(title && { title: { contains: title } }),
      ...(mode && { mode }),
      ...(platform && { platform }),
      ...(status && { status }),
    }

    const [list, total] = await Promise.all([
      this.prisma.appSplashConfig.findMany({
        where,
        orderBy: { orderNum: 'asc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.appSplashConfig.count({ where }),
    ])

    return { list, total, pageNum, pageSize }
  }

  async findOne(id: string) {
    const splash = await this.prisma.appSplashConfig.findUnique({ where: { id } })
    if (!splash) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '启动页配置不存在')
    }
    return splash
  }

  async create(dto: CreateSplashDto, createBy?: string) {
    return this.prisma.appSplashConfig.create({
      data: {
        ...dto,
        startTime: dto.startTime ? new Date(dto.startTime) : null,
        endTime: dto.endTime ? new Date(dto.endTime) : null,
        createBy,
      },
    })
  }

  async update(id: string, dto: UpdateSplashDto, updateBy?: string) {
    const splash = await this.prisma.appSplashConfig.findUnique({ where: { id } })
    if (!splash) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '启动页配置不存在')
    }
    return this.prisma.appSplashConfig.update({
      where: { id },
      data: {
        ...dto,
        startTime: dto.startTime ? new Date(dto.startTime) : undefined,
        endTime: dto.endTime ? new Date(dto.endTime) : undefined,
        updateBy,
      },
    })
  }

  async updateStatus(id: string, status: string, updateBy?: string) {
    const splash = await this.prisma.appSplashConfig.findUnique({ where: { id } })
    if (!splash) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '启动页配置不存在')
    }
    return this.prisma.appSplashConfig.update({
      where: { id },
      data: { status, updateBy },
    })
  }

  async remove(id: string) {
    const splash = await this.prisma.appSplashConfig.findUnique({ where: { id } })
    if (!splash) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '启动页配置不存在')
    }
    await this.prisma.appSplashConfig.delete({ where: { id } })
  }

  async batchDelete(ids: string[]) {
    const result = await this.prisma.appSplashConfig.deleteMany({
      where: { id: { in: ids } },
    })
    return { deleted: result.count }
  }
}
