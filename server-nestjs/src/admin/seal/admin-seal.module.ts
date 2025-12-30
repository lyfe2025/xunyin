import { Module } from '@nestjs/common';
import { AdminSealController } from './admin-seal.controller';
import { AdminSealService } from './admin-seal.service';

@Module({
  controllers: [AdminSealController],
  providers: [AdminSealService],
})
export class AdminSealModule {}
