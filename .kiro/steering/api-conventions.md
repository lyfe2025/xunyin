---
inclusion: always
---

# API 设计规范

## 全局路由前缀

项目在 `main.ts` 中配置了全局前缀 `api`：
```typescript
app.setGlobalPrefix('api')
```

**重要**：Controller 中的路由路径**不要**包含 `api` 前缀，NestJS 会自动添加。

## 路由命名

### App 端 API（移动端）
- 最终 URL 前缀：`/api/app/`
- Controller 路径：`app/xxx`（不含 `api`）
- 示例：
  - `GET /api/app/cities` - 获取城市列表
  - `GET /api/app/cities/:id` - 获取城市详情
  - `POST /api/app/journeys/:id/start` - 开始文化之旅

### Admin 端 API（管理后台）
- 最终 URL 前缀：`/api/admin/`
- Controller 路径：`admin/xxx`（不含 `api`）
- 示例：
  - `GET /api/admin/cities` - 城市列表（分页）
  - `POST /api/admin/cities` - 创建城市
  - `PUT /api/admin/cities/:id` - 更新城市
  - `DELETE /api/admin/cities/:id` - 删除城市

### 系统管理 API
- 最终 URL 前缀：`/api/system/`
- Controller 路径：`system/xxx`（不含 `api`）

### 监控 API
- 最终 URL 前缀：`/api/monitor/`
- Controller 路径：`monitor/xxx`（不含 `api`）

## Controller 路由示例

```typescript
// ✅ 正确：不包含 api 前缀
@Controller('app/cities')
export class CityController {}

// ❌ 错误：包含 api 前缀会导致路由变成 /api/api/app/cities
@Controller('api/app/cities')
export class CityController {}
```

## RESTful 规范

### HTTP 方法
- `GET` - 查询资源
- `POST` - 创建资源 / 执行操作
- `PUT` - 更新资源（全量）
- `PATCH` - 更新资源（部分）
- `DELETE` - 删除资源

### URL 设计
- 使用名词复数：`/cities`, `/journeys`, `/seals`
- 嵌套资源：`/cities/:cityId/journeys`
- 操作动词：`/journeys/:id/start`, `/seals/:id/chain`

## 查询参数

### 分页
```
GET /api/admin/cities?pageNum=1&pageSize=10
```

### 筛选
```
GET /api/app/cities?province=浙江省
GET /api/app/seals?type=route
```

### 排序
```
GET /api/app/journeys?orderBy=createTime&order=desc
```

## 响应状态码

| 状态码 | 含义 | 使用场景 |
|--------|------|----------|
| 200 | 成功 | GET/PUT/PATCH/DELETE 成功 |
| 201 | 已创建 | POST 创建成功 |
| 400 | 请求错误 | 参数校验失败 |
| 401 | 未认证 | Token 无效或过期 |
| 403 | 无权限 | 权限不足 |
| 404 | 未找到 | 资源不存在 |
| 500 | 服务器错误 | 内部异常 |

## 业务状态码

| 状态码 | 含义 |
|--------|------|
| 200 | 操作成功 |
| 40001 | 验证码错误 |
| 40002 | 验证码已过期 |
| 40003 | 用户不存在 |
| 40004 | 密码错误 |
| 40005 | 账号已禁用 |
| 40101 | Token 无效 |
| 40102 | Token 已过期 |
| 40301 | 无权限访问 |

## 数据格式

### 时间格式
- 返回 ISO 8601 格式：`2025-01-15T10:30:00.000Z`
- 前端显示时转换为本地时间

### 金额/距离
- 使用字符串避免精度问题：`"distance": "1234.56"`
- 或使用整数（最小单位）：`"distanceMeters": 123456`

### 经纬度
```json
{
  "latitude": 30.2741234,
  "longitude": 120.1551234
}
```

## Swagger 文档

### 必须添加的装饰器
- `@ApiTags()` - 接口分组
- `@ApiOperation()` - 接口描述
- `@ApiProperty()` - DTO 字段描述
- `@ApiResponse()` - 响应描述

### 示例
```typescript
@ApiTags('城市管理')
@Controller('app/cities')  // 注意：不含 api 前缀
export class CityController {
  @Get()
  @ApiOperation({ summary: '获取城市列表', description: '支持按省份筛选' })
  @ApiQuery({ name: 'province', required: false, description: '省份名称' })
  @ApiResponse({ status: 200, description: '成功', type: CityListVo })
  async findAll(@Query() query: QueryCityDto) {}
}
```
