-- =============================================
-- Xunyin Admin - 初始化数据脚本
-- 说明：本脚本用于初始化系统基础数据
-- 注意：密码使用 bcrypt 加密，默认密码为 admin123
-- 前置条件：需先执行 schema.sql 创建表结构和索引
-- =============================================

-- 1. 初始化部门数据（层级结构）
-- 1.1 总公司（根部门）
INSERT INTO sys_dept (dept_name, order_num, status, parent_id, ancestors, leader, phone, email, del_flag, create_time)
VALUES ('总公司', 0, '0', NULL, '0', '张总', '', '', '0', NOW())
ON CONFLICT DO NOTHING;

-- 1.2 技术部
INSERT INTO sys_dept (dept_name, order_num, status, parent_id, ancestors, leader, phone, email, del_flag, create_time)
SELECT '技术部', 1, '0', dept_id, '0,' || dept_id, '李工', '', '', '0', NOW()
FROM sys_dept WHERE dept_name = '总公司' AND del_flag = '0'
ON CONFLICT DO NOTHING;

-- 1.3 研发一部
INSERT INTO sys_dept (dept_name, order_num, status, parent_id, ancestors, leader, phone, email, del_flag, create_time)
SELECT '研发一部', 2, '0', dept_id, 
  (SELECT '0,' || parent.dept_id || ',' || child.dept_id 
   FROM sys_dept parent, sys_dept child 
   WHERE parent.dept_name = '总公司' AND child.dept_name = '技术部' AND parent.del_flag = '0' AND child.del_flag = '0'),
  '王工', '', '', '0', NOW()
FROM sys_dept WHERE dept_name = '技术部' AND del_flag = '0'
ON CONFLICT DO NOTHING;

-- 1.4 测试一部
INSERT INTO sys_dept (dept_name, order_num, status, parent_id, ancestors, leader, phone, email, del_flag, create_time)
SELECT '测试一部', 3, '0', dept_id,
  (SELECT '0,' || parent.dept_id || ',' || child.dept_id 
   FROM sys_dept parent, sys_dept child 
   WHERE parent.dept_name = '总公司' AND child.dept_name = '技术部' AND parent.del_flag = '0' AND child.del_flag = '0'),
  '赵工', '', '', '0', NOW()
FROM sys_dept WHERE dept_name = '技术部' AND del_flag = '0'
ON CONFLICT DO NOTHING;

-- 1.5 人事部
INSERT INTO sys_dept (dept_name, order_num, status, parent_id, ancestors, leader, phone, email, del_flag, create_time)
SELECT '人事部', 4, '0', dept_id, '0,' || dept_id, '刘姐', '', '', '0', NOW()
FROM sys_dept WHERE dept_name = '总公司' AND del_flag = '0'
ON CONFLICT DO NOTHING;

-- 1.6 财务部
INSERT INTO sys_dept (dept_name, order_num, status, parent_id, ancestors, leader, phone, email, del_flag, create_time)
SELECT '财务部', 5, '0', dept_id, '0,' || dept_id, '钱会', '', '', '0', NOW()
FROM sys_dept WHERE dept_name = '总公司' AND del_flag = '0'
ON CONFLICT DO NOTHING;

-- 1.7 华东分公司
INSERT INTO sys_dept (dept_name, order_num, status, parent_id, ancestors, leader, phone, email, del_flag, create_time)
SELECT '华东分公司', 6, '0', dept_id, '0,' || dept_id, '孙总', '', '', '0', NOW()
FROM sys_dept WHERE dept_name = '总公司' AND del_flag = '0'
ON CONFLICT DO NOTHING;

-- 1.8 上海办事处
INSERT INTO sys_dept (dept_name, order_num, status, parent_id, ancestors, leader, phone, email, del_flag, create_time)
SELECT '上海办事处', 7, '0', dept_id,
  (SELECT '0,' || parent.dept_id || ',' || child.dept_id 
   FROM sys_dept parent, sys_dept child 
   WHERE parent.dept_name = '总公司' AND child.dept_name = '华东分公司' AND parent.del_flag = '0' AND child.del_flag = '0'),
  '周主任', '', '', '0', NOW()
FROM sys_dept WHERE dept_name = '华东分公司' AND del_flag = '0'
ON CONFLICT DO NOTHING;

-- 1.9 杭州办事处
INSERT INTO sys_dept (dept_name, order_num, status, parent_id, ancestors, leader, phone, email, del_flag, create_time)
SELECT '杭州办事处', 8, '0', dept_id,
  (SELECT '0,' || parent.dept_id || ',' || child.dept_id 
   FROM sys_dept parent, sys_dept child 
   WHERE parent.dept_name = '总公司' AND child.dept_name = '华东分公司' AND parent.del_flag = '0' AND child.del_flag = '0'),
  '吴主任', '', '', '0', NOW()
FROM sys_dept WHERE dept_name = '华东分公司' AND del_flag = '0'
ON CONFLICT DO NOTHING;


-- 2. 初始化角色数据(所有角色启用状态)
INSERT INTO sys_role (role_name, role_key, role_sort, status, data_scope, menu_check_strictly, dept_check_strictly, del_flag, remark, create_time)
VALUES 
  ('超级管理员', 'admin', 1, '0', '1', true, true, '0', '拥有系统所有权限', NOW()),
  ('系统管理员', 'system_admin', 2, '0', '2', true, true, '0', '负责系统管理模块', NOW()),
  ('监控管理员', 'monitor_admin', 3, '0', '1', true, true, '0', '负责系统监控模块', NOW()),
  ('普通用户', 'common_user', 4, '0', '3', true, true, '0', '只读权限,无增删改权限', NOW())
ON CONFLICT DO NOTHING;


-- 3. 初始化用户数据
-- 注意：这里的密码是 bcrypt 加密后的 'admin123'，salt rounds = 10
INSERT INTO sys_user (user_name, nick_name, email, phonenumber, sex, password, status, dept_id, del_flag, remark, create_time)
SELECT 'admin', '超级管理员', 'admin@example.com', '13800000000', '0',
  '$2b$10$N9qo8uLOickgx2ZMRZoMy.MqrqgBi1SY2lCb1S6Y8VpFl5K4bXKq2', -- admin123
  '0', dept_id, '0', '系统超级管理员账号', NOW()
FROM sys_dept WHERE dept_name = '总公司' AND del_flag = '0'
ON CONFLICT (user_name) WHERE del_flag = '0' DO NOTHING;

INSERT INTO sys_user (user_name, nick_name, email, phonenumber, sex, password, status, dept_id, del_flag, remark, create_time)
SELECT 'system_admin', '系统管理员', 'system@example.com', '13800000001', '0',
  '$2b$10$N9qo8uLOickgx2ZMRZoMy.MqrqgBi1SY2lCb1S6Y8VpFl5K4bXKq2', -- admin123
  '0', dept_id, '0', '负责系统管理', NOW()
FROM sys_dept WHERE dept_name = '技术部' AND del_flag = '0'
ON CONFLICT (user_name) WHERE del_flag = '0' DO NOTHING;

INSERT INTO sys_user (user_name, nick_name, email, phonenumber, sex, password, status, dept_id, del_flag, remark, create_time)
SELECT 'monitor_admin', '监控管理员', 'monitor@example.com', '13800000002', '1',
  '$2b$10$N9qo8uLOickgx2ZMRZoMy.MqrqgBi1SY2lCb1S6Y8VpFl5K4bXKq2', -- admin123
  '0', dept_id, '0', '负责系统监控', NOW()
FROM sys_dept WHERE dept_name = '研发一部' AND del_flag = '0'
ON CONFLICT (user_name) WHERE del_flag = '0' DO NOTHING;

INSERT INTO sys_user (user_name, nick_name, email, phonenumber, sex, password, status, dept_id, del_flag, remark, create_time)
SELECT 'user', '普通用户', 'user@example.com', '13800000003', '1',
  '$2b$10$N9qo8uLOickgx2ZMRZoMy.MqrqgBi1SY2lCb1S6Y8VpFl5K4bXKq2', -- admin123
  '0', dept_id, '0', '普通用户账号', NOW()
FROM sys_dept WHERE dept_name = '测试一部' AND del_flag = '0'
ON CONFLICT (user_name) WHERE del_flag = '0' DO NOTHING;


-- 4. 绑定用户角色
-- 4.1 超级管理员
INSERT INTO sys_user_role (user_id, role_id)
SELECT u.user_id, r.role_id
FROM sys_user u, sys_role r
WHERE u.user_name = 'admin' AND u.del_flag = '0' 
  AND r.role_key = 'admin' AND r.del_flag = '0'
ON CONFLICT DO NOTHING;

-- 4.2 系统管理员
INSERT INTO sys_user_role (user_id, role_id)
SELECT u.user_id, r.role_id
FROM sys_user u, sys_role r
WHERE u.user_name = 'system_admin' AND u.del_flag = '0'
  AND r.role_key = 'system_admin' AND r.del_flag = '0'
ON CONFLICT DO NOTHING;

-- 4.3 监控管理员
INSERT INTO sys_user_role (user_id, role_id)
SELECT u.user_id, r.role_id
FROM sys_user u, sys_role r
WHERE u.user_name = 'monitor_admin' AND u.del_flag = '0'
  AND r.role_key = 'monitor_admin' AND r.del_flag = '0'
ON CONFLICT DO NOTHING;

-- 4.4 普通用户
INSERT INTO sys_user_role (user_id, role_id)
SELECT u.user_id, r.role_id
FROM sys_user u, sys_role r
WHERE u.user_name = 'user' AND u.del_flag = '0'
  AND r.role_key = 'common_user' AND r.del_flag = '0'
ON CONFLICT DO NOTHING;


-- 5. 初始化岗位数据
INSERT INTO sys_post (post_code, post_name, post_sort, status, create_time)
VALUES 
  ('dev', '开发', 1, '0', NOW()),
  ('pm', '产品经理', 2, '0', NOW())
ON CONFLICT (post_code) DO NOTHING;


-- 6. 绑定用户岗位
INSERT INTO sys_user_post (user_id, post_id)
SELECT u.user_id, p.post_id
FROM sys_user u, sys_post p
WHERE u.user_name = 'admin' AND u.del_flag = '0' AND p.post_code = 'dev'
ON CONFLICT DO NOTHING;

INSERT INTO sys_user_post (user_id, post_id)
SELECT u.user_id, p.post_id
FROM sys_user u, sys_post p
WHERE u.user_name = 'system_admin' AND u.del_flag = '0' AND p.post_code = 'dev'
ON CONFLICT DO NOTHING;

