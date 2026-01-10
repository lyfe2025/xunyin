# Flutter App 配色规范

## 品牌配色体系

寻印 App 采用「中国红 + 黛青」双色体系，体现文化探索的品牌调性。

### 核心色彩

| 角色 | 变量名 | 色值 | 用途 |
|------|--------|------|------|
| **品牌主色** | `accent` | `#C41E3A` 中国红 | 主要按钮、CTA、重要操作、品牌标识 |
| **品牌主色-亮** | `accentLight` | `#E04358` | 渐变、悬停状态 |
| **品牌主色-暗** | `accentDark` | `#9A1830` | 渐变、按下状态 |
| **辅助色** | `primary` | `#425066` 黛青 | 次要元素、装饰、阴影、图标 |
| **辅助色-亮** | `primaryLight` | `#5A6B82` | 渐变 |
| **辅助色-暗** | `primaryDark` | `#2D3A4D` | 渐变 |

### 使用原则

#### ✅ 使用 `accent`（中国红）的场景

- 主要操作按钮（登录、确认、提交、保存）
- 引导性按钮（发现城市、开始旅程）
- 重要链接（用户协议、隐私政策）
- 获取验证码按钮
- 品牌 Logo 和标识
- 进度完成状态

```dart
// ✅ 正确：主要按钮使用 accent
gradient: LinearGradient(
  colors: [AppColors.accent, AppColors.accentDark],
)

// ✅ 正确：AppPrimaryButton 已内置 accent 色
AppPrimaryButton(
  onPressed: _submit,
  child: Text('确认'),
)
```

#### ✅ 使用 `primary`（黛青）的场景

- 装饰性阴影（`withValues(alpha: 0.05~0.15)`）
- Aurora 背景渐变装饰
- 地图路线颜色
- 次要图标（分享、相册等非主要操作）
- 信息展示类元素
- 进度条渐变的辅助色

```dart
// ✅ 正确：装饰性阴影
BoxShadow(
  color: AppColors.primary.withValues(alpha: 0.08),
  blurRadius: 20,
)

// ✅ 正确：次要图标
Icon(Icons.share, color: AppColors.primary)

// ✅ 正确：进度条渐变（accent 为主，primary 为辅）
LinearGradient(
  colors: [AppColors.accent, AppColors.primary],
)
```

#### ❌ 避免的用法

```dart
// ❌ 错误：主要按钮不应使用 primary
gradient: LinearGradient(
  colors: [AppColors.primary, AppColors.primaryDark],
)

// ❌ 错误：CTA 按钮不应混用
colors: [AppColors.primary, AppColors.accent]  // 应统一用 accent
```

### 按钮组件规范

**推荐**：主要 CTA 按钮统一使用 `AppPrimaryButton`，它内置了品牌渐变效果。

| 组件 | 用途 | 样式 | 推荐度 |
|------|------|------|--------|
| `AppPrimaryButton` | 主要操作（登录、确认、开始导航等） | `accent → accentDark` 渐变 | ⭐⭐⭐ 首选 |
| `AppSecondaryButton` | 次要操作 | `accent` 描边 | ⭐⭐⭐ |
| `AppGlassButton` | 玻璃态按钮 | 透明 + 边框 | ⭐⭐ |
| `ElevatedButton` | 系统按钮（备用） | 纯色 `accent` | ⭐ 不推荐 |
| `TextButton` | 文字按钮 | `accent` 文字 | ⭐⭐ |
| `OutlinedButton` | 描边按钮 | 根据场景选择 | ⭐⭐ |

```dart
// ✅ 推荐：使用 AppPrimaryButton（自带渐变）
AppPrimaryButton(
  onPressed: _handleSubmit,
  child: Text('确认'),
)

// ✅ 推荐：带图标的主要按钮
AppPrimaryButton(
  onPressed: _startNavigation,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.navigation_rounded, size: 18),
      SizedBox(width: 8),
      Text('开始导航'),
    ],
  ),
)

// ❌ 不推荐：直接使用 ElevatedButton（无渐变）
ElevatedButton(
  onPressed: _handleSubmit,
  child: Text('确认'),
)
```

### 状态色

| 用途 | 变量名 | 色值 |
|------|--------|------|
| 成功 | `success` | `#52C41A` |
| 警告 | `warning` | `#FAAD14` |
| 错误 | `error` | `#FF4D4F` |
| 信息 | `info` | `#1890FF` |

### 印记专用色

| 用途 | 变量名 | 色值 |
|------|--------|------|
| 金色印记 | `sealGold` | `#E6B422` |
| 银色印记 | `sealSilver` | `#C0C0C0` |
| 铜色印记 | `sealBronze` | `#CD7F32` |
| 未解锁 | `sealLocked` | `#CCCCCC` |

#### `sealGold` 的特殊用途

除了印记展示，`sealGold` 还用于区块链相关功能：
- 上链存证按钮和图标
- 链上验证相关 UI
- 体现"珍贵、永久、可信"的视觉语义

### 深色模式适配

使用 `AppColors` 提供的适配方法：

```dart
// 自动适配深色模式
AppColors.textPrimaryAdaptive(context)
AppColors.cardBackground(context)
AppColors.borderAdaptive(context)
```

### 代码位置

配色定义：`app_flutter/lib/core/theme/app_colors.dart`
主题配置：`app_flutter/lib/core/theme/app_theme.dart`
