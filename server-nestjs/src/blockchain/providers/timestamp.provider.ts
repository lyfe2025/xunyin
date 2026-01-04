import { Injectable, Logger } from '@nestjs/common';
import { createHash, randomBytes } from 'crypto';
import {
  ChainProvider,
  ChainData,
  ChainResult,
  VerifyResult,
} from '../interfaces/chain-provider.interface';

/**
 * 可信时间戳存证实现
 *
 * 时间戳存证是一种轻量级的电子数据存证方案，通过可信时间戳服务
 * 为数据打上权威时间戳，证明数据在某一时刻已经存在。
 *
 * 常见的可信时间戳服务商：
 * - 联合信任时间戳服务中心 (TSA)
 * - 国家授时中心
 * - 各省级 CA 机构
 *
 * 优势：
 * - 成本低，按次计费
 * - 接入简单，标准 RFC 3161 协议
 * - 具有法律效力，被司法机关认可
 *
 * 接入流程：
 * 1. 与时间戳服务商签约
 * 2. 获取 API 密钥
 * 3. 对数据哈希请求时间戳
 * 4. 保存时间戳令牌作为存证凭证
 */
@Injectable()
export class TimestampProvider implements ChainProvider {
  private readonly logger = new Logger(TimestampProvider.name);

  getChainName(): string {
    return 'Timestamp';
  }

  chain(data: ChainData): Promise<ChainResult> {
    // TODO: 对接可信时间戳服务 API
    // 实际对接时需要：
    // 1. 构造待存证数据
    // 2. 计算数据哈希
    // 3. 向 TSA 服务请求时间戳
    // 4. 获取时间戳令牌 (TST)

    // 模拟实现
    const originalData = {
      sealId: data.sealId,
      userId: data.userId,
      sealName: data.sealName,
      earnedTime: data.earnedTime.toISOString(),
      location: data.location,
      journeyId: data.journeyId,
    };

    // 计算数据哈希
    const dataHash = createHash('sha256')
      .update(JSON.stringify(originalData))
      .digest('hex');

    // 模拟时间戳令牌
    const timestamp = Date.now();
    const certificate = {
      version: '1.0',
      type: 'TIMESTAMP_TOKEN',
      algorithm: 'SHA-256',
      dataHash,
      originalData,
      timestamp,
      tsaInfo: {
        name: '可信时间戳服务',
        serialNumber: randomBytes(8).toString('hex').toUpperCase(),
        accuracy: '1s',
      },
      nonce: randomBytes(16).toString('hex'),
    };

    // 生成时间戳凭证哈希作为 txHash
    const txHash = `ts_${createHash('sha256').update(JSON.stringify(certificate)).digest('hex')}`;

    this.logger.log(
      `时间戳存证成功: sealId=${data.sealId}, txHash=${txHash.slice(0, 20)}...`,
    );

    return Promise.resolve({
      txHash,
      blockHeight: timestamp.toString(),
      chainTime: new Date(timestamp),
      chainName: this.getChainName(),
      certificate,
    });
  }

  verify(
    txHash: string,
    certificate?: Record<string, unknown>,
  ): Promise<VerifyResult> {
    if (!certificate) {
      return Promise.resolve({
        valid: false,
        txHash,
        blockHeight: '0',
        chainTime: new Date(),
        chainName: this.getChainName(),
      });
    }

    const expectedHash = createHash('sha256')
      .update(JSON.stringify(certificate))
      .digest('hex');

    const valid = txHash === `ts_${expectedHash}`;
    const timestamp = certificate.timestamp as number | undefined;

    return Promise.resolve({
      valid,
      txHash,
      blockHeight: timestamp?.toString() || '0',
      chainTime: timestamp ? new Date(timestamp) : new Date(),
      chainName: this.getChainName(),
      certificate,
    });
  }
}