INSERT INTO sys_user_post (user_id, post_id)
SELECT u.user_id, p.post_id
FROM sys_user u, sys_post p
WHERE u.user_name = 'monitor_admin' AND u.del_flag = '0' AND p.post_code = 'dev'
ON CONFLICT DO NOTHING;

INSERT INTO sys_user_post (user_id, post_id)
SELECT u.user_id, p.post_id
FROM sys_user u, sys_post p
WHERE u.user_name = 'user' AND u.del_flag = '0' AND p.post_code = 'pm'
ON CONFLICT DO NOTHING;


-- 7. 初始化字典类型
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_time)
VALUES
  ('显示隐藏', 'sys_show_hide', '0', NOW()),
  ('正常停用', 'sys_normal_disable', '0', NOW()),
  ('是否', 'sys_yes_no', '0', NOW()),
  ('用户性别', 'sys_user_sex', '0', NOW()),
  ('任务状态', 'sys_job_status', '0', NOW()),
  ('任务分组', 'sys_job_group', '0', NOW()),
  ('通知类型', 'sys_notice_type', '0', NOW()),
  ('通知状态', 'sys_notice_status', '0', NOW()),
  ('操作类型', 'sys_oper_type', '0', NOW()),
  ('通用状态', 'sys_common_status', '0', NOW())
ON CONFLICT (dict_type) DO NOTHING;


-- 8. 初始化字典数据
INSERT INTO sys_dict_data (dict_type, dict_label, dict_value, dict_sort, status, is_default, create_time)
VALUES
  -- 显示隐藏
  ('sys_show_hide', '显示', '0', 1, '0', 'N', NOW()),
  ('sys_show_hide', '隐藏', '1', 2, '0', 'N', NOW()),
  -- 正常停用
  ('sys_normal_disable', '正常', '0', 1, '0', 'Y', NOW()),
  ('sys_normal_disable', '停用', '1', 2, '0', 'N', NOW()),
  -- 是否
  ('sys_yes_no', '是', 'Y', 1, '0', 'Y', NOW()),
  ('sys_yes_no', '否', 'N', 2, '0', 'N', NOW()),
  -- 用户性别
  ('sys_user_sex', '男', '0', 1, '0', 'N', NOW()),
  ('sys_user_sex', '女', '1', 2, '0', 'N', NOW()),
  ('sys_user_sex', '未知', '2', 3, '0', 'Y', NOW()),
  -- 任务状态
  ('sys_job_status', '正常', '0', 1, '0', 'Y', NOW()),
  ('sys_job_status', '暂停', '1', 2, '0', 'N', NOW()),
  -- 任务分组
  ('sys_job_group', 'DEFAULT', 'DEFAULT', 1, '0', 'Y', NOW()),
  ('sys_job_group', 'SYSTEM', 'SYSTEM', 2, '0', 'N', NOW()),
  -- 通知类型
  ('sys_notice_type', '通知', '1', 1, '0', 'N', NOW()),
  ('sys_notice_type', '公告', '2', 2, '0', 'N', NOW()),
  -- 通知状态
  ('sys_notice_status', '正常', '0', 1, '0', 'Y', NOW()),
  ('sys_notice_status', '关闭', '1', 2, '0', 'N', NOW()),
  -- 操作类型
  ('sys_oper_type', '其它', '0', 0, '0', 'N', NOW()),
  ('sys_oper_type', '新增', '1', 1, '0', 'N', NOW()),
  ('sys_oper_type', '修改', '2', 2, '0', 'N', NOW()),
  ('sys_oper_type', '删除', '3', 3, '0', 'N', NOW()),
  ('sys_oper_type', '授权', '4', 4, '0', 'N', NOW()),
  ('sys_oper_type', '导出', '5', 5, '0', 'N', NOW()),
  ('sys_oper_type', '导入', '6', 6, '0', 'N', NOW()),
  ('sys_oper_type', '强退', '7', 7, '0', 'N', NOW()),
  ('sys_oper_type', '生成代码', '8', 8, '0', 'N', NOW()),
  ('sys_oper_type', '清空数据', '9', 9, '0', 'N', NOW()),
  -- 通用状态
  ('sys_common_status', '成功', '0', 1, '0', 'Y', NOW()),
  ('sys_common_status', '失败', '1', 2, '0', 'N', NOW())
ON CONFLICT (dict_type, dict_value) DO NOTHING;


-- 9. 初始化系统配置
INSERT INTO sys_config (config_name, config_key, config_value, config_type, create_time)
VALUES
  -- 账户安全设置
  ('初始密码', 'sys.account.initPassword', 'admin123', 'Y', NOW()),
  ('验证码开关', 'sys.account.captchaEnabled', 'false', 'Y', NOW()),
  ('两步验证开关', 'sys.account.twoFactorEnabled', 'false', 'Y', NOW()),

  -- 网站信息设置
  ('网站名称', 'sys.app.name', 'Xunyin Admin', 'Y', NOW()),
  ('网站描述', 'sys.app.description', '企业级全栈权限管理系统', 'Y', NOW()),
  ('版权信息', 'sys.app.copyright', '© 2025 Xunyin Admin. All rights reserved.', 'Y', NOW()),
  ('ICP备案号', 'sys.app.icp', '', 'Y', NOW()),
  ('联系邮箱', 'sys.app.email', 'admin@example.com', 'Y', NOW()),
  -- 邮件设置
  ('邮件服务开关', 'sys.mail.enabled', 'false', 'Y', NOW()),
  ('SMTP服务器', 'sys.mail.host', '', 'Y', NOW()),
  ('SMTP端口', 'sys.mail.port', '465', 'Y', NOW()),
  ('邮箱账号', 'sys.mail.username', '', 'Y', NOW()),
  ('邮箱密码', 'sys.mail.password', '', 'Y', NOW()),
  ('发件人地址', 'sys.mail.from', '', 'Y', NOW()),
  -- 存储设置
  ('存储类型', 'sys.storage.type', 'local', 'Y', NOW()),
  ('本地存储路径', 'sys.storage.local.path', './uploads', 'Y', NOW()),
  ('OSS端点', 'sys.storage.oss.endpoint', '', 'Y', NOW()),
  ('OSS存储桶', 'sys.storage.oss.bucket', '', 'Y', NOW()),
  ('OSS AccessKey', 'sys.storage.oss.accessKey', '', 'Y', NOW()),
  ('OSS SecretKey', 'sys.storage.oss.secretKey', '', 'Y', NOW()),
  -- 网站Logo和图标
  ('网站Logo', 'sys.app.logo', '', 'Y', NOW()),
  ('网站图标', 'sys.app.favicon', '', 'Y', NOW()),

  -- 安全入口
  ('安全登录路径', 'sys.security.loginPath', '/login', 'Y', NOW()),
  -- 登录限制
  ('登录失败次数', 'sys.login.maxRetry', '5', 'Y', NOW()),
  ('账户锁定时长', 'sys.login.lockTime', '10', 'Y', NOW()),
  -- 会话设置
  ('会话超时时间', 'sys.session.timeout', '30', 'Y', NOW()),
  -- 邮件SSL
  ('SSL/TLS开关', 'sys.mail.ssl', 'true', 'Y', NOW()),

  -- ========== 三方登录配置 ==========
  -- 微信登录
  ('微信登录开关', 'oauth.wechat.enabled', 'false', 'Y', NOW()),
  ('微信AppID', 'oauth.wechat.appId', '', 'Y', NOW()),
  ('微信AppSecret', 'oauth.wechat.appSecret', '', 'Y', NOW()),
  -- Google登录
  ('Google登录开关', 'oauth.google.enabled', 'false', 'Y', NOW()),
  ('Google Client ID', 'oauth.google.clientId', '', 'Y', NOW()),
  ('Google Client Secret', 'oauth.google.clientSecret', '', 'Y', NOW()),
  -- Apple登录
  ('Apple登录开关', 'oauth.apple.enabled', 'false', 'Y', NOW()),
  ('Apple Team ID', 'oauth.apple.teamId', '', 'Y', NOW()),
  ('Apple Client ID', 'oauth.apple.clientId', '', 'Y', NOW()),
  ('Apple Key ID', 'oauth.apple.keyId', '', 'Y', NOW()),
  ('Apple Private Key', 'oauth.apple.privateKey', '', 'Y', NOW()),

  -- ========== 地图配置 ==========
  -- 高德地图
  ('高德地图开关', 'map.amap.enabled', 'true', 'Y', NOW()),
  ('高德Web服务Key', 'map.amap.webKey', '', 'Y', NOW()),
  ('高德Android Key', 'map.amap.androidKey', '', 'Y', NOW()),
  ('高德iOS Key', 'map.amap.iosKey', '', 'Y', NOW()),
  -- 腾讯地图
  ('腾讯地图开关', 'map.tencent.enabled', 'false', 'Y', NOW()),
  ('腾讯地图Key', 'map.tencent.key', '', 'Y', NOW()),
  -- Google地图（海外）
  ('Google地图开关', 'map.google.enabled', 'false', 'Y', NOW()),
  ('Google地图Key', 'map.google.key', '', 'Y', NOW()),

  -- ========== App配置 ==========
  ('App名称', 'app.name', '寻印', 'Y', NOW()),
  ('App版本', 'app.version', '1.0.0', 'Y', NOW()),
  ('强制更新版本', 'app.forceUpdateVersion', '', 'Y', NOW()),
  ('App下载地址', 'app.downloadUrl', '', 'Y', NOW()),
  ('用户协议URL', 'app.userAgreementUrl', '', 'Y', NOW()),
  ('隐私政策URL', 'app.privacyPolicyUrl', '', 'Y', NOW())
ON CONFLICT (config_key) DO NOTHING;


-- 10. 初始化通知公告
INSERT INTO sys_notice (notice_title, notice_type, notice_content, status, create_time)
VALUES ('系统维护', '2', '本周日凌晨进行系统维护。', '0', NOW())
ON CONFLICT DO NOTHING;


-- 11. 初始化定时任务
INSERT INTO sys_job (job_name, job_group, invoke_target, cron_expression, misfire_policy, concurrent, status, create_time)
VALUES ('示例任务', 'DEFAULT', 'log:示例任务执行成功', '0/30 * * * * *', '3', '1', '0', NOW())
ON CONFLICT DO NOTHING;


-- 12. 初始化菜单数据
-- 12.1 系统管理目录
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
VALUES ('系统管理', 'system', 'Layout', 2, 'M', '0', '0', 'settings', 1, NULL, NULL)
ON CONFLICT DO NOTHING;

