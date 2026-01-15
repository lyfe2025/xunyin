import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common'
import { PrismaClient } from '@prisma/client'
import { Pool } from 'pg'
import { PrismaPg } from '@prisma/adapter-pg'
import { ConfigService } from '@nestjs/config'

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private pool: Pool

  constructor(configService: ConfigService) {
    const connectionString = configService.get<string>('DATABASE_URL')
    const pool = new Pool({
      connectionString,
      // 连接池配置
      max: 20, // 最大连接数（降低以减少资源占用）
      idleTimeoutMillis: 30000, // 空闲连接超时 30 秒
      connectionTimeoutMillis: 10000, // 连接超时 10 秒
      // 不设置 min，让连接池按需创建连接
      // TCP keepalive 配置，防止连接被意外关闭
      keepAlive: true,
      keepAliveInitialDelayMillis: 10000, // 10 秒后开始发送 keepalive
    })

    // 监听连接池错误，避免未处理的错误导致进程崩溃
    pool.on('error', (err) => {
      console.error('Unexpected error on idle client', err)
    })

    const adapter = new PrismaPg(pool)

    super({
      adapter,
      log: ['warn', 'error'],
    })

    this.pool = pool
  }

  async onModuleInit() {
    await this.$connect()
  }

  async onModuleDestroy() {
    await this.$disconnect()
    // 确保连接池也被关闭
    await this.pool.end()
  }
}
