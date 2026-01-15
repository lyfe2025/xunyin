#!/bin/bash

# 图片资源验证脚本（JPG 格式）
# 检查所有初始数据需要的图片是否存在且有效

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
UPLOADS_DIR="$BASE_DIR/uploads"

# 颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "==================================="
echo "图片资源验证（64张 JPG）"
echo "==================================="
echo ""

total_files=0
valid_files=0
missing_files=0
invalid_files=0

# 验证单个文件
verify_file() {
  local file_path="$1"
  local file_name=$(basename "$file_path")
  
  total_files=$((total_files + 1))
  
  if [ ! -f "$file_path" ]; then
    echo -e "${RED}✗${NC} $file_name - 文件不存在"
    missing_files=$((missing_files + 1))
    return 1
  fi
  
  # 检查文件是否为有效的 JPEG
  if file "$file_path" | grep -q "JPEG"; then
    echo -e "${GREEN}✓${NC} $file_name"
    valid_files=$((valid_files + 1))
    return 0
  else
    echo -e "${RED}✗${NC} $file_name - 无效的 JPEG 文件"
    invalid_files=$((invalid_files + 1))
    return 1
  fi
}

echo -e "${YELLOW}1. 验证城市封面图（4张）...${NC}"
verify_file "$UPLOADS_DIR/images/city-hangzhou.jpg"
verify_file "$UPLOADS_DIR/images/city-suzhou.jpg"
verify_file "$UPLOADS_DIR/images/city-nanjing.jpg"
verify_file "$UPLOADS_DIR/images/city-fuzhou.jpg"

echo ""
echo -e "${YELLOW}2. 验证文化之旅封面图（6张）...${NC}"
verify_file "$UPLOADS_DIR/images/journey-westlake.jpg"
verify_file "$UPLOADS_DIR/images/journey-lingyin.jpg"
verify_file "$UPLOADS_DIR/images/journey-garden.jpg"
verify_file "$UPLOADS_DIR/images/journey-sanfang.jpg"
verify_file "$UPLOADS_DIR/images/journey-gushan.jpg"
verify_file "$UPLOADS_DIR/images/journey-minjiang.jpg"

echo ""
echo -e "${YELLOW}3. 验证印记图片（12张）...${NC}"
verify_file "$UPLOADS_DIR/images/seal-westlake.jpg"
verify_file "$UPLOADS_DIR/images/seal-lingyin.jpg"
verify_file "$UPLOADS_DIR/images/seal-garden.jpg"
verify_file "$UPLOADS_DIR/images/seal-sanfang.jpg"
verify_file "$UPLOADS_DIR/images/seal-gushan.jpg"
verify_file "$UPLOADS_DIR/images/seal-minjiang.jpg"
verify_file "$UPLOADS_DIR/images/seal-hangzhou.jpg"
verify_file "$UPLOADS_DIR/images/seal-suzhou.jpg"
verify_file "$UPLOADS_DIR/images/seal-nanjing.jpg"
verify_file "$UPLOADS_DIR/images/seal-fuzhou.jpg"
verify_file "$UPLOADS_DIR/images/seal-jiangnan.jpg"
verify_file "$UPLOADS_DIR/images/seal-mindu.jpg"

echo ""
echo -e "${YELLOW}4. 验证用户头像（4张）...${NC}"
verify_file "$UPLOADS_DIR/avatars/user1.jpg"
verify_file "$UPLOADS_DIR/avatars/user2.jpg"
verify_file "$UPLOADS_DIR/avatars/user3.jpg"
verify_file "$UPLOADS_DIR/avatars/user4.jpg"

echo ""
echo -e "${YELLOW}5. 验证身份证示例图片（6张）...${NC}"
verify_file "$UPLOADS_DIR/idcard/front-demo1.jpg"
verify_file "$UPLOADS_DIR/idcard/back-demo1.jpg"
verify_file "$UPLOADS_DIR/idcard/front-demo2.jpg"
verify_file "$UPLOADS_DIR/idcard/back-demo2.jpg"
verify_file "$UPLOADS_DIR/idcard/front-demo3.jpg"
verify_file "$UPLOADS_DIR/idcard/back-demo3.jpg"

echo ""
echo -e "${YELLOW}6. 验证探索照片（原图 16张）...${NC}"
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
  verify_file "$UPLOADS_DIR/photos/$photo.jpg"
done

echo ""
echo -e "${YELLOW}7. 验证探索照片（缩略图 16张）...${NC}"
for photo in "${photos[@]}"; do
  verify_file "$UPLOADS_DIR/photos/thumb/$photo.jpg"
done

echo ""
echo "==================================="
echo "验证结果"
echo "==================================="
echo "总文件数：$total_files"
echo -e "${GREEN}有效文件：$valid_files${NC}"
if [ $missing_files -gt 0 ]; then
  echo -e "${RED}缺失文件：$missing_files${NC}"
fi
if [ $invalid_files -gt 0 ]; then
  echo -e "${RED}无效文件：$invalid_files${NC}"
fi
echo ""

if [ $valid_files -eq $total_files ]; then
  echo -e "${GREEN}✓ 所有图片验证通过！${NC}"
  echo ""
  echo "图片来源：Picsum Photos (https://picsum.photos)"
  exit 0
else
  echo -e "${RED}✗ 部分图片验证失败，请运行 download-all-images.sh 重新下载${NC}"
  exit 1
fi
