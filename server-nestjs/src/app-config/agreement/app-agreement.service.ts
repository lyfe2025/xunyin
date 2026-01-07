import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../prisma/prisma.service'
import { BusinessException } from '../../common/exceptions'
import { ErrorCode } from '../../common/enums'

@Injectable()
export class AppAgreementService {
  constructor(private prisma: PrismaService) {}

  /**
   * 获取协议内容（公开接口）
   * @param type user_agreement | privacy_policy | about_us
   */
  async findByType(type: string) {
    const validTypes = ['user_agreement', 'privacy_policy', 'about_us']
    if (!validTypes.includes(type)) {
      throw new BusinessException(ErrorCode.INVALID_PARAMS, '无效的协议类型')
    }

    const agreement = await this.prisma.appAgreement.findUnique({
      where: { type },
      select: {
        type: true,
        title: true,
        content: true,
        version: true,
        updateTime: true,
      },
    })

    if (!agreement) {
      // 返回默认内容
      return this.getDefaultAgreement(type)
    }

    return agreement
  }

  private getDefaultAgreement(type: string) {
    const defaults: Record<string, { title: string; content: string }> = {
      user_agreement: {
        title: '用户协议',
        content: '<p>用户协议内容正在完善中...</p>',
      },
      privacy_policy: {
        title: '隐私政策',
        content: '<p>隐私政策内容正在完善中...</p>',
      },
      about_us: {
        title: '关于我们',
        content: '<p>关于我们内容正在完善中...</p>',
      },
    }

    return {
      type,
      ...defaults[type],
      version: '1.0',
      updateTime: null,
    }
  }
}
