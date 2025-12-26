# Zeabur 部署指南（免费版）

## 免费版限制

- 每月 $5 额度
- PostgreSQL + Redis 会消耗较多资源，建议优先保证数据库运行
- 如果额度不够，可以考虑使用外部免费数据库（如 Supabase、Neon）

## 部署步骤

### 1. 准备工作

确保代码已推送到 GitHub 仓库。

### 2. 创建 Zeabur 项目

1. 登录 [Zeabur 控制台](https://zeabur.com)
2. 点击 "New Project"
3. 选择区域（建议选择离用户近的）

### 3. 添加 PostgreSQL 数据库

1. 点击 "Add Service" → "Marketplace" → "PostgreSQL"
2. 等待服务启动
3. 点击服务卡片，复制 `Connection String` 备用

### 4. 添加 Redis 缓存

1. 点击 "Add Service" → "Marketplace" → "Redis"
2. 等待服务启动
3. 点击服务卡片，复制 `Connection String` 备用

### 5. 部署后端服务

1. 点击 "Add Service" → "Git" → 选择你的仓库
2. 设置 **Root Directory**: `server-nestjs`
3. Zeabur 会自动检测 Dockerfile
4. 点击服务卡片 → "Variables" 添加环境变量：

```
NODE_ENV=production
PORT=3000
DATABASE_URL=<粘贴 PostgreSQL Connection String>
REDIS_ENABLED=true
REDIS_URL=<粘贴 Redis Connection String>
JWT_SECRET=<生成一个32位以上的随机字符串>
LOG_LEVEL=info
LOG_DIR=logs
CORS_ORIGINS=<稍后填写前端域名>
```

生成 JWT_SECRET 的方法：
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

5. 等待部署完成

### 6. 初始化数据库

部署成功后，需要运行数据库迁移：

1. 在 Zeabur 控制台，点击后端服务
2. 进入 "Command" 标签
3. 执行：
```bash
npx prisma migrate deploy
npx prisma db seed
```

### 7. 部署前端服务

1. 点击 "Add Service" → "Git" → 选择同一个仓库
2. 设置 **Root Directory**: `web`
3. 等待部署完成
4. 点击服务卡片 → "Networking" → 生成域名

### 8. 配置 CORS

1. 复制前端的域名（如 `xxx.zeabur.app`）
2. 回到后端服务 → "Variables"
3. 更新 `CORS_ORIGINS` 为前端域名（包含 https://）：
```
CORS_ORIGINS=https://xxx.zeabur.app
```
4. 服务会自动重启

### 9. 验证部署

1. 访问前端域名
2. 使用默认账号登录：
   - 用户名：`admin`
   - 密码：`admin123`

## 常见问题

### Q: 部署后前端无法访问 API？

检查：
1. 后端服务是否正常运行
2. `CORS_ORIGINS` 是否正确配置
3. 前端 nginx 代理是否指向正确的内网地址

### Q: 数据库连接失败？

检查 `DATABASE_URL` 格式是否正确，Zeabur 提供的连接字符串可以直接使用。

### Q: 免费额度不够用？

方案 A：使用外部免费数据库
- PostgreSQL: [Neon](https://neon.tech) 或 [Supabase](https://supabase.com)
- Redis: [Upstash](https://upstash.com)

方案 B：关闭 Redis（仅开发测试）
- 设置 `REDIS_ENABLED=false`，使用内存模式

## 服务内网地址

Zeabur 服务间通信使用内网地址：
- 后端: `server.zeabur.internal:3000`
- PostgreSQL: 使用 Zeabur 提供的连接字符串
- Redis: 使用 Zeabur 提供的连接字符串
