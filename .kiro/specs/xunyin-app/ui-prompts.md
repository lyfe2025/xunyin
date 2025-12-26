# 寻印 App - UI 设计提示词

## 页面设计提示词

### 1. 首页 - 全屏沉浸式地图

```
Mobile app UI design, full-screen illustrated map of China for cultural tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Elegant, culturally rich, immersive

Key elements:
- Full-screen map with NO top navigation bar, NO bottom tab bar
- Illustrated style map with warm paper texture background
- City markers as cute cultural icons (pandas for Chengdu, pagoda for Xi'an, West Lake for Hangzhou, ice sculpture for Harbin)
- Right side floating vertical toolbar with 5 circular buttons (profile 👤, trophy 🏆, camera 📷, music 🎵, location 📍)
- Floating buttons have subtle shadow and glass morphism effect
- User location indicator with soft teal glow
- Subtle ink wash texture overlay on map

Device: iPhone 14 Pro, 390x844px
```

### 2. 城市面板 - Bottom Sheet（收起状态）

```
Mobile app UI design, bottom sheet panel for city cultural information in tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Elegant, culturally rich, discoverable

Key elements:
- Map visible in background (slightly dimmed), focused on Hangzhou area
- Bottom sheet covering 40% of screen from bottom
- Drag indicator bar at top of sheet (small horizontal line)
- City name "杭州 · 文化之书" with search icon (🔍)
- Explorer count "👥 3,569人探索过"
- Horizontal scrollable province tags: [华东] [华南] [华北] [西南] [海外]
- Two journey cards in horizontal scroll:
  - Card 1: "西湖十景" with West Lake illustration, 0.5km, ⭐⭐⭐⭐⭐, 10探索点
  - Card 2: "龙井茶道" with tea leaf illustration, 2.1km, ⭐⭐⭐⭐, 6探索点
- Cards have 16px rounded corners, subtle shadow, cream background
- "发现更多文化之旅" button at bottom

Device: iPhone 14 Pro, 390x844px
```

### 3. 城市面板 - Bottom Sheet（展开状态）

```
Mobile app UI design, expanded bottom sheet for city cultural details in tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Elegant, informative, inspiring

Key elements:
- Bottom sheet covering 85% of screen
- Drag indicator bar at top
- City header: "杭州 · 文化之书" with search icon
- Stats row: "👥 3,569人探索过 | 📍 3条文化之旅"
- Province tags horizontal scroll
- Large city cover illustration (West Lake with pagoda, ink wash style, warm tones)
- City description text in elegant typography
- Section divider "─── 文化之旅 ───"
- Journey list cards (vertical stack):
  - Card: 🏯 icon, "西湖十景文化之旅", 0.5km, ⭐⭐⭐⭐⭐, 10探索点, 3小时, "👥 1,234人完成"
  - Card: 🍵 icon, "龙井茶文化之旅", 2.1km, ⭐⭐⭐⭐, 6探索点, 2小时, "👥 856人完成"
  - Locked card: 🔒 icon, "南宋御街历史探秘", grayed out, "完成前2条文化之旅后解锁"

Device: iPhone 14 Pro, 390x844px
```

### 4. 文化之旅详情页

```
Mobile app UI design, cultural journey detail page for tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Adventurous, organized, culturally rich

Key elements:
- Back button (←) in top left corner
- Title: "西湖十景文化之旅"
- Hero image: West Lake scenic illustration with mountains, pagoda, willow trees, ink wash style
- Info section with icons:
  - 📍 位置: 杭州西湖风景区
  - 🎨 主题: 江南水乡文化
  - ⏱️ 预计时长: 3小时
  - 📏 总距离: 5.2公里
  - 👥 已有 1,234 人完成
- Section divider "─── 探索点列表 ───"
- Exploration point cards (numbered list):
  - "1. 断桥残雪" - 📷拍照任务 · 500m - teal [导航] button - "在断桥上与白娘子合影"
  - "2. 平湖秋月" - 🖐️AR手势 · 800m - teal [导航] button - "比出赏月的手势"
  - "3. 雷峰夕照" - 🔍AR寻宝 · 1.2km - teal [导航] button - "找到隐藏的法海"
- Large CTA button at bottom: "开始这条文化之旅" (teal background, white text)

Device: iPhone 14 Pro, 390x844px
```

