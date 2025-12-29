---
inclusion: fileMatch
fileMatchPattern: "server-nestjs/**/*.ts"
---

# NestJS 后端开发规范

## 目录结构

```
server-nestjs/src/
├── modules/           # 业务模块
│   ├── city/         # 城市模块
│   │   ├── city.module.ts
│   │   ├── city.controller.ts
│   │   ├── city.service.ts
│   │   └── dto/
│   │       ├── create-city.dto.ts
│   │       └── update-city.dto.ts
├── common/           # 公共模块
│   ├── decorators/   # 自定义装饰器
│   ├── filters/      # 异常过滤器
│   ├── guards/       # 守卫
│   ├── interceptors/ # 拦截器
│   └── pipes/        # 管道
└── prisma/           # Prisma 服务
```

## 模块规范

### Controller
- 使用 `@Controller('api/app/xxx')` 定义 App 端路由
- 使用 `@Controller('api/admin/xxx')` 定义管理端路由
- 使用 Swagger 装饰器文档化 API

```typescript
@ApiTags('城市管理')
@Controller('api/app/cities')
export class CityController {
  @Get()
  @ApiOperation({ summary: '获取城市列表' })
  async findAll(@Query() query: QueryCityDto) {}
}
```

### Service
- 注入 PrismaService 进行数据库操作
- 业务逻辑封装在 Service 层
- 使用事务处理复杂操作

```typescript
@Injectable()
export class CityService {
  constructor(private prisma: PrismaService) {}
  
  async findAll(query: QueryCityDto) {
    return this.prisma.city.findMany({
      where: { status: '0' },
      orderBy: { orderNum: 'asc' },
    });
  }
}
```

### DTO
- 使用 class-validator 进行参数校验
- 使用 class-transformer 进行数据转换
- 分离 Create/Update/Query DTO

```typescript
export class CreateCityDto {
  @ApiProperty({ description: '城市名称' })
  @IsString()
  @MaxLength(50)
  name: string;

  @ApiProperty({ description: '省份' })
  @IsString()
  province: string;
}
```

## API 响应格式

### 统一响应结构
```typescript
{
  code: 200,        // 状态码
  msg: 'success',   // 消息
  data: {}          // 数据
}
```

### 分页响应
```typescript
{
  code: 200,
  msg: 'success',
  data: {
    list: [],       // 数据列表
    total: 100,     // 总数
    pageNum: 1,     // 当前页
    pageSize: 10    // 每页数量
  }
}
```

## 错误处理

### 业务异常
```typescript
throw new BadRequestException('城市名称已存在');
throw new NotFoundException('城市不存在');
throw new ForbiddenException('无权限操作');
```

### 自定义业务码
```typescript
throw new HttpException({
  code: 40001,
  msg: '验证码已过期'
}, HttpStatus.BAD_REQUEST);
```

## 认证与授权

### App 端认证
- 使用 `@UseGuards(AppAuthGuard)` 保护接口
- 使用 `@CurrentUser()` 获取当前用户

```typescript
@Get('profile')
@UseGuards(AppAuthGuard)
async getProfile(@CurrentUser() user: AppUser) {
  return user;
}
```

### 管理端认证
- 使用 `@UseGuards(JwtAuthGuard)` 保护接口
- 使用 `@RequirePermissions('system:user:list')` 权限控制

## 日志规范

```typescript
import { Logger } from '@nestjs/common';

@Injectable()
export class CityService {
  private readonly logger = new Logger(CityService.name);
  
  async create(dto: CreateCityDto) {
    this.logger.log(`Creating city: ${dto.name}`);
  }
}
```
