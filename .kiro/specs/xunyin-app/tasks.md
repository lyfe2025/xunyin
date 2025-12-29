# Implementation Tasks

本文档将实现任务分为两个阶段：
- **Phase 1**: NestJS 后端 API 开发（可立即开始）
- **Phase 2**: Flutter App 页面开发（等 UI 设计稿完成后）

---

## Phase 1: NestJS 后端 API 开发

### Task 1: 数据库模型设计与 Prisma Schema 扩展

#### Task 1.1: 添加寻印业务数据模型
- [ ] 在 `server-nestjs/prisma/schema.prisma` 中添加以下模型：

```prisma
// ============ 寻印 App 业务模型 ============

/// App用户表（与管理后台用户分离）
model AppUser {
  id            String    @id @default(cuid())
  phone         String?   @unique @db.VarChar(20)
  nickname      String    @db.VarChar(50)
  avatar        String?   @db.VarChar(255)
  openId        String?   @unique @map("open_id") @db.VarChar(100)  // 微信openId
  unionId       String?   @map("union_id") @db.VarChar(100)         // 微信unionId
  badgeTitle    String?   @map("badge_title") @db.VarChar(50)       // 当前称号
  totalPoints   Int       @default(0) @map("total_points")          // 总积分
  status        String    @default("0") @db.Char(1)                 // 0正常 1禁用
  createTime    DateTime  @default(now()) @map("create_time")
  updateTime    DateTime  @updatedAt @map("update_time")
  
  journeyProgresses JourneyProgress[]
  seals             UserSeal[]
  photos            ExplorationPhoto[]
  activities        UserActivity[]
  
  @@index([phone])
  @@index([openId])
  @@map("app_user")
}

/// 城市表
model City {
  id            String    @id @default(cuid())
  name          String    @db.VarChar(50)
  province      String    @db.VarChar(50)
  latitude      Decimal   @db.Decimal(10, 7)
  longitude     Decimal   @db.Decimal(10, 7)
  iconAsset     String?   @map("icon_asset") @db.VarChar(255)
  coverImage    String?   @map("cover_image") @db.VarChar(255)
  description   String?   @db.Text
  explorerCount Int       @default(0) @map("explorer_count")
  bgmUrl        String?   @map("bgm_url") @db.VarChar(255)
  orderNum      Int       @default(0) @map("order_num")
  status        String    @default("0") @db.Char(1)
  createTime    DateTime  @default(now()) @map("create_time")
  updateTime    DateTime  @updatedAt @map("update_time")
  
  journeys      Journey[]
  citySeals     Seal[]    @relation("CitySeal")
  
  @@index([province])
  @@index([status])
  @@map("city")
}

/// 文化之旅表
model Journey {
  id              String    @id @default(cuid())
  cityId          String    @map("city_id")
  name            String    @db.VarChar(100)
  theme           String    @db.VarChar(100)
  coverImage      String?   @map("cover_image") @db.VarChar(255)
  description     String?   @db.Text
  rating          Int       @default(5)                              // 星级 1-5
  estimatedMinutes Int      @map("estimated_minutes")                // 预计时长(分钟)
  totalDistance   Decimal   @map("total_distance") @db.Decimal(10, 2) // 总距离(米)
  completedCount  Int       @default(0) @map("completed_count")
  isLocked        Boolean   @default(false) @map("is_locked")
  unlockCondition String?   @map("unlock_condition") @db.VarChar(255)
  bgmUrl          String?   @map("bgm_url") @db.VarChar(255)
  orderNum        Int       @default(0) @map("order_num")
  status          String    @default("0") @db.Char(1)
  createTime      DateTime  @default(now()) @map("create_time")
  updateTime      DateTime  @updatedAt @map("update_time")
  
  city            City      @relation(fields: [cityId], references: [id])
  points          ExplorationPoint[]
  progresses      JourneyProgress[]
  routeSeals      Seal[]    @relation("RouteSeal")
  photos          ExplorationPhoto[]
  
  @@index([cityId])
  @@index([status])
  @@map("journey")
}

/// 探索点表
model ExplorationPoint {
  id                  String    @id @default(cuid())
  journeyId           String    @map("journey_id")
  name                String    @db.VarChar(100)
  latitude            Decimal   @db.Decimal(10, 7)
  longitude           Decimal   @db.Decimal(10, 7)
  taskType            String    @map("task_type") @db.VarChar(20)    // gesture, photo, treasure
  taskDescription     String    @map("task_description") @db.VarChar(255)
  targetGesture       String?   @map("target_gesture") @db.VarChar(50)
  arAssetUrl          String?   @map("ar_asset_url") @db.VarChar(255)
  culturalBackground  String?   @map("cultural_background") @db.Text
  culturalKnowledge   String?   @map("cultural_knowledge") @db.Text  // 文化小知识
  distanceFromPrev    Decimal?  @map("distance_from_prev") @db.Decimal(10, 2)
  pointsReward        Int       @default(50) @map("points_reward")
  orderNum            Int       @map("order_num")
  status              String    @default("0") @db.Char(1)
  createTime          DateTime  @default(now()) @map("create_time")
  updateTime          DateTime  @updatedAt @map("update_time")
  
  journey             Journey   @relation(fields: [journeyId], references: [id])
  completions         PointCompletion[]
  photos              ExplorationPhoto[]
  
  @@index([journeyId])
  @@index([status])
  @@map("exploration_point")
}

/// 用户文化之旅进度表
model JourneyProgress {
  id              String    @id @default(cuid())
  userId          String    @map("user_id")
  journeyId       String    @map("journey_id")
  status          String    @default("in_progress") @db.VarChar(20)  // in_progress, completed, abandoned
  startTime       DateTime  @map("start_time")
  completeTime    DateTime? @map("complete_time")
  timeSpentMinutes Int?     @map("time_spent_minutes")
  createTime      DateTime  @default(now()) @map("create_time")
  updateTime      DateTime  @updatedAt @map("update_time")
  
  user            AppUser   @relation(fields: [userId], references: [id])
  journey         Journey   @relation(fields: [journeyId], references: [id])
  pointCompletions PointCompletion[]
  
  @@unique([userId, journeyId])
  @@index([userId])
  @@index([journeyId])
  @@index([status])
  @@map("journey_progress")
}

/// 探索点完成记录表
model PointCompletion {
  id              String    @id @default(cuid())
  progressId      String    @map("progress_id")
  pointId         String    @map("point_id")
  completeTime    DateTime  @map("complete_time")
  pointsEarned    Int       @map("points_earned")
  photoUrl        String?   @map("photo_url") @db.VarChar(255)
  createTime      DateTime  @default(now()) @map("create_time")
  
  progress        JourneyProgress   @relation(fields: [progressId], references: [id])
  point           ExplorationPoint  @relation(fields: [pointId], references: [id])
  
  @@unique([progressId, pointId])
  @@index([progressId])
  @@index([pointId])
  @@map("point_completion")
}

/// 印记表
model Seal {
  id              String    @id @default(cuid())
  type            String    @db.VarChar(20)                          // route, city, special
  name            String    @db.VarChar(100)
  imageAsset      String    @map("image_asset") @db.VarChar(255)
  description     String?   @db.Text
  unlockCondition String?   @map("unlock_condition") @db.VarChar(255)
  badgeTitle      String?   @map("badge_title") @db.VarChar(50)      // 解锁的称号
  journeyId       String?   @map("journey_id")                       // 路线印记关联
  cityId          String?   @map("city_id")                          // 城市印记关联
  orderNum        Int       @default(0) @map("order_num")
  status          String    @default("0") @db.Char(1)
  createTime      DateTime  @default(now()) @map("create_time")
  updateTime      DateTime  @updatedAt @map("update_time")
  
  journey         Journey?  @relation("RouteSeal", fields: [journeyId], references: [id])
  city            City?     @relation("CitySeal", fields: [cityId], references: [id])
  userSeals       UserSeal[]
  
  @@index([type])
  @@index([journeyId])
  @@index([cityId])
  @@index([status])
  @@map("seal")
}

/// 用户印记表
model UserSeal {
  id              String    @id @default(cuid())
  userId          String    @map("user_id")
  sealId          String    @map("seal_id")
  earnedTime      DateTime  @map("earned_time")
  timeSpentMinutes Int?     @map("time_spent_minutes")
  pointsEarned    Int       @default(0) @map("points_earned")
  isChained       Boolean   @default(false) @map("is_chained")
  chainName       String?   @map("chain_name") @db.VarChar(50)
  txHash          String?   @map("tx_hash") @db.VarChar(100)
  blockHeight     BigInt?   @map("block_height")
  chainTime       DateTime? @map("chain_time")
  createTime      DateTime  @default(now()) @map("create_time")
  updateTime      DateTime  @updatedAt @map("update_time")
  
  user            AppUser   @relation(fields: [userId], references: [id])
  seal            Seal      @relation(fields: [sealId], references: [id])
  
  @@unique([userId, sealId])
  @@index([userId])
  @@index([sealId])
  @@index([isChained])
  @@map("user_seal")
}

/// 探索照片表
model ExplorationPhoto {
  id              String    @id @default(cuid())
  userId          String    @map("user_id")
  journeyId       String    @map("journey_id")
  pointId         String    @map("point_id")
  photoUrl        String    @map("photo_url") @db.VarChar(255)
  thumbnailUrl    String?   @map("thumbnail_url") @db.VarChar(255)
  filter          String?   @db.VarChar(20)                          // 使用的滤镜
  latitude        Decimal?  @db.Decimal(10, 7)
  longitude       Decimal?  @db.Decimal(10, 7)
  takenTime       DateTime  @map("taken_time")
  createTime      DateTime  @default(now()) @map("create_time")
  
  user            AppUser   @relation(fields: [userId], references: [id])
  journey         Journey   @relation(fields: [journeyId], references: [id])
  point           ExplorationPoint @relation(fields: [pointId], references: [id])
  
  @@index([userId])
  @@index([journeyId])
  @@index([pointId])
  @@index([takenTime])
  @@map("exploration_photo")
}

/// 用户动态表
model UserActivity {
  id              String    @id @default(cuid())
  userId          String    @map("user_id")
  type            String    @db.VarChar(50)                          // seal_earned, journey_completed, etc.
  title           String    @db.VarChar(255)
  relatedId       String?   @map("related_id")                       // 关联的印记/文化之旅ID
  createTime      DateTime  @default(now()) @map("create_time")
  
  user            AppUser   @relation(fields: [userId], references: [id])
  
  @@index([userId])
  @@index([createTime])
  @@map("user_activity")
}

/// 背景音乐表
model BackgroundMusic {
  id              String    @id @default(cuid())
  name            String    @db.VarChar(100)
  url             String    @db.VarChar(255)
  context         String    @db.VarChar(20)                          // home, city, journey
  contextId       String?   @map("context_id")                       // 城市ID或文化之旅ID
  duration        Int?                                               // 时长(秒)
  orderNum        Int       @default(0) @map("order_num")
  status          String    @default("0") @db.Char(1)
  createTime      DateTime  @default(now()) @map("create_time")
  updateTime      DateTime  @updatedAt @map("update_time")
  
  @@index([context, contextId])
  @@index([status])
  @@map("background_music")
}
```

