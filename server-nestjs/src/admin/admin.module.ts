import { Module } from '@nestjs/common';
import { AdminCityModule } from './city/admin-city.module';
import { AdminJourneyModule } from './journey/admin-journey.module';
import { AdminPointModule } from './point/admin-point.module';
import { AdminSealModule } from './seal/admin-seal.module';
import { AdminDashboardModule } from './dashboard/admin-dashboard.module';
import { AdminAppUserModule } from './appuser/admin-appuser.module';
import { AdminProgressModule } from './progress/admin-progress.module';
import { AdminUserSealModule } from './user-seal/admin-user-seal.module';

@Module({
  imports: [
    AdminCityModule,
    AdminJourneyModule,
    AdminPointModule,
    AdminSealModule,
    AdminDashboardModule,
    AdminAppUserModule,
    AdminProgressModule,
    AdminUserSealModule,
  ],
})
export class AdminModule { }
