# 代码质量规范

## Lint 检查要求

每次修改代码后，必须执行 lint 检查确保代码质量：

```bash
# 检查整个项目
pnpm lint

# 自动修复可修复的问题
pnpm lint --fix

# 单独检查后端
pnpm --filter server-nestjs lint

# 单独检查前端
pnpm --filter web lint
```

## TypeScript 类型安全

### 禁止使用 `any` 类型

项目启用了严格的 TypeScript 检查，避免使用 `any` 类型：

```typescript
// ❌ 错误：使用 any
const where: any = {}
async update(@Request() req: any) {}

// ✅ 正确：使用具体类型
const where: Prisma.UserWhereInput = {}
async update(@CurrentUser() user: JwtUser) {}
```

### Prisma 查询类型

使用 Prisma 生成的类型定义：

```typescript
import { Prisma } from '@prisma/client'

// 查询条件
const where: Prisma.UserWhereInput = {}
const where: Prisma.CityWhereInput = {}

// 创建数据
const data: Prisma.UserCreateInput = {}

// 更新数据
const data: Prisma.UserUpdateInput = {}
```

### 获取当前用户

#### Admin 端（管理后台）

使用 `@CurrentUser()` 装饰器获取 JWT 用户信息：

```typescript
import { CurrentUser, JwtUser } from '../common/decorators/user.decorator'

@Put(':id')
@UseGuards(JwtAuthGuard)
async update(@Param('id') id: string, @Body() dto: UpdateDto, @CurrentUser() user: JwtUser) {
  return this.service.update(id, dto, user?.userName)
}
```

#### App 端（移动端）

使用 App 端专用的 `@CurrentUser()` 装饰器：

```typescript
import { CurrentUser } from '../app-auth/decorators/current-user.decorator'
import type { CurrentAppUser } from '../app-auth/decorators/current-user.decorator'

@Get('profile')
@UseGuards(AppAuthGuard)
async getProfile(@CurrentUser() user: CurrentAppUser) {
  return this.service.getProfile(user.userId)
}
```

### Map 类型安全

当 Map 的 key 可能为 null 时，需要先检查：

```typescript
// ❌ 错误：contextId 可能为 null
const name = cityMap.get(item.contextId)

// ✅ 正确：先检查 contextId 是否存在
const name = item.contextId ? cityMap.get(item.contextId) : undefined
```

### 移除未使用的导入

确保没有未使用的导入：

```typescript
// ❌ 错误：ApiProperty 未使用
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'

// ✅ 正确：只导入需要的
import { ApiPropertyOptional } from '@nestjs/swagger'
```

## Prettier 配置

项目使用统一的 Prettier 配置，配置文件位于：
- 根目录：`.prettierrc.json`（基础配置）
- `server-nestjs/.prettierrc.json`
- `web/.prettierrc.json`

### 统一配置项

| 配置项 | 值 | 说明 |
|--------|-----|------|
| semi | false | 不使用分号 |
| singleQuote | true | 使用单引号 |
| printWidth | 100 | 行宽 100 字符 |
| tabWidth | 2 | 缩进 2 空格 |
| useTabs | false | 使用空格缩进 |
| trailingComma | all | 尾随逗号（全部） |
| bracketSpacing | true | 对象括号内空格 |
| arrowParens | always | 箭头函数参数始终加括号 |
| endOfLine | auto | 换行符自动检测 |

## ESLint 配置

ESLint 配置中的 `prettier/prettier` 规则使用空对象 `{}`，自动读取 `.prettierrc.json` 配置，避免配置不一致。

```javascript
// 正确写法
'prettier/prettier': ['error', {}]

// 避免内联配置（容易与 .prettierrc.json 不一致）
// 'prettier/prettier': ['error', { endOfLine: 'auto' }]
```

## 提交前检查

建议在提交代码前执行：

```bash
# 1. 运行 lint 检查
pnpm lint

# 2. 如有问题，自动修复
pnpm lint --fix

# 3. 确认无错误后提交
git add .
git commit -m "your message"
```

## EditorConfig

项目根目录包含 `.editorconfig` 文件，确保不同编辑器的基础格式一致：
- 字符集：UTF-8
- 缩进：2 空格
- 换行符：LF
- 文件末尾：插入空行
- 行尾空格：自动删除