#### Task 1.2: 执行数据库迁移
- [ ] 运行 `npx prisma migrate dev --name add_xunyin_models`
- [ ] 运行 `npx prisma generate` 生成 Prisma Client

---

### Task 2: App 用户认证模块

#### Task 2.1: 创建 App Auth 模块结构
- [ ] 创建 `server-nestjs/src/app-auth/` 目录
- [ ] 创建以下文件：
  - `app-auth.module.ts`
  - `app-auth.controller.ts`
  - `app-auth.service.ts`
  - `dto/login.dto.ts`
  - `dto/register.dto.ts`
  - `strategies/app-jwt.strategy.ts`
  - `guards/app-auth.guard.ts`

#### Task 2.2: 实现 App 用户认证接口
- [ ] `POST /api/app/auth/login/phone` - 手机号验证码登录
- [ ] `POST /api/app/auth/login/wechat` - 微信登录
- [ ] `POST /api/app/auth/refresh` - 刷新 Token
- [ ] `GET /api/app/auth/me` - 获取当前用户信息
- [ ] `PUT /api/app/auth/profile` - 更新用户资料

---

### Task 3: 城市模块

#### Task 3.1: 创建城市模块结构
- [ ] 创建 `server-nestjs/src/city/` 目录
- [ ] 创建以下文件：
  - `city.module.ts`
  - `city.controller.ts`
  - `city.service.ts`
  - `dto/city.dto.ts`

