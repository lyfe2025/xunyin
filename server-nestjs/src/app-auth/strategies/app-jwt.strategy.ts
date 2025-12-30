import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

/**
 * App JWT Payload 接口
 */
export interface AppJwtPayload {
  /** 用户ID */
  sub: string;
  /** 手机号 */
  phone?: string;
  /** 昵称 */
  nickname: string;
  /** Token 类型: access | refresh */
  type?: 'access' | 'refresh';
}

/**
 * App 端 JWT 策略
 * 使用 'app-jwt' 作为策略名称，与管理端 'jwt' 策略区分
 */
@Injectable()
export class AppJwtStrategy extends PassportStrategy(Strategy, 'app-jwt') {
  constructor(configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey:
        configService.get<string>('JWT_SECRET') || 'super-secret-key',
    });
  }

  /**
   * 验证 JWT payload
   * 返回值会被注入到 req.user
   */
  validate(payload: AppJwtPayload) {
    return {
      userId: payload.sub,
      phone: payload.phone,
      nickname: payload.nickname,
    };
  }
}