-- 12.2 系统管理子菜单
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '用户管理', 'user', 'system/user/index', 1, 'C', '0', '0', 'user', 1, menu_id, 'system:user:list'
FROM sys_menu WHERE path = 'system' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '角色管理', 'role', 'system/role/index', 2, 'C', '0', '0', 'users', 1, menu_id, 'system:role:list'
FROM sys_menu WHERE path = 'system' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '菜单管理', 'menu', 'system/menu/index', 3, 'C', '0', '0', 'menu', 1, menu_id, 'system:menu:list'
FROM sys_menu WHERE path = 'system' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '部门管理', 'dept', 'system/dept/index', 4, 'C', '0', '0', 'building-2', 1, menu_id, 'system:dept:list'
FROM sys_menu WHERE path = 'system' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '岗位管理', 'post', 'system/post/index', 5, 'C', '0', '0', 'badge-check', 1, menu_id, 'system:post:list'
FROM sys_menu WHERE path = 'system' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '字典管理', 'dict', 'system/dict/index', 6, 'C', '0', '0', 'book-a', 1, menu_id, 'system:dict:list'
FROM sys_menu WHERE path = 'system' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '参数设置', 'config', 'system/config/index', 7, 'C', '0', '0', 'settings-2', 1, menu_id, 'system:config:list'
FROM sys_menu WHERE path = 'system' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '系统设置', 'setting', 'system/setting/index', 8, 'C', '0', '0', 'sliders-vertical', 1, menu_id, 'system:setting:view'
FROM sys_menu WHERE path = 'system' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '通知公告', 'notice', 'system/notice/index', 9, 'C', '0', '0', 'megaphone', 1, menu_id, 'system:notice:list'
FROM sys_menu WHERE path = 'system' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '更新日志', 'changelog', 'system/changelog/index', 10, 'C', '0', '0', 'scroll-text', 1, menu_id, NULL
FROM sys_menu WHERE path = 'system' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

-- 12.3 系统监控目录
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
VALUES ('系统监控', 'monitor', 'Layout', 3, 'M', '0', '0', 'monitor', 1, NULL, NULL)
ON CONFLICT DO NOTHING;

-- 12.4 系统监控子菜单
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '在线用户', 'online', 'monitor/online/index', 1, 'C', '0', '0', 'user-check', 1, menu_id, 'monitor:online:list'
FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '操作日志', 'operlog', 'monitor/operlog/index', 2, 'C', '0', '0', 'list', 1, menu_id, 'monitor:operlog:list'
FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '登录日志', 'logininfor', 'monitor/logininfor/index', 3, 'C', '0', '0', 'log-in', 1, menu_id, 'monitor:logininfor:list'
FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '定时任务', 'job', 'monitor/job/index', 4, 'C', '0', '0', 'alarm-clock', 1, menu_id, 'monitor:job:list'
FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '服务监控', 'server', 'monitor/server/index', 5, 'C', '0', '0', 'server', 1, menu_id, 'monitor:server:list'
FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '缓存监控', 'cache', 'monitor/cache/index', 6, 'C', '0', '0', 'database-backup', 1, menu_id, 'monitor:cache:view'
FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '数据监控', 'druid', 'monitor/druid/index', 7, 'C', '0', '0', 'database', 1, menu_id, 'monitor:druid:view'
FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

-- 12.5 系统工具目录
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
VALUES ('系统工具', 'tool', 'Layout', 4, 'M', '0', '0', 'wrench', 1, NULL, NULL)
ON CONFLICT DO NOTHING;

-- 12.6 系统工具子菜单
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '接口文档', 'swagger', 'tool/swagger/index', 1, 'C', '0', '0', 'file-text', 1, menu_id, 'tool:swagger:view'
FROM sys_menu WHERE path = 'tool' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '表单构建', 'build', 'tool/build/index', 2, 'C', '0', '0', 'factory', 1, menu_id, 'tool:build:view'
FROM sys_menu WHERE path = 'tool' AND parent_id IS NULL
ON CONFLICT DO NOTHING;


-- 13. 初始化按钮权限（F 类型）
-- 13.1 用户管理按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '用户查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'system:user:query'
FROM sys_menu WHERE path = 'user' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '用户新增', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'system:user:add'
FROM sys_menu WHERE path = 'user' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '用户修改', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'system:user:edit'
FROM sys_menu WHERE path = 'user' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '用户删除', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'system:user:remove'
FROM sys_menu WHERE path = 'user' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '重置密码', '', '', 5, 'F', '1', '0', '#', 1, menu_id, 'system:user:resetPwd'
FROM sys_menu WHERE path = 'user' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '用户导出', '', '', 6, 'F', '1', '0', '#', 1, menu_id, 'system:user:export'
FROM sys_menu WHERE path = 'user' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '用户导入', '', '', 7, 'F', '1', '0', '#', 1, menu_id, 'system:user:import'
FROM sys_menu WHERE path = 'user' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 13.2 角色管理按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '角色查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'system:role:query'
FROM sys_menu WHERE path = 'role' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '角色新增', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'system:role:add'
FROM sys_menu WHERE path = 'role' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '角色修改', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'system:role:edit'
FROM sys_menu WHERE path = 'role' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '角色删除', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'system:role:remove'
FROM sys_menu WHERE path = 'role' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 13.3 菜单管理按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '菜单查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'system:menu:query'
FROM sys_menu WHERE path = 'menu' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '菜单新增', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'system:menu:add'
FROM sys_menu WHERE path = 'menu' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '菜单修改', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'system:menu:edit'
FROM sys_menu WHERE path = 'menu' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '菜单删除', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'system:menu:remove'
FROM sys_menu WHERE path = 'menu' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 13.4 部门管理按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '部门查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'system:dept:query'
FROM sys_menu WHERE path = 'dept' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '部门新增', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'system:dept:add'
FROM sys_menu WHERE path = 'dept' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '部门修改', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'system:dept:edit'
FROM sys_menu WHERE path = 'dept' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '部门删除', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'system:dept:remove'
FROM sys_menu WHERE path = 'dept' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 13.5 岗位管理按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '岗位查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'system:post:query'
FROM sys_menu WHERE path = 'post' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '岗位新增', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'system:post:add'
FROM sys_menu WHERE path = 'post' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '岗位修改', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'system:post:edit'
FROM sys_menu WHERE path = 'post' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '岗位删除', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'system:post:remove'
FROM sys_menu WHERE path = 'post' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 13.6 字典管理按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '字典查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'system:dict:query'
FROM sys_menu WHERE path = 'dict' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '字典新增', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'system:dict:add'
FROM sys_menu WHERE path = 'dict' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '字典修改', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'system:dict:edit'
FROM sys_menu WHERE path = 'dict' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '字典删除', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'system:dict:remove'
FROM sys_menu WHERE path = 'dict' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 13.7 参数设置按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '参数查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'system:config:query'
FROM sys_menu WHERE path = 'config' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '参数新增', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'system:config:add'
FROM sys_menu WHERE path = 'config' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '参数修改', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'system:config:edit'
FROM sys_menu WHERE path = 'config' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '参数删除', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'system:config:remove'
FROM sys_menu WHERE path = 'config' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 13.8 通知公告按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '公告查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'system:notice:query'
FROM sys_menu WHERE path = 'notice' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '公告新增', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'system:notice:add'
FROM sys_menu WHERE path = 'notice' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '公告修改', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'system:notice:edit'
FROM sys_menu WHERE path = 'notice' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '公告删除', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'system:notice:remove'
FROM sys_menu WHERE path = 'notice' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 13.9 定时任务按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '任务查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'monitor:job:query'
FROM sys_menu WHERE path = 'job' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '任务新增', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'monitor:job:add'
FROM sys_menu WHERE path = 'job' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '任务修改', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'monitor:job:edit'
FROM sys_menu WHERE path = 'job' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '任务删除', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'monitor:job:remove'
FROM sys_menu WHERE path = 'job' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '状态变更', '', '', 5, 'F', '1', '0', '#', 1, menu_id, 'monitor:job:changeStatus'
FROM sys_menu WHERE path = 'job' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 13.10 缓存监控按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '清理指定', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'monitor:cache:clearName'
FROM sys_menu WHERE path = 'cache' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '清理全部', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'monitor:cache:clearAll'
FROM sys_menu WHERE path = 'cache' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 13.11 在线用户按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '强退用户', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'monitor:online:forceLogout'
FROM sys_menu WHERE path = 'online' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 13.12 操作日志按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '日志删除', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'monitor:operlog:remove'
FROM sys_menu WHERE path = 'operlog' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 13.13 登录日志按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '日志删除', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'monitor:logininfor:remove'
FROM sys_menu WHERE path = 'logininfor' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;


-- 14. 为不同角色分配菜单权限
-- 14.1 超级管理员 - 拥有所有权限
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT r.role_id, m.menu_id
FROM sys_role r, sys_menu m
WHERE r.role_key = 'admin' AND r.del_flag = '0'
ON CONFLICT DO NOTHING;

-- 14.2 系统管理员 - 拥有系统管理模块的所有权限
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT r.role_id, m.menu_id
FROM sys_role r, sys_menu m
WHERE r.role_key = 'system_admin' AND r.del_flag = '0'
  AND (
    -- 系统管理目录
    (m.path = 'system' AND m.parent_id IS NULL)
    -- 系统管理下的所有菜单和按钮
    OR m.parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
    OR m.parent_id IN (
      SELECT menu_id FROM sys_menu 
      WHERE parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
    )
  )
ON CONFLICT DO NOTHING;

-- 14.3 监控管理员 - 拥有系统监控模块的所有权限
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT r.role_id, m.menu_id
FROM sys_role r, sys_menu m
WHERE r.role_key = 'monitor_admin' AND r.del_flag = '0'
  AND (
    -- 系统监控目录
    (m.path = 'monitor' AND m.parent_id IS NULL)
    -- 系统监控下的所有菜单和按钮
    OR m.parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
    OR m.parent_id IN (
      SELECT menu_id FROM sys_menu 
      WHERE parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
    )
    -- 系统工具(接口文档)
    OR (m.path = 'tool' AND m.parent_id IS NULL)
    OR m.path = 'swagger'
  )
ON CONFLICT DO NOTHING;

