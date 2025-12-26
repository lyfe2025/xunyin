# Requirements Document

## Introduction

寻印是一款基于地图SDK和AR技术的文化旅游探索应用，用户可以在不同地区的旅游景点完成各种任务来收集文化印记。与传统的步数导向应用不同，本应用以任务完成和印记收集为核心玩法，结合当地文化主题，提供沉浸式的旅游体验。收集的印记可上链存证，获得公信力认证。

## Project Structure

本项目采用 monorepo 结构，Flutter App 位于 `app/` 目录下：

```
├── web/                    # Vue 管理后台
├── server-nestjs/          # NestJS 后端
├── app/                    # Flutter APP (本需求)
```

Flutter App 将与现有的 NestJS 后端进行 API 交互。

## Glossary

- **Cultural_Journey（文化之旅）**: 一条包含多个探索点的旅游路线，具有特定的文化主题
- **Chapter（篇章/文化之书）**: 一个城市或景区的文化主题集合，包含多条相关文化之旅
- **Exploration_Point（探索点）**: 文化之旅中的单个任务点，通过地图位置+AR锚定
- **Task（任务）**: 在探索点需要完成的具体活动，如AR手势、拍照等
- **Seal（印记）**: 完成文化之旅或达成条件后收集的文化证明，分为路线印记、城市印记、特殊印记
- **Seal_Collection（印记集）**: 用户收集和展示所有印记的页面
- **AR_Anchor（AR锚点）**: 通过地图位置和AR技术定位的虚拟标记点
- **BGM（背景音乐）**: 根据场景自动切换的沉浸式背景音乐，增强文化氛围
- **Map_Module**: 地图模块，负责地图显示、导航和位置服务
- **Journey_Module**: 文化之旅模块，负责路线和探索点管理
- **AR_Module**: AR模块，负责AR相机和任务交互
- **Validation_Module**: 验证模块，负责任务完成验证
- **Seal_Module**: 印记模块，负责印记授予和管理
- **Blockchain_Module**: 区块链模块，负责印记上链存证
- **User_Module**: 用户模块，负责账户和数据管理
- **Content_Module**: 内容模块，负责文化内容展示
- **Album_Module**: 相册模块，负责照片管理
- **Audio_Module**: 音频模块，负责背景音乐播放

## Requirements

### Requirement 1: 全国地图浏览与城市篇章

**User Story:** As a 用户, I want 在全屏地图上浏览各地的旅游点并通过底部面板发现城市篇章, so that 我可以沉浸式地发现全国各地的文化之旅。

#### Acceptance Criteria

1. WHEN 用户打开应用 THEN THE Map_Module SHALL 基于高德SDK显示全屏插画风格地图视图，标注各城市旅游点
2. WHEN 用户在全国地图上点击某个城市图标 THEN THE Map_Module SHALL 从底部弹出城市面板（Bottom Sheet），展示城市文化介绍和文化之旅列表
3. WHEN 城市面板弹出 THEN THE Map_Module SHALL 将地图聚焦到该城市位置
4. WHEN 用户上滑城市面板 THEN THE Map_Module SHALL 展开面板显示更多文化之旅详情
5. WHEN 用户下滑城市面板或点击地图空白处 THEN THE Map_Module SHALL 收起底部面板
6. WHEN 用户在城市面板内点击搜索图标 THEN THE Map_Module SHALL 提供景点搜索功能
7. WHEN 用户放大地图到城市级别 THEN THE Map_Module SHALL 显示该城市内的各条文化之旅位置
8. WHEN 用户继续放大到文化之旅级别 THEN THE Map_Module SHALL 显示文化之旅内的各个探索点位置
9. WHEN 用户点击地图上的文化之旅标记 THEN THE Map_Module SHALL 展示文化之旅详情，包括主题介绍、探索点数量和预计时长
10. THE Map_Module SHALL 支持定位用户当前位置并显示附近的旅游点
11. WHEN 用户点击探索点的导航按钮 THEN THE Map_Module SHALL 基于高德SDK提供App内步行导航功能
12. WHILE 用户正在导航 THEN THE Map_Module SHALL 实时显示距离、预计到达时间和路线指引
13. WHEN 用户进入探索点有效范围（50米内） THEN THE Map_Module SHALL 自动提示用户可以开始任务

