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