-- 14.4 普通用户 - 只有查看权限,无增删改权限
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT r.role_id, m.menu_id
FROM sys_role r, sys_menu m
WHERE r.role_key = 'common_user' AND r.del_flag = '0'
  AND (
    -- 系统管理目录(只读)
    (m.path = 'system' AND m.parent_id IS NULL)
    -- 系统管理下的菜单(不包括按钮)
    OR (m.parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL) AND m.menu_type = 'C')
    -- 系统监控目录(只读)
    OR (m.path = 'monitor' AND m.parent_id IS NULL)
    -- 系统监控下的菜单(不包括按钮)
    OR (m.parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL) AND m.menu_type = 'C')
  )
ON CONFLICT DO NOTHING;


-- 15. 任务日志样例
INSERT INTO sys_job_log (job_name, job_group, invoke_target, job_message, status, exception_info, create_time)
VALUES 
  ('示例任务', 'DEFAULT', 'log:示例任务执行成功', '执行成功', '0', '', NOW()),
  ('示例任务', 'DEFAULT', 'log:示例任务执行成功', '执行失败：模拟异常', '1', 'MockError: something wrong', NOW())
ON CONFLICT DO NOTHING;


-- 16. 登录日志样例
INSERT INTO sys_login_log (user_name, ipaddr, browser, os, status, msg, login_time)
VALUES 
  ('admin', '127.0.0.1', 'Chrome', 'macOS', '0', '登录成功', NOW()),
  ('user', '127.0.0.1', 'Chrome', 'macOS', '1', '密码错误', NOW())
ON CONFLICT DO NOTHING;


-- 17. 操作日志样例
INSERT INTO sys_oper_log (title, business_type, method, request_method, oper_name, dept_name, oper_url, oper_ip, oper_location, oper_param, json_result, status, oper_time)
VALUES 
  ('部门管理', 1, 'DeptController.create', 'POST', 'admin', '总公司', '/system/dept', '127.0.0.1', '内网', '{"deptName":"技术部"}', '{"code":200}', 0, NOW()),
  ('岗位管理', 3, 'PostController.remove', 'DELETE', 'admin', '总公司', '/system/post', '127.0.0.1', '内网', '{"ids":"1,2"}', '{"code":200}', 0, NOW())
ON CONFLICT DO NOTHING;


-- 提示信息
DO $$
DECLARE
  menu_count INTEGER;
  role_menu_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO menu_count FROM sys_menu;
  SELECT COUNT(*) INTO role_menu_count FROM sys_role_menu WHERE role_id = (SELECT role_id FROM sys_role WHERE role_key = 'admin' AND del_flag = '0');
  
  RAISE NOTICE '==============================================';
  RAISE NOTICE '初始化数据导入完成！';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '默认账号(密码均为 admin123)：';
  RAISE NOTICE '- admin - 超级管理员';
  RAISE NOTICE '- system_admin - 系统管理员';
  RAISE NOTICE '- monitor_admin - 监控管理员';
  RAISE NOTICE '- user - 普通用户';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '数据统计：';
  RAISE NOTICE '- 部门：9 个';
  RAISE NOTICE '- 角色：4 个(全部启用)';
  RAISE NOTICE '- 用户：4 个';
  RAISE NOTICE '  * admin - 超级管理员(所有权限)';
  RAISE NOTICE '  * system_admin - 系统管理员(系统管理模块)';
  RAISE NOTICE '  * monitor_admin - 监控管理员(系统监控模块)';
  RAISE NOTICE '  * user - 普通用户(只读权限)';
  RAISE NOTICE '- 岗位：2 个';
  RAISE NOTICE '- 菜单：% 个', menu_count;
  RAISE NOTICE '- 超级管理员权限：% 个菜单', role_menu_count;
  RAISE NOTICE '- 字典类型：10 个';
  RAISE NOTICE '- 字典数据：29 条';
  RAISE NOTICE '- 系统配置：27 条';
  RAISE NOTICE '- 任务日志样例：2 条';
  RAISE NOTICE '- 登录日志样例：2 条';
  RAISE NOTICE '- 操作日志样例：2 条';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '注意事项：';
  RAISE NOTICE '1. 生产环境请立即修改默认密码';
  RAISE NOTICE '2. 本脚本与 Prisma seed.ts 保持完全一致';
  RAISE NOTICE '3. 可重复执行，使用 ON CONFLICT DO NOTHING';
  RAISE NOTICE '==============================================';
END $$;


-- =============================================
-- 补充缺失的按钮权限
-- =============================================

-- 操作日志按钮补充
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '日志查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'monitor:operlog:query'
FROM sys_menu WHERE path = 'operlog' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '日志导出', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'monitor:operlog:export'
FROM sys_menu WHERE path = 'operlog' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '日志清空', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'monitor:operlog:clear'
FROM sys_menu WHERE path = 'operlog' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 登录日志按钮补充
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '日志查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'monitor:logininfor:query'
FROM sys_menu WHERE path = 'logininfor' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '日志导出', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'monitor:logininfor:export'
FROM sys_menu WHERE path = 'logininfor' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '日志清空', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'monitor:logininfor:clear'
FROM sys_menu WHERE path = 'logininfor' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '账户解锁', '', '', 5, 'F', '1', '0', '#', 1, menu_id, 'monitor:logininfor:unlock'
FROM sys_menu WHERE path = 'logininfor' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 在线用户按钮补充
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '用户查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'monitor:online:query'
FROM sys_menu WHERE path = 'online' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 定时任务按钮补充
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '立即执行', '', '', 6, 'F', '1', '0', '#', 1, menu_id, 'monitor:job:run'
FROM sys_menu WHERE path = 'job' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '查看日志', '', '', 7, 'F', '1', '0', '#', 1, menu_id, 'monitor:job:log'
FROM sys_menu WHERE path = 'job' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'monitor' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 系统设置按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '设置修改', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'system:setting:edit'
FROM sys_menu WHERE path = 'setting' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'system' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 为超级管理员分配新增的按钮权限
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT r.role_id, m.menu_id
FROM sys_role r, sys_menu m
WHERE r.role_key = 'admin' AND r.del_flag = '0'
  AND m.menu_id NOT IN (SELECT menu_id FROM sys_role_menu WHERE role_id = r.role_id)
ON CONFLICT DO NOTHING;

-- 为监控管理员分配新增的监控模块按钮权限
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT r.role_id, m.menu_id
FROM sys_role r, sys_menu m
WHERE r.role_key = 'monitor_admin' AND r.del_flag = '0'
  AND m.perms LIKE 'monitor:%'
  AND m.menu_id NOT IN (SELECT menu_id FROM sys_role_menu WHERE role_id = r.role_id)
ON CONFLICT DO NOTHING;

-- =============================================
-- 寻印管理模块初始数据
-- 说明：与 Prisma seed.ts 保持同步
-- 同步日期：2025-12-29
-- =============================================

-- 18. 寻印管理菜单
-- 18.1 寻印管理目录
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
VALUES ('寻印管理', 'xunyin', 'Layout', 1, 'M', '0', '0', 'map-pin', 1, NULL, NULL)
ON CONFLICT DO NOTHING;

-- 18.2 寻印管理子菜单
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '城市管理', 'city', 'xunyin/city/index', 1, 'C', '0', '0', 'building', 1, menu_id, 'xunyin:city:list'
FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '文化之旅管理', 'journey', 'xunyin/journey/index', 2, 'C', '0', '0', 'route', 1, menu_id, 'xunyin:journey:list'
FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '探索点管理', 'point', 'xunyin/point/index', 3, 'C', '0', '0', 'map-pin-check', 1, menu_id, 'xunyin:point:list'
FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '印记管理', 'seal', 'xunyin/seal/index', 4, 'C', '0', '0', 'stamp', 1, menu_id, 'xunyin:seal:list'
FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT 'App用户管理', 'appuser', 'xunyin/appuser/index', 5, 'C', '0', '0', 'user-circle', 1, menu_id, 'xunyin:appuser:list'
FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '用户进度', 'progress', 'xunyin/progress/index', 6, 'C', '0', '0', 'list-checks', 1, menu_id, 'xunyin:progress:list'
FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '用户印记', 'user-seal', 'xunyin/user-seal/index', 7, 'C', '0', '0', 'award', 1, menu_id, 'xunyin:userseal:list'
FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '数据统计', 'stats', 'xunyin/dashboard/index', 8, 'C', '0', '0', 'chart-bar', 1, menu_id, 'xunyin:stats:view'
FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL
ON CONFLICT DO NOTHING;

-- 18.3 城市管理按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '城市查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'xunyin:city:query'
FROM sys_menu WHERE path = 'city' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '城市新增', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'xunyin:city:add'
FROM sys_menu WHERE path = 'city' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '城市修改', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'xunyin:city:edit'
FROM sys_menu WHERE path = 'city' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '城市删除', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'xunyin:city:remove'
FROM sys_menu WHERE path = 'city' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 18.4 文化之旅管理按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '文化之旅查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'xunyin:journey:query'
FROM sys_menu WHERE path = 'journey' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '文化之旅新增', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'xunyin:journey:add'
FROM sys_menu WHERE path = 'journey' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '文化之旅修改', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'xunyin:journey:edit'
FROM sys_menu WHERE path = 'journey' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '文化之旅删除', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'xunyin:journey:remove'
FROM sys_menu WHERE path = 'journey' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 18.5 探索点管理按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '探索点查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'xunyin:point:query'
FROM sys_menu WHERE path = 'point' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '探索点新增', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'xunyin:point:add'
FROM sys_menu WHERE path = 'point' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '探索点修改', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'xunyin:point:edit'
FROM sys_menu WHERE path = 'point' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '探索点删除', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'xunyin:point:remove'
FROM sys_menu WHERE path = 'point' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 18.6 印记管理按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '印记查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'xunyin:seal:query'
FROM sys_menu WHERE path = 'seal' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '印记新增', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'xunyin:seal:add'
FROM sys_menu WHERE path = 'seal' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '印记修改', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'xunyin:seal:edit'
FROM sys_menu WHERE path = 'seal' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '印记删除', '', '', 4, 'F', '1', '0', '#', 1, menu_id, 'xunyin:seal:remove'
FROM sys_menu WHERE path = 'seal' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 18.7 App用户管理按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT 'App用户查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'xunyin:appuser:query'
FROM sys_menu WHERE path = 'appuser' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT 'App用户修改', '', '', 2, 'F', '1', '0', '#', 1, menu_id, 'xunyin:appuser:edit'
FROM sys_menu WHERE path = 'appuser' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT 'App用户禁用', '', '', 3, 'F', '1', '0', '#', 1, menu_id, 'xunyin:appuser:disable'
FROM sys_menu WHERE path = 'appuser' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 18.8 用户进度按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '用户进度查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'xunyin:progress:query'
FROM sys_menu WHERE path = 'progress' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 18.9 用户印记按钮
INSERT INTO sys_menu (menu_name, path, component, order_num, menu_type, visible, status, icon, is_frame, parent_id, perms)
SELECT '用户印记查询', '', '', 1, 'F', '1', '0', '#', 1, menu_id, 'xunyin:userseal:query'
FROM sys_menu WHERE path = 'user-seal' AND parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
ON CONFLICT DO NOTHING;

