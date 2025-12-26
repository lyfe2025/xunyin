# Swagger API 文档完整指南

## 📖 目录

1. [快速开始](#快速开始)
2. [自动生成配置](#自动生成配置)
3. [装饰器使用指南](#装饰器使用指南)
4. [最佳实践](#最佳实践)
5. [常见问题](#常见问题)
6. [示例代码](#示例代码)

---

## 快速开始

### 🎯 访问 API 文档

启动项目后,访问:
```
http://localhost:3000/api-docs
```

### ✅ 已完成配置

本项目已完整配置 Swagger,包括:
- ✅ Swagger UI 集成
- ✅ JWT Bearer 认证支持
- ✅ API 标签分类
- ✅ 自动生成装饰器(CLI 插件)
- ✅ JSDoc 注释支持

### 📦 依赖包

```json
{
  "@nestjs/swagger": "^7.x",
  "swagger-ui-express": "^5.x"
}
```

---

## 自动生成配置

### 🎯 CLI 插件功能

NestJS Swagger CLI 插件会自动为你生成装饰器,大大减少手动编写的工作量。

### 配置文件

**`nest-cli.json`:**
```json
{
  "compilerOptions": {
    "plugins": [
      {
        "name": "@nestjs/swagger",
        "options": {
          "classValidatorShim": true,
          "introspectComments": true,
          "dtoFileNameSuffix": [".dto.ts", ".entity.ts"],
          "controllerFileNameSuffix": ".controller.ts"
        }
      }
    ]
  }
}
```

### 插件选项说明

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `classValidatorShim` | 从 `class-validator` 装饰器推断类型 | `true` |
| `introspectComments` | 从 JSDoc 注释生成描述 | `true` |
| `dtoFileNameSuffix` | DTO 文件后缀 | `[".dto.ts"]` |
| `controllerFileNameSuffix` | Controller 文件后缀 | `[".controller.ts"]` |

### 自动生成的内容

#### 1. DTO 属性装饰器

**❌ 之前需要手动写:**
```typescript
export class CreateUserDto {
  @ApiProperty({ description: '用户名', example: 'admin' })
  @IsString()
  userName: string;
}
```

**✅ 现在自动生成:**
```typescript
export class CreateUserDto {
  /** 用户账号 */  // JSDoc 注释会自动转为 description
  @IsString()
  userName: string;  // 自动添加 @ApiProperty()
}
```

#### 2. Controller 参数装饰器

**自动识别并添加:**
- `@Body()` → 自动添加 `@ApiBody()`
- `@Param()` → 自动添加 `@ApiParam()`
- `@Query()` → 自动添加 `@ApiQuery()`

#### 3. 类型推断

**从 class-validator 推断:**
```typescript
export class CreateUserDto {
  @IsString()
  userName: string;  // 自动推断: type: 'string'
  
  @IsNumber()
  age: number;  // 自动推断: type: 'number'
  
  @IsOptional()
  @IsString()
  nickName?: string;  // 自动推断: required: false
}
```

#### 4. 枚举类型

```typescript
export class CreateUserDto {
  /** 用户性别 (0=男 1=女 2=未知) */
  @IsIn(['0', '1', '2'])
  sex: string;  // 自动推断: enum: ['0', '1', '2']
}
```

---

## 装饰器使用指南

### Controller 级别装饰器

#### 基础配置

```typescript
import { Controller } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('用户管理')  // API 分组标签
@ApiBearerAuth('JWT-auth')  // 需要 JWT 认证
@Controller('system/user')
export class UserController {
  // ...
}
```

#### 完整示例

```typescript
import { Controller, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiExtraModels } from '@nestjs/swagger';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';

@ApiTags('用户管理')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@ApiExtraModels(UserResponseDto)  // 注册响应模型
@Controller('system/user')
export class UserController {
  // ...
}
```

### 方法级别装饰器

#### @ApiOperation - 操作描述

```typescript
import { Get } from '@nestjs/common';
import { ApiOperation } from '@nestjs/swagger';

@Get()
@ApiOperation({ 
  summary: '查询用户列表',  // 简短描述
  description: '分页查询用户列表,支持多条件筛选'  // 详细描述
})
async findAll() {
  // ...
}
```

#### @ApiResponse - 响应定义

```typescript
import { ApiResponse } from '@nestjs/swagger';

@Get(':id')
@ApiResponse({ 
  status: 200, 
  description: '查询成功',
  type: UserResponseDto  // 响应数据类型
})
@ApiResponse({ 
  status: 404, 
  description: '用户不存在' 
})
async findOne(@Param('id') id: string) {
  // ...
}
```

#### @ApiParam - 路径参数

```typescript
import { ApiParam } from '@nestjs/swagger';

@Get(':id')
@ApiParam({ 
  name: 'id', 
  description: '用户ID', 
  example: '1' 
})
async findOne(@Param('id') id: string) {
  // ...
}
```

#### @ApiQuery - 查询参数

```typescript
import { ApiQuery } from '@nestjs/swagger';

@Get()
@ApiQuery({ 
  name: 'pageNum', 
  required: false, 
  description: '页码', 
  example: 1 
})
@ApiQuery({ 
  name: 'pageSize', 
  required: false, 
  description: '每页数量', 
  example: 10 
})
async findAll(@Query() query: QueryUserDto) {
  // ...
}
```

#### @ApiBody - 请求体

```typescript
import { ApiBody } from '@nestjs/swagger';

@Post()
@ApiBody({ 
  type: CreateUserDto,
  description: '创建用户的数据',
  examples: {
    user1: {
      summary: '管理员示例',
      value: {
        userName: 'admin',
        nickName: '管理员',
        roleIds: ['1']
      }
    }
  }
})
async create(@Body() createUserDto: CreateUserDto) {
  // ...
}
```

### DTO 装饰器

#### @ApiProperty - 属性定义

```typescript
import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsEmail } from 'class-validator';

export class CreateUserDto {
  @ApiProperty({
    description: '用户账号',
    example: 'admin',
    minLength: 2,
    maxLength: 30,
  })
  @IsString()
  userName: string;

  @ApiProperty({
    description: '用户昵称',
    example: '管理员',
  })
  @IsString()
  nickName: string;

  @ApiProperty({
    description: '邮箱地址',
    example: 'admin@example.com',
    required: false,
  })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiProperty({
    description: '用户状态',
    example: '0',
    enum: ['0', '1'],
    default: '0',
  })
  @IsOptional()
  status?: string;
}
```

#### @ApiPropertyOptional - 可选属性

```typescript
import { ApiPropertyOptional } from '@nestjs/swagger';

export class QueryUserDto {
  @ApiPropertyOptional({ description: '用户名', example: 'admin' })
  userName?: string;

  @ApiPropertyOptional({ description: '手机号', example: '13800138000' })
  phonenumber?: string;
}
```

#### @ApiHideProperty - 隐藏属性

```typescript
import { ApiHideProperty } from '@nestjs/swagger';

export class UserEntity {
  @ApiProperty({ description: '用户ID' })
  userId: string;

  @ApiHideProperty()  // 不在 Swagger 中显示
  password: string;
}
```

### 响应模型装饰器

```typescript
import { ApiProperty } from '@nestjs/swagger';

export class UserResponseDto {
  @ApiProperty({ description: '用户ID', example: '1' })
  userId: string;

  @ApiProperty({ description: '用户名', example: 'admin' })
  userName: string;

  @ApiProperty({ description: '昵称', example: '管理员' })
  nickName: string;

  @ApiProperty({ description: '状态', example: '0' })
  status: string;
}

export class PageResponseDto<T> {
  @ApiProperty({ description: '总数', example: 100 })
  total: number;

  @ApiProperty({ description: '数据列表', type: [UserResponseDto] })
  rows: T[];
}
```

---

## 最佳实践

### 1. 使用 JSDoc 注释

**✅ 推荐:**
```typescript
export class CreateUserDto {
  /** 用户账号 */
  @IsString()
  userName: string;

  /** 用户昵称 */
  @IsString()
  nickName: string;

  /** 用户性别 (0=男 1=女 2=未知) */
  @IsOptional()
  sex?: string;
}
```

**❌ 不推荐:**
```typescript
export class CreateUserDto {
  @ApiProperty({ description: '用户账号' })  // 重复工作
  @IsString()
  userName: string;
}
```

### 2. Controller 必须添加的装饰器

```typescript
@ApiTags('模块名称')  // 必须: API 分组
@ApiBearerAuth('JWT-auth')  // 如果需要认证
@Controller('path')
export class XxxController {
  
  @ApiOperation({ summary: '操作描述' })  // 必须: 每个方法
  @ApiResponse({ status: 200, description: '成功' })  // 推荐
  @Get()
  async method() {
    // ...
  }
}
```

### 3. DTO 规范

```typescript
/**
 * 创建用户 DTO
 */
export class CreateUserDto {
  /** 用户账号 */
  @IsNotEmpty({ message: '用户名称不能为空' })
  @IsString()
  userName: string;

  /** 用户昵称 */
  @IsNotEmpty({ message: '用户昵称不能为空' })
  @IsString()
  nickName: string;

  /** 用户密码 */
  @IsOptional()
  @IsString()
  password?: string;
}
```

### 4. 响应格式统一

```typescript
// 统一响应格式
export class ApiResponseDto<T> {
  @ApiProperty({ description: '状态码', example: 200 })
  code: number;

  @ApiProperty({ description: '消息', example: '操作成功' })
  msg: string;

  @ApiProperty({ description: '数据' })
  data: T;
}

// 使用
@ApiResponse({ 
  status: 200, 
  type: ApiResponseDto<UserResponseDto>
})
```

### 5. 分页查询规范

```typescript
export class PageQueryDto {
  /** 页码 */
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  pageNum?: number = 1;

  /** 每页数量 */
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  pageSize?: number = 10;
}

export class QueryUserDto extends PageQueryDto {
  /** 用户名 */
  @IsOptional()
  @IsString()
  userName?: string;
}
```

---

## 常见问题

### Q1: Swagger 页面显示空白?

**原因:** 可能是 main.ts 配置问题

**解决:**
```typescript
// main.ts
import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Swagger 配置
  const config = new DocumentBuilder()
    .setTitle('RBAC Admin Pro API')
    .setDescription('权限管理系统 API 文档')
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: '输入 JWT token',
        in: 'header',
      },
      'JWT-auth',
    )
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document);

  await app.listen(3000);
}
```

### Q2: 自动生成不生效?

**检查清单:**
1. ✅ `nest-cli.json` 配置正确
2. ✅ 文件后缀匹配 (`.dto.ts`, `.controller.ts`)
3. ✅ 重启开发服务器
4. ✅ 清理 `dist` 目录

```bash
# 清理并重启
rm -rf dist
npm run start:dev
```

### Q3: DTO 没有显示描述?

**原因:** 缺少 JSDoc 注释或 `introspectComments` 未开启

**解决:**
```typescript
// ✅ 正确
export class CreateUserDto {
  /** 用户账号 */  // JSDoc 注释
  @IsString()
  userName: string;
}

// ❌ 错误
export class CreateUserDto {
  // 用户账号  // 普通注释不会被识别
  @IsString()
  userName: string;
}
```

### Q4: 枚举类型没有显示?

**解决:**
```typescript
// 方式 1: 使用 @IsIn
export class CreateUserDto {
  /** 用户状态 (0=正常 1=停用) */
  @IsIn(['0', '1'])
  status: string;  // 自动推断 enum
}

// 方式 2: 手动指定
export class CreateUserDto {
  @ApiProperty({
    description: '用户状态',
    enum: ['0', '1'],
    example: '0',
  })
  status: string;
}
```

### Q5: 响应模型不显示?

**原因:** 没有注册模型

**解决:**
```typescript
import { ApiExtraModels, ApiResponse, getSchemaPath } from '@nestjs/swagger';

@ApiExtraModels(UserResponseDto)  // 注册模型
@Controller('user')
export class UserController {
  
  @ApiResponse({
    status: 200,
    schema: {
      allOf: [
        { $ref: getSchemaPath(UserResponseDto) }
      ]
    }
  })
  @Get()
  async findAll() {
    // ...
  }
}
```

### Q6: 如何隐藏某些 API?

**方式 1: 使用 @ApiExcludeEndpoint**
```typescript
import { ApiExcludeEndpoint } from '@nestjs/swagger';

@ApiExcludeEndpoint()  // 隐藏此接口
@Get('internal')
async internalApi() {
  // ...
}
```

**方式 2: 使用环境变量**
```typescript
// main.ts
if (process.env.NODE_ENV !== 'production') {
  // 只在非生产环境显示 Swagger
  SwaggerModule.setup('api-docs', app, document);
}
```

---

## 示例代码

### 完整的 Controller 示例

```typescript
import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiQuery,
  ApiBody,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';
import { UserService } from './user.service';
import { CreateUserDto, UpdateUserDto, QueryUserDto } from './dto';

@ApiTags('用户管理')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard)
@Controller('system/user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post()
  @ApiOperation({ summary: '新增用户' })
  @ApiBody({ type: CreateUserDto })
  @ApiResponse({ status: 201, description: '创建成功' })
  @ApiResponse({ status: 400, description: '参数错误' })
  async create(@Body() createUserDto: CreateUserDto) {
    return this.userService.create(createUserDto);
  }

  @Get()
  @ApiOperation({ summary: '查询用户列表' })
  @ApiQuery({ name: 'pageNum', required: false, description: '页码', example: 1 })
  @ApiQuery({ name: 'pageSize', required: false, description: '每页数量', example: 10 })
  @ApiResponse({ status: 200, description: '查询成功' })
  async findAll(@Query() query: QueryUserDto) {
    return this.userService.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: '查询用户详情' })
  @ApiParam({ name: 'id', description: '用户ID', example: '1' })
  @ApiResponse({ status: 200, description: '查询成功' })
  @ApiResponse({ status: 404, description: '用户不存在' })
  async findOne(@Param('id') id: string) {
    return this.userService.findOne(id);
  }

  @Put(':id')
  @ApiOperation({ summary: '修改用户' })
  @ApiParam({ name: 'id', description: '用户ID', example: '1' })
  @ApiBody({ type: UpdateUserDto })
  @ApiResponse({ status: 200, description: '修改成功' })
  async update(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    return this.userService.update(id, updateUserDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除用户' })
  @ApiParam({ name: 'id', description: '用户ID', example: '1' })
  @ApiResponse({ status: 200, description: '删除成功' })
  async remove(@Param('id') id: string) {
    return this.userService.remove(id);
  }
}
```

### 完整的 DTO 示例

```typescript
import {
  IsNotEmpty,
  IsString,
  IsOptional,
  IsEmail,
  IsArray,
  IsIn,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

/**
 * 创建用户 DTO
 */
export class CreateUserDto {
  /** 用户账号 */
  @IsNotEmpty({ message: '用户名称不能为空' })
  @IsString()
  userName: string;

  /** 用户昵称 */
  @IsNotEmpty({ message: '用户昵称不能为空' })
  @IsString()
  nickName: string;

  /** 用户密码 */
  @IsOptional()
  @IsString()
  password?: string;

  /** 部门ID */
  @IsOptional()
  @IsString()
  deptId?: string;

  /** 手机号码 */
  @IsOptional()
  @IsString()
  phonenumber?: string;

  /** 邮箱地址 */
  @IsOptional()
  @IsEmail({}, { message: '邮箱格式不正确' })
  email?: string;

  /** 用户性别 (0=男 1=女 2=未知) */
  @IsOptional()
  @IsIn(['0', '1', '2'])
  sex?: string;

  /** 用户状态 (0=正常 1=停用) */
  @IsOptional()
  @IsIn(['0', '1'])
  status?: string;

  /** 备注信息 */
  @IsOptional()
  @IsString()
  remark?: string;

  /** 角色ID列表 */
  @IsOptional()
  @IsArray()
  roleIds?: string[];

  /** 岗位ID列表 */
  @IsOptional()
  @IsArray()
  postIds?: string[];
}

/**
 * 查询用户 DTO
 */
export class QueryUserDto {
  /** 用户名 */
  @IsOptional()
  @IsString()
  userName?: string;

  /** 手机号 */
  @IsOptional()
  @IsString()
  phonenumber?: string;

  /** 状态 */
  @IsOptional()
  @IsIn(['0', '1'])
  status?: string;

  /** 部门ID */
  @IsOptional()
  @IsString()
  deptId?: string;

  /** 页码 */
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  pageNum?: number = 1;

  /** 每页数量 */
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  pageSize?: number = 10;
}
```

---

## 参考资源

### 📚 官方文档
- [NestJS Swagger](https://docs.nestjs.com/openapi/introduction)
- [Swagger UI](https://swagger.io/tools/swagger-ui/)
- [OpenAPI Specification](https://swagger.io/specification/)

### 🔧 相关工具
- [@nestjs/swagger](https://www.npmjs.com/package/@nestjs/swagger)
- [swagger-ui-express](https://www.npmjs.com/package/swagger-ui-express)

---

**文档版本:** v1.0  
**最后更新:** 2025-12-05  
**维护者:** 开发团队
