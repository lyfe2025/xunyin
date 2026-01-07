import { Module } from '@nestjs/common'
import { AppProfileController } from './app-profile.controller'
import { AppProfileService } from './app-profile.service'
import { AppUploadController } from './app-upload.controller'
import { AppSmsController } from './app-sms.controller'
import { UploadModule } from '../common/upload/upload.module'
import { SmsModule } from '../common/sms/sms.module'

@Module({
  imports: [UploadModule, SmsModule],
  controllers: [AppProfileController, AppUploadController, AppSmsController],
  providers: [AppProfileService],
  exports: [AppProfileService],
})
export class AppProfileModule {}
