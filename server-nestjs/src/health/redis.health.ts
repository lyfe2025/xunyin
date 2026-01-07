import { Injectable } from '@nestjs/common'
import { HealthIndicator, HealthIndicatorResult, HealthCheckError } from '@nestjs/terminus'
import { RedisService } from '../redis/redis.service'

@Injectable()
export class RedisHealthIndicator extends HealthIndicator {
  constructor(private redis: RedisService) {
    super()
  }

  async isHealthy(key: string): Promise<HealthIndicatorResult> {
    try {
      const pong: string = await this.redis.ping()
      const isHealthy = pong === 'PONG'
      const result = this.getStatus(key, isHealthy, { response: pong })
      return result
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err))
      throw new HealthCheckError(
        'Redis health check failed',
        this.getStatus(key, false, { message: error.message }),
      )
    }
  }
}
