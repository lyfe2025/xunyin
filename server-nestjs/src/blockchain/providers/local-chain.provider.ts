import { Injectable, Logger } from '@nestjs/common'
import { createHash, randomBytes } from 'crypto'
import {
  ChainProvider,
  ChainData,
  ChainResult,
  VerifyResult,
} from '../interfaces/chain-provider.interface'

/**
 * 本地哈希存证实现
 * 用于 MVP/演示阶段，无需对接真实区块链
 */
@Injectable()
export class LocalChainProvider implements ChainProvider {
  private readonly logger = new Logger(LocalChainProvider.name)

  getChainName(): string {
    return 'LocalChain'
  }

  chain(data: ChainData): Promise<ChainResult> {
    // 构造存证证书
    const certificate = {
      version: '1.0',
      type: 'SEAL_CERTIFICATE',
      data: {
        sealId: data.sealId,
        userId: data.userId,
        sealName: data.sealName,
        earnedTime: data.earnedTime.toISOString(),
        location: data.location,
        journeyId: data.journeyId,
      },
      timestamp: Date.now(),
      nonce: randomBytes(16).toString('hex'),
    }

    // 生成存证哈希
    const contentHash = createHash('sha256').update(JSON.stringify(certificate)).digest('hex')

    // 生成伪交易哈希
    const txHash = `0x${contentHash}`

    // 生成伪区块高度（基于时间戳，保证递增）
    const blockHeight = (Math.floor(Date.now() / 1000) - 1700000000).toString()

    this.logger.log(`本地存证成功: sealId=${data.sealId}, txHash=${txHash.slice(0, 20)}...`)

    return Promise.resolve({
      txHash,
      blockHeight,
      chainTime: new Date(),
      chainName: this.getChainName(),
      certificate,
    })
  }

  verify(txHash: string, certificate?: Record<string, unknown>): Promise<VerifyResult> {
    if (!certificate) {
      return Promise.resolve({
        valid: false,
        txHash,
        blockHeight: '0',
        chainTime: new Date(),
        chainName: this.getChainName(),
      })
    }

    // 重新计算哈希验证
    const expectedHash = createHash('sha256').update(JSON.stringify(certificate)).digest('hex')

    const valid = txHash === `0x${expectedHash}`
    const timestamp = certificate.timestamp as number | undefined
    const blockHeight = certificate.blockHeight as string | undefined

    return Promise.resolve({
      valid,
      txHash,
      blockHeight: blockHeight || '0',
      chainTime: timestamp ? new Date(timestamp) : new Date(),
      chainName: this.getChainName(),
      certificate,
    })
  }
}
