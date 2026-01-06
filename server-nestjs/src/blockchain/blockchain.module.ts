import { Module } from '@nestjs/common'
import { BlockchainController } from './blockchain.controller'
import { BlockchainService } from './blockchain.service'
import { BlockchainConfigService } from './blockchain-config.service'
import { CHAIN_PROVIDER } from './interfaces/chain-provider.interface'
import {
  LocalChainProvider,
  AntChainProvider,
  BSNChainProvider,
  PolygonProvider,
  TimestampProvider,
  ZhixinChainProvider,
} from './providers'

@Module({
  controllers: [BlockchainController],
  providers: [
    BlockchainService,
    BlockchainConfigService,
    LocalChainProvider,
    AntChainProvider,
    BSNChainProvider,
    PolygonProvider,
    TimestampProvider,
    ZhixinChainProvider,
    {
      provide: CHAIN_PROVIDER,
      useFactory: async (
        configService: BlockchainConfigService,
        localChain: LocalChainProvider,
        antChain: AntChainProvider,
        bsnChain: BSNChainProvider,
        polygonChain: PolygonProvider,
        timestampChain: TimestampProvider,
        zhixinChain: ZhixinChainProvider,
      ) => {
        const provider = await configService.getProvider()
        switch (provider) {
          case 'antchain':
            return antChain
          case 'bsn':
            return bsnChain
          case 'polygon':
            return polygonChain
          case 'timestamp':
            return timestampChain
          case 'zhixin':
            return zhixinChain
          default:
            return localChain
        }
      },
      inject: [
        BlockchainConfigService,
        LocalChainProvider,
        AntChainProvider,
        BSNChainProvider,
        PolygonProvider,
        TimestampProvider,
        ZhixinChainProvider,
      ],
    },
  ],
  exports: [BlockchainService, BlockchainConfigService],
})
export class BlockchainModule {}
