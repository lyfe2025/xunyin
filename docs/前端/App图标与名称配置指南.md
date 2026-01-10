# App 图标与名称配置指南

## 当前配置

| 平台 | 显示名称 | 配置文件 |
|------|----------|----------|
| iOS | 寻印 | `ios/Runner/Info.plist` → `CFBundleDisplayName` |
| Android | 寻印 | `android/app/src/main/AndroidManifest.xml` → `android:label` |

## 静态配置（打包时确定）

### 修改 App 名称

**iOS** - `ios/Runner/Info.plist`：
```xml
<key>CFBundleDisplayName</key>
<string>寻印</string>
```

**Android** - `android/app/src/main/AndroidManifest.xml`：
```xml
<application android:label="寻印" ...>
```

### 修改 App 图标

推荐使用 `flutter_launcher_icons` 自动生成所有尺寸：

```bash
# 1. 添加依赖
flutter pub add flutter_launcher_icons --dev

# 2. 在 pubspec.yaml 添加配置
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"  # 1024x1024 PNG
  adaptive_icon_background: "#C41E3A"       # Android 自适应图标背景色

# 3. 生成图标
flutter pub run flutter_launcher_icons
```

**图标文件位置：**
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Android: `android/app/src/main/res/mipmap-*/`

## 动态切换（运行时切换）

### 能力与限制

| 功能 | iOS | Android | 说明 |
|------|-----|---------|------|
| 动态切换图标 | ✅ | ✅ | 需预先打包多套图标 |
| 动态切换名称 | ✅ | ✅ | 与图标绑定切换 |
| 后台控制切换 | ✅ | ✅ | App 启动时请求配置 |
| 用户无感知切换 | ❌ | ❌ | 系统限制，无法绑过 |
| 从服务器下载新图标 | ❌ | ❌ | 必须预先打包 |

### 系统限制

- **iOS**: 切换时系统会弹出提示框"您已更改此 App 的图标"，无法禁用
- **Android**: 切换时 App 会短暂"闪退"重启

### 实现方式

使用 `flutter_dynamic_icon` 插件：

```yaml
dependencies:
  flutter_dynamic_icon: ^2.1.0
```

```dart
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';

// 切换到备用图标（如春节版）
await FlutterDynamicIcon.setAlternateIconName("icon_spring_festival");

// 恢复默认图标
await FlutterDynamicIcon.setAlternateIconName(null);

// 获取当前图标名称
final currentIcon = await FlutterDynamicIcon.getAlternateIconName();
```

### 后台控制切换流程

```dart
/// App 启动时检查图标配置
Future<void> checkAppIconConfig() async {
  try {
    // 1. 从后台获取当前应该显示的图标配置
    final config = await api.get('/config/app-icon');
    final targetIcon = config['iconName']; // 如 "spring_festival" 或 null
    
    // 2. 获取当前图标
    final currentIcon = await FlutterDynamicIcon.getAlternateIconName();
    
    // 3. 如果不一致，提示用户切换
    if (currentIcon != targetIcon) {
      final confirmed = await showIconSwitchDialog(targetIcon);
      if (confirmed) {
        await FlutterDynamicIcon.setAlternateIconName(targetIcon);
      }
    }
  } catch (e) {
    // 忽略错误，使用当前图标
  }
}
```

### iOS 配置备用图标

在 `Info.plist` 中添加：

```xml
<key>CFBundleIcons</key>
<dict>
    <key>CFBundlePrimaryIcon</key>
    <dict>
        <key>CFBundleIconFiles</key>
        <array>
            <string>AppIcon</string>
        </array>
    </dict>
    <key>CFBundleAlternateIcons</key>
    <dict>
        <key>icon_spring_festival</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>AppIcon-SpringFestival</string>
            </array>
        </dict>
        <key>icon_mid_autumn</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>AppIcon-MidAutumn</string>
            </array>
        </dict>
    </dict>
</dict>
```

### Android 配置备用图标

在 `AndroidManifest.xml` 中添加 activity-alias：

```xml
<!-- 默认图标 -->
<activity android:name=".MainActivity" android:icon="@mipmap/ic_launcher" ...>
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity>

<!-- 春节图标 -->
<activity-alias
    android:name=".MainActivitySpringFestival"
    android:enabled="false"
    android:icon="@mipmap/ic_launcher_spring"
    android:label="寻印·新春版"
    android:targetActivity=".MainActivity">
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity-alias>
```

## 推荐方案

### 节日图标最佳实践

1. **提前发版** - 节日前发布包含新图标的版本，根据日期自动提示切换
2. **用户主动选择** - 在 App 内引导用户切换，而非强制切换
3. **保留默认选项** - 允许用户随时切回默认图标

```dart
/// 节日图标检查示例
void checkHolidayIcon() {
  final now = DateTime.now();
  
  // 春节期间（农历新年前后）
  if (now.month == 1 && now.day >= 20 || now.month == 2 && now.day <= 15) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('🧧 新春快乐'),
        content: Text('春节限定图标已上线，是否切换？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('暂不')),
          TextButton(
            onPressed: () async {
              await FlutterDynamicIcon.setAlternateIconName('icon_spring_festival');
              Navigator.pop(context);
            },
            child: Text('立即切换'),
          ),
        ],
      ),
    );
  }
}
```

## 总结

| 需求 | 方案 | 用户体验 |
|------|------|----------|
| 固定 App 名称/图标 | 修改配置文件，打包发布 | ⭐⭐⭐⭐⭐ 最佳 |
| 节日限定图标 | 提前发版 + 日期判断提示切换 | ⭐⭐⭐⭐ 良好 |
| 后台控制切换 | 动态图标 + 用户确认 | ⭐⭐⭐ 一般 |
| 完全无感知切换 | ❌ 无法实现 | - |