### Requirement 2: 文化之旅与探索点管理

**User Story:** As a 用户, I want 发现文化之旅中的所有探索点和任务详情, so that 我可以规划我的旅游行程。

#### Acceptance Criteria

1. WHEN 用户选择一条文化之旅 THEN THE Journey_Module SHALL 显示该文化之旅的所有探索点列表和地图路径
2. WHEN 用户查看探索点详情 THEN THE Journey_Module SHALL 展示该点的任务类型、任务描述和文化背景介绍
3. WHEN 用户开始一条文化之旅 THEN THE Journey_Module SHALL 记录开始时间并追踪完成进度
4. WHILE 用户正在进行文化之旅 THEN THE Journey_Module SHALL 实时显示已完成和未完成的探索点状态
5. WHEN 用户暂停或退出文化之旅 THEN THE Journey_Module SHALL 保存当前进度以便后续继续
6. WHEN 用户查看文化之旅详情 THEN THE Journey_Module SHALL 显示预计时长、总距离和已完成人数
7. THE Journey_Module SHALL 支持文化之旅解锁机制，部分文化之旅需完成前置条件才能开启
8. WHEN 用户查看城市面板 THEN THE Journey_Module SHALL 显示该城市的文化之旅解锁进度
9. WHEN 用户查看城市面板 THEN THE Journey_Module SHALL 显示该城市的总探索人数
10. WHEN 用户查看城市面板展开状态 THEN THE Journey_Module SHALL 显示城市封面插画和文化介绍
11. WHEN 用户查看文化之旅卡片 THEN THE Journey_Module SHALL 显示星级评分、探索点数量和距离
12. WHEN 用户查看探索点列表 THEN THE Journey_Module SHALL 显示每个探索点的任务类型和距离

### Requirement 3: AR任务系统

**User Story:** As a 用户, I want 通过AR方式完成各种有趣的任务, so that 我可以收获沉浸式的文化体验。

#### Acceptance Criteria

1. WHEN 用户到达探索点有效范围内 THEN THE AR_Module SHALL 激活AR相机并显示虚拟锚点
2. WHEN 任务类型为手势识别 THEN THE AR_Module SHALL 检测用户的手势并与目标手势进行匹配
3. WHEN 任务类型为拍照探索 THEN THE AR_Module SHALL 提供AR滤镜或虚拟元素叠加功能
4. WHEN 用户完成AR任务 THEN THE AR_Module SHALL 保存任务完成记录和相关照片
5. IF AR识别失败或环境不适合 THEN THE AR_Module SHALL 提供备选的任务完成方式
6. WHEN AR相机启动 THEN THE AR_Module SHALL 请求并验证相机权限
7. WHEN 手势识别进行中 THEN THE AR_Module SHALL 实时显示识别进度百分比
8. THE AR_Module SHALL 支持多种AR滤镜选择（如古风、水墨、原图）
9. WHEN 任务类型为AR寻宝 THEN THE AR_Module SHALL 在场景中显示隐藏的虚拟物品供用户寻找
10. WHEN AR任务页面显示 THEN THE AR_Module SHALL 显示当前探索点进度（如 2/10）

### Requirement 4: 任务验证与完成

**User Story:** As a 用户, I want 系统能准确验证我的任务完成情况, so that 我的印记是真实有效的。

#### Acceptance Criteria

