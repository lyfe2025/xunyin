import { Controller, Get } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger'
import {
  HealthCheck,
  HealthCheckService,
  MemoryHealthIndicator,
  DiskHealthIndicator,
} from '@nestjs/terminus'
import { PrismaHealthIndicator } from './prisma.health'
import { RedisHealthIndicator } from './redis.health'

@ApiTags('健康检查')
@Controller('health')
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private memory: MemoryHealthIndicator,
    private disk: DiskHealthIndicator,
    private prisma: PrismaHealthIndicator,
    private redis: RedisHealthIndicator,
  ) {}

  /**
   * 基础存活检查 - 用于 K8s liveness probe
   * 只检查应用是否在运行，不检查依赖服务
   */
  @Get('liveness')
  @ApiOperation({ summary: '存活检查', description: '检查应用是否在运行' })
  @ApiResponse({ status: 200, description: '应用正常运行' })
  liveness() {
    return { status: 'ok', timestamp: new Date().toISOString() }
  }

  /**
   * 就绪检查 - 用于 K8s readiness probe
   * 检查应用是否准备好接收流量（包括数据库、Redis）
   */
  @Get('readiness')
  @HealthCheck()
  @ApiOperation({ summary: '就绪检查', description: '检查应用是否准备好接收请求' })
  @ApiResponse({ status: 200, description: '应用就绪' })
  @ApiResponse({ status: 503, description: '应用未就绪' })
  readiness() {
    return this.health.check([
      () => this.prisma.isHealthy('database'),
      () => this.redis.isHealthy('redis'),
    ])
  }

  /**
   * 完整健康检查 - 用于监控面板
   * 检查所有依赖服务和系统资源
   */
  @Get()
  @HealthCheck()
  @ApiOperation({ summary: '完整健康检查', description: '检查所有服务和系统资源' })
  @ApiResponse({ status: 200, description: '所有服务健康' })
  @ApiResponse({ status: 503, description: '部分服务不健康' })
  check() {
    return this.health.check([
      // 数据库检查
      () => this.prisma.isHealthy('database'),
      // Redis 检查
      () => this.redis.isHealthy('redis'),
      // 内存检查 - 堆内存不超过 500MB
      () => this.memory.checkHeap('memory_heap', 500 * 1024 * 1024),
      // 磁盘检查 - 根目录使用率不超过 90%
      () => this.disk.checkStorage('disk', { path: '/', thresholdPercent: 0.9 }),
    ])
  }
}