#### Task 3.2: 实现城市 API
- [ ] `GET /api/app/cities` - 获取城市列表（支持省份筛选）
- [ ] `GET /api/app/cities/:id` - 获取城市详情
- [ ] `GET /api/app/cities/:id/journeys` - 获取城市文化之旅列表
- [ ] `GET /api/app/cities/nearby` - 获取附近城市（基于经纬度）

---

### Task 4: 文化之旅模块

#### Task 4.1: 创建文化之旅模块结构
- [ ] 创建 `server-nestjs/src/journey/` 目录
- [ ] 创建以下文件：
  - `journey.module.ts`
  - `journey.controller.ts`
  - `journey.service.ts`
  - `dto/journey.dto.ts`
  - `dto/start-journey.dto.ts`

#### Task 4.2: 实现文化之旅 API
- [ ] `GET /api/app/journeys/:id` - 获取文化之旅详情
- [ ] `GET /api/app/journeys/:id/points` - 获取探索点列表
- [ ] `POST /api/app/journeys/:id/start` - 开始文化之旅
- [ ] `GET /api/app/journeys/progress` - 获取用户进行中的文化之旅
- [ ] `PUT /api/app/journeys/:id/abandon` - 放弃文化之旅

---

### Task 5: 探索点与任务模块

#### Task 5.1: 创建探索点模块结构
- [ ] 创建 `server-nestjs/src/exploration-point/` 目录
- [ ] 创建以下文件：
  - `exploration-point.module.ts`
  - `exploration-point.controller.ts`
  - `exploration-point.service.ts`
  - `dto/complete-task.dto.ts`

