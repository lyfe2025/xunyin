# Design Document

## Overview

本设计文档描述寻印 Flutter App 的技术架构和实现方案。App 采用 Flutter 3.x 开发，集成高德地图 SDK 和 AR 功能，与现有 NestJS 后端进行 API 交互。

## Architecture

### 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐│
│  │   Screens   │ │   Widgets   │ │   State Management      ││
│  │  (Pages)    │ │ (Components)│ │   (Riverpod)            ││
│  └─────────────┘ └─────────────┘ └─────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│                      Domain Layer                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐│
│  │   Entities  │ │  Use Cases  │ │   Repository Interfaces ││
│  └─────────────┘ └─────────────┘ └─────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐│
│  │ Repositories│ │ Data Sources│ │   Models (DTOs)         ││
│  │ (Impl)      │ │ (API/Local) │ │                         ││
│  └─────────────┘ └─────────────┘ └─────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│                      Infrastructure                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐│
│  │ 高德地图SDK │ │   AR SDK    │ │   Native Plugins        ││
│  │ (AMap)      │ │ (ARCore/Kit)│ │   (Camera, Location)    ││
│  └─────────────┘ └─────────────┘ └─────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### 目录结构

```
app/
├── android/                    # Android 原生配置
├── ios/                        # iOS 原生配置
├── lib/
│   ├── main.dart              # 应用入口
│   ├── app.dart               # App 配置
│   │
│   ├── core/                  # 核心模块
│   │   ├── config/            # 配置（API、环境变量）
│   │   ├── constants/         # 常量定义
│   │   ├── errors/            # 错误处理
│   │   ├── network/           # 网络层（Dio 配置）
│   │   ├── storage/           # 本地存储
│   │   ├── theme/             # 主题配置
│   │   └── utils/             # 工具类
│   │
│   ├── features/              # 功能模块
│   │   ├── map/               # 地图模块
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── journey/           # 文化之旅模块
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── ar/                # AR 任务模块
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── seal/              # 印记模块
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── blockchain/        # 区块链模块
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── user/              # 用户模块
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── album/             # 相册模块
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── audio/             # 音频模块
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   ├── shared/                # 共享组件
│   │   ├── widgets/           # 通用 Widget
│   │   └── providers/         # 全局 Provider
│   │
│   └── routes/                # 路由配置
│       └── app_router.dart
│
├── assets/                    # 静态资源
│   ├── images/
│   ├── icons/
│   ├── audio/
│   └── fonts/
│
├── test/                      # 测试
├── pubspec.yaml
└── README.md
```

## State Management

采用 Riverpod 作为状态管理方案：

### Provider 结构

```dart
// 全局状态
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);
final audioStateProvider = StateNotifierProvider<AudioNotifier, AudioState>(...);
final locationProvider = StreamProvider<Position>(...);

// 功能模块状态
final mapStateProvider = StateNotifierProvider<MapNotifier, MapState>(...);
final journeyProvider = FutureProvider.family<Journey, String>(...);
final sealCollectionProvider = FutureProvider<List<Seal>>(...);
```

### 状态流转

```
用户操作 → Provider → Repository → API/Local → 更新状态 → UI 重建
```

## 高德地图 SDK 集成

### 依赖配置

```yaml
# pubspec.yaml
dependencies:
  amap_flutter_map: ^3.0.0      # 高德地图 Flutter 插件
  amap_flutter_location: ^3.0.0  # 高德定位
  amap_flutter_navi: ^1.0.0      # 高德导航（如有）
```

### 地图模块设计

```dart
// lib/features/map/domain/entities/city_marker.dart
class CityMarker {
  final String id;
  final String name;
  final LatLng position;
  final String iconAsset;      // 插画图标
  final int journeyCount;
  final int explorerCount;
}

// lib/features/map/presentation/widgets/immersive_map.dart
class ImmersiveMap extends ConsumerWidget {
  // 全屏沉浸式地图
  // 自定义插画风格 Marker
  // 支持缩放级别切换显示内容
}

// lib/features/map/presentation/widgets/floating_controls.dart
class FloatingControls extends StatelessWidget {
  // 右侧竖排浮动控件
  // 我的、印记、相册、音乐、定位
}

// lib/features/map/presentation/widgets/city_bottom_sheet.dart
class CityBottomSheet extends StatelessWidget {
  // 城市面板 Bottom Sheet
  // 支持拖拽展开/收起
  // 省份标签横向滚动
}
```

### 导航功能

```dart
// lib/features/map/domain/usecases/start_navigation.dart
class StartNavigation {
  // 调用高德 SDK 步行导航
  // 实时距离、时间更新
  // 到达探索点检测（50米范围）
}
```

## AR 模块技术选型

