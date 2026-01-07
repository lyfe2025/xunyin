# 技术栈与构建系统

## Monorepo 结构

使用 pnpm workspace 管理，包含三个子项目：

| 项目 | 路径 | 技术栈 |
|------|------|--------|
| 后端 | `server-nestjs/` | NestJS 11 + Prisma 7 + PostgreSQL 16 |
| 前端 | `web/` | Vue 3.5 + Vite 7 + shadcn-vue |
| 移动端 | `app_flutter/` | Flutter 3.8 + Riverpod |

## 后端技术栈 (server-nestjs)

- **框架**: NestJS 11
- **ORM**: Prisma 7
- **数据库**: PostgreSQL 16 + Redis 7
- **认证**: JWT + Passport + 双因素认证 (TOTP)
- **文档**: Swagger (OpenAPI)
- **日志**: Winston + daily-rotate-file
- **文件存储**: 本地 / AWS S3
- **邮件**: Nodemailer

## 前端技术栈 (web)

- **框架**: Vue 3.5 + Composition API
- **构建**: Vite 7 + TypeScript 5.9
- **UI**: shadcn-vue + Tailwind CSS 3.4
- **状态**: Pinia 3
- **路由**: Vue Router 4
- **表单**: VeeValidate + Zod
- **富文本**: Tiptap

## 移动端技术栈 (app_flutter)

- **框架**: Flutter 3.8 (Dart)
- **状态管理**: Riverpod 2
- **路由**: go_router
- **网络**: Dio
- **存储**: shared_preferences + flutter_secure_storage

## 常用命令

```bash
# 安装依赖
pnpm install

# 开发模式（同时启动前后端）
pnpm dev

# 单独启动
pnpm dev:web      # 前端 http://localhost:5173
pnpm dev:server   # 后端 http://localhost:3000

# 构建
pnpm build

# 代码检查
pnpm lint

# 类型检查
pnpm type-check   # 前端
pnpm validate     # 后端 (lint + tsc)

# 数据库
pnpm db:migrate   # 创建并应用迁移
pnpm db:seed      # 导入种子数据
pnpm db:studio    # Prisma GUI

# Docker 部署
docker-compose up -d              # 启动全部
docker-compose up -d --build      # 重新构建并启动
```

## 环境配置

- 后端环境变量: `server-nestjs/.env` (参考 `.env.example`)
- 前端环境变量: `web/.env.development`, `web/.env.production`
- Docker 环境: 根目录 `.env`

## 端口约定

| 服务 | 开发端口 | Docker 端口 |
|------|----------|-------------|
| 前端 | 5173 | 8080 |
| 后端 | 3000 | 3000 |
| PostgreSQL | 5433 | 5433 |
| Redis | 6379 | 6379 |
