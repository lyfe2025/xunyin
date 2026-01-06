import { Module } from '@nestjs/common'
import { AdminProgressController } from './admin-progress.controller'
import { AdminProgressService } from './admin-progress.service'

@Module({
  controllers: [AdminProgressController],
  providers: [AdminProgressService],
})
export class AdminProgressModule {}