### 方案对比

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| ARCore/ARKit + ar_flutter_plugin | 原生性能好 | 需要分平台适配 | 复杂 AR 场景 |
| camera + ML Kit | 轻量、易集成 | AR 效果有限 | 手势识别、简单叠加 |
| Unity as Library | 功能强大 | 包体积大、集成复杂 | 游戏级 AR |

### 推荐方案

采用 **camera + ML Kit + 自定义 AR 叠加** 的轻量方案：

```yaml
dependencies:
  camera: ^0.10.0
  google_mlkit_pose_detection: ^0.5.0   # 手势/姿态识别
  google_mlkit_image_labeling: ^0.5.0   # 图像识别
```

### AR 模块设计

```dart
// lib/features/ar/domain/entities/ar_task.dart
enum ARTaskType {
  gesture,    // 手势识别
  photo,      // 拍照探索
  treasure,   // AR 寻宝
}

class ARTask {
  final String id;
  final ARTaskType type;
  final String targetGesture;     // 目标手势（手势任务）
  final String arAssetUrl;        // AR 素材 URL
  final List<String> filters;     // 可用滤镜
}

// lib/features/ar/presentation/screens/ar_camera_screen.dart
class ARCameraScreen extends ConsumerStatefulWidget {
  // AR 相机页面
  // 实时手势识别
  // AR 元素叠加
  // 滤镜切换
}

// lib/features/ar/domain/usecases/validate_gesture.dart
class ValidateGesture {
  // 手势匹配验证
  // 返回匹配度百分比
}
```

## NestJS 后端 API 交互

### API 客户端配置

```dart
// lib/core/network/api_client.dart
class ApiClient {
  final Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ));
    
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }
}
```

### API 端点设计

```
# 用户模块
POST   /api/auth/login              # 登录
POST   /api/auth/register           # 注册
GET    /api/users/me                # 获取当前用户
PUT    /api/users/me                # 更新用户信息

# 地图模块
GET    /api/cities                  # 获取城市列表
GET    /api/cities/:id              # 获取城市详情
GET    /api/cities/:id/journeys     # 获取城市文化之旅列表

# 文化之旅模块
GET    /api/journeys/:id            # 获取文化之旅详情
GET    /api/journeys/:id/points     # 获取探索点列表
POST   /api/journeys/:id/start      # 开始文化之旅
PUT    /api/journeys/:id/progress   # 更新进度

# 探索点模块
GET    /api/points/:id              # 获取探索点详情
POST   /api/points/:id/complete     # 完成探索点任务

# 印记模块
GET    /api/seals                   # 获取用户印记列表
GET    /api/seals/:id               # 获取印记详情
POST   /api/seals/:id/chain         # 上链存证

# 相册模块
GET    /api/photos                  # 获取照片列表
POST   /api/photos                  # 上传照片
DELETE /api/photos/:id              # 删除照片

# 音频模块
GET    /api/audio/city/:cityId      # 获取城市背景音乐
GET    /api/audio/journey/:journeyId # 获取文化之旅背景音乐
```

### Repository 实现

```dart
// lib/features/journey/data/repositories/journey_repository_impl.dart
class JourneyRepositoryImpl implements JourneyRepository {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;
  
  @override
  Future<Journey> getJourney(String id) async {
    try {
      final response = await _apiClient.get('/journeys/$id');
      return JourneyModel.fromJson(response.data);
    } catch (e) {
      // 离线时从本地缓存读取
      return _localStorage.getJourney(id);
    }
  }
}
```

## Data Models

### 核心实体

```dart
// 城市
class City {
  final String id;
  final String name;
  final String province;
  final LatLng position;
  final String iconAsset;
  final String coverImage;
  final String description;
  final int explorerCount;
  final List<Journey> journeys;
}

// 文化之旅
class Journey {
  final String id;
  final String cityId;
  final String name;
  final String theme;
  final String coverImage;
  final String description;
  final int rating;              // 星级 1-5
  final Duration estimatedTime;
  final double totalDistance;
  final int completedCount;
  final List<ExplorationPoint> points;
  final bool isLocked;
  final String? unlockCondition;
}

// 探索点
class ExplorationPoint {
  final String id;
  final String journeyId;
  final String name;
  final LatLng position;
  final ARTaskType taskType;
  final String taskDescription;
  final String culturalBackground;
  final double distanceFromPrevious;
  final int order;
}

// 印记
class Seal {
  final String id;
  final SealType type;           // route, city, special
  final String name;
  final String imageAsset;
  final DateTime? completedAt;
  final Duration? timeSpent;
  final int pointsEarned;
  final String? badgeTitle;      // 称号徽章
  final BlockchainRecord? chainRecord;
  final List<String> photoUrls;
  final bool isLocked;
  final String? unlockCondition;
}

enum SealType { route, city, special }

// 区块链记录
class BlockchainRecord {
  final String chainName;
  final String txHash;
  final int blockHeight;
  final DateTime timestamp;
}

// 用户
class User {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final String? badgeTitle;
  final UserStats stats;
}

class UserStats {
  final int completedJourneys;
  final int completedPoints;
  final int collectedSeals;
  final int chainedSeals;
  final int unlockedCities;
  final int totalCities;
}
```

