import { Module } from '@nestjs/common'
import { ExplorationPointController } from './exploration-point.controller'
import { ExplorationPointService } from './exploration-point.service'

@Module({
  controllers: [ExplorationPointController],
  providers: [ExplorationPointService],
  exports: [ExplorationPointService],
})
export class ExplorationPointModule {}
