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

## 交互反馈组件规范

### 加载组件

| 组件 | 用途 | 特点 |
|------|------|------|
| `AppLoading` | 通用加载 | 带品牌呼吸光晕动画 |
| `AppLoadingSimple` | 小空间加载 | 简单指示器，无动画 |
| `AppLoadingCard` | 卡片内加载 | 带容器背景 |
| `AppLoadingOverlay` | 全屏遮罩加载 | 阻止用户操作 |
| `AppPageLoading` | 页面级加载 | 居中显示 |

```dart
// ✅ 推荐：使用统一加载组件
const AppLoading(message: '加载中...')

// ✅ 全屏加载遮罩
await AppLoadingOverlay.show(
  context: context,
  task: () => someAsyncTask(),
  message: '处理中...',
);
```

### 对话框组件

| 组件 | 用途 | 特点 |
|------|------|------|
| `AppDialog` | 基础对话框 | Glassmorphism 风格 |
| `AppConfirmDialog` | 确认对话框 | 带图标、品牌渐变按钮 |
| `AppSuccessDialog` | 成功提示 | 绿色图标 |
| `AppErrorDialog` | 错误提示 | 红色图标 |

```dart
// ✅ 确认对话框
final confirmed = await AppConfirmDialog.show(
  context: context,
  title: '退出登录',
  content: '确定要退出吗？',
  confirmText: '退出',
  isDanger: true,  // 图标显示警告样式
);

// ✅ 成功提示
await AppSuccessDialog.show(
  context: context,
  title: '操作成功',
  content: '数据已保存',
);
```

**注意**：所有对话框的确认按钮统一使用品牌红渐变，`isDanger` 参数只影响图标颜色（警告图标 + 红色）。

### 通知组件 (SnackBar)

| 方法 | 用途 | 颜色 |
|------|------|------|
| `AppSnackBar.success()` | 成功提示 | 绿色 + ✓ 图标 |
| `AppSnackBar.error()` | 错误提示 | 红色 + ✗ 图标 |
| `AppSnackBar.warning()` | 警告提示 | 黄色 + ⚠ 图标 |
| `AppSnackBar.info()` | 信息提示 | 蓝色 + ℹ 图标 |
| `AppSnackBar.show()` | 普通提示 | 深色背景 |
| `AppSnackBar.loading()` | 加载提示 | 品牌色 + 转圈 |
| `AppSnackBar.withAction()` | 带操作按钮 | 深色 + 按钮 |

```dart
// ✅ 推荐：使用统一 SnackBar
AppSnackBar.success(context, '保存成功');
AppSnackBar.error(context, '操作失败');

// ✅ 带操作按钮
AppSnackBar.withAction(
  context,
  message: '已删除',
  actionLabel: '撤销',
  onAction: () => undoDelete(),
);

// ❌ 不推荐：直接使用 ScaffoldMessenger
ScaffoldMessenger.of(context).showSnackBar(...);
```

### Toast 轻量提示

```dart
// 居中显示，自动消失
AppToast.show(context, '已复制');
AppToast.success(context, '操作成功');
AppToast.error(context, '操作失败');
```
