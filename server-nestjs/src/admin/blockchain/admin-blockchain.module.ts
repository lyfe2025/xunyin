import { Module } from '@nestjs/common'
import { AdminBlockchainController } from './admin-blockchain.controller'
import { AdminBlockchainService } from './admin-blockchain.service'
import { BlockchainModule } from '../../blockchain/blockchain.module'

@Module({
  imports: [BlockchainModule],
  controllers: [AdminBlockchainController],
  providers: [AdminBlockchainService],
})
export class AdminBlockchainModule {}
