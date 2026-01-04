import { Injectable } from '@nestjs/common';
import { BlockchainConfigService } from '../../blockchain/blockchain-config.service';
import type {
  ChainProviderInfoVo,
  ChainProviderOption,
} from './dto/blockchain-config.dto';

const PROVIDER_OPTIONS: Omit<
  ChainProviderOption,
  'isConfigured' | 'isCurrent'
>[] = [
  {
    value: 'local',
    label: '本地哈希存证',
    description: '本地生成哈希存证，无需外部服务',
  },
  {
    value: 'timestamp',
    label: '时间戳存证',
    description: '可信时间戳服务，具有法律效力',
  },
  {
    value: 'antchain',
    label: '蚂蚁链',
    description: '蚂蚁集团区块链平台',
  },
  {
    value: 'zhixin',
    label: '至信链',
    description: '腾讯区块链可信存证平台',
  },
  {
    value: 'bsn',
    label: 'BSN 开放联盟链',
    description: '区块链服务网络',
  },
  {
    value: 'polygon',
    label: 'Polygon 公链',
    description: '以太坊 Layer2 公链',
  },
];

@Injectable()
export class AdminBlockchainService {
  constructor(private configService: BlockchainConfigService) {}

  /**
   * 获取当前链服务配置信息
   */
  async getChainProviderInfo(): Promise<ChainProviderInfoVo> {
    const config = await this.configService.getChainConfig();
    const currentProvider = config.provider;

    // 检查各链服务的配置状态
    const configuredMap: Record<string, boolean> = {
      local: true, // 本地存证无需配置
      timestamp: !!config.timestamp.apiKey,
      antchain: !!(config.antchain.appId && config.antchain.privateKey),
      zhixin: !!(config.zhixin.secretId && config.zhixin.secretKey),
      bsn: !!(config.bsn.apiKey && config.bsn.projectId),
      polygon: !!(config.polygon.privateKey && config.polygon.contractAddress),
    };

    const options: ChainProviderOption[] = PROVIDER_OPTIONS.map((opt) => ({
      ...opt,
      isConfigured: configuredMap[opt.value] ?? false,
      isCurrent: opt.value === currentProvider,
    }));

    const currentOption = options.find((o) => o.isCurrent);

    return {
      currentProvider,
      currentProviderName: currentOption?.label || currentProvider,
      isConfigured: configuredMap[currentProvider] ?? false,
      options,
    };
  }
}
