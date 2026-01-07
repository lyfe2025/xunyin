# 寻印 App (Flutter)

文化之旅探索 App，探索城市文化，收集专属印记。

## 技术栈

- Flutter 3.32+
- Riverpod (状态管理)
- Go Router (路由)
- Dio (网络请求)

## 项目结构

```
lib/
├── core/                 # 核心模块
│   ├── api/             # API 客户端
│   ├── config/          # 配置
│   ├── router/          # 路由
│   ├── storage/         # 本地存储
│   ├── theme/           # 主题配色
│   └── utils/           # 工具类
├── features/            # 功能模块
│   ├── auth/            # 认证
│   ├── city/            # 城市
│   ├── home/            # 首页
│   ├── journey/         # 文化之旅
│   ├── profile/         # 个人中心
│   └── seal/            # 印记
├── models/              # 数据模型
├── providers/           # Riverpod Providers
├── services/            # 业务服务
└── shared/              # 共享组件
    └── widgets/
```

## 开发

```bash
# 安装依赖
flutter pub get

# 运行
flutter run

# 构建
flutter build apk
flutter build ios
```

## 配色方案

采用中国传统色系：
- 主色：黛青 (#425066)
- 强调色：朱砂 (#CF4526)
- 背景：米白/宣纸色 (#F8F5F0)
- 印记金：#D4AF37

## API 对接

后端 API 前缀：`/api/app/`

主要接口：
- `/auth` - 认证
- `/cities` - 城市
- `/journeys` - 文化之旅
- `/points` - 探索点
- `/seals` - 印记
- `/photos` - 相册
- `/stats` - 统计
