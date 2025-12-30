import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { Request } from 'express';

/**
 * App 当前用户信息接口
 */
export interface CurrentAppUser {
  userId: string;
  phone?: string;
  nickname: string;
}

/**
 * 获取当前登录的 App 用户
 *
 * @example
 * ```typescript
 * @Get('profile')
 * @UseGuards(AppAuthGuard)
 * async getProfile(@CurrentUser() user: CurrentAppUser) {
 *   return user;
 * }
 * ```
 */
export const CurrentUser = createParamDecorator(
  (data: keyof CurrentAppUser | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest<Request>();
    const user = request.user as CurrentAppUser;

    // 如果指定了属性名，返回该属性
    if (data) {
      return user?.[data];
    }

    return user;
  },
);
