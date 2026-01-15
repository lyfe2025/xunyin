#!/bin/bash

# 完整图片资源下载脚本
# 使用 Picsum Photos 占位图服务

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
UPLOADS_DIR="$BASE_DIR/uploads"

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "==================================="
echo "寻印项目 - 图片资源下载"
echo "==================================="
echo ""

# 创建必要的目录
mkdir -p "$UPLOADS_DIR/images"
mkdir -p "$UPLOADS_DIR/photos"
mkdir -p "$UPLOADS_DIR/photos/thumb"
mkdir -p "$UPLOADS_DIR/idcard"
mkdir -p "$UPLOADS_DIR/avatars"

# 下载函数
download_image() {
  local url="$1"
  local output="$2"
  local description="$3"
  
  if [ -f "$output" ]; then
    echo -e "${YELLOW}⊙${NC} $description - 已存在，跳过"
    return 0
  fi
  
  echo -e "${BLUE}↓${NC} 下载 $description..."
  if curl -L -s -o "$output" "$url"; then
    echo -e "${GREEN}✓${NC} $description - 下载成功"
    return 0
  else
    echo -e "${RED}✗${NC} $description - 下载失败"
    return 1
  fi
}

echo -e "${YELLOW}1. 下载城市封面图（4张 JPG）...${NC}"
download_image "https://picsum.photos/seed/city-hangzhou/800/600.jpg" \
  "$UPLOADS_DIR/images/city-hangzhou.jpg" "杭州城市封面"

download_image "https://picsum.photos/seed/city-suzhou/800/600.jpg" \
  "$UPLOADS_DIR/images/city-suzhou.jpg" "苏州城市封面"

download_image "https://picsum.photos/seed/city-nanjing/800/600.jpg" \
  "$UPLOADS_DIR/images/city-nanjing.jpg" "南京城市封面"

download_image "https://picsum.photos/seed/city-fuzhou/800/600.jpg" \
  "$UPLOADS_DIR/images/city-fuzhou.jpg" "福州城市封面"

echo ""
echo -e "${YELLOW}2. 下载文化之旅封面图（6张 JPG）...${NC}"
download_image "https://picsum.photos/seed/journey-westlake/800/600.jpg" \
  "$UPLOADS_DIR/images/journey-westlake.jpg" "西湖十景探秘封面"

download_image "https://picsum.photos/seed/journey-lingyin/800/600.jpg" \
  "$UPLOADS_DIR/images/journey-lingyin.jpg" "灵隐禅踪封面"

download_image "https://picsum.photos/seed/journey-garden/800/600.jpg" \
  "$UPLOADS_DIR/images/journey-garden.jpg" "园林雅韵封面"

download_image "https://picsum.photos/seed/journey-sanfang/800/600.jpg" \
  "$UPLOADS_DIR/images/journey-sanfang.jpg" "三坊七巷寻古封面"

download_image "https://picsum.photos/seed/journey-gushan/800/600.jpg" \
  "$UPLOADS_DIR/images/journey-gushan.jpg" "鼓山禅意行封面"

download_image "https://picsum.photos/seed/journey-minjiang/800/600.jpg" \
  "$UPLOADS_DIR/images/journey-minjiang.jpg" "闽江两岸封面"

echo ""
echo -e "${YELLOW}3. 下载印记图片（12张 JPG）...${NC}"
download_image "https://picsum.photos/seed/seal-westlake/400/400.jpg" \
  "$UPLOADS_DIR/images/seal-westlake.jpg" "西湖探秘者印记"

download_image "https://picsum.photos/seed/seal-lingyin/400/400.jpg" \
  "$UPLOADS_DIR/images/seal-lingyin.jpg" "禅心悟道印记"

download_image "https://picsum.photos/seed/seal-garden/400/400.jpg" \
  "$UPLOADS_DIR/images/seal-garden.jpg" "园林雅士印记"

download_image "https://picsum.photos/seed/seal-sanfang/400/400.jpg" \
  "$UPLOADS_DIR/images/seal-sanfang.jpg" "坊巷寻踪印记"

download_image "https://picsum.photos/seed/seal-gushan/400/400.jpg" \
  "$UPLOADS_DIR/images/seal-gushan.jpg" "鼓山禅心印记"

download_image "https://picsum.photos/seed/seal-minjiang/400/400.jpg" \
  "$UPLOADS_DIR/images/seal-minjiang.jpg" "闽江行者印记"

download_image "https://picsum.photos/seed/seal-hangzhou/400/400.jpg" \
  "$UPLOADS_DIR/images/seal-hangzhou.jpg" "杭州城市印记"

download_image "https://picsum.photos/seed/seal-suzhou/400/400.jpg" \
  "$UPLOADS_DIR/images/seal-suzhou.jpg" "苏州城市印记"