-- 18.10 为超级管理员分配寻印管理权限
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT r.role_id, m.menu_id
FROM sys_role r, sys_menu m
WHERE r.role_key = 'admin' AND r.del_flag = '0'
  AND (
    (m.path = 'xunyin' AND m.parent_id IS NULL)
    OR m.parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
    OR m.parent_id IN (
      SELECT menu_id FROM sys_menu 
      WHERE parent_id = (SELECT menu_id FROM sys_menu WHERE path = 'xunyin' AND parent_id IS NULL)
    )
  )
ON CONFLICT DO NOTHING;


-- 19. 寻印业务字典
-- 19.1 字典类型
INSERT INTO sys_dict_type (dict_name, dict_type, status, create_time)
VALUES
  ('任务类型', 'xunyin_task_type', '0', NOW()),
  ('印记类型', 'xunyin_seal_type', '0', NOW()),
  ('进度状态', 'xunyin_progress_status', '0', NOW()),
  ('动态类型', 'xunyin_activity_type', '0', NOW()),
  ('音频场景', 'xunyin_audio_context', '0', NOW()),
  ('登录方式', 'xunyin_login_type', '0', NOW()),
  ('性别', 'xunyin_gender', '0', NOW()),
  ('照片滤镜', 'xunyin_photo_filter', '0', NOW()),
  ('区块链', 'xunyin_chain_name', '0', NOW()),
  ('实名认证状态', 'xunyin_verification_status', '0', NOW())
ON CONFLICT (dict_type) DO NOTHING;

-- 19.2 字典数据
INSERT INTO sys_dict_data (dict_type, dict_label, dict_value, dict_sort, status, is_default, create_time)
VALUES
  -- 任务类型
  ('xunyin_task_type', '手势识别', 'gesture', 1, '0', 'N', NOW()),
  ('xunyin_task_type', '拍照探索', 'photo', 2, '0', 'N', NOW()),
  ('xunyin_task_type', 'AR寻宝', 'treasure', 3, '0', 'N', NOW()),
  -- 印记类型
  ('xunyin_seal_type', '路线印记', 'route', 1, '0', 'N', NOW()),
  ('xunyin_seal_type', '城市印记', 'city', 2, '0', 'N', NOW()),
  ('xunyin_seal_type', '特殊印记', 'special', 3, '0', 'N', NOW()),
  -- 进度状态
  ('xunyin_progress_status', '进行中', 'in_progress', 1, '0', 'Y', NOW()),
  ('xunyin_progress_status', '已完成', 'completed', 2, '0', 'N', NOW()),
  ('xunyin_progress_status', '已放弃', 'abandoned', 3, '0', 'N', NOW()),
  -- 动态类型
  ('xunyin_activity_type', '获得印记', 'seal_earned', 1, '0', 'N', NOW()),
  ('xunyin_activity_type', '完成文化之旅', 'journey_completed', 2, '0', 'N', NOW()),
  ('xunyin_activity_type', '开始文化之旅', 'journey_started', 3, '0', 'N', NOW()),
  ('xunyin_activity_type', '完成探索点', 'point_completed', 4, '0', 'N', NOW()),
  ('xunyin_activity_type', '升级', 'level_up', 5, '0', 'N', NOW()),
  ('xunyin_activity_type', '获得称号', 'badge_earned', 6, '0', 'N', NOW()),
  -- 音频场景
  ('xunyin_audio_context', '首页', 'home', 1, '0', 'N', NOW()),
  ('xunyin_audio_context', '城市', 'city', 2, '0', 'N', NOW()),
  ('xunyin_audio_context', '文化之旅', 'journey', 3, '0', 'N', NOW()),
  ('xunyin_audio_context', '探索点', 'point', 4, '0', 'N', NOW()),
  -- 登录方式
  ('xunyin_login_type', '微信登录', 'wechat', 1, '0', 'Y', NOW()),
  ('xunyin_login_type', '邮箱登录', 'email', 2, '0', 'N', NOW()),
  ('xunyin_login_type', 'Google登录', 'google', 3, '0', 'N', NOW()),
  ('xunyin_login_type', 'Apple登录', 'apple', 4, '0', 'N', NOW()),
  -- 性别
  ('xunyin_gender', '男', '0', 1, '0', 'N', NOW()),
  ('xunyin_gender', '女', '1', 2, '0', 'N', NOW()),
  ('xunyin_gender', '未知', '2', 3, '0', 'Y', NOW()),
  -- 照片滤镜
  ('xunyin_photo_filter', '原图', 'original', 1, '0', 'Y', NOW()),
  ('xunyin_photo_filter', '复古', 'vintage', 2, '0', 'N', NOW()),
  ('xunyin_photo_filter', '黑白', 'mono', 3, '0', 'N', NOW()),
  ('xunyin_photo_filter', '暖色', 'warm', 4, '0', 'N', NOW()),
  ('xunyin_photo_filter', '冷色', 'cool', 5, '0', 'N', NOW()),
  ('xunyin_photo_filter', '胶片', 'film', 6, '0', 'N', NOW()),
  -- 区块链
  ('xunyin_chain_name', '蚂蚁链', 'antchain', 1, '0', 'Y', NOW()),
  ('xunyin_chain_name', '长安链', 'chainmaker', 2, '0', 'N', NOW()),
  ('xunyin_chain_name', '至信链', 'zhixin', 3, '0', 'N', NOW()),
  -- 实名认证状态
  ('xunyin_verification_status', '待审核', 'pending', 1, '0', 'Y', NOW()),
  ('xunyin_verification_status', '已通过', 'approved', 2, '0', 'N', NOW()),
  ('xunyin_verification_status', '已拒绝', 'rejected', 3, '0', 'N', NOW())
ON CONFLICT DO NOTHING;


-- =============================================
-- 寻印业务初始数据
-- 说明：城市、文化之旅、探索点、印记、示例用户
-- 同步日期：2025-12-31
-- =============================================

-- 20. 城市数据
INSERT INTO city (name, province, latitude, longitude, description, cover_image, explorer_count, order_num, status, create_time)
VALUES 
  ('杭州', '浙江省', 30.2741, 120.1551, '杭州，简称"杭"，是浙江省省会，素有"人间天堂"的美誉。西湖、灵隐寺、雷峰塔等名胜古迹闻名遐迩。', '', 0, 1, '0', NOW()),
  ('苏州', '江苏省', 31.2989, 120.5853, '苏州，古称姑苏，是江苏省地级市。以园林著称，拙政园、留园等被列入世界文化遗产。', '', 0, 2, '0', NOW()),
  ('南京', '江苏省', 32.0603, 118.7969, '南京，简称"宁"，是江苏省省会，六朝古都，有着深厚的历史文化底蕴。', '', 0, 3, '0', NOW())
ON CONFLICT DO NOTHING;


-- 21. 文化之旅数据
-- 21.1 杭州 - 西湖十景探秘
INSERT INTO journey (city_id, name, theme, description, cover_image, rating, estimated_minutes, total_distance, completed_count, is_locked, order_num, status, create_time)
SELECT id, '西湖十景探秘', '自然风光', '漫步西湖，探寻苏堤春晓、断桥残雪等十大经典景观，感受"欲把西湖比西子"的诗意之美。', '', 3, 180, 8500, 0, false, 1, '0', NOW()
FROM city WHERE name = '杭州'
ON CONFLICT DO NOTHING;

-- 21.2 杭州 - 灵隐禅踪
INSERT INTO journey (city_id, name, theme, description, cover_image, rating, estimated_minutes, total_distance, completed_count, is_locked, order_num, status, create_time)
SELECT id, '灵隐禅踪', '佛教文化', '探访千年古刹灵隐寺，感受飞来峰石刻艺术，体验禅宗文化的深邃与宁静。', '', 4, 120, 3200, 0, false, 2, '0', NOW()
FROM city WHERE name = '杭州'
ON CONFLICT DO NOTHING;

-- 21.3 苏州 - 园林雅韵
INSERT INTO journey (city_id, name, theme, description, cover_image, rating, estimated_minutes, total_distance, completed_count, is_locked, order_num, status, create_time)
SELECT id, '园林雅韵', '古典园林', '游览拙政园、留园等世界文化遗产，领略"咫尺之内再造乾坤"的园林艺术。', '', 3, 150, 5000, 0, false, 1, '0', NOW()
FROM city WHERE name = '苏州'
ON CONFLICT DO NOTHING;


-- 22. 探索点数据
-- 22.1 西湖十景探秘 - 苏堤春晓
INSERT INTO exploration_point (journey_id, name, latitude, longitude, task_type, task_description, target_gesture, cultural_background, cultural_knowledge, distance_from_prev, points_reward, order_num, status, create_time)
SELECT j.id, '苏堤春晓', 30.2456, 120.1423, 'photo', '在苏堤上拍摄一张春日美景照片', NULL, 
  '苏堤是北宋诗人苏轼任杭州知州时主持修建的堤坝，全长2.8公里。', 
  '苏堤春晓是西湖十景之首，每到春天，堤上桃红柳绿，景色宜人。', 
  0, 100, 1, '0', NOW()
FROM journey j WHERE j.name = '西湖十景探秘'
ON CONFLICT DO NOTHING;

-- 22.2 西湖十景探秘 - 断桥残雪
INSERT INTO exploration_point (journey_id, name, latitude, longitude, task_type, task_description, target_gesture, cultural_background, cultural_knowledge, distance_from_prev, points_reward, order_num, status, create_time)
SELECT j.id, '断桥残雪', 30.2589, 120.1512, 'gesture', '在断桥上做出"白娘子"的经典手势', 'heart', 
  '断桥是白娘子与许仙相遇的地方，承载着美丽的爱情传说。', 
  '断桥并非断裂之桥，而是因冬日雪后，桥面阳面雪融，阴面雪残，远望似断非断。', 
  1000, 120, 2, '0', NOW()
FROM journey j WHERE j.name = '西湖十景探秘'
ON CONFLICT DO NOTHING;

