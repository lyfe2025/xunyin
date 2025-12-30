import { Injectable, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import { BusinessException } from '../common/exceptions';
import { ErrorCode } from '../common/enums';
import {
  PhoneLoginDto,
  WechatLoginDto,
  RefreshTokenDto,
} from './dto/login.dto';
import { UpdateProfileDto } from './dto/profile.dto';
import type { AppJwtPayload } from './strategies/app-jwt.strategy';

@Injectable()
export class AppAuthService {
  private readonly logger = new Logger(AppAuthService.name);

  // Token 过期时间配置
  private readonly ACCESS_TOKEN_EXPIRES = '7d';
  private readonly REFRESH_TOKEN_EXPIRES = '30d';
  private readonly SMS_CODE_EXPIRES = 300; // 5分钟
  private readonly SMS_CODE_PREFIX = 'app:sms:';

  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
    private redisService: RedisService,
  ) {}

  /**
   * 手机号验证码登录
   */
  async loginByPhone(dto: PhoneLoginDto) {
    const { phone, code } = dto;

    // 验证短信验证码
    const isValid = await this.verifySmsCode(phone, code);
    if (!isValid) {
      throw new BusinessException(
        ErrorCode.CAPTCHA_ERROR,
        '验证码错误或已过期',
      );
    }

    // 查找或创建用户
    let user = await this.prisma.appUser.findUnique({ where: { phone } });

    if (!user) {
      // 新用户自动注册
      user = await this.prisma.appUser.create({
        data: {
          phone,
          nickname: `用户${phone.slice(-4)}`,
        },
      });
      this.logger.log(`新用户注册: ${phone}`);
    }

    // 检查用户状态
    if (user.status === '1') {
      throw new BusinessException(ErrorCode.ACCOUNT_DISABLED, '账号已被禁用');
    }

    // 清除验证码
    await this.clearSmsCode(phone);

    // 生成 Token
    return this.generateTokens({
      id: user.id,
      phone: user.phone,
      nickname: user.nickname,
    });
  }

  /**
   * 微信登录
   */
  async loginByWechat(dto: WechatLoginDto) {
    const { code, nickname, avatar } = dto;

    // TODO: 调用微信 API 获取 openId 和 unionId
    const wechatUserInfo = this.getWechatUserInfo(code);

    if (!wechatUserInfo.openId) {
      throw new BusinessException(
        ErrorCode.INVALID_CREDENTIALS,
        '微信授权失败',
      );
    }

    // 查找或创建用户
    let user = await this.prisma.appUser.findUnique({
      where: { openId: wechatUserInfo.openId },
    });

    if (!user) {
      // 新用户自动注册
      user = await this.prisma.appUser.create({
        data: {
          openId: wechatUserInfo.openId,
          unionId: wechatUserInfo.unionId,
          nickname: nickname || wechatUserInfo.nickname || '微信用户',
          avatar: avatar || wechatUserInfo.avatar,
        },
      });
      this.logger.log(`微信新用户注册: ${wechatUserInfo.openId}`);
    }

    // 检查用户状态
    if (user.status === '1') {
      throw new BusinessException(ErrorCode.ACCOUNT_DISABLED, '账号已被禁用');
    }

    // 生成 Token
    return this.generateTokens({
      id: user.id,
      phone: user.phone,
      nickname: user.nickname,
    });
  }

  /**
   * 刷新 Token
   */
  async refreshToken(dto: RefreshTokenDto) {
    const { refreshToken } = dto;

    try {
      // 验证 refresh token
      const payload = this.jwtService.verify<AppJwtPayload>(refreshToken);

      if (payload.type !== 'refresh') {
        throw new BusinessException(ErrorCode.INVALID_TOKEN, 'Token 类型错误');
      }

      // 查找用户
      const user = await this.prisma.appUser.findUnique({
        where: { id: payload.sub },
      });

      if (!user) {
        throw new BusinessException(ErrorCode.USER_NOT_FOUND, '用户不存在');
      }

      if (user.status === '1') {
        throw new BusinessException(ErrorCode.ACCOUNT_DISABLED, '账号已被禁用');
      }

      // 生成新的 Token
      return this.generateTokens({
        id: user.id,
        phone: user.phone,
        nickname: user.nickname,
      });
    } catch (error) {
      if (error instanceof BusinessException) {
        throw error;
      }
      throw new BusinessException(
        ErrorCode.INVALID_TOKEN,
        'Token 无效或已过期',
      );
    }
  }

  /**
   * 获取当前用户信息
   */
  async getCurrentUser(userId: string) {
    const user = await this.prisma.appUser.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new BusinessException(ErrorCode.USER_NOT_FOUND, '用户不存在');
    }

    return {
      id: user.id,
      phone: user.phone,
      nickname: user.nickname,
      avatar: user.avatar,
      badgeTitle: user.badgeTitle,
      totalPoints: user.totalPoints,
      createTime: user.createTime,
    };
  }

  /**
   * 更新用户资料
   */
  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const user = await this.prisma.appUser.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new BusinessException(ErrorCode.USER_NOT_FOUND, '用户不存在');
    }

    const updated = await this.prisma.appUser.update({
      where: { id: userId },
      data: {
        ...(dto.nickname && { nickname: dto.nickname }),
        ...(dto.avatar && { avatar: dto.avatar }),
      },
    });

    return {
      id: updated.id,
      phone: updated.phone,
      nickname: updated.nickname,
      avatar: updated.avatar,
      badgeTitle: updated.badgeTitle,
      totalPoints: updated.totalPoints,
      createTime: updated.createTime,
    };
  }

  /**
   * 发送短信验证码
   */
  async sendSmsCode(phone: string) {
    // 生成6位验证码
    const code = Math.random().toString().slice(-6);

    // 存储到 Redis
    const key = `${this.SMS_CODE_PREFIX}${phone}`;
    const client = this.redisService.getClient();
    await client.setex(key, this.SMS_CODE_EXPIRES, code);

    // TODO: 调用短信服务发送验证码
    // 开发环境直接返回验证码
    const isDev = this.configService.get('NODE_ENV') !== 'production';

    this.logger.log(`发送验证码到 ${phone}: ${code}`);

    return {
      message: '验证码已发送',
      ...(isDev && { code }), // 开发环境返回验证码
    };
  }

  // ==================== 私有方法 ====================

  /**
   * 生成访问令牌和刷新令牌
   */
  private generateTokens(user: {
    id: string;
    phone: string | null;
    nickname: string;
  }) {
    const accessPayload: AppJwtPayload = {
      sub: user.id,
      phone: user.phone || undefined,
      nickname: user.nickname,
      type: 'access',
    };

    const refreshPayload: AppJwtPayload = {
      sub: user.id,
      phone: user.phone || undefined,
      nickname: user.nickname,
      type: 'refresh',
    };

    const token = this.jwtService.sign(accessPayload, {
      expiresIn: this.ACCESS_TOKEN_EXPIRES,
    });

    const refreshToken = this.jwtService.sign(refreshPayload, {
      expiresIn: this.REFRESH_TOKEN_EXPIRES,
    });

    return {
      token,
      refreshToken,
      expiresIn: 7 * 24 * 60 * 60, // 7天（秒）
    };
  }

  /**
   * 验证短信验证码
   */
  private async verifySmsCode(phone: string, code: string): Promise<boolean> {
    const key = `${this.SMS_CODE_PREFIX}${phone}`;
    const client = this.redisService.getClient();
    const storedCode = await client.get(key);
    return storedCode === code;
  }

  /**
   * 清除短信验证码
   */
  private async clearSmsCode(phone: string): Promise<void> {
    const key = `${this.SMS_CODE_PREFIX}${phone}`;
    const client = this.redisService.getClient();
    await Promise.resolve(client.del(key));
  }

  /**
   * 获取微信用户信息
   * TODO: 实现微信 OAuth 接口调用
   */
  private getWechatUserInfo(code: string): {
    openId: string;
    unionId?: string;
    nickname?: string;
    avatar?: string;
  } {
    // TODO: 调用微信 API
    // 1. 用 code 换取 access_token 和 openid
    // 2. 用 access_token 获取用户信息

    // 模拟返回
    this.logger.warn(`微信登录待实现，code: ${code}`);
    return {
      openId: `wx_${code}_${Date.now()}`,
      unionId: undefined,
      nickname: undefined,
      avatar: undefined,
    };
  }
}