#### Task 5.2: 实现探索点 API
- [ ] `GET /api/app/points/:id` - 获取探索点详情
- [ ] `POST /api/app/points/:id/complete` - 完成探索点任务
- [ ] `POST /api/app/points/:id/validate-location` - 验证用户位置

---

### Task 6: 印记模块

#### Task 6.1: 创建印记模块结构
- [ ] 创建 `server-nestjs/src/seal/` 目录
- [ ] 创建以下文件：
  - `seal.module.ts`
  - `seal.controller.ts`
  - `seal.service.ts`
  - `dto/seal.dto.ts`

#### Task 6.2: 实现印记 API
- [ ] `GET /api/app/seals` - 获取用户印记列表（支持类型筛选）
- [ ] `GET /api/app/seals/:id` - 获取印记详情
- [ ] `GET /api/app/seals/progress` - 获取印记收集进度
- [ ] `GET /api/app/seals/available` - 获取所有可收集印记（含锁定状态）

---

### Task 7: 区块链存证模块

#### Task 7.1: 创建区块链模块结构
- [ ] 创建 `server-nestjs/src/blockchain/` 目录
- [ ] 创建以下文件：
  - `blockchain.module.ts`
  - `blockchain.controller.ts`
  - `blockchain.service.ts`
  - `dto/chain-seal.dto.ts`

#### Task 7.2: 实现区块链 API
- [ ] `POST /api/app/blockchain/chain/:sealId` - 印记上链
- [ ] `GET /api/app/blockchain/verify/:txHash` - 验证链上记录
- [ ] `GET /api/app/blockchain/status/:sealId` - 查询上链状态

---

### Task 8: 相册模块

#### Task 8.1: 创建相册模块结构
- [ ] 创建 `server-nestjs/src/album/` 目录
- [ ] 创建以下文件：
  - `album.module.ts`
  - `album.controller.ts`
  - `album.service.ts`
  - `dto/photo.dto.ts`

#### Task 8.2: 实现相册 API
- [ ] `GET /api/app/photos` - 获取照片列表（支持按文化之旅/时间筛选）
- [ ] `GET /api/app/photos/stats` - 获取相册统计
- [ ] `POST /api/app/photos` - 上传照片
- [ ] `DELETE /api/app/photos/:id` - 删除照片
- [ ] `GET /api/app/photos/journey/:journeyId` - 获取文化之旅照片

