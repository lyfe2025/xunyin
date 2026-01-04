import { Injectable, Logger } from '@nestjs/common';
import { RedisService } from '../redis/redis.service';
import { PrismaService } from '../prisma/prisma.service';

export interface UserStatusInfo {
  exists: boolean;
  status: string; // '0' = 正常, '1' = 停用
  delFlag: string; // '0' = 正常, '2' = 已删除
}

/**
 * 用户状态缓存服务
 * 用于在 JWT Guard 中快速校验用户状态，避免每次请求都查库
 */
@Injectable()
export class UserStatusCacheService {
  private readonly logger = new Logger(UserStatusCacheService.name);
  private readonly CACHE_PREFIX = 'user:status:';
  private readonly CACHE_TTL = 300; // 缓存 5 分钟

  constructor(
    private readonly redis: RedisService,
    private readonly prisma: PrismaService,
  ) {}

  /**
   * 获取用户状态（优先从缓存读取）
   */
  async getUserStatus(userId: string): Promise<UserStatusInfo> {
    const cacheKey = `${this.CACHE_PREFIX}${userId}`;
    const client = this.redis.getClient();

    // 1. 尝试从缓存读取
    const cached = await client.get(cacheKey);
    if (cached) {
      try {
        return JSON.parse(cached) as UserStatusInfo;
      } catch {
        // 缓存数据损坏，忽略
      }
    }

    // 2. 从数据库查询
    const user = await this.prisma.sysUser.findUnique({
      where: { userId: BigInt(userId) },
      select: { status: true, delFlag: true },
    });

    const statusInfo: UserStatusInfo = user
      ? {
          exists: true,
          status: user.status || '0',
          delFlag: user.delFlag || '0',
        }
      : { exists: false, status: '1', delFlag: '2' };

    // 3. 写入缓存
    await client.setex(cacheKey, this.CACHE_TTL, JSON.stringify(statusInfo));

    return statusInfo;
  }

  /**
   * 使用户状态缓存失效（用户状态变更时调用）
   */
  async invalidateUserStatus(userId: string): Promise<void> {
    const cacheKey = `${this.CACHE_PREFIX}${userId}`;
    const client = this.redis.getClient();
    await Promise.resolve(client.del(cacheKey));
    this.logger.debug(`用户状态缓存已失效: ${userId}`);
  }

  /**
   * 清除所有用户状态缓存（seed 数据后调用）
   */
  async clearAllUserStatusCache(): Promise<void> {
    const client = this.redis.getClient();
    const pattern = `${this.CACHE_PREFIX}*`;

    // 使用 scanStream 遍历并删除
    const iter = client.scanStream({ match: pattern, count: 100 });

    return new Promise((resolve) => {
      const keysToDelete: string[] = [];

      iter.on('data', (keys: string[]) => {
        keysToDelete.push(...keys);
      });

      iter.on('end', async () => {
        if (keysToDelete.length > 0) {
          for (const key of keysToDelete) {
            await Promise.resolve(client.del(key));
          }
          this.logger.log(`已清除 ${keysToDelete.length} 个用户状态缓存`);
        }
        resolve();
      });
    });
  }
}
