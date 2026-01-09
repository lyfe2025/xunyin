import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaService } from '../../prisma/prisma.service'

@Injectable()
export class PublicSealService {
  constructor(private prisma: PrismaService) { }

  /**
   * 获取印记公开详情（用于分享页面）
   * 注意：这是公开 API，不需要登录，返回脱敏数据
   * 支持两种 ID：userSealId（用户印记ID）或 sealId（印记模板ID，返回最新获得者）
   */
  async findOne(id: string) {
    // 先尝试通过 userSealId 查询
    let userSeal = await this.prisma.userSeal.findUnique({
      where: { id },
      include: {
        seal: {
          include: {
            journey: true,
            city: true,
          },
        },
        user: {
          select: {
            nickname: true,
            avatar: true,
          },
        },
      },
    })

    // 如果找不到，尝试通过 sealId 查询（返回最新获得该印记的用户）
    if (!userSeal) {
      userSeal = await this.prisma.userSeal.findFirst({
        where: { sealId: id },
        orderBy: { earnedTime: 'desc' },
        include: {
          seal: {
            include: {
              journey: true,
              city: true,
            },
          },
          user: {
            select: {
              nickname: true,
              avatar: true,
            },
          },
        },
      })
    }

    if (!userSeal || userSeal.seal.status !== '0') {
      throw new NotFoundException('印记不存在或已下架')
    }

    // 脱敏处理用户昵称
    const nickname = userSeal.user.nickname
    const maskedNickname = this.maskNickname(nickname)

    return {
      id: userSeal.id,
      type: userSeal.seal.type,
      name: userSeal.seal.name,
      imageAsset: userSeal.seal.imageAsset,
      description: userSeal.seal.description,
      badgeTitle: userSeal.seal.badgeTitle,
      journeyName: userSeal.seal.journey?.name,
      cityName: userSeal.seal.city?.name,
      earnedTime: userSeal.earnedTime,
      isChained: userSeal.isChained,
      txHash: userSeal.txHash,
      chainTime: userSeal.chainTime,
      userNickname: maskedNickname,
      userAvatar: userSeal.user.avatar,
    }
  }

  /**
   * 脱敏处理昵称
   * 例如：张三 -> 张*，小明同学 -> 小**学
   */
  private maskNickname(nickname: string): string {
    if (!nickname) return '匿名用户'
    const len = nickname.length
    if (len <= 1) return nickname
    if (len === 2) return nickname[0] + '*'
    // 保留首尾字符，中间用 * 替换
    const stars = '*'.repeat(Math.min(len - 2, 3))
    return nickname[0] + stars + nickname[len - 1]
  }
}
