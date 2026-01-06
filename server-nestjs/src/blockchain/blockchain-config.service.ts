import { Injectable, Logger } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'

export interface ChainConfig {
  provider: 'local' | 'antchain' | 'bsn' | 'polygon' | 'timestamp' | 'zhixin'
  antchain: {
    appId: string
    privateKey: string
    endpoint: string
  }
  bsn: {
    apiKey: string
    projectId: string
    endpoint: string
  }
  polygon: {
    rpcUrl: string
    privateKey: string
    contractAddress: string
  }
  timestamp: {
    apiKey: string
    endpoint: string
  }
  zhixin: {
    secretId: string
    secretKey: string
    endpoint: string
  }
}

@Injectable()
export class BlockchainConfigService {
  private readonly logger = new Logger(BlockchainConfigService.name)

  constructor(private prisma: PrismaService) {}

  /**
   * 获取区块链配置
   */
  async getChainConfig(): Promise<ChainConfig> {
    const configs = await this.prisma.sysConfig.findMany({
      where: {
        configKey: { startsWith: 'chain.' },
      },
    })

    const configMap: Record<string, string> = {}
    configs.forEach((c) => {
      if (c.configKey) {
        configMap[c.configKey] = c.configValue || ''
      }
    })

    return {
      provider: (configMap['chain.provider'] as ChainConfig['provider']) || 'local',
      antchain: {
        appId: configMap['chain.antchain.appId'] || '',
        privateKey: configMap['chain.antchain.privateKey'] || '',
        endpoint: configMap['chain.antchain.endpoint'] || 'https://rest.antchain.alipay.com',
      },
      bsn: {
        apiKey: configMap['chain.bsn.apiKey'] || '',
        projectId: configMap['chain.bsn.projectId'] || '',
        endpoint: configMap['chain.bsn.endpoint'] || 'https://api.bsngate.com',
      },
      polygon: {
        rpcUrl: configMap['chain.polygon.rpcUrl'] || 'https://polygon-rpc.com',
        privateKey: configMap['chain.polygon.privateKey'] || '',
        contractAddress: configMap['chain.polygon.contractAddress'] || '',
      },
      timestamp: {
        apiKey: configMap['chain.timestamp.apiKey'] || '',
        endpoint: configMap['chain.timestamp.endpoint'] || 'https://tsa.example.com/timestamp',
      },
      zhixin: {
        secretId: configMap['chain.zhixin.secretId'] || '',
        secretKey: configMap['chain.zhixin.secretKey'] || '',
        endpoint: configMap['chain.zhixin.endpoint'] || 'https://tbaas.tencentcloudapi.com',
      },
    }
  }

  /**
   * 获取当前链服务提供者
   */
  async getProvider(): Promise<string> {
    const config = await this.prisma.sysConfig.findFirst({
      where: { configKey: 'chain.provider' },
    })
    return config?.configValue || 'local'
  }
}