1. WHEN 用户提交任务完成请求 THEN THE Validation_Module SHALL 验证用户地理位置是否在探索点有效范围内
2. WHEN 手势任务提交 THEN THE Validation_Module SHALL 通过AI识别验证手势正确性
3. WHEN 拍照任务提交 THEN THE Validation_Module SHALL 验证照片元数据和位置信息
4. WHEN 任务验证通过 THEN THE Validation_Module SHALL 更新用户的探索进度并发放即时奖励
5. IF 任务验证失败 THEN THE Validation_Module SHALL 提示失败原因并允许用户重新尝试
6. THE Validation_Module SHALL 在离线状态下缓存验证请求，待网络恢复后同步
7. WHEN 任务完成 THEN THE Validation_Module SHALL 显示任务完成页面，包含拍摄照片和积分奖励
8. WHEN 任务完成 THEN THE Validation_Module SHALL 解锁并展示文化小知识内容
9. WHEN 任务完成 THEN THE Validation_Module SHALL 提供分享到社交平台和继续下一个探索点的选项
10. WHEN 到达探索点提示显示 THEN THE Validation_Module SHALL 提供「开始任务」和「稍后再来」两个选项

### Requirement 5: 印记系统

**User Story:** As a 用户, I want 完成文化之旅后收集文化印记, so that 我可以收集和展示我的旅游足迹。

#### Acceptance Criteria

1. WHEN 用户完成文化之旅中的所有探索点 THEN THE Seal_Module SHALL 授予该文化之旅的路线印记
2. WHEN 用户完成某城市的所有文化之旅 THEN THE Seal_Module SHALL 授予该城市的城市印记
3. WHEN 用户达成特定条件 THEN THE Seal_Module SHALL 授予特殊印记（如首次完成、节日限定、速通等）
4. WHEN 印记授予成功 THEN THE Seal_Module SHALL 在用户的印记集中显示该印记
5. WHEN 用户查看印记集 THEN THE Seal_Module SHALL 展示所有已收集的印记、完成时间和文化之旅信息
6. THE Seal_Module SHALL 支持印记分享到社交平台
7. WHEN 印记授予 THEN THE Seal_Module SHALL 播放获得印记的动画效果
8. WHEN 用户查看印记集 THEN THE Seal_Module SHALL 分类展示路线印记、城市印记、特殊印记
9. WHEN 用户查看印记集 THEN THE Seal_Module SHALL 显示各类印记的收集进度条
10. THE Seal_Module SHALL 显示未解锁印记为锁定状态并提示解锁条件
11. WHEN 用户查看印记集 THEN THE Seal_Module SHALL 显示进行中的文化之旅及其进度
12. WHEN 用户查看印记详情 THEN THE Seal_Module SHALL 显示该印记关联的探索照片
13. WHEN 用户完成文化之旅 THEN THE Seal_Module SHALL 解锁相应的称号徽章（如「西湖文化达人」）
14. WHEN 文化之旅完成页显示 THEN THE Seal_Module SHALL 显示完成时间、用时和积分奖励
15. WHEN 文化之旅完成页显示 THEN THE Seal_Module SHALL 提供「分享印记」和「返回首页」按钮
16. THE Seal_Module SHALL 提供筛选功能入口

### Requirement 6: 区块链存证

**User Story:** As a 用户, I want 我的印记能够上链存证, so that 我的旅游印记具有公信力和不可篡改性。

#### Acceptance Criteria

1. WHEN 用户收集印记 THEN THE Blockchain_Module SHALL 生成印记的唯一哈希值
2. WHEN 用户选择上链存证 THEN THE Blockchain_Module SHALL 将印记信息写入区块链
3. WHEN 存证完成 THEN THE Blockchain_Module SHALL 返回链上交易凭证和查询地址
4. WHEN 用户或第三方查询印记 THEN THE Blockchain_Module SHALL 提供链上验证接口
5. THE Blockchain_Module SHALL 确保存证数据包含用户ID、文化之旅ID、完成时间和任务完成证明
6. IF 上链失败 THEN THE Blockchain_Module SHALL 提示错误原因并支持重试
7. WHEN 用户查看印记详情 THEN THE Blockchain_Module SHALL 显示链名称、交易哈希、区块高度和时间戳
8. THE Blockchain_Module SHALL 支持复制交易哈希和跳转链上查看
9. THE Blockchain_Module SHALL 在印记卡片上显示已上链标识（🔗）
10. WHEN 文化之旅完成页显示 THEN THE Blockchain_Module SHALL 提供「立即上链」入口

