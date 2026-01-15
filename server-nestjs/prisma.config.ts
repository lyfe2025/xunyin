import path from 'node:path'
import { config } from 'dotenv'
import { defineConfig } from 'prisma/config'

// 显式加载 .env 文件
config({ path: path.resolve(__dirname, '.env') })

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
    seed: 'ts-node prisma/seed.ts',
  },
  datasource: {
    url: process.env.DATABASE_URL!,
  },
})
