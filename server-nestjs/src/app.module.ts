import { Module, MiddlewareConsumer, NestModule } from '@nestjs/common'
import { APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core'
import { ConfigModule } from '@nestjs/config'
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler'
import { AppController } from './app.controller'
import { AppService } from './app.service'
import { PrismaModule } from './prisma/prisma.module'
import { UserModule } from './system/user/user.module'
import { AuthModule } from './auth/auth.module'
import { MenuModule } from './system/menu/menu.module'
import { DeptModule } from './system/dept/dept.module'
import { RoleModule } from './system/role/role.module'
import { DictModule } from './system/dict/dict.module'
import { SysConfigModule } from './system/config/config.module'
import { NoticeModule } from './system/notice/notice.module'
import { OperationLogInterceptor } from './common/interceptors/operation-log.interceptor'
import { PermissionGuard } from './common/guards/permission.guard'
import { PostModule } from './system/post/post.module'
import { MonitorModule } from './monitor/monitor.module'
import { LoggerModule } from './common/logger/logger.module'
import { HttpLoggerMiddleware } from './common/middleware/http-logger.middleware'
import { UploadModule } from './common/upload/upload.module'
import { MailModule } from './common/mail/mail.module'
import { ExcelModule } from './common/excel/excel.module'
import { AppAuthModule } from './app-auth/app-auth.module'
import { CityModule } from './city/city.module'
import { JourneyModule } from './journey/journey.module'
import { ExplorationPointModule } from './exploration-point/exploration-point.module'
import { SealModule } from './seal/seal.module'
import { BlockchainModule } from './blockchain/blockchain.module'
import { AlbumModule } from './album/album.module'
import { UserStatsModule } from './user-stats/user-stats.module'
import { AudioModule } from './audio/audio.module'
import { MapModule } from './map/map.module'
import { AdminModule } from './admin/admin.module'
import { HealthModule } from './health/health.module'
import { AppConfigModule } from './app-config/app-config.module'
import { AppProfileModule } from './app-profile/app-profile.module'

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true, // 全局可用
    }),
    // 全局限流配置：每分钟最多 100 次请求
    ThrottlerModule.forRoot([
      {
        name: 'short',
        ttl: 1000, // 1 秒
        limit: 10, // 每秒最多 10 次
      },
      {
        name: 'medium',
        ttl: 10000, // 10 秒
        limit: 50, // 每 10 秒最多 50 次
      },
      {
        name: 'long',
        ttl: 60000, // 1 分钟
        limit: 100, // 每分钟最多 100 次
      },
    ]),
    LoggerModule,
    PrismaModule,
    UserModule,
    AuthModule,
    MenuModule,
    DeptModule,
    RoleModule,
    DictModule,
    SysConfigModule,
    NoticeModule,
    MonitorModule,
    PostModule,
    UploadModule,
    MailModule,
    ExcelModule,
    // 寻印 App 模块
    AppAuthModule,
    CityModule,
    JourneyModule,
    ExplorationPointModule,
    SealModule,
    BlockchainModule,
    AlbumModule,
    UserStatsModule,
    AudioModule,
    MapModule,
    // 寻印 Admin 模块
    AdminModule,
    // App 端配置模块（公开 API）
    AppConfigModule,
    // App 端用户资料模块
    AppProfileModule,
    // 健康检查模块
    HealthModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    PermissionGuard,
    {
      provide: APP_INTERCEPTOR,
      useClass: OperationLogInterceptor,
    },
    // 全局限流守卫
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(HttpLoggerMiddleware).forRoutes('*')
  }
}
