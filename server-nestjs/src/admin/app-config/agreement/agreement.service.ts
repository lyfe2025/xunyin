import { Injectable } from '@nestjs/common'
import { PrismaService } from '../../../prisma/prisma.service'
import { BusinessException } from '../../../common/exceptions'
import { ErrorCode } from '../../../common/enums'
import type { UpdateAgreementDto } from './dto/agreement.dto'

@Injectable()
export class AgreementService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.appAgreement.findMany({
      orderBy: { type: 'asc' },
    })
  }

  async findByType(type: string) {
    let agreement = await this.prisma.appAgreement.findUnique({
      where: { type },
    })

    // 如果不存在，创建默认内容
    if (!agreement) {
      const defaultData = this.getDefaultAgreement(type)
      agreement = await this.prisma.appAgreement.create({
        data: defaultData,
      })
    }

    return agreement
  }

  async update(type: string, dto: UpdateAgreementDto, updateBy?: string) {
    const existing = await this.prisma.appAgreement.findUnique({
      where: { type },
    })

    if (existing) {
      return this.prisma.appAgreement.update({
        where: { type },
        data: { ...dto, updateBy },
      })
    }

    // 不存在则创建
    const defaultData = this.getDefaultAgreement(type)
    return this.prisma.appAgreement.create({
      data: {
        ...defaultData,
        ...dto,
        createBy: updateBy,
      },
    })
  }

  private getDefaultAgreement(type: string) {
    const defaults: Record<string, { title: string; content: string }> = {
      user_agreement: {
        title: '用户协议',
        content: '<p>请在此处编辑用户协议内容...</p>',
      },
      privacy_policy: {
        title: '隐私政策',
        content: '<p>请在此处编辑隐私政策内容...</p>',
      },
      about_us: {
        title: '关于我们',
        content: '<p>请在此处编辑关于我们内容...</p>',
      },
    }

    if (!defaults[type]) {
      throw new BusinessException(ErrorCode.INVALID_PARAMS, '无效的协议类型')
    }

    return {
      type,
      ...defaults[type],
      version: '1.0',
    }
  }
}