### Requirement 7: 用户账户与数据

**User Story:** As a 用户, I want 管理我的账户和查看我的旅游数据, so that 我可以追踪我的整体旅游进度。

#### Acceptance Criteria

1. WHEN 用户首次使用应用 THEN THE User_Module SHALL 提供注册或第三方登录选项
2. WHEN 用户登录成功 THEN THE User_Module SHALL 同步用户的所有进度和印记数据
3. WHEN 用户查看个人主页 THEN THE User_Module SHALL 展示统计数据，包括完成文化之旅数、总探索点数、收集印记数
4. THE User_Module SHALL 支持用户数据的云端备份和恢复
5. IF 用户更换设备 THEN THE User_Module SHALL 支持数据迁移和账户恢复
6. WHEN 用户退出登录 THEN THE User_Module SHALL 清除本地敏感数据但保留缓存
7. THE User_Module SHALL 支持用户修改个人资料和头像
8. WHEN 用户查看个人主页 THEN THE User_Module SHALL 显示城市解锁进度、印记收集进度和已上链数量
9. WHEN 用户查看个人主页 THEN THE User_Module SHALL 显示用户称号徽章
10. WHEN 用户查看个人主页 THEN THE User_Module SHALL 显示最近动态列表
11. THE User_Module SHALL 提供区块链钱包入口
12. THE User_Module SHALL 提供旅行统计详情入口
13. THE User_Module SHALL 提供积分商城入口
14. THE User_Module SHALL 提供设置入口

### Requirement 8: 文化内容展示

**User Story:** As a 用户, I want 在探索过程中了解当地的文化和传统, so that 我的旅游体验更有深度和意义。

#### Acceptance Criteria

1. WHEN 用户进入文化之旅 THEN THE Content_Module SHALL 展示该地区的文化主题介绍
2. WHEN 用户到达探索点 THEN THE Content_Module SHALL 提供该地点的历史故事和文化背景
3. WHEN 用户完成任务 THEN THE Content_Module SHALL 解锁相关的深度文化内容
4. THE Content_Module SHALL 支持多媒体内容展示，包括文字、图片、音频和视频
5. WHERE 用户选择语音导览 THEN THE Content_Module SHALL 提供语音讲解功能
6. THE Content_Module SHALL 支持内容离线缓存以便无网络时查看
7. WHEN 任务完成页显示文化小知识 THEN THE Content_Module SHALL 提供「查看更多」入口跳转深度内容

### Requirement 9: 相册管理

**User Story:** As a 用户, I want 从地图浮动控件快速进入相册查看和管理我的探索照片, so that 我可以回顾和分享我的旅行记忆。

#### Acceptance Criteria

1. WHEN 用户点击地图右侧浮动相册图标 THEN THE Album_Module SHALL 打开相册页面展示所有探索照片
2. WHEN 用户进入相册页面 THEN THE Album_Module SHALL 展示所有探索照片的统计信息（总照片数、文化之旅数）
3. WHEN 用户按文化之旅筛选 THEN THE Album_Module SHALL 按文化之旅分类展示照片
4. WHEN 用户按时间筛选 THEN THE Album_Module SHALL 按时间线展示照片
5. WHEN 用户点击照片 THEN THE Album_Module SHALL 显示照片详情，包括拍摄地点和时间
6. THE Album_Module SHALL 支持照片分享到社交平台
7. THE Album_Module SHALL 支持删除不需要的照片
8. WHEN 用户查看文化之旅分类 THEN THE Album_Module SHALL 显示每条文化之旅的照片数量
9. THE Album_Module SHALL 提供筛选功能入口

### Requirement 10: 背景音乐系统

**User Story:** As a 用户, I want 在探索过程中有沉浸式的背景音乐, so that 我可以获得更有氛围感的文化体验。

#### Acceptance Criteria