download_image "https://picsum.photos/seed/seal-nanjing/400/400.jpg" \
  "$UPLOADS_DIR/images/seal-nanjing.jpg" "南京城市印记"

download_image "https://picsum.photos/seed/seal-fuzhou/400/400.jpg" \
  "$UPLOADS_DIR/images/seal-fuzhou.jpg" "福州城市印记"

download_image "https://picsum.photos/seed/seal-jiangnan/400/400.jpg" \
  "$UPLOADS_DIR/images/seal-jiangnan.jpg" "江南水乡印记"

download_image "https://picsum.photos/seed/seal-mindu/400/400.jpg" \
  "$UPLOADS_DIR/images/seal-mindu.jpg" "闽都风华印记"

echo ""
echo -e "${YELLOW}4. 下载用户头像（4张 JPG）...${NC}"
download_image "https://picsum.photos/id/1005/200/200.jpg" \
  "$UPLOADS_DIR/avatars/user1.jpg" "用户1头像"

download_image "https://picsum.photos/id/1011/200/200.jpg" \
  "$UPLOADS_DIR/avatars/user2.jpg" "用户2头像"

download_image "https://picsum.photos/id/1015/200/200.jpg" \
  "$UPLOADS_DIR/avatars/user3.jpg" "用户3头像"

download_image "https://picsum.photos/id/1025/200/200.jpg" \
  "$UPLOADS_DIR/avatars/user4.jpg" "用户4头像"

echo ""
echo -e "${YELLOW}5. 下载身份证示例图片（6张 JPG）...${NC}"
download_image "https://picsum.photos/seed/idcard-front1/600/400.jpg" \
  "$UPLOADS_DIR/idcard/front-demo1.jpg" "身份证正面示例1"

download_image "https://picsum.photos/seed/idcard-back1/600/400.jpg" \
  "$UPLOADS_DIR/idcard/back-demo1.jpg" "身份证反面示例1"

download_image "https://picsum.photos/seed/idcard-front2/600/400.jpg" \
  "$UPLOADS_DIR/idcard/front-demo2.jpg" "身份证正面示例2"

download_image "https://picsum.photos/seed/idcard-back2/600/400.jpg" \
  "$UPLOADS_DIR/idcard/back-demo2.jpg" "身份证反面示例2"

download_image "https://picsum.photos/seed/idcard-front3/600/400.jpg" \
  "$UPLOADS_DIR/idcard/front-demo3.jpg" "身份证正面示例3"

download_image "https://picsum.photos/seed/idcard-back3/600/400.jpg" \
  "$UPLOADS_DIR/idcard/back-demo3.jpg" "身份证反面示例3"

echo ""
echo -e "${YELLOW}6. 下载探索照片 - 原图（16张 JPG）...${NC}"
photos=(
  "westlake-duanqiao-1"
  "westlake-duanqiao-2"
  "westlake-leifeng-1"
  "westlake-santan-1"
  "westlake-huagang-user3-1"
  "westlake-duanqiao-user3-1"
  "westlake-leifeng-user3-1"
  "westlake-santan-user3-1"
  "lingyin-feilai-1"
  "lingyin-temple-user3-1"
  "lingyin-yongfu-user3-1"
  "lingyin-feilai-user3-1"
  "sanfang-yijin-1"
  "sanfang-linzexu-1"
  "sanfang-yijin-user3-1"
  "sanfang-linzexu-user3-1"
)

for photo in "${photos[@]}"; do
  download_image "https://picsum.photos/seed/photo-${photo}/800/600.jpg" \
    "$UPLOADS_DIR/photos/$photo.jpg" "探索照片 $photo"
done

echo ""
echo -e "${YELLOW}7. 下载探索照片 - 缩略图（16张 JPG）...${NC}"
for photo in "${photos[@]}"; do
  download_image "https://picsum.photos/seed/thumb-${photo}/300/200.jpg" \
    "$UPLOADS_DIR/photos/thumb/$photo.jpg" "缩略图 $photo"
done

echo ""
echo "==================================="
echo -e "${GREEN}✓ 所有图片下载完成！${NC}"
echo "==================================="
echo ""
echo "图片统计："
echo "- 城市封面图：4张 JPG"
echo "- 文化之旅封面图：6张 JPG"
echo "- 印记图片：12张 JPG"
echo "- 用户头像：4张 JPG"
echo "- 身份证示例：6张 JPG"
echo "- 探索照片：32张 JPG（16张原图 + 16张缩略图）"
echo "- 配置图片：2张 PNG（logo.png, favicon.png - 已存在）"
echo ""
echo "总计：64张 JPG 图片"
echo ""
echo "图片来源：Picsum Photos (https://picsum.photos)"
echo ""
echo "下一步："
echo "运行 seed 导入数据：pnpm --filter server-nestjs db:seed"

