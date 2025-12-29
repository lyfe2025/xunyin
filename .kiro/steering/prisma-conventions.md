---
inclusion: fileMatch
fileMatchPattern: "**/*.prisma"
---

# Prisma 数据库规范

> 详细使用指南请参考：`docs/指南/Prisma使用指南.md`

## ⚠️ 关键规则（必须遵守）

### 1. 永远不要使用 `db push`
- ❌ **禁止使用** `npx prisma db push`
- ❌ `db push` 会导致数据库和迁移历史不同步
- ✅ **始终使用** `npx prisma migrate dev --name <描述>`

### 2. Schema 变更的标准流程
```bash
# 1. 修改 schema.prisma
# 2. 创建并应用迁移（必须！）
npx prisma migrate dev --name <描述性名称>
# 3. 如果需要初始数据
npx prisma db seed
```

### 3. Shadow Database 权限问题
`migrate dev` 需要创建 shadow database，如果遇到权限错误：
```
Error: P3014 - permission denied to create database
```
解决方案：用超级用户授权
```bash
psql -h localhost -U <superuser> -c "ALTER USER xunyin_admin CREATEDB;"
```

### 4. 数据库漂移（Drift）处理
如果 `migrate dev` 报告 drift（数据库和迁移历史不同步）：
- **开发环境**：使用 `npx prisma migrate reset --force` 重置
- **生产环境**：手动创建迁移修复差异

## 核心原则

1. **始终使用 migration 管理变更**
   - ❌ 不要直接修改数据库
   - ❌ 不要使用 `db push`（仅用于快速原型，不适合正式开发）
   - ✅ 通过 `schema.prisma` + `migrate dev` 管理变更

2. **所有命令必须在 `server-nestjs` 目录下执行**
   - 或使用根目录的 `./db.sh` 交互式脚本

## 命名规范

### 模型命名
- 模型名使用 PascalCase（如 `AppUser`, `JourneyProgress`）
- 使用 `@@map("snake_case")` 映射到数据库表名
- 表名使用 snake_case（如 `app_user`, `journey_progress`）

### 字段命名
- 字段名使用 camelCase（如 `createTime`, `userId`）
- 使用 `@map("snake_case")` 映射到数据库列名
- 列名使用 snake_case（如 `create_time`, `user_id`）

### 示例
```prisma
model AppUser {
  id         String   @id @default(cuid())
  userId     String   @map("user_id")
  createTime DateTime @default(now()) @map("create_time")
  
  @@map("app_user")
}
```

## 字段类型规范

### ID 字段
- 业务表使用 `String @id @default(cuid())` 作为主键
- 系统表（sys_*）使用 `BigInt @id @default(autoincrement())` 保持兼容

### 状态字段
- 状态字段使用 `String @db.Char(1)`
- `"0"` 表示正常/启用，`"1"` 表示停用/禁用
- 删除标志：`"0"` 存在，`"2"` 已删除

### 时间字段
- `createTime DateTime @default(now()) @map("create_time")`
- `updateTime DateTime @updatedAt @map("update_time")`

### 字符串长度
- 名称类：`@db.VarChar(50)` 或 `@db.VarChar(100)`
- URL/路径：`@db.VarChar(255)`
- 长文本：`@db.Text`
- 手机号：`@db.VarChar(20)`
- 状态码：`@db.Char(1)`

### 数值类型
- 经纬度：`Decimal @db.Decimal(10, 7)`
- 距离（米）：`Decimal @db.Decimal(10, 2)`
- 计数器：`Int @default(0)`

## 索引规范

### 必须添加索引的字段
- 外键字段（如 `userId`, `journeyId`）
- 状态字段（如 `status`）
- 常用查询字段（如 `createTime`）

### 索引示例
```prisma
@@index([userId])
@@index([status])
@@index([createTime])
```

## 关系定义

### 一对多关系
```prisma
// 父表
model City {
  id       String    @id @default(cuid())
  journeys Journey[]
}

// 子表
model Journey {
  id     String @id @default(cuid())
  cityId String @map("city_id")
  city   City   @relation(fields: [cityId], references: [id])
  
  @@index([cityId])
}
```

### 多对多关系（使用中间表）
```prisma
model UserSeal {
  userId String @map("user_id")
  sealId String @map("seal_id")
  user   AppUser @relation(fields: [userId], references: [id])
  seal   Seal    @relation(fields: [sealId], references: [id])
  
  @@id([userId, sealId])
}
```