-- 22.3 西湖十景探秘 - 雷峰夕照
INSERT INTO exploration_point (journey_id, name, latitude, longitude, task_type, task_description, target_gesture, cultural_background, cultural_knowledge, distance_from_prev, points_reward, order_num, status, create_time)
SELECT j.id, '雷峰夕照', 30.2312, 120.1489, 'photo', '拍摄雷峰塔的夕阳剪影', NULL, 
  '雷峰塔始建于公元977年，因白娘子传说而闻名。', 
  '原塔于1924年倒塌，现塔为2002年重建，塔内保存有原塔遗址。', 
  1200, 100, 3, '0', NOW()
FROM journey j WHERE j.name = '西湖十景探秘'
ON CONFLICT DO NOTHING;

-- 22.4 西湖十景探秘 - 三潭印月
INSERT INTO exploration_point (journey_id, name, latitude, longitude, task_type, task_description, target_gesture, cultural_background, cultural_knowledge, distance_from_prev, points_reward, order_num, status, create_time)
SELECT j.id, '三潭印月', 30.2378, 120.1398, 'treasure', '找到三潭印月的AR宝藏', NULL, 
  '三潭印月是西湖中最大的岛屿，岛上有"我心相印亭"等景点。', 
  '三座石塔建于明代，每逢中秋，塔中点燃灯烛，与明月倒影相映成趣。', 
  900, 150, 4, '0', NOW()
FROM journey j WHERE j.name = '西湖十景探秘'
ON CONFLICT DO NOTHING;

-- 22.5 灵隐禅踪 - 飞来峰
INSERT INTO exploration_point (journey_id, name, latitude, longitude, task_type, task_description, target_gesture, cultural_background, cultural_knowledge, distance_from_prev, points_reward, order_num, status, create_time)
SELECT j.id, '飞来峰', 30.2398, 120.0912, 'photo', '拍摄飞来峰石刻造像', NULL, 
  '飞来峰有五代至宋元时期的石刻造像470余尊，是中国南方石窟艺术的瑰宝。', 
  '相传此峰是从印度灵鹫山飞来，故名飞来峰。', 
  0, 100, 1, '0', NOW()
FROM journey j WHERE j.name = '灵隐禅踪'
ON CONFLICT DO NOTHING;

-- 22.6 灵隐禅踪 - 灵隐寺山门
INSERT INTO exploration_point (journey_id, name, latitude, longitude, task_type, task_description, target_gesture, cultural_background, cultural_knowledge, distance_from_prev, points_reward, order_num, status, create_time)
SELECT j.id, '灵隐寺山门', 30.2412, 120.0934, 'gesture', '双手合十，做出礼佛手势', 'namaste', 
  '灵隐寺始建于东晋咸和元年（326年），是中国佛教禅宗十大古刹之一。', 
  '寺名取"仙灵所隐"之意，历史上曾多次毁建。', 
  400, 120, 2, '0', NOW()
FROM journey j WHERE j.name = '灵隐禅踪'
ON CONFLICT DO NOTHING;

-- 22.7 灵隐禅踪 - 大雄宝殿
INSERT INTO exploration_point (journey_id, name, latitude, longitude, task_type, task_description, target_gesture, cultural_background, cultural_knowledge, distance_from_prev, points_reward, order_num, status, create_time)
SELECT j.id, '大雄宝殿', 30.2425, 120.0945, 'photo', '拍摄大雄宝殿全景', NULL, 
  '大雄宝殿内供奉释迦牟尼佛像，高24.8米，是中国最大的木雕坐式佛像之一。', 
  '殿内还有十八罗汉像，神态各异，栩栩如生。', 
  350, 100, 3, '0', NOW()
FROM journey j WHERE j.name = '灵隐禅踪'
ON CONFLICT DO NOTHING;


-- 23. 印记数据
-- 23.1 路线印记
INSERT INTO seal (type, name, image_asset, description, badge_title, journey_id, city_id, order_num, status, create_time)
SELECT 'route', '西湖探秘者', '', '完成西湖十景探秘路线，获得此印记', '西湖探秘者', j.id, NULL, 1, '0', NOW()
FROM journey j WHERE j.name = '西湖十景探秘'
ON CONFLICT DO NOTHING;

INSERT INTO seal (type, name, image_asset, description, badge_title, journey_id, city_id, order_num, status, create_time)
SELECT 'route', '禅心悟道', '', '完成灵隐禅踪路线，获得此印记', '禅心悟道', j.id, NULL, 2, '0', NOW()
FROM journey j WHERE j.name = '灵隐禅踪'
ON CONFLICT DO NOTHING;

INSERT INTO seal (type, name, image_asset, description, badge_title, journey_id, city_id, order_num, status, create_time)
SELECT 'route', '园林雅士', '', '完成园林雅韵路线，获得此印记', '园林雅士', j.id, NULL, 3, '0', NOW()
FROM journey j WHERE j.name = '园林雅韵'
ON CONFLICT DO NOTHING;

-- 23.2 城市印记
INSERT INTO seal (type, name, image_asset, description, badge_title, journey_id, city_id, order_num, status, create_time)
SELECT 'city', '杭州印记', '', '完成杭州所有文化之旅，获得城市印记', '杭州文化使者', NULL, c.id, 10, '0', NOW()
FROM city c WHERE c.name = '杭州'
ON CONFLICT DO NOTHING;

INSERT INTO seal (type, name, image_asset, description, badge_title, journey_id, city_id, order_num, status, create_time)
SELECT 'city', '苏州印记', '', '完成苏州所有文化之旅，获得城市印记', '苏州文化使者', NULL, c.id, 11, '0', NOW()
FROM city c WHERE c.name = '苏州'
ON CONFLICT DO NOTHING;

INSERT INTO seal (type, name, image_asset, description, badge_title, journey_id, city_id, order_num, status, create_time)
SELECT 'city', '南京印记', '', '完成南京所有文化之旅，获得城市印记', '南京文化使者', NULL, c.id, 12, '0', NOW()
FROM city c WHERE c.name = '南京'
ON CONFLICT DO NOTHING;

-- 23.3 特殊印记
INSERT INTO seal (type, name, image_asset, description, badge_title, journey_id, city_id, order_num, status, create_time)
VALUES ('special', '江南水乡', '', '完成杭州和苏州的所有路线，获得特殊印记', '江南水乡行者', NULL, NULL, 20, '0', NOW())
ON CONFLICT DO NOTHING;


-- 24. 示例 App 用户
INSERT INTO app_user (phone, nickname, avatar, login_type, total_points, status, create_time)
VALUES ('13800138000', '探索者小明', '', 'wechat', 520, '0', NOW())
ON CONFLICT DO NOTHING;

INSERT INTO app_user (phone, nickname, avatar, login_type, total_points, status, create_time)
VALUES ('13900139000', '文化行者', '', 'email', 320, '0', NOW())
ON CONFLICT DO NOTHING;

INSERT INTO app_user (phone, nickname, avatar, login_type, total_points, status, create_time)
VALUES ('13700137000', '印记收藏家', '', 'wechat', 850, '0', NOW())
ON CONFLICT DO NOTHING;


-- 24.1 用户实名认证数据
-- 用户1: 已通过认证
INSERT INTO user_verification (id, user_id, real_name, id_card_no, id_card_front, id_card_back, status, verified_at, create_time, update_time)
SELECT 
  'verification_demo_1',
  u.id,
  '张明',
  'ENCRYPTED_330102199001011234',
  '/uploads/idcard/front-demo1.jpg',
  '/uploads/idcard/back-demo1.jpg',
  'approved',
  '2025-01-08 10:00:00',
  NOW(),
  NOW()
FROM app_user u
WHERE u.phone = '13800138000'
ON CONFLICT DO NOTHING;

-- 同步更新用户1的 is_verified 状态
UPDATE app_user SET is_verified = TRUE WHERE phone = '13800138000';

-- 用户2: 待审核
INSERT INTO user_verification (id, user_id, real_name, id_card_no, id_card_front, id_card_back, status, create_time, update_time)
SELECT 
  'verification_demo_2',
  u.id,
  '李文化',
  'ENCRYPTED_350102199205052345',
  '/uploads/idcard/front-demo2.jpg',
  '/uploads/idcard/back-demo2.jpg',
  'pending',
  NOW(),
  NOW()
FROM app_user u
WHERE u.phone = '13900139000'
ON CONFLICT DO NOTHING;

-- 用户3: 已拒绝（照片模糊）
INSERT INTO user_verification (id, user_id, real_name, id_card_no, id_card_front, id_card_back, status, reject_reason, create_time, update_time)
SELECT 
  'verification_demo_3',
  u.id,
  '王收藏',
  'ENCRYPTED_330106198812123456',
  '/uploads/idcard/front-demo3.jpg',
  '/uploads/idcard/back-demo3.jpg',
  'rejected',
  '身份证照片模糊，请重新上传清晰照片',
  NOW(),
  NOW()
FROM app_user u
WHERE u.phone = '13700137000'
ON CONFLICT DO NOTHING;


-- 25. 用户进度数据
-- 用户1: 西湖十景探秘 - 已完成
INSERT INTO journey_progress (id, user_id, journey_id, status, start_time, complete_time, time_spent_minutes, create_time, update_time)
SELECT 
  'progress_demo_1',
  u.id,
  j.id,
  'completed',
  '2025-01-10 09:00:00',
  '2025-01-10 15:30:00',
  390,
  NOW(),
  NOW()
FROM app_user u, journey j
WHERE u.phone = '13800138000' AND j.name = '西湖十景探秘'
ON CONFLICT DO NOTHING;

-- 用户1: 灵隐禅踪 - 进行中
INSERT INTO journey_progress (id, user_id, journey_id, status, start_time, create_time, update_time)
SELECT 
  'progress_demo_2',
  u.id,
  j.id,
  'in_progress',
  '2025-01-15 10:00:00',
  NOW(),
  NOW()
FROM app_user u, journey j
WHERE u.phone = '13800138000' AND j.name = '灵隐禅踪'
ON CONFLICT DO NOTHING;

-- 用户2: 三坊七巷寻古 - 进行中
INSERT INTO journey_progress (id, user_id, journey_id, status, start_time, create_time, update_time)
SELECT 
  'progress_demo_3',
  u.id,
  j.id,
  'in_progress',
  '2025-01-12 14:00:00',
  NOW(),
  NOW()
FROM app_user u, journey j
WHERE u.phone = '13900139000' AND j.name = '三坊七巷寻古'
ON CONFLICT DO NOTHING;

-- 用户3: 西湖十景探秘 - 已完成
INSERT INTO journey_progress (id, user_id, journey_id, status, start_time, complete_time, time_spent_minutes, create_time, update_time)
SELECT 
  'progress_demo_4',
  u.id,
  j.id,
  'completed',
  '2025-01-05 08:00:00',
  '2025-01-05 14:00:00',
  360,
  NOW(),
  NOW()
