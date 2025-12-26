#!/bin/bash

# 自动为所有 handleSubmit 函数添加错误处理的脚本

echo "开始修复前端错误处理..."

# 需要修复的文件列表
files=(
  "src/views/system/menu/index.vue"
  "src/views/system/dept/index.vue"
  "src/views/system/post/index.vue"
  "src/views/system/config/index.vue"
  "src/views/system/notice/index.vue"
  "src/views/monitor/job/index.vue"
)

# 备份目录
backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "处理文件: $file"
    
    # 备份原文件
    cp "$file" "$backup_dir/"
    
    # 检查是否已经有 catch 块
    if grep -A 15 "async function handleSubmit" "$file" | grep -q "catch"; then
      echo "  ✓ 已有错误处理,跳过"
    else
      echo "  ⚠ 需要手动添加错误处理"
      echo "    请在 try 块后添加:"
      echo "    } catch (error) {"
      echo "      console.error('提交失败:', error)"
      echo "    } finally {"
    fi
  else
    echo "文件不存在: $file"
  fi
done

echo ""
echo "修复完成!"
echo "备份文件保存在: $backup_dir"
echo ""
echo "请手动检查以下文件并添加错误处理:"
for file in "${files[@]}"; do
  echo "  - $file"
done
