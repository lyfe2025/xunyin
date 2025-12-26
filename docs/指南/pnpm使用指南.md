# pnpm 使用指南

本项目采用 pnpm workspace 管理 Monorepo，可在根目录统一管理前后端。

## pnpm 简介

### 与 npm 对比

| 特性 | npm | pnpm |
|------|-----|------|
| 存储方式 | 扁平化 node_modules | 内容寻址存储 + 符号链接 |
| 磁盘占用 | 高（重复安装） | 低（全局共享，节省 50%-80%） |
| 安装速度 | 基准 | 快 2-3 倍 |
| 幽灵依赖 | 存在 | 不存在（严格模式） |
| Monorepo | 需要 lerna 等工具 | 原生 workspace 支持 |

### 核心优势

1. **内容寻址存储**：所有包存储在全局 `~/.pnpm-store/`，项目通过硬链接引用
2. **严格依赖**：只能访问 `package.json` 中声明的依赖，避免幽灵依赖
3. **原生 Workspace**：完美支持 Monorepo 项目

## 安装 pnpm

```bash
# 使用 npm 安装
npm install -g pnpm

# 使用 Homebrew (macOS)
brew install pnpm

# 使用 corepack (Node.js 16.13+)
corepack enable
corepack prepare pnpm@latest --activate
```

## 项目初始化

```bash
# 克隆项目后，在根目录安装所有依赖
pnpm install
```

这会自动安装 `web/` 和 `server-nestjs/` 的依赖，并建立 workspace 链接。

## 常用命令

### 开发命令

| 命令 | 说明 |
|------|------|
| `pnpm dev` | 同时启动前端和后端开发服务器 |
| `pnpm dev:web` | 只启动前端 (http://localhost:5173) |
| `pnpm dev:server` | 只启动后端 (http://localhost:3000) |

### 构建命令

| 命令 | 说明 |
|------|------|
| `pnpm build` | 构建前端和后端 |
| `pnpm build:web` | 只构建前端 |
| `pnpm build:server` | 只构建后端 |

### 代码检查

| 命令 | 说明 |
|------|------|
| `pnpm lint` | 检查所有代码 |
| `pnpm format` | 格式化所有代码 |
| `pnpm type-check` | 前端 TypeScript 类型检查 |
| `pnpm validate` | 后端 lint + 类型检查 |

### 数据库命令

| 命令 | 说明 |
|------|------|
| `pnpm db:migrate` | 创建并应用数据库迁移 |
| `pnpm db:generate` | 重新生成 Prisma Client |
| `pnpm db:seed` | 运行种子数据脚本 |
| `pnpm db:studio` | 打开 Prisma Studio GUI |

## 依赖管理

### 命令对比

| 操作 | npm | pnpm |
|------|-----|------|
| 安装所有依赖 | `npm install` | `pnpm install` |
| 添加依赖 | `npm install pkg` | `pnpm add pkg` |
| 添加开发依赖 | `npm install -D pkg` | `pnpm add -D pkg` |
| 全局安装 | `npm install -g pkg` | `pnpm add -g pkg` |
| 移除依赖 | `npm uninstall pkg` | `pnpm remove pkg` |
| 运行脚本 | `npm run dev` | `pnpm dev` |
| 更新依赖 | `npm update` | `pnpm update` |
| 清理缓存 | `npm cache clean` | `pnpm store prune` |

### 添加依赖

```bash
# 给前端添加依赖
pnpm --filter web add axios

# 给前端添加开发依赖
pnpm --filter web add -D @types/node

# 给后端添加依赖
pnpm --filter server-nestjs add lodash

# 给根目录添加依赖（通常是开发工具）
pnpm add -w -D prettier
```

### 移除依赖

```bash
# 从前端移除
pnpm --filter web remove axios

# 从后端移除
pnpm --filter server-nestjs remove lodash
```

### 更新依赖

```bash
# 更新所有包的依赖
pnpm -r update

# 更新指定包的依赖
pnpm --filter web update

# 交互式更新
pnpm -r update -i
```

## 在子项目中运行命令

```bash
# 在前端运行任意命令
pnpm --filter web <command>

# 在后端运行任意命令
pnpm --filter server-nestjs <command>

# 在所有子项目中运行
pnpm -r <command>

# 并行运行
pnpm -r --parallel <command>
```

### 示例

```bash
# 前端类型检查
pnpm --filter web run type-check

# 后端运行测试
pnpm --filter server-nestjs run test

# 在后端执行 prisma 命令
pnpm --filter server-nestjs exec prisma studio
```

## Workspace 配置

项目根目录的 `pnpm-workspace.yaml`：

```yaml
packages:
  - 'web'
  - 'server-nestjs'
```

## 与交互式脚本的区别

项目提供两个交互式脚本：

| 脚本 | 用途 |
|------|------|
| `./monorepo.sh` | 服务管理（启停、构建、Docker 部署） |
| `./db.sh` | 数据库管理（Prisma 迁移、备份恢复） |

### pnpm vs monorepo.sh

| 功能 | pnpm | monorepo.sh |
|------|------|-------------|
| 启动服务 | `pnpm dev` | `./monorepo.sh` → 选择 1 |
| 运行方式 | 前台运行 | 后台运行 + 日志跟踪 |
| 状态监控 | 无 | 有（PID、端口、运行时间） |
| 交互式菜单 | 无 | 有 |
| 日志管理 | 终端输出 | 文件记录 + tail 跟踪 |
| Docker 部署 | 无 | 有（启动/停止/构建/日志） |

### monorepo.sh 功能

**本地开发 (1-9)**
- 一键启停前后端、数据库迁移、Prisma Studio
- 代码检查、API 冒烟测试、数据库重置

**Docker 部署 (10-19)**
- 启动/停止/重启服务
- 构建镜像、查看状态、查看日志

### 建议

- 日常开发用 `pnpm dev`（简单直接）
- 需要后台运行或状态监控时用 `./monorepo.sh`
- 数据库操作用 `./db.sh`（特别是生产环境迁移和备份）

## 从 npm 迁移

```bash
# 1. 删除现有 node_modules 和 lock 文件
rm -rf node_modules package-lock.json
rm -rf web/node_modules web/package-lock.json
rm -rf server-nestjs/node_modules server-nestjs/package-lock.json

# 2. 使用 pnpm 安装
pnpm install
```

## 常见问题

### 1. 安装依赖报错

```bash
# 清理缓存重新安装
rm -rf node_modules web/node_modules server-nestjs/node_modules
pnpm store prune
pnpm install
```

### 2. 幽灵依赖报错

pnpm 严格模式下，不能使用未声明的依赖。如果报错找不到某个包：

```bash
# 显式添加该依赖
pnpm --filter <package> add <missing-dep>
```

### 3. 查看依赖树

```bash
# 查看某个包的依赖
pnpm --filter web list

# 查看为什么安装了某个包
pnpm --filter web why lodash
```

### 4. 清理 pnpm store

```bash
# 清理未使用的包
pnpm store prune
```

## 参考链接

- [pnpm 官方文档](https://pnpm.io/zh/)
- [pnpm Workspace](https://pnpm.io/zh/workspaces)
- [pnpm 性能对比](https://pnpm.io/benchmarks)
