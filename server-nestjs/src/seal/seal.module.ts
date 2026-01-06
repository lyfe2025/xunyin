import { Module } from '@nestjs/common'
import { SealController } from './seal.controller'
import { SealService } from './seal.service'

@Module({
  controllers: [SealController],
  providers: [SealService],
  exports: [SealService],
})
export class SealModule {}
