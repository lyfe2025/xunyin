import { Injectable } from '@nestjs/common'
import { HealthIndicatorResult, HealthCheckError } from '@nestjs/terminus'
import { RedisService } from '../redis/redis.service'

@Injectable()
export class RedisHealthIndicator {
  constructor(private redis: RedisService) {}

  async isHealthy(key: string): Promise<HealthIndicatorResult> {
    try {
      const pong: string = await this.redis.ping()
      const isHealthy = pong === 'PONG'
      return {
        [key]: {
          status: isHealthy ? 'up' : 'down',
          response: pong,
        },
      }
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err))
      throw new HealthCheckError('Redis health check failed', {
        [key]: {
          status: 'down',
          message: error.message,
        },
      })
    }
  }
}
