import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../prisma/prisma.service'
import { BusinessException } from '../../common/exceptions'
import { ErrorCode } from '../../common/enums'
import type {
  QueryAppUserDto,
  QueryVerificationDto,
  AuditVerificationDto,
} from './dto/admin-appuser.dto'

@Injectable()
export class AdminAppUserService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: QueryAppUserDto) {
    const {
      phone,
      email,
      nickname,
      loginType,
      isVerified,
      status,
      pageNum = 1,
      pageSize = 20,
    } = query

    const where = {
      ...(phone && { phone: { contains: phone } }),
      ...(email && { email: { contains: email } }),
      ...(nickname && { nickname: { contains: nickname } }),
      ...(loginType && { loginType }),
      ...(isVerified !== undefined && { isVerified }),
      ...(status && { status }),
    }

    const [list, total] = await Promise.all([
      this.prisma.appUser.findMany({
        where,
        orderBy: { createTime: 'desc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
        include: {
          verification: {
            select: { status: true, realName: true, verifiedAt: true },
          },
        },
      }),
      this.prisma.appUser.count({ where }),
    ])

    return { list, total, pageNum, pageSize }
  }

  async findOne(id: string) {
    const user = await this.prisma.appUser.findUnique({
      where: { id },
      include: {
        verification: true,
      },
    })
    if (!user) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, 'App用户不存在')
    }
    return user
  }

  async changeStatus(id: string, status: string) {
    const user = await this.prisma.appUser.findUnique({ where: { id } })
    if (!user) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, 'App用户不存在')
    }
    return this.prisma.appUser.update({
      where: { id },
      data: { status },
    })
  }

  // ========== 实名认证管理 ==========

  async findVerifications(query: QueryVerificationDto) {
    const { userId, realName, status, pageNum = 1, pageSize = 20 } = query

    const where = {
      ...(userId && { userId }),
      ...(realName && { realName: { contains: realName } }),
      ...(status && { status }),
    }

    const [list, total] = await Promise.all([
      this.prisma.userVerification.findMany({
        where,
        orderBy: { createTime: 'desc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
        include: {
          user: {
            select: { id: true, nickname: true, avatar: true, phone: true },
          },
        },
      }),
      this.prisma.userVerification.count({ where }),
    ])

    return { list, total, pageNum, pageSize }
  }

  async findVerification(id: string) {
    const verification = await this.prisma.userVerification.findUnique({
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
      },
    })
    if (!verification) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '认证记录不存在')
    }
    return verification
  }

  async auditVerification(id: string, dto: AuditVerificationDto) {
    const verification = await this.prisma.userVerification.findUnique({
      where: { id },
    })
    if (!verification) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '认证记录不存在')
    }
    if (verification.status !== 'pending') {
      throw new BusinessException(ErrorCode.INVALID_PARAMS, '该认证已审核')
    }
    if (dto.status === 'rejected' && !dto.rejectReason) {
      throw new BusinessException(ErrorCode.INVALID_PARAMS, '拒绝时必须填写原因')
    }

    // 使用事务更新认证状态和用户实名标记
    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.userVerification.update({
        where: { id },
        data: {
          status: dto.status,
          rejectReason: dto.status === 'rejected' ? dto.rejectReason : null,
          verifiedAt: dto.status === 'approved' ? new Date() : null,
        },
      })

      // 如果通过，更新用户的实名状态
      if (dto.status === 'approved') {
        await tx.appUser.update({
          where: { id: verification.userId },
          data: { isVerified: true },
        })
      }

      return updated
    })
  }

  // ========== 统计接口 ==========

  async getAppUserStats() {
    const [total, verified, unverified, active, disabled] = await Promise.all([
      this.prisma.appUser.count(),
      this.prisma.appUser.count({ where: { isVerified: true } }),
      this.prisma.appUser.count({ where: { isVerified: false } }),
      this.prisma.appUser.count({ where: { status: '0' } }),
      this.prisma.appUser.count({ where: { status: '1' } }),
    ])
    return { total, verified, unverified, active, disabled }
  }

  async getVerificationStats() {
    const [total, pending, approved, rejected] = await Promise.all([
      this.prisma.userVerification.count(),
      this.prisma.userVerification.count({ where: { status: 'pending' } }),
      this.prisma.userVerification.count({ where: { status: 'approved' } }),
      this.prisma.userVerification.count({ where: { status: 'rejected' } }),
    ])
    return { total, pending, approved, rejected }
  }

  // ========== 批量审核 ==========

  async batchAuditVerifications(dto: {
    ids: string[]
    status: 'approved' | 'rejected'
    rejectReason?: string
  }) {
    if (dto.status === 'rejected' && !dto.rejectReason) {
      throw new BusinessException(ErrorCode.INVALID_PARAMS, '拒绝时必须填写原因')
    }

    // 查找所有待审核的记录
    const verifications = await this.prisma.userVerification.findMany({
      where: {
        id: { in: dto.ids },
        status: 'pending',
      },
    })

    if (verifications.length === 0) {
      throw new BusinessException(ErrorCode.INVALID_PARAMS, '没有可审核的记录')
    }

    // 使用事务批量更新
    return this.prisma.$transaction(async (tx) => {
      // 更新认证状态
      await tx.userVerification.updateMany({
        where: {
          id: { in: verifications.map((v) => v.id) },
        },
        data: {
          status: dto.status,
          rejectReason: dto.status === 'rejected' ? dto.rejectReason : null,
          verifiedAt: dto.status === 'approved' ? new Date() : null,
        },
      })

      // 如果通过，批量更新用户的实名状态
      if (dto.status === 'approved') {
        await tx.appUser.updateMany({
          where: {
            id: { in: verifications.map((v) => v.userId) },
          },
          data: { isVerified: true },
        })
      }

      return { count: verifications.length }
    })
  }
}
