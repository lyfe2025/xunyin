#!/bin/bash
# =============================================
# 寻印 App 背景音乐下载指南
# =============================================
# 
# 由于版权和网络限制，请手动从以下网站下载免费可商用的中国风音乐：
#
# 推荐来源（免费商用，无需署名）：
# 1. Pixabay Music: https://pixabay.com/music/search/chinese/
# 2. Chosic: https://www.chosic.com/free-music/chinese/
# 3. Incompetech: https://incompetech.com/music/royalty-free/music.html
#
# =============================================

set -e

# 创建音频目录
BGM_DIR="../uploads/audio/bgm"
mkdir -p "$BGM_DIR"

echo "=============================================="
echo "  寻印 App 背景音乐配置指南"
echo "=============================================="
echo ""
echo "目标目录: $BGM_DIR"
echo ""
echo "请从以下网站手动下载中国风背景音乐："
echo ""
echo "【推荐来源】"
echo "  1. Pixabay Music (免费商用)"
echo "     https://pixabay.com/music/search/chinese/"
echo "     https://pixabay.com/music/search/guzheng/"
echo "     https://pixabay.com/music/search/zen/"
echo ""
echo "  2. Chosic (免费商用，部分需署名)"
echo "     https://www.chosic.com/free-music/chinese/"
echo ""
echo "【需要的音乐文件】"
echo ""
echo "  首页背景音乐:"
echo "    - home-default.mp3  (古韵悠然 - 轻柔古风)"
echo "    - home-nature.mp3   (山水清音 - 自然氛围)"
echo ""
echo "  城市背景音乐:"
echo "    - city-hangzhou.mp3 (江南丝竹 - 杭州)"
echo "    - city-suzhou.mp3   (姑苏雅韵 - 苏州)"
echo "    - city-nanjing.mp3  (金陵古调 - 南京)"
echo "    - city-fuzhou.mp3   (闽韵悠扬 - 福州)"
echo ""
echo "  文化之旅背景音乐:"
echo "    - journey-westlake.mp3  (西湖春晓 - 西湖十景)"
echo "    - journey-lingyin.mp3   (禅意空灵 - 灵隐禅踪)"
echo "    - journey-sanfang.mp3   (坊巷古韵 - 三坊七巷)"
echo "    - journey-gushan.mp3    (鼓山梵音 - 鼓山禅意行)"
echo "    - journey-minjiang.mp3  (闽江夜曲 - 闽江两岸)"
echo ""
echo "【Pixabay 推荐曲目 ID】"
echo "  搜索以下关键词可找到合适的音乐："
echo "    - chinese traditional"
echo "    - guzheng"
echo "    - bamboo flute"
echo "    - zen meditation"
echo "    - asian ambient"
echo ""
echo "【下载后操作】"
echo "  1. 将下载的 mp3 文件重命名为上述文件名"
echo "  2. 放入目录: $BGM_DIR/"
echo "  3. 重启后端服务"
echo ""
echo "【验证】"
echo "  访问: http://localhost:3000/uploads/audio/bgm/home-default.mp3"
echo ""

# 检查现有文件
echo "【当前已有文件】"
if ls "$BGM_DIR"/*.mp3 1> /dev/null 2>&1; then
  ls -lh "$BGM_DIR"/*.mp3
else
  echo "  (暂无音乐文件)"
fi

echo ""
echo "=============================================="
