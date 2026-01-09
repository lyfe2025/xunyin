---
inclusion: manual
---

# UI/UX Pro Max - Flutter 设计智能

可搜索的 UI 样式、配色方案、字体搭配、图表类型、产品推荐、UX 指南和 Flutter 最佳实践数据库。

## 前置条件

确保 Python 已安装：

```bash
python3 --version || python --version
```

---

## 使用方法

当用户请求 UI/UX 相关工作（设计、构建、创建、实现、审查、修复、改进）时，按以下流程操作：

### 步骤 1: 分析用户需求

从用户请求中提取关键信息：
- **产品类型**: SaaS、电商、作品集、仪表盘、落地页等
- **风格关键词**: 极简、活泼、专业、优雅、暗色模式等
- **行业**: 医疗、金融科技、游戏、教育、文化旅游等
- **技术栈**: 默认使用 `flutter`

### 步骤 2: 搜索相关领域

使用 `search.py` 多次搜索以获取全面信息：

```bash
python3 .shared/ui-ux-pro-max/scripts/search.py "<关键词>" --domain <领域> [-n <最大结果数>]
```

**推荐搜索顺序：**

1. **Product** - 获取产品类型的风格推荐
2. **Style** - 获取详细风格指南（颜色、效果、框架）
3. **Typography** - 获取字体搭配和 Google Fonts 导入
4. **Color** - 获取配色方案（主色、辅色、CTA、背景、文字、边框）
5. **UX** - 获取最佳实践和反模式
6. **Stack** - 获取 Flutter 特定指南

### 步骤 3: Flutter 特定指南

**始终使用 `flutter` 作为技术栈：**

```bash
python3 .shared/ui-ux-pro-max/scripts/search.py "<关键词>" --stack flutter
```

---

## 搜索参考

### 可用领域

| 领域 | 用途 | 示例关键词 |
|------|------|-----------|
| `product` | 产品类型推荐 | SaaS, e-commerce, portfolio, healthcare, beauty, service, cultural, travel |
| `style` | UI 样式、颜色、效果 | glassmorphism, minimalism, dark mode, brutalism, aurora |
| `typography` | 字体搭配、Google Fonts | elegant, playful, professional, modern |
| `color` | 按产品类型的配色方案 | saas, ecommerce, healthcare, beauty, fintech, service |
| `chart` | 图表类型、库推荐 | trend, comparison, timeline, funnel, pie |
| `ux` | 最佳实践、反模式 | animation, accessibility, z-index, loading |
| `prompt` | AI 提示词、CSS 关键词 | (风格名称) |

### Flutter 技术栈

| 类别 | 关键词 |
|------|--------|
| Widgets | StatelessWidget, StatefulWidget, const, composition |
| State | setState, Riverpod, Provider, dispose |
| Layout | Column, Row, Expanded, Flexible, SizedBox, LayoutBuilder |
| Lists | ListView.builder, itemExtent, keys, SliverList |
| Navigation | go_router, named routes, PopScope |
| Async | FutureBuilder, StreamBuilder, loading states |
| Theming | ThemeData, ColorScheme, dark mode |
| Animation | implicit animations, AnimationController, Hero |
| Forms | Form widget, TextEditingController, validation |
| Performance | const widgets, RepaintBoundary, DevTools |
| Accessibility | Semantics, large fonts, screen readers |

---

## 示例工作流

**用户请求：** "为寻印 App 设计一个文化之旅详情页"

**AI 应该：**