---

### Task 9: 用户统计模块

#### Task 9.1: 创建用户统计模块结构
- [ ] 创建 `server-nestjs/src/user-stats/` 目录
- [ ] 创建以下文件：
  - `user-stats.module.ts`
  - `user-stats.controller.ts`
  - `user-stats.service.ts`

#### Task 9.2: 实现用户统计 API
- [ ] `GET /api/app/stats/overview` - 获取用户统计概览
- [ ] `GET /api/app/stats/activities` - 获取用户最近动态
- [ ] `GET /api/app/stats/travel` - 获取旅行统计详情

---

### Task 10: 背景音乐模块

#### Task 10.1: 创建音乐模块结构
- [ ] 创建 `server-nestjs/src/audio/` 目录
- [ ] 创建以下文件：
  - `audio.module.ts`
  - `audio.controller.ts`
  - `audio.service.ts`

#### Task 10.2: 实现音乐 API
- [ ] `GET /api/app/audio/home` - 获取首页背景音乐
- [ ] `GET /api/app/audio/city/:cityId` - 获取城市背景音乐
- [ ] `GET /api/app/audio/journey/:journeyId` - 获取文化之旅背景音乐

---

### Task 10.5: 地图服务模块

> 说明：后端提供地图配置和地理围栏验证，不依赖具体前端地图方案。

#### Task 10.5.1: 创建地图服务模块结构
- [ ] 创建 `server-nestjs/src/map/` 目录
- [ ] 创建以下文件：
  - `map.module.ts`
  - `map.controller.ts`
  - `map.service.ts`
  - `providers/amap.provider.ts` - 高德 API 封装（导航、POI）
  - `dto/location.dto.ts`
  - `dto/route.dto.ts`

#### Task 10.5.2: 实现地图配置 API
- [ ] `GET /api/app/map/config` - 获取地图配置
  ```json
  {
    "provider": "amap",  // 当前使用的地图方案
    "amap": {
      "key": "xxx",
      "securityCode": "xxx"
    },
    "maptiler": {        // 备选方案配置
      "key": "xxx",
      "styleUrl": "xxx"
    },
    "cityMarkers": [     // 城市图标配置（与地图方案无关）
      {
        "cityId": "hangzhou",
        "iconAsset": "assets/icons/hangzhou.png",
        "position": { "lat": 30.27, "lng": 120.15 }
      }
    ]
  }
  ```

#### Task 10.5.3: 实现地理围栏验证 API
- [ ] `POST /api/app/map/validate-location` - 验证用户是否在探索点范围内
  ```json
  // Request
  {
    "pointId": "xxx",
    "userLat": 30.2741,
    "userLng": 120.1551
  }
  // Response
  {
    "isInRange": true,
    "distance": 35.2,  // 米
    "threshold": 50    // 米
  }
  ```

#### Task 10.5.4: 实现路径规划代理 API（高德）
- [ ] `POST /api/app/map/route/walking` - 步行路径规划
  ```json
  // Request
  {
    "origin": { "lat": 30.2741, "lng": 120.1551 },
    "destination": { "lat": 30.2801, "lng": 120.1601 }
  }
  // Response
  {
    "distance": 850,      // 米
    "duration": 12,       // 分钟
    "polyline": "xxx",    // 编码后的路径
    "steps": [...]        // 导航步骤
  }
  ```

#### Task 10.5.5: 实现 POI 搜索代理 API
- [ ] `GET /api/app/map/search` - 景点搜索（代理高德 POI 搜索）
  ```json
  // Request: ?keyword=断桥&city=杭州
  // Response
  {
    "pois": [
      {
        "name": "断桥残雪",
        "address": "杭州市西湖区...",
        "lat": 30.2601,
        "lng": 120.1501
      }
    ]
  }
  ```

#### Task 10.5.6: 实现地图数据缓存
- [ ] 缓存城市边界数据
- [ ] 缓存热门路径规划结果
- [ ] 缓存 POI 搜索结果（Redis）

