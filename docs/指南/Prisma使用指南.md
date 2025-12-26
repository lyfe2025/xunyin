# Prisma 完整使用指南

## 📖 目录

1. [新人入门](#新人入门)
2. [环境准备](#环境准备)
3. [数据库初始化](#数据库初始化)
4. [日常开发流程](#日常开发流程)
5. [Migration 管理](#migration-管理)
6. [数据回滚](#数据回滚)
7. [常见问题](#常见问题)
8. [命令速查表](#命令速查表)

---

## 新人入门

### 🎯 Prisma 是什么?

Prisma 是一个现代化的 ORM(对象关系映射)工具,它帮助我们:
- 📝 用 TypeScript 定义数据库模型
- 🔄 自动生成类型安全的数据库客户端
- 📦 管理数据库结构变更(Migration)
- 🌱 初始化测试数据(Seed)

### 📁 项目结构

```
server-nestjs/
├── prisma/
│   ├── schema.prisma       # 数据模型定义
│   ├── seed.ts             # 初始数据脚本
│   └── migrations/         # 数据库变更历史
│       ├── 0_init/
│       │   └── migration.sql
│       └── 1_add_table_comments/
│           └── migration.sql
├── prisma.config.ts        # Prisma 配置
├── .env                    # 环境变量(包含数据库连接)
└── package.json
```

---

## 环境准备

### 第 1 步: 创建数据库

#### 使用 PostgreSQL

```bash
# 1. 登录 PostgreSQL
psql -U postgres

# 2. 创建数据库
CREATE DATABASE xunyin_admin;

# 3. 创建用户(可选)
CREATE USER xunyin_admin WITH PASSWORD 'XunyinAdmin@2024';

# 4. 授权
GRANT ALL PRIVILEGES ON DATABASE xunyin_admin TO xunyin_admin;

# 5. 退出
\q
```

#### 使用 Docker(推荐)

```bash
# 启动 PostgreSQL 容器
docker run -d \
  --name postgres-xunyin \
  -e POSTGRES_DB=xunyin_admin \
  -e POSTGRES_USER=xunyin_admin \
  -e POSTGRES_PASSWORD=XunyinAdmin@2024 \
  -p 5432:5432 \
  postgres:15
```

### 第 2 步: 配置环境变量

```bash
# 进入后端目录
cd server-nestjs

# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件
vim .env
```

配置数据库连接:

```env
# .env 文件内容
DATABASE_URL="postgresql://xunyin_admin:XunyinAdmin@2024@localhost:5432/xunyin_admin?schema=public"

# 格式说明:
# postgresql://用户名:密码@主机:端口/数据库名?schema=模式名
```

### 第 3 步: 安装依赖

```bash
# 在 server-nestjs 目录下
npm install
```

---

## 数据库初始化

### 方式 1: 使用 Migration(推荐)

这是标准的 Prisma 工作流,适合团队协作。

```bash
# 确保在 server-nestjs 目录
cd server-nestjs

# 1. 应用所有 migrations
npx prisma migrate deploy

# 输出示例:
# Applying migration `0_init`
# Applying migration `1_add_table_comments`
# The following migration(s) have been applied:
# migrations/
#   └─ 0_init/
#       └─ migration.sql
#   └─ 1_add_table_comments/
#       └─ migration.sql

# 2. 初始化数据
npx prisma db seed

# 输出示例:
# Running seed command `ts-node prisma/seed.ts` ...
# Start seeding ...
# Initialized department hierarchy
# Ensured admin role with id: 1
# Ensured user with id: 1
# 🌱 The seed command has been executed.

# 3. 验证数据(可选)
npx prisma studio
# 会打开浏览器,可视化查看数据库
```

### 方式 2: 使用 SQL 脚本(备选)

如果你更熟悉 SQL,也可以直接执行初始化脚本。

```bash
# 在项目根目录
psql -h localhost -U xunyin_admin -d xunyin_admin -f db/schema.sql
psql -h localhost -U xunyin_admin -d xunyin_admin -f db/init_data.sql
```

### 验证初始化结果

```bash
# 方法 1: 使用 Prisma Studio
npx prisma studio

# 方法 2: 使用 psql
psql -h localhost -U xunyin_admin -d xunyin_admin

# 查看表
\dt

# 查看用户
SELECT user_name, nick_name, status FROM sys_user WHERE del_flag = '0';

# 查看角色
SELECT role_name, role_key, role_sort FROM sys_role WHERE del_flag = '0';
```

**预期结果:**
- ✅ 用户: admin (密码: admin123)
- ✅ 角色: 超级管理员、部门管理员、普通管理员
- ✅ 部门: 总公司及其子部门
- ✅ 菜单: 完整的菜单树

---

## 日常开发流程

### 场景 1: 添加新字段

假设要给 `sys_user` 表添加 `age` 字段。

#### 步骤 1: 修改 schema.prisma

```prisma
model SysUser {
  userId      BigInt    @id @default(autoincrement()) @map("user_id")
  userName    String    @map("user_name") @db.VarChar(30)
  age         Int?      @map("age")  // 新增字段
  // ... 其他字段
  
  @@map("sys_user")
}
```

#### 步骤 2: 生成 migration

```bash
# 在 server-nestjs 目录
npx prisma migrate dev --name add_user_age

# Prisma 会:
# 1. 生成 SQL 文件: migrations/20251205XXXXXX_add_user_age/migration.sql
# 2. 应用到本地数据库
# 3. 重新生成 TypeScript 类型
```

生成的 SQL 示例:

```sql
-- migrations/20251205XXXXXX_add_user_age/migration.sql
ALTER TABLE "sys_user" ADD COLUMN "age" INTEGER;
```

#### 步骤 3: 使用新字段

```typescript
// 在代码中使用
const user = await prisma.sysUser.create({
  data: {
    userName: 'test',
    age: 25,  // TypeScript 会自动识别这个字段
  },
});
```

#### 步骤 4: 提交代码

```bash
git add prisma/
git commit -m "feat: add age field to user table"
git push
```

### 场景 2: 创建新表

#### 步骤 1: 在 schema.prisma 中定义

```prisma
model SysNotification {
  notificationId BigInt   @id @default(autoincrement()) @map("notification_id")
  title          String   @db.VarChar(100)
  content        String   @db.Text
  userId         BigInt   @map("user_id")
  isRead         String   @default("0") @map("is_read") @db.Char(1)
  createTime     DateTime @default(now()) @map("create_time")
  
  user           SysUser  @relation(fields: [userId], references: [userId])
  
  @@map("sys_notification")
}

// 同时需要在 SysUser 中添加关联
model SysUser {
  // ... 其他字段
  notifications  SysNotification[]
}
```

#### 步骤 2: 生成 migration

```bash
npx prisma migrate dev --name create_notification_table
```

### 场景 3: 团队成员同步

当其他成员拉取了你的代码:

```bash
# 1. 拉取代码
git pull

# 2. 安装可能的新依赖
npm install

# 3. 应用新的 migrations
npx prisma migrate dev

# Prisma 会自动:
# - 检测到新的 migration
# - 应用到本地数据库
# - 重新生成 TypeScript 类型
```

---

## Migration 管理

### 查看 Migration 状态

```bash
npx prisma migrate status

# 输出示例:
# 2 migrations found in prisma/migrations
# 
# Database schema is up to date!
```

### Migration 命令对比

| 命令 | 用途 | 环境 | 说明 |
|------|------|------|------|
| `migrate dev` | 开发时创建和应用 migration | 开发 | 会修改数据库并生成类型 |
| `migrate deploy` | 只应用 migration,不生成新的 | 生产 | 用于 CI/CD 和生产部署 |
| `migrate status` | 查看 migration 状态 | 任何 | 只读操作 |
| `migrate reset` | 重置数据库 | 开发 | ⚠️ 删除所有数据! |
| `migrate resolve` | 标记 migration 为已应用 | 任何 | 用于修复状态 |

### 生产环境部署

```bash
# 在生产服务器上
cd server-nestjs

# 1. 应用 migrations (不会生成新文件)
npx prisma migrate deploy

# 2. 可选: 初始化数据
npx prisma db seed
```

---

## 数据回滚

### ⚠️ 重要说明

Prisma **不支持自动回滚**,需要手动创建回滚 migration。

### 方法 1: 创建反向 Migration(推荐)

假设你刚才添加了 `age` 字段,现在想回滚:

#### 步骤 1: 修改 schema.prisma

```prisma
model SysUser {
  userId      BigInt    @id @default(autoincrement()) @map("user_id")
  userName    String    @map("user_name") @db.VarChar(30)
  // age         Int?      @map("age")  // 删除这行
  // ... 其他字段
}
```

#### 步骤 2: 生成回滚 migration

```bash
npx prisma migrate dev --name remove_user_age

# 生成的 SQL:
# ALTER TABLE "sys_user" DROP COLUMN "age";
```

### 方法 2: 手动编写回滚 SQL

如果 migration 比较复杂,可以手动编写:

```bash
# 1. 创建 migration 目录
mkdir -p prisma/migrations/$(date +%Y%m%d%H%M%S)_rollback_user_age

# 2. 创建 migration.sql
cat > prisma/migrations/$(date +%Y%m%d%H%M%S)_rollback_user_age/migration.sql << 'EOF'
-- 回滚: 删除 age 字段
ALTER TABLE "sys_user" DROP COLUMN IF EXISTS "age";
EOF

# 3. 应用 migration
npx prisma migrate deploy
```

### 方法 3: 完全重置(仅开发环境)

⚠️ **警告: 这会删除所有数据!**

```bash
# 重置数据库到初始状态
npx prisma migrate reset

# 这会:
# 1. 删除数据库
# 2. 重新创建数据库
# 3. 应用所有 migrations
# 4. 运行 seed 脚本
```

### 方法 4: 恢复到特定 Migration

如果你想回到某个特定的 migration 状态:

```bash
# 1. 查看 migration 历史
ls -la prisma/migrations/

# 2. 删除不需要的 migration 文件(谨慎!)
rm -rf prisma/migrations/20251205XXXXXX_add_user_age

# 3. 重置数据库
npx prisma migrate reset

# 4. 重新应用剩余的 migrations
npx prisma migrate deploy
```

### 生产环境回滚策略

**推荐流程:**

1. **准备回滚 migration**
   ```bash
   # 在开发环境测试回滚
   npx prisma migrate dev --name rollback_xxx
   ```

2. **测试回滚**
   ```bash
   # 在测试环境验证
   npx prisma migrate deploy
   ```

3. **生产环境执行**
   ```bash
   # 备份数据库
   pg_dump -h localhost -U xunyin_admin xunyin_admin > backup.sql
   
   # 应用回滚 migration
   npx prisma migrate deploy
   ```

4. **验证**
   ```bash
   # 检查数据完整性
   npx prisma studio
   ```

---

## 常见问题

### Q1: 报错 "Could not find Prisma Schema"

**原因:** 在错误的目录运行命令

**解决:**
```bash
# 确保在 server-nestjs 目录
cd server-nestjs
pwd  # 应该显示 .../server-nestjs
```

### Q2: Migration 冲突

**场景:** 多人同时修改了 schema

**解决:**
```bash
# 1. 拉取最新代码
git pull

# 2. 如果有冲突,解决 schema.prisma 冲突

# 3. 重新生成 migration
npx prisma migrate dev --name merge_changes
```

### Q3: 数据库状态不一致

**症状:** `migrate status` 显示不一致

**解决:**
```bash
# 方法 1: 标记为已应用(如果确定已执行)
npx prisma migrate resolve --applied <migration_name>

# 方法 2: 标记为回滚(如果需要重新执行)
npx prisma migrate resolve --rolled-back <migration_name>

# 方法 3: 重置(开发环境)
npx prisma migrate reset
```

### Q4: Seed 执行失败

**原因:** 数据已存在或约束冲突

**解决:**
```bash
# 我们的 seed.ts 已经是幂等的,可以安全重试
npx prisma db seed

# 如果还是失败,检查错误信息
# 可能需要清理冲突数据
```

### Q5: 生成的类型不正确

**解决:**
```bash
# 重新生成 Prisma Client
npx prisma generate

# 重启 TypeScript 服务器(VSCode)
# Cmd/Ctrl + Shift + P -> "TypeScript: Restart TS Server"
```

### Q6: 连接数据库失败

**检查清单:**
```bash
# 1. 数据库是否运行
pg_isready -h localhost -p 5432

# 2. 环境变量是否正确
cat .env | grep DATABASE_URL

# 3. 用户权限是否足够
psql -h localhost -U xunyin_admin -d xunyin_admin -c "SELECT 1"

# 4. 防火墙是否开放
telnet localhost 5432
```

### Q7: 可以直接去数据库改表结构吗?

**答案: 强烈不建议!**

如果你手动改了数据库,Prisma 的 `schema.prisma` 和 `migrations` 就会和数据库状态不一致,导致下次迁移报错。

**正确做法:**
```bash
# 1. 修改 schema.prisma
vim prisma/schema.prisma

# 2. 生成 migration
npx prisma migrate dev --name <描述>
```

### Q8: `npx prisma generate` 是做什么的?

**答案:** 它读取 `schema.prisma` 并生成 TypeScript 类型定义和 Client 代码。

**何时需要运行:**
- 拉取别人代码后
- CI/CD 环境中
- Client 报错提示找不到字段时

**说明:** 通常 `migrate dev` 会自动触发它,但有时需要手动运行。

---

## 交互式脚本 db.sh

项目根目录提供了 `db.sh` 交互式脚本，封装了常用的 Prisma 命令：

```bash
./db.sh    # 启动交互式菜单
```

### 功能菜单

**本地开发**
| 序号 | 功能 | 命令 |
|------|------|------|
| 1 | 生成 Prisma Client | `pnpm prisma generate` |
| 2 | 创建开发迁移 | `pnpm prisma migrate dev --name xxx` |
| 3 | 查看迁移状态 | `pnpm prisma migrate status` |
| 4 | 重置数据库 (危险) | `pnpm prisma migrate reset` |
| 5 | 推送 Schema | `pnpm prisma db push` |
| 6 | 拉取数据库 Schema | `pnpm prisma db pull` |
| 7 | 导入种子数据 | `pnpm prisma db seed` |
| 8 | 启动 Prisma Studio | `pnpm prisma studio` |
| 9 | 格式化 Schema | `pnpm prisma format` |
| 10 | 验证 Schema | `pnpm prisma validate` |

**Docker / 生产环境**
| 序号 | 功能 | 命令 |
|------|------|------|
| 11 | 执行生产迁移 | `DATABASE_URL=... pnpm prisma migrate deploy` |
| 12 | 查看迁移状态 | `DATABASE_URL=... pnpm prisma migrate status` |
| 13 | 导入种子数据 | `DATABASE_URL=... pnpm prisma db seed` |
| 14 | 执行 SQL 文件 | `docker exec -i xunyin-postgres psql < file.sql` |
| 15 | 备份数据库 | `docker exec xunyin-postgres pg_dump > backup.sql` |
| 16 | 恢复数据库 | `docker exec -i xunyin-postgres psql < backup.sql` |
| 17 | 连接 PostgreSQL | `docker exec -it xunyin-postgres psql` |

### 命令行直接调用

```bash
./db.sh generate       # 生成 Prisma Client
./db.sh migrate-dev    # 创建开发迁移
./db.sh deploy         # 执行生产迁移
./db.sh backup         # 备份数据库
./db.sh --help         # 查看所有命令
```

---

## 命令速查表

### 📋 快速参考表

⚠️ **重要:** 所有命令必须在 `server-nestjs` 目录下执行（或使用根目录的 `db.sh` 脚本）!

| 命令 | 作用 | 使用场景 | 环境 |
|------|------|---------|------|
| `npx prisma migrate dev` | **最常用**。根据 schema.prisma 的变更更新数据库,并记录 migration | 开发阶段,修改了表结构后 | 开发 |
| `npx prisma migrate dev --name <name>` | 同上,但可以给这次变更起个名字(如 `add_user_age`) | 提交有意义的变更记录 | 开发 |
| `npx prisma migrate deploy` | **生产环境专用**。只应用未执行的 migration,不生成新文件 | 在服务器部署上线时使用 | 生产 |
| `npx prisma migrate status` | 查看 migration 状态 | 检查哪些 migration 还未应用 | 任何 |
| `npx prisma migrate reset` | **清空数据库**,重新执行所有 migration 和 seed | ⚠️ **慎用**。想重置环境从头开始时 | 开发 |
| `npx prisma db seed` | 执行 seed.ts 脚本,填充初始数据 | 初始化数据库后,或者想重置测试数据时 | 任何 |
| `npx prisma studio` | 打开一个 Web 界面,可以直接查看和编辑数据库数据 | 想直观查看数据,不想写 SQL 时 | 任何 |
| `npx prisma generate` | 重新生成 TypeScript 类型和 Client 代码 | 拉取别人代码后,或 Client 报错提示找不到字段时 | 任何 |
| `npx prisma format` | 格式化 schema.prisma 文件 | 保持代码风格一致 | 开发 |
| `npx prisma validate` | 验证 schema.prisma 语法 | 检查 schema 是否有错误 | 任何 |

### 基础命令

```bash
# 查看帮助
npx prisma --help
npx prisma migrate --help

# 查看版本
npx prisma --version
```

### Migration 命令详解

```bash
# 开发环境: 创建并应用 migration
npx prisma migrate dev --name <描述>
# 例如: npx prisma migrate dev --name add_user_age

# 生产环境: 只应用 migration
npx prisma migrate deploy

# 查看状态
npx prisma migrate status

# 重置数据库(⚠️ 删除所有数据)
npx prisma migrate reset

# 标记 migration 为已应用(修复状态用)
npx prisma migrate resolve --applied <migration_name>

# 标记 migration 为已回滚(修复状态用)
npx prisma migrate resolve --rolled-back <migration_name>

# 生成 migration SQL 但不应用(高级用法)
npx prisma migrate diff \
  --from-schema-datamodel prisma/schema.prisma \
  --to-schema-datasource prisma/schema.prisma \
  --script
```

### 数据库命令

```bash
# 初始化数据(幂等,可重复执行)
npx prisma db seed

# 推送 schema 到数据库(不创建 migration,快速原型开发用)
npx prisma db push

# 从数据库拉取 schema(反向工程)
npx prisma db pull

# 执行原始 SQL
npx prisma db execute --file ./script.sql
```

### 开发工具

```bash
# 打开数据库可视化界面(推荐!)
npx prisma studio
# 访问 http://localhost:5555

# 生成 Prisma Client(TypeScript 类型)
npx prisma generate

# 格式化 schema.prisma
npx prisma format

# 验证 schema.prisma 语法
npx prisma validate
```

### 常用组合命令

```bash
# 新环境初始化
npx prisma migrate deploy && npx prisma db seed

# 开发时修改 schema
npx prisma migrate dev --name <描述>

# 重置并重新初始化(开发环境)
npx prisma migrate reset

# 查看并验证
npx prisma migrate status && npx prisma studio

# 拉取代码后同步
git pull && npm install && npx prisma migrate dev

# 部署前检查
npx prisma validate && npx prisma migrate status
```

### 🔧 调试命令

```bash
# 查看 Prisma 配置
npx prisma --version

# 查看数据库连接
npx prisma db execute --stdin <<< "SELECT 1"

# 查看生成的 SQL(不执行)
npx prisma migrate diff \
  --from-empty \
  --to-schema-datamodel prisma/schema.prisma \
  --script

# 查看 migration 历史
ls -la prisma/migrations/

# 查看数据库中的 migration 记录
psql $DATABASE_URL -c "SELECT * FROM _prisma_migrations ORDER BY finished_at"
```

---

## 最佳实践

### ✅ 推荐做法

1. **始终使用 migration**
   - ❌ 不要直接修改数据库
   - ✅ 通过 `schema.prisma` + `migrate dev` 管理变更

2. **Migration 命名规范**
   ```bash
   # 好的命名
   npx prisma migrate dev --name add_user_age
   npx prisma migrate dev --name create_notification_table
   npx prisma migrate dev --name fix_user_email_constraint
   
   # 不好的命名
   npx prisma migrate dev --name update
   npx prisma migrate dev --name fix
   ```

3. **提交前检查**
   ```bash
   # 确保类型正确
   npm run check
   
   # 确保 migration 已生成
   git status | grep migrations
   ```

4. **生产部署前测试**
   ```bash
   # 在测试环境先验证
   npx prisma migrate deploy
   ```

5. **定期备份**
   ```bash
   # 生产环境定期备份
   pg_dump -h localhost -U xunyin_admin xunyin_admin > backup_$(date +%Y%m%d).sql
   ```

### ❌ 避免的做法

1. ❌ 不要在生产环境使用 `migrate dev`
2. ❌ 不要手动修改 migration 文件(除非你知道自己在做什么)
3. ❌ 不要删除已应用的 migration
4. ❌ 不要在 `schema.prisma` 和数据库之间不一致
5. ❌ 不要在生产环境使用 `migrate reset`

---

## 参考资源

### 📚 官方文档
- [Prisma 官方文档](https://www.prisma.io/docs)
- [Prisma Migration 指南](https://www.prisma.io/docs/concepts/components/prisma-migrate)
- [Prisma Schema 参考](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference)

---

**文档版本:** v1.0  
**最后更新:** 2025-12-05  
**维护者:** 开发团队
