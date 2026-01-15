import { Module } from '@nestjs/common'
import { BlockchainController } from './blockchain.controller'
import { BlockchainService } from './blockchain.service'
import { BlockchainConfigService } from './blockchain-config.service'
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
  ],
  exports: [BlockchainService, BlockchainConfigService],
})
export class BlockchainModule { }
