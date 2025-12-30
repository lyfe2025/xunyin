import { Module } from '@nestjs/common';
import { AdminCityController } from './admin-city.controller';
import { AdminCityService } from './admin-city.service';

@Module({
  controllers: [AdminCityController],
  providers: [AdminCityService],
})
export class AdminCityModule {}
