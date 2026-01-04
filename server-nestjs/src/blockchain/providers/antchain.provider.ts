import { Injectable, Logger } from '@nestjs/common';
import { createHash } from 'crypto';
import {
  ChainProvider,
  ChainData,
  ChainResult,
  VerifyResult,
} from '../interfaces/chain-provider.interface';
import { BlockchainConfigService } from '../blockchain-config.service';

/**
 * 蚂蚁链开放联盟链实现
 */
@Injectable()
export class AntChainProvider implements ChainProvider {
  private readonly logger = new Logger(AntChainProvider.name);

  constructor(private configService: BlockchainConfigService) {}

  getChainName(): string {
    return 'AntChain';
  }

  async chain(data: ChainData): Promise<ChainResult> {
    const config = await this.configService.getChainConfig();
    const { appId, privateKey, endpoint } = config.antchain;

    // 构造存证内容
    const content = {
      sealId: data.sealId,
      userId: data.userId,
      sealName: data.sealName,
      earnedTime: data.earnedTime.toISOString(),
      location: data.location,
      journeyId: data.journeyId,
      timestamp: Date.now(),
    };

    // 计算内容哈希
    const contentHash = createHash('sha256')
      .update(JSON.stringify(content))
      .digest('hex');

    // 检查配置是否完整
    if (!appId || !privateKey) {
      this.logger.warn('蚂蚁链配置不完整，使用模拟数据');
      const txHash = `0x${contentHash}`;
      const blockHeight = Math.floor(
        Math.random() * 1000000 + 10000000,
      ).toString();

      return {
        txHash,
        blockHeight,
        chainTime: new Date(),
        chainName: this.getChainName(),
        certificate: content,
      };
    }

    // TODO: 调用蚂蚁链 API
    // const client = new AntChainClient({ appId, privateKey, endpoint });
    // const result = await client.deposit({
    //   content: contentHash,
    //   bizId: data.sealId,
    //   category: 'SEAL_CERTIFICATE',
    // });

    this.logger.log(`蚂蚁链存证: appId=${appId}, endpoint=${endpoint}`);
    const txHash = `0x${contentHash}`;
    const blockHeight = Math.floor(
      Math.random() * 1000000 + 10000000,
    ).toString();

    return {
      txHash,
      blockHeight,
      chainTime: new Date(),
      chainName: this.getChainName(),
      certificate: content,
    };
  }

  verify(txHash: string): Promise<VerifyResult> {
    // TODO: 调用蚂蚁链查询 API

    return Promise.resolve({
      valid: true,
      txHash,
      blockHeight: '0',
      chainTime: new Date(),
      chainName: this.getChainName(),
    });
  }
}
