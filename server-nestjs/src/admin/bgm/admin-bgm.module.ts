import { Module } from '@nestjs/common';
import { AdminBgmController } from './admin-bgm.controller';
import { AdminBgmService } from './admin-bgm.service';

@Module({
    controllers: [AdminBgmController],
    providers: [AdminBgmService],
})
export class AdminBgmModule {}
