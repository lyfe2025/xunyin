---
inclusion: fileMatch
fileMatchPattern: "**/init*.sql"
---

# 初始化数据规范

## 菜单数据规范

### 菜单类型
- `M` - 目录（一级菜单）
- `C` - 菜单（页面）
- `F` - 按钮（权限）

### 菜单字段
```sql
INSERT INTO sys_menu (
  menu_name,    -- 菜单名称
  path,         -- 路由地址
  component,    -- 组件路径
  order_num,    -- 显示顺序
  menu_type,    -- 菜单类型 M/C/F
  visible,      -- 是否显示 0显示 1隐藏
  status,       -- 状态 0正常 1停用
  icon,         -- 图标名称
  is_frame,     -- 是否外链 0是 1否
  parent_id,    -- 父菜单ID
  perms         -- 权限标识
)
```

### 权限标识命名
- 格式：`模块:资源:操作`
- 示例：
  - `xunyin:city:list` - 城市列表
  - `xunyin:city:add` - 新增城市
  - `xunyin:city:edit` - 编辑城市
  - `xunyin:city:remove` - 删除城市
  - `xunyin:journey:list` - 文化之旅列表

### 寻印管理菜单结构
```
寻印管理 (M)
├── 城市管理 (C) - xunyin:city:list
│   ├── 城市查询 (F) - xunyin:city:query
│   ├── 城市新增 (F) - xunyin:city:add
│   ├── 城市修改 (F) - xunyin:city:edit
│   └── 城市删除 (F) - xunyin:city:remove
├── 文化之旅管理 (C) - xunyin:journey:list
├── 探索点管理 (C) - xunyin:point:list
├── 印记管理 (C) - xunyin:seal:list
├── App用户管理 (C) - xunyin:appuser:list
└── 数据统计 (C) - xunyin:stats:view
```

## 字典数据规范

### 字典类型命名
- 格式：`模块_字典名`
- 示例：
  - `xunyin_task_type` - 任务类型
  - `xunyin_seal_type` - 印记类型
  - `xunyin_progress_status` - 进度状态

### 寻印业务字典
```sql
-- 任务类型
('xunyin_task_type', '手势识别', 'gesture', 1)
('xunyin_task_type', '拍照探索', 'photo', 2)
('xunyin_task_type', 'AR寻宝', 'treasure', 3)

-- 印记类型
('xunyin_seal_type', '路线印记', 'route', 1)
('xunyin_seal_type', '城市印记', 'city', 2)
('xunyin_seal_type', '特殊印记', 'special', 3)

-- 进度状态
('xunyin_progress_status', '进行中', 'in_progress', 1)
('xunyin_progress_status', '已完成', 'completed', 2)
('xunyin_progress_status', '已放弃', 'abandoned', 3)
```

## SQL 编写规范

### 使用 ON CONFLICT 避免重复插入
```sql
INSERT INTO sys_menu (menu_name, path, ...)
VALUES ('寻印管理', 'xunyin', ...)
ON CONFLICT DO NOTHING;
```

### 使用子查询获取父级 ID
```sql
INSERT INTO sys_menu (menu_name, parent_id, ...)
SELECT '城市管理', menu_id, ...
FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL
ON CONFLICT DO NOTHING;
```

### 角色菜单绑定
```sql
-- 为管理员角色绑定寻印管理菜单
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT r.role_id, m.menu_id
FROM sys_role r, sys_menu m
WHERE r.role_key = 'admin' AND r.del_flag = '0'
  AND m.path = 'xunyin'
ON CONFLICT DO NOTHING;
```
