import { Module } from '@nestjs/common'
import { UploadController } from './upload.controller'
import { DownloadController } from './download.controller'
import { StorageService } from './storage.service'
import { UploadConfigService } from './upload-config.service'
import { PrismaModule } from '../../prisma/prisma.module'
import { LoggerModule } from '../logger/logger.module'

@Module({
  imports: [PrismaModule, LoggerModule],
  controllers: [UploadController, DownloadController],
  providers: [StorageService, UploadConfigService],
  exports: [StorageService, UploadConfigService],
})
export class UploadModule {}
