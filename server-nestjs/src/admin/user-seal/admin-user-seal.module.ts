import { Module } from '@nestjs/common';
import { AdminUserSealController } from './admin-user-seal.controller';
import { AdminUserSealService } from './admin-user-seal.service';

@Module({
    controllers: [AdminUserSealController],
    providers: [AdminUserSealService],
})
export class AdminUserSealModule { }