### 5. 文化之旅进行中页面

```
Mobile app UI design, journey in-progress page with map for tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Guided, purposeful, exciting

Key elements:
- Close button (×) in top left
- Title: "西湖十景文化之旅"
- Progress indicator "进度 1/10" in top right (teal badge)
- Map view (60% of screen) showing:
  - Teal route path connecting exploration points
  - Numbered circular markers (1, 2, 3...) for each point
  - Current target (point 1) highlighted with glow
  - User location blue dot with direction indicator
- Info card below map (white card with shadow):
  - Label: "下一个探索点"
  - Point name: "1. 断桥残雪" (bold)
  - "距离：500m | 步行约6分钟"
  - "开始导航" button (teal, full width)
- Collapsible exploration point list at bottom:
  - ○ 1. 断桥残雪 - 500m
  - ○ 2. 平湖秋月 - 1.3km
  - ○ 3. 雷峰夕照 - 2.5km

Device: iPhone 14 Pro, 390x844px
```

### 6. 导航中页面

```
Mobile app UI design, walking navigation screen for tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Clear, confident, helpful

Key elements:
- Close button (×) in top left
- Title: "导航到：断桥残雪"
- Full map view with:
  - Walking route highlighted in teal dashed line
  - Destination marker (red pin with cultural icon)
  - User location blue dot with direction cone
  - Street names visible
- Navigation instruction card (bottom, white with shadow):
  - Large teal direction arrow icon (↑)
  - "前方 100米 右转" (bold text)
  - Horizontal divider line
  - "剩余距离：350m"
  - "预计到达：4分钟"
- "结束导航" button at bottom (outline style, teal border)

Device: iPhone 14 Pro, 390x844px
```

### 7. 到达探索点提示

```
Mobile app UI design, arrival notification modal for tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Exciting, rewarding, inviting

Key elements:
- Map background (dimmed) showing user at destination
- Teal 50-meter radius circle around exploration point
- Centered modal card (white, rounded corners, shadow):
  - Celebration sparkle icon at top (gold)
  - "你已到达探索点！" (large, bold)
  - Point name: "1. 断桥残雪"
  - Task type badge: "📷 拍照任务"
  - Task description: "在断桥上与白娘子合影"
  - Two buttons stacked:
    - "开始任务" (teal filled, prominent)
    - "稍后再来" (outline style)

Device: iPhone 14 Pro, 390x844px
```

### 8. AR任务页 - 手势识别

```
Mobile app UI design, AR camera screen for gesture recognition in tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Focused, interactive, magical

Key elements:
- Close button (×) in top left (white with shadow for visibility)
- Progress indicator "探索点 2/10" in top right (white badge)
- Full-screen camera view as background (showing real outdoor scene)
- AR anchor floating in scene: glowing moon icon with subtle particle effects
- Target gesture reference box (bottom left): small card showing required "赏月" hand pose silhouette
- Bottom info panel (semi-transparent dark overlay):
  - Point name: "平湖秋月" (white text)
  - Instruction: "请对准AR锚点，比出赏月手势"
  - Progress bar: "████████░░░░░░░░ 识别中 60%" (teal fill)
- "拍照确认" circular button at bottom (disabled/gray until gesture matched)

Device: iPhone 14 Pro, 390x844px
```

### 9. AR任务页 - 拍照探索

