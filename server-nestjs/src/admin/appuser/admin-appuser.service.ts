import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { BusinessException } from '../../common/exceptions';
import { ErrorCode } from '../../common/enums';
import type { QueryAppUserDto } from './dto/admin-appuser.dto';

@Injectable()
export class AdminAppUserService {
  constructor(private prisma: PrismaService) { }

  async findAll(query: QueryAppUserDto) {
    const { phone, email, nickname, loginType, status, pageNum = 1, pageSize = 10 } = query;

    const where = {
      ...(phone && { phone: { contains: phone } }),
      ...(email && { email: { contains: email } }),
      ...(nickname && { nickname: { contains: nickname } }),
      ...(loginType && { loginType }),
      ...(status && { status }),
    };

    const [list, total] = await Promise.all([
      this.prisma.appUser.findMany({
        where,
        orderBy: { createTime: 'desc' },
        skip: (pageNum - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.appUser.count({ where }),
    ]);

    return { list, total, pageNum, pageSize };
  }

  async findOne(id: string) {
    const user = await this.prisma.appUser.findUnique({ where: { id } });
    if (!user) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, 'App用户不存在');
    }
    return user;
  }

  async changeStatus(id: string, status: string) {
    const user = await this.prisma.appUser.findUnique({ where: { id } });
    if (!user) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, 'App用户不存在');
    }
    return this.prisma.appUser.update({
      where: { id },
      data: { status },
    });
  }
}
