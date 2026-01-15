import { Injectable, Logger } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'
import { BusinessException } from '../common/exceptions'
import { ErrorCode } from '../common/enums'
import type { ChainProvider } from './interfaces/chain-provider.interface'
import { BlockchainConfigService } from './blockchain-config.service'
import {
  LocalChainProvider,
  AntChainProvider,
  BSNChainProvider,
  PolygonProvider,
  TimestampProvider,
  ZhixinChainProvider,
} from './providers'
import type { Prisma } from '@prisma/client'

@Injectable()
export class BlockchainService {
  private readonly logger = new Logger(BlockchainService.name)

  constructor(
    private prisma: PrismaService,
    private configService: BlockchainConfigService,
    private localChain: LocalChainProvider,
    private antChain: AntChainProvider,
    private bsnChain: BSNChainProvider,
    private polygonChain: PolygonProvider,
    private timestampChain: TimestampProvider,
    private zhixinChain: ZhixinChainProvider,
  ) { }

  /**
   * 动态获取链服务提供者
   */
  private async getChainProvider(): Promise<ChainProvider> {
    const provider = await this.configService.getProvider()
    switch (provider) {
      case 'antchain':
        return this.antChain
      case 'bsn':
        return this.bsnChain
      case 'polygon':
        return this.polygonChain
      case 'timestamp':
        return this.timestampChain
      case 'zhixin':
        return this.zhixinChain
      default:
        return this.localChain
    }
  }

  /**
   * 印记上链
   */
  async chainSeal(userId: string, sealId: string) {
    const userSeal = await this.prisma.userSeal.findUnique({
      where: { userId_sealId: { userId, sealId } },
      include: { seal: true },
    })

    if (!userSeal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '未找到该印记')
    }

    if (userSeal.isChained) {
      throw new BusinessException(ErrorCode.DATA_ALREADY_EXISTS, '印记已上链')
    }

    // 动态获取链服务提供者
    const chainProvider = await this.getChainProvider()

    // 调用链服务上链
    const chainResult = await chainProvider.chain({
      sealId: userSeal.sealId,
      userId: userSeal.userId,
      sealName: userSeal.seal.name,
      earnedTime: userSeal.earnedTime,
    })

    // 更新数据库
    const updated = await this.prisma.userSeal.update({
      where: { id: userSeal.id },
      data: {
        isChained: true,
        chainName: chainResult.chainName,
        txHash: chainResult.txHash,
        blockHeight: BigInt(chainResult.blockHeight),
        chainTime: chainResult.chainTime,
        chainCertificate: chainResult.certificate as Prisma.InputJsonValue,
      },
    })

    this.logger.log(
      `印记上链成功: sealId=${sealId}, chain=${chainResult.chainName}, txHash=${chainResult.txHash.slice(0, 20)}...`,
    )

    return {
      sealId: updated.sealId,
      txHash: updated.txHash,
      blockHeight: updated.blockHeight?.toString(),
      chainTime: updated.chainTime,
      chainName: updated.chainName,
    }
  }

  /**
   * 验证链上记录
   */
  async verifyChain(txHash: string) {
    const userSeal = await this.prisma.userSeal.findFirst({
      where: { txHash },
      include: { seal: true, user: true },
    })

    if (!userSeal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '未找到链上记录')
    }

    // 动态获取链服务提供者
    const chainProvider = await this.getChainProvider()

    // 调用链服务验证
    const verifyResult = await chainProvider.verify(
      txHash,
      userSeal.chainCertificate as Record<string, unknown> | undefined,
    )

    return {
      valid: verifyResult.valid,
      txHash: userSeal.txHash,
      blockHeight: userSeal.blockHeight?.toString(),
      chainTime: userSeal.chainTime,
      chainName: userSeal.chainName,
      sealName: userSeal.seal.name,
      ownerNickname: userSeal.user.nickname,
      earnedTime: userSeal.earnedTime,
    }
  }

  /**
   * 查询上链状态
   */
  async getChainStatus(userId: string, sealId: string) {
    const userSeal = await this.prisma.userSeal.findUnique({
      where: { userId_sealId: { userId, sealId } },
    })

    if (!userSeal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '未找到该印记')
    }

    return {
      sealId: userSeal.sealId,
      isChained: userSeal.isChained,
      chainName: userSeal.chainName,
      txHash: userSeal.txHash,
      blockHeight: userSeal.blockHeight?.toString(),
      chainTime: userSeal.chainTime,
    }
  }
}