```
Mobile app UI design, AR camera screen for photo task with virtual character in tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Fun, creative, immersive

Key elements:
- Close button (×) in top left (white with shadow)
- Progress indicator "探索点 1/10" in top right (white badge)
- Full-screen camera view showing real bridge scene
- AR virtual character: Lady White Snake (白娘子) in elegant white traditional Chinese dress, semi-transparent ethereal glow, positioned naturally on bridge
- Bottom info panel (semi-transparent):
  - Task title: "与白娘子合影" (white, bold)
  - Instruction: "站在断桥上，与AR白娘子合影"
  - Tip: "提示：可以选择不同滤镜"
- Filter selection row: three pill buttons [古风] [水墨] [原图] - "古风" selected with teal background
- Large circular shutter button at bottom center (white with teal ring)

Device: iPhone 14 Pro, 390x844px
```

### 10. 任务完成页

```
Mobile app UI design, task completion celebration screen for tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Rewarding, educational, motivating

Key elements:
- Warm white background with subtle confetti particles
- Centered layout:
  - "恭喜！" (gold color, decorative)
  - "任务完成！" (large, teal, bold)
- Photo frame: captured image with subtle cream border and shadow
- Success message: "断桥残雪 探索成功" (teal text)
- Reward card (gold gradient border):
  - Coin icon + "+50 积分"
  - Subtle glow effect
- Section divider "─── 文化小知识 ───"
- Knowledge card (cream background):
  - Text: "断桥残雪是西湖十景之一，因《白蛇传》中许仙与白娘子在此相遇而闻名..."
  - "查看更多 >" link (teal, right aligned)
- Two action buttons at bottom:
  - "分享到社交" (outline, teal border)
  - "继续下一个" (filled, teal background)

Device: iPhone 14 Pro, 390x844px
```

### 11. 文化之旅完成页 - 收集印记

```
Mobile app UI design, journey completion screen with seal reward for tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Proud, accomplished, prestigious

Key elements:
- Warm white background with subtle celebration particles
- Header: "恭喜完成文化之旅！" (teal, centered)
- Large seal illustration (centered, prominent):
  - Traditional Chinese red seal/stamp style
  - Square shape with rounded worn edges
  - "西湖十景" carved text in seal script
  - "2024.01" date
  - Red ink texture with slight smudge effect
  - Subtle gold glow around seal
- Journey info below seal:
  - "西湖十景文化之旅"
  - "完成时间：2024-01-15"
  - "用时：2小时45分"
- Reward summary card (cream background, gold border):
  - "+500 积分" with coin icon
  - "+1 路线印记" with seal icon
  - "解锁「西湖文化达人」称号" with badge icon
- Blockchain section card:
  - "🔗 上链存证" header
  - "将此印记永久记录到区块链，获得不可篡改的完成证明"
  - "立即上链" button (gold background)
- Bottom buttons:
  - "分享印记" (outline)
  - "返回首页" (teal filled)

Device: iPhone 14 Pro, 390x844px
```

### 12. 印记集页面

```
Mobile app UI design, seal collection gallery page for tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Collectible, motivating, organized

Key elements:
- Back button (←), title "我的印记集", filter icon (right)
- Progress summary card (cream background):
  - "📊 收集进度"
  - Three rows with progress bars:
    - "路线印记: 12/100" + teal progress bar (12%)
    - "城市印记: 3/50" + teal progress bar (6%)
    - "特殊印记: 5/30" + teal progress bar (17%)
  - "已上链: 8" (gold text)
- Section: "─── 路线印记 ───"
  - 3-column grid of seal cards:
    - Seal 1: 🏯 西湖十景, red stamp style, "🔗已上链" badge
    - Seal 2: 🏔️ 黄山云海, red stamp style, "🔗已上链" badge
    - Seal 3: ⛩️ 京都祇园, red stamp style, "未上链"
- Section: "─── 城市印记 ───"
  - Seal grid:
    - Seal 1: 🌆 杭州全通, gold stamp style, "🔗已上链"
    - Seal 2: 🔒 locked, gray, "???" text, "未解锁"
    - Seal 3: 🔒 locked, gray, "???" text, "未解锁"
- Section: "─── 特殊印记 ───"
  - Seal grid:
    - 🌸 樱花季限定 (pink tint)
    - ⚡ 速通达人 (gold tint)
    - 🔒 隐藏印记 (locked)
- Section: "─── 进行中的文化之旅 ───"
  - Journey card: "🗼 上海外滩文化之旅", progress bar "████████░░░░ 7/10", "继续 >" button

Device: iPhone 14 Pro, 390x844px
```

