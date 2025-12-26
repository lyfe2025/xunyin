# Docker 生产环境运维指南

本文档介绍 Xunyin Admin 在 Docker 环境下的日常运维操作。

## 一、服务管理

### 1.1 基本命令

```bash
# 进入项目目录（所有命令都需要在此目录执行）
cd /www/wwwroot/xunyin-admin

# 查看所有容器状态
docker compose ps

# 启动所有服务
docker compose up -d

# 停止所有服务（保留数据）
docker compose down

# 重启所有服务
docker compose restart

# 重启单个服务
docker compose restart server
docker compose restart web
docker compose restart postgres
docker compose restart redis
```

### 1.2 查看日志

```bash
# 查看所有服务日志（实时跟踪）
docker compose logs -f

# 查看单个服务日志
docker compose logs -f server    # 后端日志
docker compose logs -f web       # 前端 nginx 日志
docker compose logs -f postgres  # 数据库日志

# 查看最近 100 行日志
docker compose logs --tail 100 server

# 查看指定时间段日志
docker compose logs --since "2024-01-01" server
```

### 1.3 更新部署

```bash
# 拉取最新代码
git pull origin main

# 重新构建并启动（推荐）
docker compose up -d --build

# 只重建特定服务
docker compose up -d --build server
docker compose up -d --build web

# 强制重新构建（不使用缓存）
docker compose build --no-cache server
docker compose up -d
```


## 二、数据库操作

### 2.1 连接数据库

```bash
# 方式一：通过 Docker 进入 psql
docker compose exec postgres psql -U xunyin_admin -d xunyin_admin

# 方式二：从宿主机连接（如果端口已映射）
psql -h 127.0.0.1 -U xunyin_admin -d xunyin_admin
```

### 2.2 常用 SQL 操作

```bash
# 执行单条 SQL
docker compose exec postgres psql -U xunyin_admin -d xunyin_admin -c "SELECT * FROM sys_user LIMIT 5;"

# 查看所有表
docker compose exec postgres psql -U xunyin_admin -d xunyin_admin -c "\dt"

# 查看表结构
docker compose exec postgres psql -U xunyin_admin -d xunyin_admin -c "\d sys_user"

# 执行 SQL 文件
docker compose exec -T postgres psql -U xunyin_admin -d xunyin_admin < /path/to/script.sql
```

### 2.3 数据库备份

```bash
# 备份整个数据库
docker compose exec -T postgres pg_dump -U xunyin_admin xunyin_admin > backup_$(date +%Y%m%d_%H%M%S).sql

# 备份到指定目录
docker compose exec -T postgres pg_dump -U xunyin_admin xunyin_admin > /www/backup/db_$(date +%Y%m%d).sql

# 只备份表结构（不含数据）
docker compose exec -T postgres pg_dump -U xunyin_admin -s xunyin_admin > schema_only.sql

# 只备份数据（不含结构）
docker compose exec -T postgres pg_dump -U xunyin_admin -a xunyin_admin > data_only.sql

# 备份单个表
docker compose exec -T postgres pg_dump -U xunyin_admin -t sys_user xunyin_admin > sys_user_backup.sql
```

### 2.4 数据库恢复

```bash
# 恢复整个数据库（⚠️ 会覆盖现有数据）
cat backup_xxx.sql | docker compose exec -T postgres psql -U xunyin_admin -d xunyin_admin

# 恢复前先清空数据库
docker compose exec postgres psql -U xunyin_admin -d xunyin_admin -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
cat backup_xxx.sql | docker compose exec -T postgres psql -U xunyin_admin -d xunyin_admin
```

### 2.5 Prisma 数据库操作

Prisma 命令需要在 server 容器内执行：

```bash
# 执行数据库迁移（应用新的 schema 变更）
docker compose exec server npx prisma migrate deploy

# 生成 Prisma Client
docker compose exec server npx prisma generate

# 导入种子数据
docker compose exec server npx prisma db seed

# 重置数据库（⚠️ 删除所有数据并重新初始化）
docker compose exec server npx prisma migrate reset --force

# 查看迁移状态
docker compose exec server npx prisma migrate status
```

### 2.6 数据库完全重置

如果需要完全重置数据库到初始状态：

```bash
# 方式一：使用 Prisma（推荐）
docker compose exec server sh -c "npx prisma migrate reset --force && npx prisma db seed"

# 方式二：删除数据卷重建（更彻底）
docker compose down -v                    # 删除所有容器和数据卷
docker compose up -d                      # 重新创建
docker compose exec server npx prisma migrate deploy
docker compose exec server npx prisma db seed
```

## 三、Redis 操作

```bash
# 进入 Redis CLI
docker compose exec redis redis-cli

# 常用 Redis 命令
docker compose exec redis redis-cli PING           # 测试连接
docker compose exec redis redis-cli KEYS "*"       # 查看所有 key
docker compose exec redis redis-cli FLUSHALL       # 清空所有数据（⚠️ 慎用）
docker compose exec redis redis-cli INFO           # 查看 Redis 信息
docker compose exec redis redis-cli DBSIZE         # 查看 key 数量
```

