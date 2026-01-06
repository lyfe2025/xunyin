import { Module } from '@nestjs/common'
import { SplashController } from './splash/splash.controller'
import { SplashService } from './splash/splash.service'
import { LoginConfigController } from './login/login-config.controller'
import { LoginConfigService } from './login/login-config.service'
import { DownloadConfigController } from './download/download-config.controller'
import { DownloadConfigService } from './download/download-config.service'
import { PromotionController } from './promotion/promotion.controller'
import { PromotionService } from './promotion/promotion.service'
import { VersionController } from './version/version.controller'
import { VersionService } from './version/version.service'
import { AgreementController } from './agreement/agreement.controller'
import { AgreementService } from './agreement/agreement.service'

@Module({
  controllers: [
    SplashController,
    LoginConfigController,
    DownloadConfigController,
    PromotionController,
    VersionController,
    AgreementController,
  ],
  providers: [
    SplashService,
    LoginConfigService,
    DownloadConfigService,
    PromotionService,
    VersionService,
    AgreementService,
  ],
})
export class AdminAppConfigModule {}
