import { Module } from '@nestjs/common'
import { JwtModule } from '@nestjs/jwt'
import { PassportModule } from '@nestjs/passport'
import { ConfigService } from '@nestjs/config'
import { PrismaModule } from '../prisma/prisma.module'
import { RedisModule } from '../redis/redis.module'
import { AppAuthController } from './app-auth.controller'
import { AppAuthService } from './app-auth.service'
import { AppJwtStrategy } from './strategies/app-jwt.strategy'
import { AppAuthGuard } from './guards/app-auth.guard'

@Module({
  imports: [
    PrismaModule,
    RedisModule,
    PassportModule,
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET') || 'super-secret-key',
        signOptions: {
          expiresIn: '7d', // 默认7天
        },
      }),
    }),
  ],
  controllers: [AppAuthController],
  providers: [AppAuthService, AppJwtStrategy, AppAuthGuard],
  exports: [AppAuthService, AppAuthGuard],
})
export class AppAuthModule {}