---

### Task 11: 管理后台 API（用于 Web 管理端）

#### Task 11.1: 城市管理
- [ ] `GET /api/admin/cities` - 城市列表（分页）
- [ ] `POST /api/admin/cities` - 创建城市
- [ ] `PUT /api/admin/cities/:id` - 更新城市
- [ ] `DELETE /api/admin/cities/:id` - 删除城市

#### Task 11.2: 文化之旅管理
- [ ] `GET /api/admin/journeys` - 文化之旅列表（分页）
- [ ] `POST /api/admin/journeys` - 创建文化之旅
- [ ] `PUT /api/admin/journeys/:id` - 更新文化之旅
- [ ] `DELETE /api/admin/journeys/:id` - 删除文化之旅

#### Task 11.3: 探索点管理
- [ ] `GET /api/admin/points` - 探索点列表
- [ ] `POST /api/admin/points` - 创建探索点
- [ ] `PUT /api/admin/points/:id` - 更新探索点
- [ ] `DELETE /api/admin/points/:id` - 删除探索点

#### Task 11.4: 印记管理
- [ ] `GET /api/admin/seals` - 印记列表
- [ ] `POST /api/admin/seals` - 创建印记
- [ ] `PUT /api/admin/seals/:id` - 更新印记
- [ ] `DELETE /api/admin/seals/:id` - 删除印记

#### Task 11.5: 数据统计
- [ ] `GET /api/admin/dashboard/stats` - 仪表盘统计数据
- [ ] `GET /api/admin/dashboard/trends` - 趋势数据

---

### Task 12: 注册模块到 AppModule

- [ ] 在 `app.module.ts` 中导入所有新模块
- [ ] 配置 API 路由前缀

---

### Task 13: API 文档与测试

#### Task 13.1: Swagger 文档
- [ ] 为所有 API 添加 Swagger 装饰器
- [ ] 配置 Swagger UI 访问路径

#### Task 13.2: 单元测试
- [ ] 为核心 Service 编写单元测试
- [ ] 为关键 API 编写 E2E 测试

---

## Phase 2: Flutter App 页面开发（等 UI 设计稿完成后）

> ⚠️ 以下任务需要 UI 设计稿完成后再开始

### Task 14: Flutter 项目初始化

#### Task 14.1: 创建 Flutter 项目
- [ ] 在 `app/` 目录创建 Flutter 项目
- [ ] 配置 `pubspec.yaml` 依赖
- [ ] 配置 Android/iOS 原生设置

#### Task 14.2: 项目架构搭建
- [ ] 创建目录结构（参考 design.md）
- [ ] 配置 Riverpod
- [ ] 配置 Dio 网络层
- [ ] 配置路由（auto_route）
- [ ] 配置主题

---

### Task 15: 地图模块集成（可替换架构）

> ⚠️ **地图展示方案待定**：首页地图展示有三个备选方案，架构设计需支持低成本切换。
> 导航功能固定使用高德 SDK（国内精准）。

#### Task 15.1: 地图抽象层设计
- [ ] 创建 `lib/core/map/` 目录
- [ ] 定义地图接口 `MapProvider`：
  ```dart
  abstract class MapProvider {
    Widget buildMap({required MapConfig config});
    void addMarkers(List<CityMarker> markers);
    void onMarkerTap(Function(String cityId) callback);
    void moveTo(LatLng position, {double? zoom});
    void setStyle(MapStyle style);
  }
  ```
- [ ] 定义 `CityMarker` 数据模型（与具体 SDK 无关）
- [ ] 定义 `MapStyle` 配置（配色、图层显示等）

#### Task 15.2: 高德地图实现（MVP 默认方案）
- [ ] 申请高德地图 API Key（Android/iOS）
- [ ] 集成 `amap_flutter_map` 插件
- [ ] 实现 `AMapProvider implements MapProvider`
- [ ] 配置简约配色样式（米白背景、柔和水系）
- [ ] 实现自定义 Marker（使用插画图标）
- [ ] 隐藏多余 POI 标注

#### Task 15.3: 高德定位与导航（固定方案）
- [ ] 集成 `amap_flutter_location`（定位）
- [ ] 实现用户位置实时追踪
- [ ] 实现步行导航功能
- [ ] 实现到达探索点检测（50米范围）

