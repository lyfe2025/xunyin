import { Module } from '@nestjs/common'
import { SealController } from './seal.controller'
import { SealService } from './seal.service'
import { BlockchainModule } from '../blockchain/blockchain.module'

@Module({
  imports: [BlockchainModule],
  controllers: [SealController],
  providers: [SealService],
  exports: [SealService],
})
export class SealModule {}
