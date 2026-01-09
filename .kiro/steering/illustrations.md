# 插画资源规范

## 插画来源

项目使用 [unDraw](https://undraw.co) 开源插画库，CC0 许可，免费商用无需署名。

## 品牌色

所有插画需要将 unDraw 默认紫色 `#6c63ff` 替换为品牌色 `#C41E3A`（中国红）。

## 下载方式

unDraw 的 SVG 文件托管在 CDN，可通过以下 URL 格式直接下载：

```
https://cdn.undraw.co/illustrations/{illustration_slug}.svg
```

### 下载步骤

1. 在 unDraw 网站搜索合适的插画，获取 slug（如 `photo-album_9d6r`）
2. 使用 curl 下载：
   ```bash
   curl -s "https://cdn.undraw.co/illustrations/photo-album_9d6r.svg" -o /tmp/photo-album.svg
   ```
3. 替换品牌色：
   ```bash
   sed -i '' 's/#6c63ff/#C41E3A/gi' /tmp/photo-album.svg
   ```
4. 复制到项目目录：
   ```bash
   cp /tmp/photo-album.svg app_flutter/assets/illustrations/
   ```

### 搜索插画

可以使用 Exa 搜索引擎查找 unDraw 插画：

```
undraw illustration SVG {关键词}
```

例如：`undraw illustration SVG travel adventure` 会返回相关插画的页面 URL。

## 插画目录

插画文件存放在 `app_flutter/assets/illustrations/` 目录。

## 当前插画清单

| 文件名 | 用途 | unDraw 原名 |
|--------|------|-------------|
| `empty_album.svg` | 相册空状态 | photo-album_9d6r |
| `empty_journey.svg` | 我的旅程空状态 | journey_brk8 |
| `empty_seal.svg` | 印记列表空状态 | collection_ly06 |
| `empty_activity.svg` | 个人中心动态空状态 | empty_4zx0 |
| `welcome_new_user.svg` | 新用户引导卡片 | welcoming_42an |
| `journey_complete.svg` | 旅程完成庆祝页 | fireworks_2xuq |
| `error_network.svg` | 网络错误/加载失败 | server-down_lxs9 |
| `no_search_result.svg` | 搜索无结果 | no-data_ig65 |
| `empty_city.svg` | 城市无文化之旅 | location-search_nesh |

## Flutter 使用方式

```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/illustrations/empty_album.svg',
  width: 180,
  height: 135,
)
```

## 注意事项

- 部分 unDraw 插画可能使用其他主色（如 `#0055DC`），需要检查并替换
- 验证颜色替换：`grep -c '#C41E3A' file.svg`
- 确保 `pubspec.yaml` 中已配置 `assets/illustrations/` 目录