FROM app_user u, journey j
WHERE u.phone = '13700137000' AND j.name = '西湖十景探秘'
ON CONFLICT DO NOTHING;

-- 用户3: 灵隐禅踪 - 已完成
INSERT INTO journey_progress (id, user_id, journey_id, status, start_time, complete_time, time_spent_minutes, create_time, update_time)
SELECT 
  'progress_demo_5',
  u.id,
  j.id,
  'completed',
  '2025-01-06 09:00:00',
  '2025-01-06 12:00:00',
  180,
  NOW(),
  NOW()
FROM app_user u, journey j
WHERE u.phone = '13700137000' AND j.name = '灵隐禅踪'
ON CONFLICT DO NOTHING;

-- 用户3: 三坊七巷寻古 - 进行中
INSERT INTO journey_progress (id, user_id, journey_id, status, start_time, create_time, update_time)
SELECT 
  'progress_demo_6',
  u.id,
  j.id,
  'in_progress',
  '2025-01-20 10:00:00',
  NOW(),
  NOW()
FROM app_user u, journey j
WHERE u.phone = '13700137000' AND j.name = '三坊七巷寻古'
ON CONFLICT DO NOTHING;


-- 25.1 探索点完成记录
-- 用户1: 西湖十景探秘 - 完成全部4个探索点
INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_1_1',
  'progress_demo_1',
  ep.id,
  '2025-01-10 10:30:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '西湖十景探秘' AND ep.name = '苏堤春晓'
ON CONFLICT DO NOTHING;

INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_1_2',
  'progress_demo_1',
  ep.id,
  '2025-01-10 12:00:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '西湖十景探秘' AND ep.name = '断桥残雪'
ON CONFLICT DO NOTHING;

INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_1_3',
  'progress_demo_1',
  ep.id,
  '2025-01-10 13:30:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '西湖十景探秘' AND ep.name = '雷峰夕照'
ON CONFLICT DO NOTHING;

INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_1_4',
  'progress_demo_1',
  ep.id,
  '2025-01-10 15:00:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '西湖十景探秘' AND ep.name = '三潭印月'
ON CONFLICT DO NOTHING;

-- 用户1: 灵隐禅踪 - 进行中，完成1个探索点
INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_2_1',
  'progress_demo_2',
  ep.id,
  '2025-01-15 10:30:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '灵隐禅踪' AND ep.name = '飞来峰'
ON CONFLICT DO NOTHING;

-- 用户2: 三坊七巷寻古 - 进行中，完成3个探索点
INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_3_1',
  'progress_demo_3',
  ep.id,
  '2025-01-12 14:45:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '三坊七巷寻古' AND ep.name = '南后街'
ON CONFLICT DO NOTHING;

INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_3_2',
  'progress_demo_3',
  ep.id,
  '2025-01-12 15:30:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '三坊七巷寻古' AND ep.name = '林则徐纪念馆'
ON CONFLICT DO NOTHING;

INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_3_3',
  'progress_demo_3',
  ep.id,
  '2025-01-12 16:15:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '三坊七巷寻古' AND ep.name = '严复故居'
ON CONFLICT DO NOTHING;

-- 用户3: 西湖十景探秘 - 完成全部4个探索点
INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_4_1',
  'progress_demo_4',
  ep.id,
  '2025-01-05 09:30:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '西湖十景探秘' AND ep.name = '苏堤春晓'
ON CONFLICT DO NOTHING;

INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_4_2',
  'progress_demo_4',
  ep.id,
  '2025-01-05 11:00:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '西湖十景探秘' AND ep.name = '断桥残雪'
ON CONFLICT DO NOTHING;

INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_4_3',
  'progress_demo_4',
  ep.id,
  '2025-01-05 12:30:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '西湖十景探秘' AND ep.name = '雷峰夕照'
ON CONFLICT DO NOTHING;

INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_4_4',
  'progress_demo_4',
  ep.id,
  '2025-01-05 14:00:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '西湖十景探秘' AND ep.name = '三潭印月'
ON CONFLICT DO NOTHING;

-- 用户3: 灵隐禅踪 - 完成全部3个探索点
INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_5_1',
  'progress_demo_5',
  ep.id,
  '2025-01-06 10:00:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '灵隐禅踪' AND ep.name = '飞来峰'
ON CONFLICT DO NOTHING;

INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_5_2',
  'progress_demo_5',
  ep.id,
  '2025-01-06 11:00:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '灵隐禅踪' AND ep.name = '灵隐寺山门'
ON CONFLICT DO NOTHING;

INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_5_3',
  'progress_demo_5',
  ep.id,
  '2025-01-06 12:00:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '灵隐禅踪' AND ep.name = '大雄宝殿'
ON CONFLICT DO NOTHING;

-- 用户3: 三坊七巷寻古 - 进行中，完成2个探索点
INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_6_1',
  'progress_demo_6',
  ep.id,
  '2025-01-20 10:45:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '三坊七巷寻古' AND ep.name = '南后街'
ON CONFLICT DO NOTHING;

INSERT INTO point_completion (id, progress_id, point_id, complete_time, points_earned, create_time)
SELECT 
  'pc_demo_6_2',
  'progress_demo_6',
  ep.id,
  '2025-01-20 11:30:00',
  ep.points_reward,
  NOW()
FROM exploration_point ep
JOIN journey j ON ep.journey_id = j.id
WHERE j.name = '三坊七巷寻古' AND ep.name = '林则徐纪念馆'
ON CONFLICT DO NOTHING;


-- 26. 用户印记数据
-- 用户1: 西湖探秘者印记 - 已上链
INSERT INTO user_seal (id, user_id, seal_id, earned_time, is_chained, chain_name, tx_hash, block_height, chain_time, create_time, update_time)
SELECT 
  'userseal_demo_1',
  u.id,
  s.id,
  '2025-01-10 15:30:00',
  true,
  'antchain',
  '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  10234567,
  '2025-01-10 16:00:00',
  NOW(),
  NOW()
FROM app_user u, seal s
WHERE u.phone = '13800138000' AND s.name = '西湖探秘者'
ON CONFLICT DO NOTHING;

-- 用户3: 西湖探秘者印记 - 已上链
INSERT INTO user_seal (id, user_id, seal_id, earned_time, is_chained, chain_name, tx_hash, block_height, chain_time, create_time, update_time)
SELECT 
  'userseal_demo_2',
  u.id,
  s.id,
  '2025-01-05 14:00:00',
  true,
  'antchain',
  '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
  10234123,
  '2025-01-05 14:30:00',
  NOW(),
  NOW()
FROM app_user u, seal s
WHERE u.phone = '13700137000' AND s.name = '西湖探秘者'
ON CONFLICT DO NOTHING;

-- 用户3: 禅心悟道印记 - 未上链
INSERT INTO user_seal (id, user_id, seal_id, earned_time, is_chained, create_time, update_time)
SELECT 
  'userseal_demo_3',
  u.id,
  s.id,
  '2025-01-06 12:00:00',
  false,
  NOW(),
  NOW()
FROM app_user u, seal s
WHERE u.phone = '13700137000' AND s.name = '禅心悟道'
ON CONFLICT DO NOTHING;

-- 用户3: 杭州城市印记 - 已上链
INSERT INTO user_seal (id, user_id, seal_id, earned_time, is_chained, chain_name, tx_hash, block_height, chain_time, create_time, update_time)
SELECT 
  'userseal_demo_4',
  u.id,
  s.id,
  '2025-01-06 12:30:00',
  true,
  'chainmaker',
  '0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
  10235000,
  '2025-01-06 13:00:00',
  NOW(),
  NOW()
FROM app_user u, seal s
WHERE u.phone = '13700137000' AND s.name = '杭州印记'
ON CONFLICT DO NOTHING;


-- 21. 初始化背景音乐数据
-- 注意：URL 为占位符，实际部署时需替换为真实音频文件地址

-- 首页默认背景音乐
INSERT INTO background_music (id, name, url, context, context_id, duration, order_num, status, create_time, update_time)
VALUES 
  ('bgm_home_1', '古韵悠然', '/audio/bgm/home-default.mp3', 'home', NULL, 180, 1, '0', NOW(), NOW()),
  ('bgm_home_2', '山水清音', '/audio/bgm/home-nature.mp3', 'home', NULL, 210, 2, '0', NOW(), NOW())
ON CONFLICT DO NOTHING;

-- 城市背景音乐
INSERT INTO background_music (id, name, url, context, context_id, duration, order_num, status, create_time, update_time)
SELECT 
  'bgm_city_hangzhou',
  '江南丝竹',
  '/audio/bgm/city-hangzhou.mp3',
  'city',
  c.id,
  240,
  1,
  '0',
  NOW(),
  NOW()
FROM city c WHERE c.name = '杭州'
ON CONFLICT DO NOTHING;

INSERT INTO background_music (id, name, url, context, context_id, duration, order_num, status, create_time, update_time)
SELECT 
  'bgm_city_suzhou',
  '姑苏雅韵',
  '/audio/bgm/city-suzhou.mp3',
  'city',
  c.id,
  220,
  1,
  '0',
  NOW(),
  NOW()
FROM city c WHERE c.name = '苏州'
ON CONFLICT DO NOTHING;

INSERT INTO background_music (id, name, url, context, context_id, duration, order_num, status, create_time, update_time)
SELECT 
  'bgm_city_nanjing',
  '金陵古调',
  '/audio/bgm/city-nanjing.mp3',
  'city',
  c.id,
  200,
  1,
  '0',
  NOW(),
  NOW()
FROM city c WHERE c.name = '南京'
ON CONFLICT DO NOTHING;

INSERT INTO background_music (id, name, url, context, context_id, duration, order_num, status, create_time, update_time)
SELECT 
  'bgm_city_fuzhou',
  '闽韵悠扬',
  '/audio/bgm/city-fuzhou.mp3',
  'city',
  c.id,
  230,
  1,
  '0',
  NOW(),
  NOW()
FROM city c WHERE c.name = '福州'
ON CONFLICT DO NOTHING;

-- 文化之旅背景音乐
INSERT INTO background_music (id, name, url, context, context_id, duration, order_num, status, create_time, update_time)
SELECT 
  'bgm_journey_westlake',
  '西湖春晓',
  '/audio/bgm/journey-westlake.mp3',
  'journey',
  j.id,
  300,
  1,
  '0',
  NOW(),
  NOW()