## 四、容器调试

### 4.1 进入容器

```bash
# 进入后端容器
docker compose exec server sh

# 进入前端容器
docker compose exec web sh

# 进入数据库容器
docker compose exec postgres sh

# 以 root 用户进入（如果需要安装工具）
docker compose exec -u root server sh
```

### 4.2 查看容器信息

```bash
# 查看容器详细信息
docker inspect xunyin-server

# 查看容器资源使用
docker stats

# 查看容器网络
docker network ls
docker network inspect xunyin-admin_xunyin-network
```

### 4.3 测试网络连通性

```bash
# 测试 server 能否访问 postgres
docker compose exec server sh -c "nc -zv postgres 5432"

# 测试 server 能否访问 redis
docker compose exec server sh -c "nc -zv redis 6379"

# 测试后端健康检查
curl http://127.0.0.1:3000/api/health
```


## 五、数据卷管理

### 5.1 查看数据卷

```bash
# 列出所有数据卷
docker volume ls

# 查看项目相关的数据卷
docker volume ls | grep xunyin

# 查看数据卷详情
docker volume inspect xunyin-admin_postgres_data
```

### 5.2 数据卷位置

| 数据卷 | 用途 | 宿主机位置 |
|--------|------|-----------|
| postgres_data | 数据库文件 | /var/lib/docker/volumes/xunyin-admin_postgres_data |
| redis_data | Redis 持久化 | /var/lib/docker/volumes/xunyin-admin_redis_data |
| server_logs | 后端日志 | /var/lib/docker/volumes/xunyin-admin_server_logs |

### 5.3 清理数据卷

```bash
# 删除未使用的数据卷
docker volume prune

# 删除指定数据卷（⚠️ 会丢失数据）
docker volume rm xunyin-admin_postgres_data
```

## 六、镜像管理

```bash
# 查看项目镜像
docker images | grep xunyin

# 删除旧镜像
docker image prune -f

# 强制重新构建镜像
docker compose build --no-cache

# 导出镜像（用于离线部署）
docker save xunyin-admin-server > server-image.tar
docker save xunyin-admin-web > web-image.tar

# 导入镜像
docker load < server-image.tar
```

## 七、常见问题排查

### 7.1 服务无法启动

```bash
# 查看详细日志
docker compose logs server

# 检查容器状态
docker compose ps -a

# 查看容器退出原因
docker inspect xunyin-server | grep -A 10 "State"
```

### 7.2 数据库连接失败

```bash
# 检查 postgres 是否运行
docker compose ps postgres

# 检查网络连通性
docker compose exec server sh -c "nc -zv postgres 5432"

# 查看数据库日志
docker compose logs postgres
```

### 7.3 磁盘空间不足

```bash
# 查看 Docker 占用空间
docker system df

# 清理未使用的资源
docker system prune -a

# 清理构建缓存
docker builder prune -a
```

### 7.4 容器网络问题（CentOS 7）

```bash
# 重启 Docker 服务
systemctl restart docker

# 重新启动容器
docker compose up -d
```

## 八、定时任务示例

### 8.1 每日数据库备份

在宝塔「计划任务」中添加 Shell 脚本，每天凌晨 3 点执行：

```bash
#!/bin/bash
BACKUP_DIR=/www/backup/xunyin-admin
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

cd /www/wwwroot/xunyin-admin
docker compose exec -T postgres pg_dump -U xunyin_admin xunyin_admin > $BACKUP_DIR/db_$DATE.sql

# 压缩备份文件
gzip $BACKUP_DIR/db_$DATE.sql

# 保留最近 7 天的备份
find $BACKUP_DIR -name "db_*.sql.gz" -mtime +7 -delete

echo "备份完成: $BACKUP_DIR/db_$DATE.sql.gz"
```

### 8.2 每周清理 Docker 资源

```bash
#!/bin/bash
# 清理未使用的镜像和容器
docker system prune -f

# 清理构建缓存（保留最近 7 天）
docker builder prune -f --filter "until=168h"

echo "Docker 清理完成"
```

## 九、命令速查表

| 操作 | 命令 |
|------|------|
| 查看状态 | `docker compose ps` |
| 启动服务 | `docker compose up -d` |
| 停止服务 | `docker compose down` |
| 重启服务 | `docker compose restart` |
| 查看日志 | `docker compose logs -f server` |
| 更新部署 | `docker compose up -d --build` |
| 进入容器 | `docker compose exec server sh` |
| 连接数据库 | `docker compose exec postgres psql -U xunyin_admin -d xunyin_admin` |
| 备份数据库 | `docker compose exec -T postgres pg_dump -U xunyin_admin xunyin_admin > backup.sql` |
| 恢复数据库 | `cat backup.sql \| docker compose exec -T postgres psql -U xunyin_admin -d xunyin_admin` |
| 执行迁移 | `docker compose exec server npx prisma migrate deploy` |
| 导入种子 | `docker compose exec server npx prisma db seed` |
| 重置数据库 | `docker compose exec server npx prisma migrate reset --force` |
| 清理资源 | `docker system prune -a` |

