import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { BusinessException } from '../common/exceptions';
import { ErrorCode } from '../common/enums';

@Injectable()
export class BlockchainService {
  private readonly logger = new Logger(BlockchainService.name);

  constructor(private prisma: PrismaService) {}

  /**
   * 印记上链
   */
  async chainSeal(userId: string, sealId: string) {
    const userSeal = await this.prisma.userSeal.findUnique({
      where: { userId_sealId: { userId, sealId } },
      include: { seal: true },
    });

    if (!userSeal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '未找到该印记');
    }

    if (userSeal.isChained) {
      throw new BusinessException(ErrorCode.DATA_ALREADY_EXISTS, '印记已上链');
    }

    // TODO: 调用区块链 API 进行上链
    // 模拟上链结果
    const txHash = `0x${Date.now().toString(16)}${Math.random().toString(16).slice(2, 10)}`;
    const blockHeight = BigInt(Math.floor(Math.random() * 1000000) + 10000000);

    const updated = await this.prisma.userSeal.update({
      where: { id: userSeal.id },
      data: {
        isChained: true,
        chainName: 'BSN',
        txHash,
        blockHeight,
        chainTime: new Date(),
      },
    });

    this.logger.log(`印记上链成功: ${sealId}, txHash: ${txHash}`);

    return {
      sealId: updated.sealId,
      txHash: updated.txHash,
      blockHeight: updated.blockHeight?.toString(),
      chainTime: updated.chainTime,
      chainName: updated.chainName,
    };
  }

  /**
   * 验证链上记录
   */
  async verifyChain(txHash: string) {
    const userSeal = await this.prisma.userSeal.findFirst({
      where: { txHash },
      include: { seal: true, user: true },
    });

    if (!userSeal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '未找到链上记录');
    }

    // TODO: 调用区块链 API 验证
    // 模拟验证结果
    return {
      valid: true,
      txHash: userSeal.txHash,
      blockHeight: userSeal.blockHeight?.toString(),
      chainTime: userSeal.chainTime,
      chainName: userSeal.chainName,
      sealName: userSeal.seal.name,
      ownerNickname: userSeal.user.nickname,
      earnedTime: userSeal.earnedTime,
    };
  }

  /**
   * 查询上链状态
   */
  async getChainStatus(userId: string, sealId: string) {
    const userSeal = await this.prisma.userSeal.findUnique({
      where: { userId_sealId: { userId, sealId } },
    });

    if (!userSeal) {
      throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '未找到该印记');
    }

    return {
      sealId: userSeal.sealId,
      isChained: userSeal.isChained,
      chainName: userSeal.chainName,
      txHash: userSeal.txHash,
      blockHeight: userSeal.blockHeight?.toString(),
      chainTime: userSeal.chainTime,
    };
  }
}
