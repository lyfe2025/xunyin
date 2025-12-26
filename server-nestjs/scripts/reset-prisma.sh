#!/bin/bash

# Prisma 数据库重置脚本
# 用于重新应用所有迁移并生成 Prisma Client

echo "🔄 开始重置 Prisma..."

# 1. 重置数据库(删除所有数据并重新应用迁移)
echo "📦 重置数据库..."
npx prisma migrate reset --force

# 2. 生成 Prisma Client
echo "🔨 生成 Prisma Client..."
npx prisma generate

echo "✅ Prisma 重置完成!"
echo ""
echo "📊 查看数据库状态:"
npx prisma migrate status
