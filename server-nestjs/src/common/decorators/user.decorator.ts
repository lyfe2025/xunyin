import { createParamDecorator, ExecutionContext } from '@nestjs/common'
import type { Request } from 'express'

/**
 * Admin 端 JWT 用户信息
 */
export interface JwtUser {
  userId: string
  userName: string
}

interface JwtPayload {
  sub: string
  username: string
}

/**
 * Admin 端获取当前用户装饰器
 *
 * @example
 * ```typescript
 * @Get('profile')
 * @UseGuards(JwtAuthGuard)
 * async getProfile(@CurrentUser() user: JwtUser) {
 *   return user;
 * }
 * ```
 */
export const CurrentUser = createParamDecorator(
  (data: keyof JwtUser | undefined, ctx: ExecutionContext): JwtUser | string | undefined => {
    const request = ctx.switchToHttp().getRequest<Request & { user?: JwtPayload }>()
    const payload = request.user

    if (!payload) {
      return undefined
    }

    const user: JwtUser = {
      userId: payload.sub,
      userName: payload.username,
    }

    return data ? user[data] : user
  },
)