### 13. 印记详情页（含区块链存证）

```
Mobile app UI design, seal detail page with blockchain verification for tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Verified, prestigious, shareable

Key elements:
- Back button (←), title "印记详情"
- Large centered seal illustration:
  - Traditional Chinese red seal style
  - "西湖十景" in seal script
  - "2024.01.15" date
  - Ink texture effect
  - Subtle shadow
- Journey info:
  - "西湖十景文化之旅" (bold)
  - "⭐⭐⭐⭐⭐ 5星文化之旅"
- Section "─── 完成信息 ───":
  - "完成时间：2024-01-15 14:32"
  - "用时：2小时45分"
  - "探索点：10/10 ✓"
- Section "─── 区块链存证 ───":
  - Green "✓ 已上链" status badge
  - Info card (cream background):
    - "链：Polygon" with chain icon
    - "交易哈希：0x7f3a...8b2c" (truncated, monospace font)
    - "区块高度：45,678,901"
    - "时间戳：2024-01-15 14:35:22"
  - Two small buttons: [复制哈希] [链上查看]
- Section "─── 探索照片 ───":
  - Horizontal scroll of 4 photo thumbnails
  - Last thumbnail shows "+7" overlay for more photos
- "分享印记" button at bottom (teal, full width)

Device: iPhone 14 Pro, 390x844px
```

### 14. 相册页面

```
Mobile app UI design, photo album page for tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Nostalgic, organized, shareable

Key elements:
- Back button (←), title "我的相册", filter icon (right)
- Stats summary card:
  - "📷 总照片: 86 | 🗺️ 文化之旅: 12"
- Section: "─── 按文化之旅分类 ───"
- Journey photo groups (expandable cards):
  - Group 1: "西湖十景文化之旅 · 10张 >" 
    - 3 photo thumbnails preview (rounded corners)
  - Group 2: "龙井茶文化之旅 · 6张 >"
    - 3 photo thumbnails preview
  - Group 3: "黄山云海探秘 · 8张 >"
    - 3 photo thumbnails preview
- Section: "─── 按时间线 ───"
- Timeline view:
  - Month header: "2024年1月" (teal text)
  - 4-column photo grid
  - Photos with subtle rounded corners
  - Chronological order, newest first

Device: iPhone 14 Pro, 390x844px
```

### 15. 个人中心页面

```
Mobile app UI design, user profile page for tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) highlights, warm white (#FBF9F7) background
- Typography: Chinese serif for titles, clean sans-serif for body
- Mood: Personal, accomplished, organized

Key elements:
- Back button (←), title "个人中心", settings icon ⚙️ (right)
- Profile header card (cream background):
  - Circular avatar (64px) with teal border
  - Username: "旅行者小明" (bold)
  - "ID: 12345678" (gray, small)
  - Badge: "🏅 西湖文化达人" (gold background pill)
- Stats row (three columns):
  - "3/50" + "城市解锁" + mini progress bar
  - "12/100" + "印记收集" + mini progress bar
  - "8" + "已上链" (gold number)
- Section "─── 功能菜单 ───":
  - Menu list (white cards with right arrow):
    - 🏆 我的印记集 >
    - 📸 我的相册 >
    - 🔗 区块链钱包 >
    - 📊 旅行统计 >
    - 🎁 积分商城 >
    - ⚙️ 设置 >
- Section "─── 最近动态 ───":
  - Activity card: "🎉 收集「西湖十景」路线印记"
  - Date: "2024-01-15" (gray, right aligned)

Device: iPhone 14 Pro, 390x844px
```

---

## 组件设计提示词

### 浮动控件组

