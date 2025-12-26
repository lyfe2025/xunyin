# Xunyin Admin - Backend (NestJS)

基于 NestJS + TypeScript + PostgreSQL 的企业级后台管理系统后端服务。

## 技术栈

- **框架**: NestJS 11
- **语言**: TypeScript 5.7
- **数据库**: PostgreSQL 16
- **ORM**: Prisma 7
- **认证**: JWT + Passport + 双因素认证 (TOTP)
- **验证**: class-validator + class-transformer
- **日志**: Winston + daily-rotate-file
- **缓存**: Redis (ioredis)
- **文件存储**: AWS S3 / 本地存储
- **邮件**: Nodemailer
- **Excel**: ExcelJS
- **API 文档**: Swagger

## 快速开始

### 环境要求

- Node.js >= 18
- PostgreSQL >= 16
- Redis >= 7

### 安装依赖

```bash
npm install
```

### 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 配置数据库连接等
```

### 初始化数据库

```bash
# 应用迁移
npx prisma migrate dev

# 生成 Prisma Client
npx prisma generate

# 填充种子数据
npx prisma db seed
```

### 运行开发服务器

```bash
npm run start:dev
```

服务运行在 http://localhost:3000

API 文档: http://localhost:3000/api-docs

## 常用命令

```bash
npm run start:dev    # 开发模式 (热重载)
npm run start:debug  # 调试模式
npm run start:prod   # 生产模式
npm run build        # 编译到 dist/
npm run check        # TypeScript 类型检查
npm run lint         # ESLint 检查
npm run validate     # lint + check 组合
npm run format       # Prettier 格式化
```

### 测试命令

```bash
npm run test         # 运行单元测试
npm run test:watch   # 监听模式
npm run test:cov     # 测试覆盖率
npm run test:e2e     # 端到端测试
```

### 数据库命令

```bash
npx prisma migrate dev     # 创建并应用迁移
npx prisma generate        # 重新生成 Client
npx prisma studio          # 数据库 GUI
npx prisma db seed         # 运行种子脚本
./scripts/reset-prisma.sh  # 重置数据库
```

## 目录结构

```
server-nestjs/
├── src/
│   ├── auth/              # 认证模块
│   │   ├── auth.*         # 登录/登出/刷新 Token
│   │   ├── captcha.*      # 图形验证码
│   │   ├── two-factor.*   # 双因素认证 (TOTP)
│   │   ├── token-blacklist.* # Token 黑名单
│   │   └── security-config.* # 安全配置
│   ├── system/            # 系统管理模块
│   │   ├── user/          # 用户管理
│   │   ├── role/          # 角色管理
│   │   ├── dept/          # 部门管理
│   │   ├── menu/          # 菜单管理
│   │   ├── dict/          # 字典管理
│   │   ├── config/        # 参数配置
│   │   ├── post/          # 岗位管理
│   │   └── notice/        # 通知公告
│   ├── monitor/           # 监控模块
│   │   ├── operlog/       # 操作日志
│   │   ├── logininfor/    # 登录日志
│   │   ├── login-log/     # 登录日志 (新)
│   │   ├── online/        # 在线用户
│   │   ├── server/        # 服务监控
│   │   ├── cache/         # 缓存监控
│   │   ├── database/      # 数据库监控
│   │   └── job/           # 定时任务
│   ├── common/            # 公共模块
│   │   ├── decorators/    # 自定义装饰器
│   │   ├── dto/           # 通用 DTO
│   │   ├── enums/         # 枚举定义
│   │   ├── exceptions/    # 自定义异常
│   │   ├── filters/       # 异常过滤器
│   │   ├── guards/        # 守卫
│   │   ├── interceptors/  # 拦截器
│   │   ├── middleware/    # 中间件
│   │   ├── logger/        # 日志服务
│   │   ├── mail/          # 邮件服务
│   │   ├── excel/         # Excel 导入导出
│   │   ├── upload/        # 文件上传
│   │   ├── services/      # 通用服务
│   │   └── utils/         # 工具函数
│   ├── prisma/            # Prisma 服务
│   └── redis/             # Redis 服务
├── prisma/
│   ├── schema.prisma      # 数据库模型
│   ├── migrations/        # 迁移文件
│   └── seed.ts            # 种子数据
├── scripts/               # 工具脚本
├── uploads/               # 文件上传目录
└── logs/                  # 日志文件目录
```

## API 响应格式

```json
{
  "code": 200,
  "msg": "success",
  "data": { ... }
}
```

## 主要功能

### 认证安全
- JWT Token 认证
- 图形验证码
- 双因素认证 (TOTP)
- Token 黑名单机制
- 登录失败锁定

### 文件服务
- 本地文件上传
- AWS S3 云存储
- 文件类型/大小校验

### 数据导出
- Excel 导入导出
- 支持大数据量流式处理

### 邮件服务
- SMTP 邮件发送
- 模板邮件支持

## 默认账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | admin123 | 超级管理员 |
