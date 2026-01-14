import { Module } from '@nestjs/common'
import { AppAgreementController } from './agreement/app-agreement.controller'
import { AppAgreementService } from './agreement/app-agreement.service'
import { AppLoginConfigController } from './login/app-login-config.controller'
import { AppLoginConfigService } from './login/app-login-config.service'

/**
 * App 端配置模块（公开 API，无需登录）
 */
@Module({
  controllers: [AppAgreementController, AppLoginConfigController],
  providers: [AppAgreementService, AppLoginConfigService],
})
export class AppConfigModule {}