```
UI component design, vertical floating action buttons for mobile app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, warm white (#FBF9F7) background

Key elements:
- 5 circular buttons stacked vertically
- Each button: 44x44px with 12px vertical gap
- Icons: 👤 profile, 🏆 trophy, 📷 camera, 🎵 music note, 📍 location pin
- Glass morphism effect: semi-transparent white background with blur
- Subtle shadow for depth (0 4px 12px rgba(0,0,0,0.1))
- Active state: teal (#2D5A5A) background with white icon
- Inactive state: white/cream background with teal icon
- Music button: shows sound wave animation when playing
- Hover/press state: slight scale up (1.05x)

Size: 44px width, ~260px total height
```

### 文化之旅卡片

```
UI component design, journey card for cultural tourism app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, warm white (#FBF9F7) background

Key elements:
- Rounded rectangle card (16px border radius)
- Left side: square illustration thumbnail (80x80px) with cultural scene
- Right side content:
  - Journey name (16px, bold, charcoal)
  - Distance badge (teal pill: "0.5km")
  - Star rating row (⭐⭐⭐⭐⭐ gold stars)
  - Info row: "10探索点 · 3小时" (gray text)
  - Completed count: "👥 1,234人完成" (small, gray)
- Subtle shadow (0 2px 8px rgba(0,0,0,0.08))
- Cream/white background
- Locked variant: grayscale overlay, 🔒 icon, "完成前置条件解锁" text

Size: Full width (358px), ~120px height
```

### 印记卡片

```
UI component design, seal stamp card for collection display in app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) primary, warm gold (#D4A574) accent, coral red (#E07A5F) for seals

Key elements:
- Square card with rounded corners (12px radius)
- Traditional Chinese seal illustration:
  - Red ink stamp texture
  - Seal script characters
  - Worn/aged edge effect
- Seal name below (14px, centered)
- Date stamp (12px, gray)
- Chain status indicator bottom right:
  - "🔗" icon for chained (gold)
  - Empty for unchained
- Locked variant:
  - Grayscale filter
  - 🔒 icon overlay centered
  - "???" as name
  - "未解锁" label
- Subtle shadow

Size: ~100x130px (seal 80x80, text below)
```

### 进度条组件

```
UI component design, progress bar for achievement tracking in app "寻印".

Design Style:
- Theme: Modern Chinese cultural tourism with ink wash painting meets minimalism
- Colors: Deep teal (#2D5A5A) for fill, light gray (#E5E5E5) for track

Key elements:
- Horizontal bar with fully rounded ends (4px radius)
- Track: light gray (#E5E5E5) background
- Fill: teal (#2D5A5A) gradient (slightly lighter at top)
- Text label right side: "12/100" format (14px, charcoal)
- Optional percentage below bar
- Subtle inner shadow on track for depth
- Animation: smooth fill transition (300ms ease-out)

Size: Flexible width, 8px height (bar only)
```

---

## 设计交付清单

完成设计后，请提供以下文件：

### P0 优先级（核心体验）
- [ ] 首页地图 + 浮动控件
- [ ] 城市面板（收起状态）
- [ ] 城市面板（展开状态）
- [ ] 文化之旅详情页
- [ ] AR 任务页 - 手势识别
- [ ] AR 任务页 - 拍照探索

### P1 优先级（完成流程）
- [ ] 文化之旅进行中页面
- [ ] 导航中页面
- [ ] 到达探索点提示
- [ ] 任务完成页
- [ ] 文化之旅完成页

### P2 优先级（辅助功能）
- [ ] 印记集页面
- [ ] 印记详情页
- [ ] 相册页面
- [ ] 个人中心页面

### 组件库
- [ ] 浮动控件组
- [ ] 文化之旅卡片
- [ ] 印记卡片
- [ ] 进度条组件

### 图标资源
- [ ] 城市插画图标（杭州、西安、成都、哈尔滨、北京）
- [ ] 任务类型图标（拍照、手势、寻宝）
- [ ] 浮动控件图标

---

设计稿完成后告诉我，我们继续生成 tasks.md 开始开发！
