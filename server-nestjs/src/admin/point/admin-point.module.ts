import { Module } from '@nestjs/common';
import { AdminPointController } from './admin-point.controller';
import { AdminPointService } from './admin-point.service';

@Module({
  controllers: [AdminPointController],
  providers: [AdminPointService],
})
export class AdminPointModule {}