FROM journey j WHERE j.name = '西湖十景探秘'
ON CONFLICT DO NOTHING;

INSERT INTO background_music (id, name, url, context, context_id, duration, order_num, status, create_time, update_time)
SELECT 
  'bgm_journey_lingyin',
  '禅意空灵',
  '/audio/bgm/journey-lingyin.mp3',
  'journey',
  j.id,
  280,
  1,
  '0',
  NOW(),
  NOW()
FROM journey j WHERE j.name = '灵隐禅踪'
ON CONFLICT DO NOTHING;

INSERT INTO background_music (id, name, url, context, context_id, duration, order_num, status, create_time, update_time)
SELECT 
  'bgm_journey_sanfang',
  '坊巷古韵',
  '/audio/bgm/journey-sanfang.mp3',
  'journey',
  j.id,
  260,
  1,
  '0',
  NOW(),
  NOW()
FROM journey j WHERE j.name = '三坊七巷寻古'
ON CONFLICT DO NOTHING;

INSERT INTO background_music (id, name, url, context, context_id, duration, order_num, status, create_time, update_time)
SELECT 
  'bgm_journey_gushan',
  '鼓山梵音',
  '/audio/bgm/journey-gushan.mp3',
  'journey',
  j.id,
  290,
  1,
  '0',
  NOW(),
  NOW()
FROM journey j WHERE j.name = '鼓山禅意行'
ON CONFLICT DO NOTHING;

INSERT INTO background_music (id, name, url, context, context_id, duration, order_num, status, create_time, update_time)
SELECT 
  'bgm_journey_minjiang',
  '闽江夜曲',
  '/audio/bgm/journey-minjiang.mp3',
  'journey',
  j.id,
  250,
  1,
  '0',
  NOW(),
  NOW()
FROM journey j WHERE j.name = '闽江两岸'
ON CONFLICT DO NOTHING;


-- 22. 初始化探索照片测试数据
-- 用户1（探索者小明）的照片 - 西湖十景探秘
INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user1_westlake_1',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/westlake-duanqiao-1.jpg',
  '/uploads/photos/thumb/westlake-duanqiao-1.jpg',
  'vintage',
  30.2598,
  120.1485,
  '2025-01-10 09:30:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13800138000' AND j.name = '西湖十景探秘' AND p.name = '断桥残雪'
ON CONFLICT DO NOTHING;

INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user1_westlake_2',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/westlake-duanqiao-2.jpg',
  '/uploads/photos/thumb/westlake-duanqiao-2.jpg',
  'ink',
  30.2599,
  120.1486,
  '2025-01-10 09:45:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13800138000' AND j.name = '西湖十景探秘' AND p.name = '断桥残雪'
ON CONFLICT DO NOTHING;

INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user1_westlake_3',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/westlake-leifeng-1.jpg',
  '/uploads/photos/thumb/westlake-leifeng-1.jpg',
  'warm',
  30.2318,
  120.1489,
  '2025-01-10 11:20:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13800138000' AND j.name = '西湖十景探秘' AND p.name = '雷峰夕照'
ON CONFLICT DO NOTHING;

INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user1_westlake_4',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/westlake-santan-1.jpg',
  '/uploads/photos/thumb/westlake-santan-1.jpg',
  'classic',
  30.2398,
  120.1398,
  '2025-01-10 13:00:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13800138000' AND j.name = '西湖十景探秘' AND p.name = '三潭印月'
ON CONFLICT DO NOTHING;

-- 用户1（探索者小明）的照片 - 灵隐禅踪
INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user1_lingyin_1',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/lingyin-feilai-1.jpg',
  '/uploads/photos/thumb/lingyin-feilai-1.jpg',
  'zen',
  30.2398,
  120.0998,
  '2025-01-15 10:30:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13800138000' AND j.name = '灵隐禅踪' AND p.name = '飞来峰'
ON CONFLICT DO NOTHING;

-- 用户2（文化行者）的照片 - 三坊七巷寻古
INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user2_sanfang_1',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/sanfang-yijin-1.jpg',
  '/uploads/photos/thumb/sanfang-yijin-1.jpg',
  'retro',
  26.0898,
  119.2998,
  '2025-01-12 14:30:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13900139000' AND j.name = '三坊七巷寻古' AND p.name = '衣锦坊'
ON CONFLICT DO NOTHING;

INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user2_sanfang_2',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/sanfang-linzexu-1.jpg',
  '/uploads/photos/thumb/sanfang-linzexu-1.jpg',
  'classic',
  26.0878,
  119.2988,
  '2025-01-12 15:15:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13900139000' AND j.name = '三坊七巷寻古' AND p.name = '林则徐纪念馆'
ON CONFLICT DO NOTHING;

-- 用户3（印记收藏家）的照片 - 西湖十景探秘
INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user3_westlake_1',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/westlake-duanqiao-user3-1.jpg',
  '/uploads/photos/thumb/westlake-duanqiao-user3-1.jpg',
  'ink',
  30.2597,
  120.1484,
  '2025-01-05 08:45:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13700137000' AND j.name = '西湖十景探秘' AND p.name = '断桥残雪'
ON CONFLICT DO NOTHING;

INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user3_westlake_2',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/westlake-leifeng-user3-1.jpg',
  '/uploads/photos/thumb/westlake-leifeng-user3-1.jpg',
  'vintage',
  30.2319,
  120.1490,
  '2025-01-05 10:30:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13700137000' AND j.name = '西湖十景探秘' AND p.name = '雷峰夕照'
ON CONFLICT DO NOTHING;

INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user3_westlake_3',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/westlake-santan-user3-1.jpg',
  '/uploads/photos/thumb/westlake-santan-user3-1.jpg',
  'warm',
  30.2399,
  120.1399,
  '2025-01-05 12:00:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13700137000' AND j.name = '西湖十景探秘' AND p.name = '三潭印月'
ON CONFLICT DO NOTHING;

INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user3_westlake_4',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/westlake-huagang-user3-1.jpg',
  '/uploads/photos/thumb/westlake-huagang-user3-1.jpg',
  'classic',
  30.2358,
  120.1358,
  '2025-01-05 13:30:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13700137000' AND j.name = '西湖十景探秘' AND p.name = '花港观鱼'
ON CONFLICT DO NOTHING;

-- 用户3（印记收藏家）的照片 - 灵隐禅踪
INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user3_lingyin_1',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/lingyin-feilai-user3-1.jpg',
  '/uploads/photos/thumb/lingyin-feilai-user3-1.jpg',
  'zen',
  30.2399,
  120.0999,
  '2025-01-06 09:30:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13700137000' AND j.name = '灵隐禅踪' AND p.name = '飞来峰'
ON CONFLICT DO NOTHING;

INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user3_lingyin_2',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/lingyin-temple-user3-1.jpg',
  '/uploads/photos/thumb/lingyin-temple-user3-1.jpg',
  'ink',
  30.2378,
  120.0978,
  '2025-01-06 10:30:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13700137000' AND j.name = '灵隐禅踪' AND p.name = '灵隐寺'
ON CONFLICT DO NOTHING;

INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user3_lingyin_3',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/lingyin-yongfu-user3-1.jpg',
  '/uploads/photos/thumb/lingyin-yongfu-user3-1.jpg',
  'vintage',
  30.2358,
  120.0958,
  '2025-01-06 11:30:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13700137000' AND j.name = '灵隐禅踪' AND p.name = '永福禅寺'
ON CONFLICT DO NOTHING;

-- 用户3（印记收藏家）的照片 - 三坊七巷寻古
INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user3_sanfang_1',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/sanfang-yijin-user3-1.jpg',
  '/uploads/photos/thumb/sanfang-yijin-user3-1.jpg',
  'retro',
  26.0899,
  119.2999,
  '2025-01-20 10:30:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13700137000' AND j.name = '三坊七巷寻古' AND p.name = '衣锦坊'
ON CONFLICT DO NOTHING;

INSERT INTO exploration_photo (id, user_id, journey_id, point_id, photo_url, thumbnail_url, filter, latitude, longitude, taken_time, create_time)
SELECT 
  'photo_user3_sanfang_2',
  u.id,
  j.id,
  p.id,
  '/uploads/photos/sanfang-linzexu-user3-1.jpg',
  '/uploads/photos/thumb/sanfang-linzexu-user3-1.jpg',
  'classic',
  26.0879,
  119.2989,
  '2025-01-20 11:15:00',
  NOW()
FROM app_user u, journey j, exploration_point p
WHERE u.phone = '13700137000' AND j.name = '三坊七巷寻古' AND p.name = '林则徐纪念馆'
ON CONFLICT DO NOTHING;


-- 提示信息（更新）
DO $
DECLARE
  city_count INTEGER;
  journey_count INTEGER;
  point_count INTEGER;
  seal_count INTEGER;
  appuser_count INTEGER;
  progress_count INTEGER;
  userseal_count INTEGER;
  completion_count INTEGER;
  bgm_count INTEGER;
  photo_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO city_count FROM city;
  SELECT COUNT(*) INTO journey_count FROM journey;
  SELECT COUNT(*) INTO point_count FROM exploration_point;
  SELECT COUNT(*) INTO seal_count FROM seal;
  SELECT COUNT(*) INTO appuser_count FROM app_user;
  SELECT COUNT(*) INTO progress_count FROM journey_progress;
  SELECT COUNT(*) INTO userseal_count FROM user_seal;
  SELECT COUNT(*) INTO completion_count FROM point_completion;
  SELECT COUNT(*) INTO bgm_count FROM background_music;
  SELECT COUNT(*) INTO photo_count FROM exploration_photo;
  
  RAISE NOTICE '==============================================';
  RAISE NOTICE '寻印业务数据导入完成！';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '业务数据统计：';
  RAISE NOTICE '- 城市：% 个', city_count;
  RAISE NOTICE '- 文化之旅：% 条', journey_count;
  RAISE NOTICE '- 探索点：% 个', point_count;
  RAISE NOTICE '- 印记：% 个', seal_count;
  RAISE NOTICE '- App用户：% 个', appuser_count;
  RAISE NOTICE '- 用户进度：% 条', progress_count;
  RAISE NOTICE '- 探索点完成：% 条', completion_count;
  RAISE NOTICE '- 用户印记：% 个', userseal_count;
  RAISE NOTICE '- 背景音乐：% 条', bgm_count;
  RAISE NOTICE '- 探索照片：% 张', photo_count;
  RAISE NOTICE '==============================================';
END $;
