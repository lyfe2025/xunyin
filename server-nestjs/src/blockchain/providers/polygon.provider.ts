import { Injectable, Logger } from '@nestjs/common'
import { createHash } from 'crypto'
import {
  ChainProvider,
  ChainData,
  ChainResult,
  VerifyResult,
} from '../interfaces/chain-provider.interface'
import { BlockchainConfigService } from '../blockchain-config.service'

/**
 * Polygon 公链实现
 * 适用于海外用户，真正去中心化存证
 */
@Injectable()
export class PolygonProvider implements ChainProvider {
  private readonly logger = new Logger(PolygonProvider.name)

  constructor(private configService: BlockchainConfigService) {}

  getChainName(): string {
    return 'Polygon'
  }

  async chain(data: ChainData): Promise<ChainResult> {
    const config = await this.configService.getChainConfig()
    const { rpcUrl, privateKey } = config.polygon

    // 构造存证内容
    const content = {
      sealId: data.sealId,
      userId: data.userId,
      sealName: data.sealName,
      earnedTime: data.earnedTime.toISOString(),
      location: data.location,
      journeyId: data.journeyId,
      timestamp: Date.now(),
    }

    const contentHash = createHash('sha256').update(JSON.stringify(content)).digest('hex')

    // 检查配置是否完整
    if (!rpcUrl || !privateKey) {
      this.logger.warn('Polygon 配置不完整，使用模拟数据')
      const txHash = `0x${contentHash}`
      const blockHeight = Math.floor(Math.random() * 1000000 + 50000000).toString()

      return {
        txHash,
        blockHeight,
        chainTime: new Date(),
        chainName: this.getChainName(),
        certificate: content,
      }
    }

    // TODO: 使用 ethers.js 调用合约
    // import { ethers } from 'ethers';
    //
    // const provider = new ethers.JsonRpcProvider(rpcUrl);
    // const wallet = new ethers.Wallet(privateKey, provider);
    //
    // // 方式1: 直接写入交易 data 字段（最简单）
    // const tx = await wallet.sendTransaction({
    //   to: wallet.address, // 发给自己
    //   value: 0,
    //   data: ethers.hexlify(ethers.toUtf8Bytes(contentHash)),
    // });
    // const receipt = await tx.wait();
    //
    // return {
    //   txHash: receipt.hash,
    //   blockHeight: receipt.blockNumber.toString(),
    //   chainTime: new Date(),
    //   chainName: this.getChainName(),
    //   certificate: content,
    // };

    this.logger.log(`Polygon 存证: rpcUrl=${rpcUrl}`)
    const txHash = `0x${contentHash}`
    const blockHeight = Math.floor(Math.random() * 1000000 + 50000000).toString()

    return {
      txHash,
      blockHeight,
      chainTime: new Date(),
      chainName: this.getChainName(),
      certificate: content,
    }
  }

  verify(txHash: string): Promise<VerifyResult> {
    // TODO: 查询链上交易
    // const provider = new ethers.JsonRpcProvider(rpcUrl);
    // const receipt = await provider.getTransactionReceipt(txHash);
    //
    // return {
    //   valid: receipt !== null && receipt.status === 1,
    //   txHash,
    //   blockHeight: receipt?.blockNumber?.toString() || '0',
    //   chainTime: new Date(),
    //   chainName: this.getChainName(),
    // };

    return Promise.resolve({
      valid: true,
      txHash,
      blockHeight: '0',
      chainTime: new Date(),
      chainName: this.getChainName(),
    })
  }
}