1. WHEN 用户打开应用 THEN THE Audio_Module SHALL 默认播放轻柔古风背景音乐
2. WHEN 用户进入城市篇章 THEN THE Audio_Module SHALL 切换为该城市特色音乐（如杭州播江南丝竹、西安播秦腔元素）
3. WHEN 用户开始文化之旅 THEN THE Audio_Module SHALL 播放与文化之旅主题匹配的背景音乐
4. WHEN 用户点击地图右侧浮动音乐图标 THEN THE Audio_Module SHALL 切换音乐播放/暂停状态
5. THE Audio_Module SHALL 记住用户的音乐偏好设置
6. WHEN 用户进入AR任务页面 THEN THE Audio_Module SHALL 自动暂停背景音乐避免干扰
7. THE Audio_Module SHALL 支持音乐淡入淡出过渡效果
8. WHEN 音乐播放状态变化 THEN THE Audio_Module SHALL 更新浮动控件图标状态

### Requirement 11: 全屏沉浸式导航

**User Story:** As a 用户, I want 在全屏地图上通过浮动控件访问所有功能, so that 我可以获得沉浸式的探索体验。

#### Acceptance Criteria

1. THE App SHALL 采用无底部导航栏、无顶部搜索栏的全屏沉浸式设计
2. THE App SHALL 在地图右侧提供竖排浮动控件，包含：我的(👤)、印记(🏆)、相册(📷)、音乐(🎵)、定位(📍)
3. WHEN 用户点击我的图标 THEN THE App SHALL 打开个人中心页面
4. WHEN 用户点击印记图标 THEN THE App SHALL 打开印记集页面
5. WHEN 用户点击定位图标 THEN THE Map_Module SHALL 将地图中心移动到用户当前位置
6. THE 浮动控件 SHALL 不遮挡地图主要内容，保持视觉简洁
7. WHEN 用户点击城市图标 THEN THE App SHALL 从底部弹出城市面板而非跳转页面
8. THE 底部面板 SHALL 支持上滑展开、下滑收起的手势交互
9. THE 底部面板 SHALL 包含省份标签横向滚动，支持快速切换区域
10. THE 底部面板 SHALL 包含拖动条指示可拖动状态

### Requirement 12: 离线支持与网络处理

**User Story:** As a 用户, I want 在网络不稳定的景区也能使用基本功能, so that 我的探索体验不会因网络问题中断。

#### Acceptance Criteria

1. THE App SHALL 支持地图数据离线缓存
2. WHEN 网络不可用 THEN THE App SHALL 显示已缓存的文化之旅和探索点信息
3. WHEN 网络恢复 THEN THE App SHALL 自动同步离线期间的任务完成数据
4. IF 关键操作需要网络 THEN THE App SHALL 提示用户当前处于离线状态
5. THE App SHALL 在启动时预加载用户附近区域的内容数据

### Requirement 13: 权限管理

**User Story:** As a 用户, I want 应用合理请求必要权限, so that 我的隐私得到保护同时功能正常使用。

#### Acceptance Criteria

1. WHEN 应用需要位置权限 THEN THE App SHALL 说明权限用途并请求授权
2. WHEN 应用需要相机权限 THEN THE App SHALL 在AR功能使用前请求授权
3. WHEN 应用需要存储权限 THEN THE App SHALL 在保存照片前请求授权
4. IF 用户拒绝必要权限 THEN THE App SHALL 提示功能受限并引导用户开启
5. THE App SHALL 遵循最小权限原则，仅请求功能必需的权限


### Requirement 14: 页面导航与返回

**User Story:** As a 用户, I want 在各个页面之间流畅导航, so that 我可以方便地浏览和返回。

#### Acceptance Criteria

1. THE App SHALL 在所有二级页面提供返回按钮（←）
2. WHEN 用户点击返回按钮 THEN THE App SHALL 返回上一级页面
3. THE App SHALL 在全屏任务页面提供关闭按钮（×）
4. WHEN 用户点击关闭按钮 THEN THE App SHALL 关闭当前页面并返回主流程
5. WHEN 用户在导航中点击关闭 THEN THE App SHALL 结束导航并返回文化之旅进行中页面
6. WHEN 用户在AR任务中点击关闭 THEN THE App SHALL 提示是否放弃当前任务
