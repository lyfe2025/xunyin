# Flutter Web 与原生 App 网络访问差异

## 概述

Flutter 支持编译为多个平台：iOS、Android、Web 等。由于运行环境不同，网络请求和静态资源访问存在显著差异。

## 运行环境对比

| 特性 | 原生 App (iOS/Android) | Flutter Web |
|------|------------------------|-------------|
| 运行环境 | 原生系统 | 浏览器 |
| 网络请求 | 直接 HTTP 请求 | 受浏览器安全策略限制 |
| 跨域限制 | 无 | 有 CORS 限制 |
| 相对路径 | 不支持 | 支持（相对于页面 origin） |
| User-Agent | 可自定义 | 浏览器限制，无法设置 |

## API 访问配置

### 原生 App

原生 App 直接访问公网 API，使用完整 URL：

```dart
// AppConfig.apiBaseUrl 返回完整 URL
// 如：https://xunyin.pynb.org/api/app
```

访问链路：
```
App → 公网 → Cloudflare → 服务器 → NestJS
```

### Flutter Web

Flutter Web 部署在 Docker 容器中，通过 Nginx 反向代理访问后端：

```dart
// AppConfig.apiBaseUrl 返回相对路径
// 如：/api/app
```

访问链路：
```
浏览器 → Cloudflare → 宝塔 Nginx → Docker App 容器
                                      ↓
                              容器内 Nginx → Docker Server 容器
```

### 配置代码

```dart
// app_flutter/lib/core/config/app_config.dart
static String get apiBaseUrl {
  if (kIsWeb) {
    // Web 环境：使用相对路径，由 Nginx 代理
    return '/api/app';
  }
  // 原生 App：使用完整 URL
  return 'https://xunyin.pynb.org/api/app';
}
```

## 静态资源访问

### 问题背景

API 返回的图片路径是相对路径：
```json
{
  "coverImage": "/uploads/images/city-hangzhou.jpg"
}
```

### 原生 App 处理

原生 App 需要拼接完整 URL：
```dart
// 输入：/uploads/images/city-hangzhou.jpg
// 输出：https://xunyin.pynb.org/uploads/images/city-hangzhou.jpg
```

### Flutter Web 处理

Flutter Web 的 `Image.network()` 组件**不支持相对路径**，必须使用完整 URL。

**错误做法**：直接使用相对路径
```dart
Image.network('/uploads/images/city-hangzhou.jpg')  // ❌ 无法加载
```

**正确做法**：拼接当前页面的 origin
```dart
Image.network('https://xunyin-web.pynb.org/uploads/images/city-hangzhou.jpg')  // ✅
```

### 解决方案

使用条件导入获取当前页面 origin：

```dart
// url_utils.dart
import 'url_utils_stub.dart'
    if (dart.library.html) 'url_utils_web.dart' as platform;

static String get serverBaseUrl {
  if (kIsWeb) {
    return platform.getOrigin();  // 返回 https://xunyin-web.pynb.org
  }
  // 原生 App 逻辑...
}

// url_utils_web.dart
import 'dart:html' as html;
String getOrigin() => html.window.location.origin;

// url_utils_stub.dart（非 Web 平台）
String getOrigin() => '';
```

## Nginx 代理配置

### Flutter Web 容器 (app_flutter/nginx.web.conf)

```nginx
server {
    listen 80;
    
    # SPA 路由
    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;
    }

    # API 代理到后端容器
    location /api/ {
        proxy_pass http://server:3000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 静态资源代理
    location ^~ /uploads/ {
        proxy_pass http://server:3000/uploads/;
        proxy_set_header Host $host;
    }
}
```

## 常见问题

### 1. 图片不显示

**症状**：API 请求正常，但图片显示占位图

**原因**：`Image.network()` 使用了相对路径

**解决**：确保 `UrlUtils.getFullImageUrl()` 在 Web 环境下返回完整 URL

### 2. Refused to set unsafe header "User-Agent"

**症状**：控制台警告 `Refused to set unsafe header "User-Agent"`

**原因**：浏览器安全策略禁止 JavaScript 设置某些 HTTP 头

**影响**：无，这只是警告，不影响功能

### 3. CORS 错误

**症状**：请求被浏览器拦截，提示跨域错误

**原因**：后端未配置 CORS 或配置不正确

**解决**：确保后端配置了正确的 CORS 头：
```typescript
// NestJS main.ts
app.enableCors({
  origin: ['https://xunyin-web.pynb.org'],
  credentials: true,
})
```

## 部署检查清单

- [ ] Flutter Web 容器 Nginx 配置了 `/api/` 代理
- [ ] Flutter Web 容器 Nginx 配置了 `/uploads/` 代理
- [ ] `UrlUtils.getFullImageUrl()` 在 Web 环境返回完整 URL
- [ ] 后端 CORS 配置包含 Flutter Web 域名
- [ ] 静态资源目录挂载到后端容器

## 相关文件

| 文件 | 说明 |
|------|------|
| `app_flutter/lib/core/config/app_config.dart` | API 地址配置 |
| `app_flutter/lib/core/utils/url_utils.dart` | URL 工具类 |
| `app_flutter/lib/core/utils/url_utils_web.dart` | Web 平台实现 |
| `app_flutter/nginx.web.conf` | Web 容器 Nginx 配置 |
| `docker-compose.yml` | Docker 编排配置 |
