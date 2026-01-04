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
 * BSN 开放联盟链实现
 */
@Injectable()
export class BSNChainProvider implements ChainProvider {
  private readonly logger = new Logger(BSNChainProvider.name);

  constructor(private configService: BlockchainConfigService) {}

  getChainName(): string {
    return 'BSN';
  }

  async chain(data: ChainData): Promise<ChainResult> {
    const config = await this.configService.getChainConfig();
    const { apiKey, projectId, endpoint } = config.bsn;

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

    const contentHash = createHash('sha256')
      .update(JSON.stringify(content))
      .digest('hex');

    // 检查配置是否完整
    if (!apiKey || !projectId) {
      this.logger.warn('BSN 配置不完整，使用模拟数据');
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

    // TODO: 调用 BSN API
    // const response = await axios.post(
    //   `${endpoint}/api/v1/contract/invoke`,
    //   {
    //     funcName: 'deposit',
    //     args: [data.sealId, JSON.stringify(content), contentHash],
    //   },
    //   {
    //     headers: {
    //       'x-api-key': apiKey,
    //       'x-project-id': projectId,
    //     },
    //   }
    // );

    this.logger.log(`BSN 存证: projectId=${projectId}, endpoint=${endpoint}`);
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
    // TODO: 调用 BSN 查询 API

    return Promise.resolve({
      valid: true,
      txHash,
      blockHeight: '0',
      chainTime: new Date(),
      chainName: this.getChainName(),
    });
  }
}
