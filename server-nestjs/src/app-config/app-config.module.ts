import { Module } from '@nestjs/common'
import { AppAgreementController } from './agreement/app-agreement.controller'
import { AppAgreementService } from './agreement/app-agreement.service'
import { AppLoginConfigController } from './login/app-login-config.controller'
import { AppLoginConfigService } from './login/app-login-config.service'
import { AppSplashController } from './splash/app-splash.controller'
import { AppSplashService } from './splash/app-splash.service'

/**
 * App 端配置模块（公开 API，无需登录）
 */
@Module({
  controllers: [AppAgreementController, AppLoginConfigController, AppSplashController],
  providers: [AppAgreementService, AppLoginConfigService, AppSplashService],
})
export class AppConfigModule {}