## 离线支持设计

### 本地存储

```dart
// lib/core/storage/local_storage.dart
class LocalStorage {
  final Hive _hive;
  
  // 缓存城市和文化之旅数据
  Future<void> cacheCity(City city);
  Future<void> cacheJourney(Journey journey);
  
  // 离线任务队列
  Future<void> queueTaskCompletion(TaskCompletion task);
  Future<List<TaskCompletion>> getPendingTasks();
  
  // 同步状态
  Future<void> syncPendingTasks();
}
```

### 网络状态监听

```dart
// lib/core/network/connectivity_service.dart
class ConnectivityService {
  Stream<ConnectivityStatus> get statusStream;
  
  // 网络恢复时自动同步
  void onConnectivityRestored() {
    _localStorage.syncPendingTasks();
  }
}
```

## 音频模块设计

```dart
// lib/features/audio/domain/entities/audio_state.dart
class AudioState {
  final bool isPlaying;
  final String? currentTrackId;
  final AudioContext context;    // home, city, journey, ar
}

enum AudioContext { home, city, journey, ar }

// lib/features/audio/presentation/providers/audio_provider.dart
class AudioNotifier extends StateNotifier<AudioState> {
  final AudioPlayer _player;
  
  // 根据上下文自动切换音乐
  Future<void> switchContext(AudioContext context, {String? contextId});
  
  // 淡入淡出过渡
  Future<void> fadeToTrack(String trackUrl);
  
  // AR 页面自动暂停
  void pauseForAR();
  void resumeFromAR();
}
```

## 路由设计

```dart
// lib/routes/app_router.dart
@MaterialAutoRouter(
  routes: [
    AutoRoute(page: MapScreen, initial: true),
    AutoRoute(page: JourneyDetailScreen),
    AutoRoute(page: JourneyProgressScreen),
    AutoRoute(page: NavigationScreen),
    AutoRoute(page: ARCameraScreen),
    AutoRoute(page: TaskCompleteScreen),
    AutoRoute(page: JourneyCompleteScreen),
    AutoRoute(page: SealCollectionScreen),
    AutoRoute(page: SealDetailScreen),
    AutoRoute(page: AlbumScreen),
    AutoRoute(page: PhotoDetailScreen),
    AutoRoute(page: ProfileScreen),
    AutoRoute(page: SettingsScreen),
  ],
)
class AppRouter extends _$AppRouter {}
```

## 权限管理

```dart
// lib/core/permissions/permission_service.dart
class PermissionService {
  // 位置权限（地图、导航）
  Future<bool> requestLocationPermission();
  
  // 相机权限（AR 任务）
  Future<bool> requestCameraPermission();
  
  // 存储权限（保存照片）
  Future<bool> requestStoragePermission();
  
  // 权限被拒绝时的引导
  Future<void> showPermissionDeniedDialog(PermissionType type);
}
```

## Correctness Properties

### 功能正确性

1. **地图显示**：城市标记位置与实际经纬度一致
2. **导航精度**：到达探索点检测范围为 50 米
3. **任务验证**：手势识别准确率 > 85%
4. **印记授予**：完成所有探索点后正确授予路线印记
5. **区块链存证**：交易哈希可在链上验证

### 状态一致性

1. **进度同步**：本地进度与服务器保持一致
2. **离线队列**：离线完成的任务在网络恢复后正确同步
3. **音频状态**：音乐播放状态与 UI 图标一致

### 性能指标

1. **地图加载**：首屏加载 < 2s
2. **AR 帧率**：相机预览 > 30fps
3. **内存占用**：< 200MB（正常使用）
4. **离线缓存**：支持缓存 10 条文化之旅数据

## 依赖清单

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  flutter_riverpod: ^2.4.0
  
  # 网络
  dio: ^5.3.0
  connectivity_plus: ^5.0.0
  
  # 本地存储
  hive: ^2.2.0
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.0
  
  # 高德地图
  amap_flutter_map: ^3.0.0
  amap_flutter_location: ^3.0.0
  
  # 相机与 AR
  camera: ^0.10.0
  google_mlkit_pose_detection: ^0.5.0
  
  # 音频
  just_audio: ^0.9.0
  audio_session: ^0.1.0
  
  # 路由
  auto_route: ^7.8.0
  
  # UI
  flutter_animate: ^4.2.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  
  # 工具
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  permission_handler: ^11.0.0
  image_picker: ^1.0.0
  share_plus: ^7.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  auto_route_generator: ^7.3.0
  mockito: ^5.4.0
