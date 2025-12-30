import { Module } from '@nestjs/common';
import { AdminAppUserController } from './admin-appuser.controller';
import { AdminAppUserService } from './admin-appuser.service';

@Module({
  controllers: [AdminAppUserController],
  providers: [AdminAppUserService],
})
export class AdminAppUserModule {}
