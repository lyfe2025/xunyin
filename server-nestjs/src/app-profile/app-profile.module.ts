import { Module } from '@nestjs/common'
import { AppProfileController } from './app-profile.controller'
import { AppProfileService } from './app-profile.service'
import { AppUploadController } from './app-upload.controller'
import { UploadModule } from '../common/upload/upload.module'

@Module({
  imports: [UploadModule],
  controllers: [AppProfileController, AppUploadController],
  providers: [AppProfileService],
  exports: [AppProfileService],
})
export class AppProfileModule {}
