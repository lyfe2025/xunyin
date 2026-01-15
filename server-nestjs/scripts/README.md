# 脚本使用说明

## 图片资源管理

### 重新下载所有初始图片

如果需要重置所有初始数据的图片资源，使用：

```bash
bash server-nestjs/scripts/download-all-images.sh
```

**这个脚本会：**
- 下载所有 64 张 JPG 图片
- 自动跳过已存在的图片
- 使用 Picsum Photos 占位图服务（稳定可靠）

### 验证图片完整性

下载完成后，验证所有图片是否有效：

```bash
bash server-nestjs/scripts/verify-images.sh
```

**这个脚本会：**
- 检查所有 64 张必需的 JPG 图片是否存在
- 验证图片文件格式是否正确
- 显示详细的验证结果

## 其他脚本

### 下载背景音乐

```bash
bash server-nestjs/scripts/download-bgm.sh
```

### 重置 Prisma 数据库

```bash
bash server-nestjs/scripts/reset-prisma.sh
```

## 注意事项

1. **初始图片已提交到 Git**：团队成员克隆项目后无需重新下载
2. **用户上传的图片不会被提交**：`.gitignore` 已配置好
3. **图片路径已在 seed.ts 中配置**：运行 `pnpm db:seed` 即可使用
4. **所有图片均为 JPG 格式**：来自 Picsum Photos 占位图服务

## 快速开始

```bash
# 1. 下载所有图片（如果需要）
bash server-nestjs/scripts/download-all-images.sh

# 2. 验证图片
bash server-nestjs/scripts/verify-images.sh

# 3. 运行 seed 导入数据
pnpm --filter server-nestjs db:seed
```

## 图片来源

所有图片来自 [Picsum Photos](https://picsum.photos) 占位图服务：
- **许可证**：免费使用
- **稳定性**：高可用性，适合开发测试
- **格式**：JPG 格式

## 图片分类

| 类别 | 数量 | 格式 | 说明 |
|------|------|------|------|
| 城市封面图 | 4 张 | JPG | 杭州、苏州、南京、福州 |
| 文化之旅封面图 | 6 张 | JPG | 各条文化之旅的封面 |
| 印记图片 | 12 张 | JPG | 路线印记、城市印记、特殊印记 |
| 用户头像 | 4 张 | JPG | 示例用户头像 |
| 身份证示例 | 6 张 | JPG | 身份证上传示例 |
| 探索照片 | 32 张 | JPG | 16 张原图 + 16 张缩略图 |
| **总计** | **64 张** | **JPG** | **全部来自 Picsum** |
