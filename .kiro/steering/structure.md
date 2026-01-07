# 项目结构

## 根目录

```
xunyin-admin/
├── server-nestjs/     # NestJS 后端
├── web/               # Vue 3 前端（管理后台）
├── app_flutter/       # Flutter 移动端
├── db/                # SQL 脚本（与 Prisma 同步）
├── docs/              # 项目文档
├── docker-compose.yml # Docker 编排
├── monorepo.sh        # 服务管理脚本
└── db.sh              # 数据库管理脚本
```

## 后端结构 (server-nestjs/src)

```
src/
├── admin/             # Admin 端业务模块（管理后台 API）
│   ├── city/          # 城市管理
│   ├── journey/       # 文化之旅管理
│   ├── seal/          # 印记管理
│   └── ...
├── app-auth/          # App 端认证（移动端登录）
├── auth/              # Admin 端认证（后台登录）
├── system/            # 系统管理（用户/角色/菜单/部门等）
├── monitor/           # 监控模块（日志/在线用户/缓存等）
├── common/            # 公共模块
│   ├── decorators/    # 自定义装饰器
│   ├── filters/       # 异常过滤器
│   ├── guards/        # 守卫
│   ├── interceptors/  # 拦截器
│   └── logger/        # 日志服务
├── prisma/            # Prisma 服务
├── redis/             # Redis 服务
└── [业务模块]/        # App 端业务（city/journey/seal 等）
```

### API 路由约定

- Admin 端: `/api/admin/*` (如 `/api/admin/cities`)
- App 端: `/api/app/*` (如 `/api/app/cities`)
- 系统: `/api/system/*`
- 监控: `/api/monitor/*`

## 前端结构 (web/src)

```
src/
├── api/               # API 接口定义
│   ├── system/        # 系统管理 API
│   ├── xunyin/        # 寻印业务 API
│   └── monitor/       # 监控 API
├── components/
│   ├── ui/            # shadcn-vue 基础组件
│   ├── common/        # 通用业务组件
│   └── business/      # 特定业务组件
├── views/             # 页面视图
│   ├── system/        # 系统管理页面
│   ├── xunyin/        # 寻印业务页面
│   └── monitor/       # 监控页面
├── stores/            # Pinia 状态管理
├── router/            # 路由配置
├── composables/       # 组合式函数
├── utils/             # 工具函数
└── types/             # TypeScript 类型定义
```

## Flutter 结构 (app_flutter/lib)

```
lib/
├── core/              # 核心模块
│   ├── api/           # API 客户端
│   ├── config/        # 配置
│   ├── router/        # 路由
│   ├── storage/       # 本地存储
│   └── theme/         # 主题
├── features/          # 功能模块
│   ├── auth/          # 认证
│   ├── home/          # 首页
│   ├── city/          # 城市
│   ├── journey/       # 文化之旅
│   ├── seal/          # 印记
│   └── profile/       # 个人中心
├── models/            # 数据模型
├── providers/         # Riverpod 状态
├── services/          # 业务服务
└── shared/widgets/    # 共享组件
```

## 数据库 (server-nestjs/prisma)

```
prisma/
├── schema.prisma      # 数据模型定义（主要来源）
├── migrations/        # 迁移文件
└── seed.ts            # 种子数据
```

## 文档 (docs/)

```
docs/
├── 指南/              # 使用指南（Prisma、Docker、SMTP 等）
├── 开发规范/          # 开发规范（日志、错误处理、测试）
├── 前端/              # 前端相关文档
├── 后端/              # 后端相关文档
└── 历史记录/          # 开发历史记录
```