## 注释规范

- 每个模型添加 `///` 文档注释说明用途
- 复杂字段添加行内注释说明取值范围

```prisma
/// 用户文化之旅进度表
model JourneyProgress {
  status String @db.VarChar(20) // in_progress, completed, abandoned
}
```


## Migration 命令规范

### 开发环境
```bash
# 创建并应用 migration（最常用）
npx prisma migrate dev --name <描述>

# 例如：
npx prisma migrate dev --name add_user_age
npx prisma migrate dev --name create_notification_table
```

### 生产环境
```bash
# 只应用 migration，不生成新文件
npx prisma migrate deploy
```

### Migration 命名规范
- 使用小写字母和下划线
- 描述清晰的变更内容
- 好的命名：`add_user_age`, `create_notification_table`, `fix_user_email_constraint`
- 不好的命名：`update`, `fix`, `change`

## 常用命令速查

| 命令 | 作用 | 环境 |
|------|------|------|
| `npx prisma migrate dev --name xxx` | 创建并应用 migration | 开发 |
| `npx prisma migrate deploy` | 只应用 migration | 生产 |
| `npx prisma migrate status` | 查看 migration 状态 | 任何 |
| `npx prisma migrate reset` | ⚠️ 重置数据库（删除所有数据） | 开发 |
| `npx prisma db seed` | 执行种子数据脚本 | 任何 |
| `npx prisma studio` | 打开数据库可视化界面 | 任何 |
| `npx prisma generate` | 重新生成 TypeScript 类型 | 任何 |

## 禁止事项

1. ❌ **不要使用 `npx prisma db push`**（会导致迁移历史不同步）
2. ❌ 不要在生产环境使用 `migrate dev`
3. ❌ 不要手动修改已生成的 migration 文件
4. ❌ 不要删除已应用的 migration
5. ❌ 不要直接修改数据库表结构
6. ❌ 不要在生产环境使用 `migrate reset`

## 常见问题处理

### Q1: 遇到 "permission denied to create database"
```bash
# 用超级用户授权 CREATEDB 权限
PGPASSWORD='<password>' psql -h localhost -U <superuser> -d postgres \
  -c "ALTER USER xunyin_admin CREATEDB;"
```

### Q2: 遇到 "Drift detected"（数据库和迁移不同步）
```bash
# 开发环境：重置数据库（会丢失数据）
npx prisma migrate reset --force

# 然后重新创建迁移
npx prisma migrate dev --name <描述>
```

### Q3: 需要初始化数据
```bash
# 初始数据写在 prisma/seed.ts 中
npx prisma db seed
```

### Q4: 检查迁移状态
```bash
npx prisma migrate status
```

## 📁 数据同步规范

### Prisma 与 SQL 文件同步

项目同时维护两套数据定义，必须保持同步：

| 位置 | 用途 | 说明 |
|------|------|------|
| `server-nestjs/prisma/schema.prisma` | Prisma 模型定义 | **主要来源**，开发时修改这里 |
| `server-nestjs/prisma/seed.ts` | 初始数据（Prisma） | **主要来源**，菜单/字典/配置等 |
| `db/schema.sql` | 表结构（SQL） | 需与 Prisma schema 同步 |
| `db/init_data.sql` | 初始数据（SQL） | 需与 seed.ts 同步 |

### 同步规则

1. **新增/修改模型时**：
   - ✅ 先修改 `schema.prisma`
   - ✅ 运行 `npx prisma migrate dev --name xxx`
   - ✅ 同步更新 `db/schema.sql`（添加对应的 CREATE TABLE）

2. **新增/修改初始数据时**：
   - ✅ 先修改 `seed.ts`
   - ✅ 运行 `npx prisma db seed`
   - ✅ 同步更新 `db/init_data.sql`（添加对应的 INSERT）

3. **为什么需要同步**：
   - `db/*.sql` 用于非 Prisma 环境（如 DBA 直接操作、备份恢复）
   - 保持两套定义一致，避免环境差异

### 同步检查清单

每次修改 Prisma 后，确认：
- [ ] `db/schema.sql` 包含所有表定义
- [ ] `db/init_data.sql` 包含所有初始数据
- [ ] 两边的字段名、类型、约束一致
