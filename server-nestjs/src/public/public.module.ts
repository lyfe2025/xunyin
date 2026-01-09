import { Module } from '@nestjs/common'
import { PrismaModule } from '../prisma/prisma.module'
import { PublicSealController } from './seal/public-seal.controller'
import { PublicSealService } from './seal/public-seal.service'
import { PublicConfigController } from './config/public-config.controller'
import { PublicConfigService } from './config/public-config.service'

@Module({
  imports: [PrismaModule],
  controllers: [PublicSealController, PublicConfigController],
  providers: [PublicSealService, PublicConfigService],
})
export class PublicModule {}