```bash
# 1. 搜索产品类型
python3 .shared/ui-ux-pro-max/scripts/search.py "cultural travel tourism service" --domain product

# 2. 搜索风格（基于行业：文化、旅游）
python3 .shared/ui-ux-pro-max/scripts/search.py "elegant minimal cultural" --domain style

# 3. 搜索配色方案
python3 .shared/ui-ux-pro-max/scripts/search.py "travel cultural service" --domain color

# 4. 搜索 UX 指南
python3 .shared/ui-ux-pro-max/scripts/search.py "animation" --domain ux
python3 .shared/ui-ux-pro-max/scripts/search.py "accessibility" --domain ux

# 5. 搜索 Flutter 指南
python3 .shared/ui-ux-pro-max/scripts/search.py "layout responsive" --stack flutter
python3 .shared/ui-ux-pro-max/scripts/search.py "theming dark mode" --stack flutter
python3 .shared/ui-ux-pro-max/scripts/search.py "animation" --stack flutter
```

**然后：** 综合所有搜索结果并实现设计。

---

## Flutter UI 专业规范

### 图标与视觉元素

| 规则 | 正确做法 | 错误做法 |
|------|---------|---------|
| **不使用 emoji 图标** | 使用 Flutter Icons 或 SVG | 使用 emoji 作为 UI 图标 |
| **稳定的悬停状态** | 使用颜色/透明度过渡 | 使用会移动布局的缩放变换 |
| **一致的图标大小** | 使用固定尺寸 (24x24) | 随意混用不同图标大小 |

### 交互与反馈

| 规则 | 正确做法 | 错误做法 |
|------|---------|---------|
| **点击反馈** | InkWell/GestureDetector 带视觉反馈 | 无交互指示 |
| **平滑过渡** | 使用 Duration(milliseconds: 200) | 即时状态变化或过慢 (>500ms) |
| **加载状态** | 显示 CircularProgressIndicator | 无加载指示 |

### 亮色/暗色模式

| 规则 | 正确做法 | 错误做法 |
|------|---------|---------|
| **主题支持** | MaterialApp 配置 theme 和 darkTheme | 只有亮色主题 |
| **颜色访问** | Theme.of(context).colorScheme | 硬编码颜色值 |
| **文字对比度** | 使用 ColorScheme 的 onSurface | 使用低对比度颜色 |

### 布局与间距

| 规则 | 正确做法 | 错误做法 |
|------|---------|---------|
| **响应式布局** | LayoutBuilder/MediaQuery | 固定宽度 |
| **一致间距** | SizedBox(height: 16) | Container(height: 16) |
| **安全区域** | SafeArea widget | 忽略刘海/底部指示器 |

---

## 交付前检查清单

### 视觉质量
- [ ] 未使用 emoji 作为图标（使用 Icons 或 SVG）
- [ ] 所有图标来自一致的图标集
- [ ] 悬停/点击状态不会导致布局偏移

### 交互
- [ ] 所有可点击元素有视觉反馈
- [ ] 过渡动画平滑 (150-300ms)
- [ ] 焦点状态对键盘导航可见

### 亮色/暗色模式
- [ ] 亮色模式文字有足够对比度 (4.5:1 最低)
- [ ] 两种模式下边框都可见
- [ ] 交付前测试两种模式

### 布局
- [ ] 响应式适配 320px, 768px, 1024px
- [ ] 无水平滚动
- [ ] SafeArea 正确使用

### 无障碍
- [ ] 所有图片有 semanticLabel
- [ ] 表单输入有标签
- [ ] 颜色不是唯一指示器
- [ ] 支持大字体 (textScaleFactor)

---

## 寻印 App 设计指南

### 产品定位
- 文化探索类应用
- 目标用户：对文化旅游感兴趣的年轻人
- 核心功能：城市探索、文化之旅、印记收集、AR 互动

### 推荐风格
- **主风格**: 优雅极简 (Elegant Minimalism)
- **辅助风格**: 玻璃拟态 (Glassmorphism) 用于卡片
- **配色**: 文化/旅游行业配色，温暖而专业

### 关键页面设计要点
- **首页**: 城市卡片展示，突出视觉吸引力
- **文化之旅详情**: 沉浸式体验，背景图片 + 渐变遮罩
- **探索点**: 清晰的任务指引，进度可视化
- **印记收藏**: 徽章展示，成就感设计
- **AR 页面**: 简洁 HUD，不干扰 AR 体验
