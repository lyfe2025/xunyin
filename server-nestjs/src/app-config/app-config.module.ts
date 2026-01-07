import { Module } from '@nestjs/common'
import { AppAgreementController } from './agreement/app-agreement.controller'
import { AppAgreementService } from './agreement/app-agreement.service'

/**
 * App 端配置模块（公开 API，无需登录）
 */
@Module({
  controllers: [AppAgreementController],
  providers: [AppAgreementService],
})
export class AppConfigModule {}
