import { Module } from '@nestjs/common'
import { AdminUserSealController } from './admin-user-seal.controller'
import { AdminUserSealService } from './admin-user-seal.service'
import { BlockchainModule } from '../../blockchain/blockchain.module'

@Module({
  imports: [BlockchainModule],
  controllers: [AdminUserSealController],
  providers: [AdminUserSealService],
})
export class AdminUserSealModule {}
