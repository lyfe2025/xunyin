import { Module } from '@nestjs/common'
import { SmsService } from './sms.service'
import { PrismaModule } from '../../prisma/prisma.module'
import { RedisModule } from '../../redis/redis.module'
import { LoggerModule } from '../logger/logger.module'

@Module({
  imports: [PrismaModule, RedisModule, LoggerModule],
  providers: [SmsService],
  exports: [SmsService],
})
export class SmsModule {}
