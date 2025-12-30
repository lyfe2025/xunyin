import { Module } from '@nestjs/common';
import { AdminJourneyController } from './admin-journey.controller';
import { AdminJourneyService } from './admin-journey.service';

@Module({
  controllers: [AdminJourneyController],
  providers: [AdminJourneyService],
})
export class AdminJourneyModule {}