#### Task 15.4: 备选方案 A - MapTiler（如需更好的自定义样式）
- [ ] 申请 MapTiler API Key
- [ ] 集成 `flutter_map` + `flutter_map_maptiler`
- [ ] 实现 `MapTilerProvider implements MapProvider`
- [ ] 在 MapTiler Cloud 配置自定义样式
- [ ] 添加渐变天空叠加层（可选）
- [ ] 添加云朵装饰叠加层（可选）

#### Task 15.5: 备选方案 B - 自绘插画地图（如需完全匹配 UI 风格）
- [ ] 设计师提供中国地图插画底图（SVG）
- [ ] 设计师提供城市坐标映射表
- [ ] 实现 `IllustrationMapProvider implements MapProvider`
- [ ] 使用 `InteractiveViewer` + `Stack` 实现缩放和交互
- [ ] 实现城市图标点击交互

#### Task 15.6: 地图方案切换配置
- [ ] 在 `AppConfig` 中添加地图方案配置
  ```dart
  enum MapProviderType { amap, maptiler, illustration }
  ```
- [ ] 通过依赖注入切换地图实现
- [ ] 支持运行时或编译时切换

**切换成本预估：**
| 切换路径 | 工作量 |
|----------|--------|
| 高德 → MapTiler | 0.5 天 |
| 高德 → 自绘插画 | 1-2 天 |
| MapTiler → 自绘插画 | 1-2 天 |

---

### Task 16: 核心页面开发

#### Task 16.1: 首页地图
- [ ] 全屏沉浸式地图
- [ ] 浮动控件组
- [ ] 城市 Marker 显示

#### Task 16.2: 城市面板
- [ ] Bottom Sheet 组件
- [ ] 城市信息展示
- [ ] 文化之旅列表

#### Task 16.3: 文化之旅详情
- [ ] 详情页布局
- [ ] 探索点列表
- [ ] 开始文化之旅

#### Task 16.4: 导航页面
- [ ] 导航中页面
- [ ] 到达提示弹窗

---

### Task 17: AR 任务页面

- [ ] AR 相机集成
- [ ] 手势识别任务
- [ ] 拍照任务
- [ ] 滤镜功能
- [ ] 任务完成页

---

### Task 18: 印记系统页面

- [ ] 印记集页面
- [ ] 印记详情页
- [ ] 区块链存证展示
- [ ] 文化之旅完成页

---

### Task 19: 其他页面

- [ ] 相册页面
- [ ] 个人中心页面
- [ ] 设置页面

---

### Task 20: 音频系统

- [ ] 背景音乐播放
- [ ] 上下文切换
- [ ] 淡入淡出效果

---

### Task 21: 离线支持

- [ ] 本地数据缓存
- [ ] 离线任务队列
- [ ] 网络恢复同步

---

### Task 22: 测试与优化

- [ ] Widget 测试
- [ ] 集成测试
- [ ] 性能优化
- [ ] 内存优化

---

## 任务优先级总结

| 优先级 | 任务范围 | 预计时间 |
|--------|----------|----------|
| P0 | Task 1-6 (数据模型 + 核心 API) | 2 周 |
| P1 | Task 7-10 (扩展 API) | 1 周 |
| P2 | Task 11-13 (管理后台 + 文档) | 1 周 |
| P3 | Task 14-22 (Flutter App) | 4-6 周 |

**开发建议：**

1. **Week 1-4**：完成后端 API（P0-P2），不受地图方案影响
2. **Week 5**：Flutter 项目搭建 + 高德地图 MVP
3. **Week 5 同时**：设计师尝试 MapTiler 样式 / 绘制插画底图
4. **Week 6**：根据设计效果决定是否切换地图方案（0.5-2 天）
5. **Week 6+**：继续完成其他页面开发

**地图方案决策点：**
- 如果高德简约配色 + 插画 Marker 效果可接受 → 继续用高德
- 如果需要更好的底图样式 → 切换到 MapTiler（0.5 天）
- 如果需要完全匹配 UI 风格 → 首页用自绘插画（1-2 天）
