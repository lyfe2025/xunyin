import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'
import { UpdateProfileDto } from './dto/update-profile.dto'

@Injectable()
export class AppProfileService {
  constructor(private prisma: PrismaService) {}

  /**
   * 获取用户资料
   */
  async getProfile(userId: string) {
    const user = await this.prisma.appUser.findUnique({
      where: { id: userId },
      select: {
        id: true,
        phone: true,
        email: true,
        nickname: true,
        avatar: true,
        gender: true,
        birthday: true,
        bio: true,
        loginType: true,
        badgeTitle: true,
        totalPoints: true,
        level: true,
        isVerified: true,
        createTime: true,
      },
    })

    if (!user) {
      throw new NotFoundException('用户不存在')
    }

    return user
  }

  /**
   * 更新用户资料
   */
  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const user = await this.prisma.appUser.findUnique({
      where: { id: userId },
    })

    if (!user) {
      throw new NotFoundException('用户不存在')
    }

    return this.prisma.appUser.update({
      where: { id: userId },
      data: {
        ...(dto.nickname && { nickname: dto.nickname }),
        ...(dto.avatar && { avatar: dto.avatar }),
        ...(dto.bio !== undefined && { bio: dto.bio }),
        ...(dto.gender && { gender: dto.gender }),
      },
      select: {
        id: true,
        nickname: true,
        avatar: true,
        bio: true,
        gender: true,
      },
    })
  }

  /**
   * 更新昵称
   */
  async updateNickname(userId: string, nickname: string) {
    return this.prisma.appUser.update({
      where: { id: userId },
      data: { nickname },
      select: { id: true, nickname: true },
    })
  }

  /**
   * 更新头像
   */
  async updateAvatar(userId: string, avatar: string) {
    return this.prisma.appUser.update({
      where: { id: userId },
      data: { avatar },
      select: { id: true, avatar: true },
    })
  }

  /**
   * 根据手机号查找用户
   */
  async findByPhone(phone: string) {
    return this.prisma.appUser.findFirst({
      where: { phone },
      select: { id: true, phone: true },
    })
  }

  /**
   * 更新手机号
   */
  async updatePhone(userId: string, phone: string) {
    return this.prisma.appUser.update({
      where: { id: userId },
      data: { phone },
      select: { id: true, phone: true },
    })
  }
}
