import { Injectable, ExecutionContext } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { BusinessException } from '../../common/exceptions';
import { ErrorCode } from '../../common/enums';

/**
 * App 端认证守卫
 * 使用 'app-jwt' 策略验证 Token
 */
@Injectable()
export class AppAuthGuard extends AuthGuard('app-jwt') {
  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }

  handleRequest<TUser = any>(
    err: Error | null,
    user: TUser,
    info: { name?: string } | null,
  ): TUser {
    // Token 验证失败
    if (err || !user) {
      if (info?.name === 'TokenExpiredError') {
        throw new BusinessException(ErrorCode.TOKEN_EXPIRED, 'Token 已过期');
      }
      if (info?.name === 'JsonWebTokenError') {
        throw new BusinessException(ErrorCode.INVALID_TOKEN, 'Token 无效');
      }
      throw new BusinessException(ErrorCode.UNAUTHORIZED, '请先登录');
    }
    return user;
  }
}
