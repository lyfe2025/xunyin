-- =============================================
-- RBAC Admin Pro - 数据库表结构
-- 说明：本脚本用于创建系统表结构和索引
-- 特性：支持幂等执行（可重复运行）
-- =============================================

-- ----------------------------
-- 1. 部门表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_dept (
  dept_id BIGSERIAL PRIMARY KEY,
  parent_id BIGINT,
  ancestors VARCHAR(500) DEFAULT '',
  dept_name VARCHAR(50) NOT NULL,
  order_num INT DEFAULT 0,
  leader VARCHAR(20),
  phone VARCHAR(11),
  email VARCHAR(50),
  status CHAR(1) DEFAULT '0',
  del_flag CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP
);
COMMENT ON TABLE sys_dept IS '部门表';
COMMENT ON COLUMN sys_dept.dept_id IS '部门ID';
COMMENT ON COLUMN sys_dept.parent_id IS '父部门ID';
COMMENT ON COLUMN sys_dept.ancestors IS '祖级列表';
COMMENT ON COLUMN sys_dept.dept_name IS '部门名称';
COMMENT ON COLUMN sys_dept.order_num IS '显示顺序';
COMMENT ON COLUMN sys_dept.leader IS '负责人';
COMMENT ON COLUMN sys_dept.phone IS '联系电话';
COMMENT ON COLUMN sys_dept.email IS '邮箱';
COMMENT ON COLUMN sys_dept.status IS '部门状态（0正常 1停用）';
COMMENT ON COLUMN sys_dept.del_flag IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN sys_dept.create_by IS '创建者';
COMMENT ON COLUMN sys_dept.create_time IS '创建时间';
COMMENT ON COLUMN sys_dept.update_by IS '更新者';
COMMENT ON COLUMN sys_dept.update_time IS '更新时间';

-- ----------------------------
-- 2. 用户表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_user (
  user_id BIGSERIAL PRIMARY KEY,
  dept_id BIGINT,
  user_name VARCHAR(30) NOT NULL,
  nick_name VARCHAR(30) NOT NULL,
  user_type VARCHAR(2) DEFAULT '00',
  email VARCHAR(50) DEFAULT '',
  phonenumber VARCHAR(11) DEFAULT '',
  sex CHAR(1) DEFAULT '0',
  avatar VARCHAR(100) DEFAULT '',
  password VARCHAR(100) DEFAULT '',
  status CHAR(1) DEFAULT '0',
  del_flag CHAR(1) DEFAULT '0',
  login_ip VARCHAR(128) DEFAULT '',
  login_date TIMESTAMP,
  two_factor_secret VARCHAR(100),
  two_factor_enabled BOOLEAN DEFAULT FALSE,
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP,
  remark VARCHAR(500)
);
COMMENT ON TABLE sys_user IS '用户信息表';
COMMENT ON COLUMN sys_user.user_id IS '用户ID';
COMMENT ON COLUMN sys_user.dept_id IS '部门ID';
COMMENT ON COLUMN sys_user.user_name IS '用户账号';
COMMENT ON COLUMN sys_user.nick_name IS '用户昵称';
COMMENT ON COLUMN sys_user.user_type IS '用户类型（00系统用户）';
COMMENT ON COLUMN sys_user.email IS '用户邮箱';
COMMENT ON COLUMN sys_user.phonenumber IS '手机号码';
COMMENT ON COLUMN sys_user.sex IS '用户性别（0男 1女 2未知）';
COMMENT ON COLUMN sys_user.avatar IS '头像地址';
COMMENT ON COLUMN sys_user.password IS '密码';
COMMENT ON COLUMN sys_user.status IS '帐号状态（0正常 1停用）';
COMMENT ON COLUMN sys_user.del_flag IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN sys_user.login_ip IS '最后登录IP';
COMMENT ON COLUMN sys_user.login_date IS '最后登录时间';
COMMENT ON COLUMN sys_user.two_factor_secret IS '两步验证密钥';
COMMENT ON COLUMN sys_user.two_factor_enabled IS '两步验证是否启用';
COMMENT ON COLUMN sys_user.create_by IS '创建者';
COMMENT ON COLUMN sys_user.create_time IS '创建时间';
COMMENT ON COLUMN sys_user.update_by IS '更新者';
COMMENT ON COLUMN sys_user.update_time IS '更新时间';
COMMENT ON COLUMN sys_user.remark IS '备注';

-- ----------------------------
-- 3. 岗位表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_post (
  post_id BIGSERIAL PRIMARY KEY,
  post_code VARCHAR(64) NOT NULL,
  post_name VARCHAR(50) NOT NULL,
  post_sort INT NOT NULL,
  status CHAR(1) NOT NULL,
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP,
  remark VARCHAR(500)
);
COMMENT ON TABLE sys_post IS '岗位信息表';
COMMENT ON COLUMN sys_post.post_id IS '岗位ID';
COMMENT ON COLUMN sys_post.post_code IS '岗位编码';
COMMENT ON COLUMN sys_post.post_name IS '岗位名称';
COMMENT ON COLUMN sys_post.post_sort IS '显示顺序';
COMMENT ON COLUMN sys_post.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN sys_post.create_by IS '创建者';
COMMENT ON COLUMN sys_post.create_time IS '创建时间';
COMMENT ON COLUMN sys_post.update_by IS '更新者';
COMMENT ON COLUMN sys_post.update_time IS '更新时间';
COMMENT ON COLUMN sys_post.remark IS '备注';

-- ----------------------------
-- 4. 角色表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_role (
  role_id BIGSERIAL PRIMARY KEY,
  role_name VARCHAR(30) NOT NULL,
  role_key VARCHAR(100) NOT NULL,
  role_sort INT NOT NULL,
  data_scope CHAR(1) DEFAULT '1',
  menu_check_strictly BOOLEAN DEFAULT TRUE,
  dept_check_strictly BOOLEAN DEFAULT TRUE,
  status CHAR(1) NOT NULL,
  del_flag CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP,
  remark VARCHAR(500)
);
COMMENT ON TABLE sys_role IS '角色信息表';
COMMENT ON COLUMN sys_role.role_id IS '角色ID';
COMMENT ON COLUMN sys_role.role_name IS '角色名称';
COMMENT ON COLUMN sys_role.role_key IS '角色权限字符串';
COMMENT ON COLUMN sys_role.role_sort IS '显示顺序';
COMMENT ON COLUMN sys_role.data_scope IS '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）';
COMMENT ON COLUMN sys_role.menu_check_strictly IS '菜单树选择项是否关联显示';
COMMENT ON COLUMN sys_role.dept_check_strictly IS '部门树选择项是否关联显示';
COMMENT ON COLUMN sys_role.status IS '角色状态（0正常 1停用）';
COMMENT ON COLUMN sys_role.del_flag IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN sys_role.create_by IS '创建者';
COMMENT ON COLUMN sys_role.create_time IS '创建时间';
COMMENT ON COLUMN sys_role.update_by IS '更新者';
COMMENT ON COLUMN sys_role.update_time IS '更新时间';
COMMENT ON COLUMN sys_role.remark IS '备注';

-- ----------------------------
-- 5. 菜单表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_menu (
  menu_id BIGSERIAL PRIMARY KEY,
  menu_name VARCHAR(50) NOT NULL,
  parent_id BIGINT,
  order_num INT DEFAULT 0,
  path VARCHAR(200) DEFAULT '',
  component VARCHAR(255),
  is_frame INT DEFAULT 1,
  is_cache INT DEFAULT 0,
  menu_type CHAR(1) DEFAULT '',
  visible CHAR(1) DEFAULT '0',
  status CHAR(1) DEFAULT '0',
  perms VARCHAR(100),
  icon VARCHAR(100) DEFAULT '#',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP,
  remark VARCHAR(500)
);
COMMENT ON TABLE sys_menu IS '菜单权限表';
COMMENT ON COLUMN sys_menu.menu_id IS '菜单ID';
COMMENT ON COLUMN sys_menu.menu_name IS '菜单名称';
COMMENT ON COLUMN sys_menu.parent_id IS '父菜单ID';
COMMENT ON COLUMN sys_menu.order_num IS '显示顺序';
COMMENT ON COLUMN sys_menu.path IS '路由地址';
COMMENT ON COLUMN sys_menu.component IS '组件路径';
COMMENT ON COLUMN sys_menu.is_frame IS '是否为外链（0是 1否）';
COMMENT ON COLUMN sys_menu.is_cache IS '是否缓存（0缓存 1不缓存）';
COMMENT ON COLUMN sys_menu.menu_type IS '菜单类型（M目录 C菜单 F按钮）';
COMMENT ON COLUMN sys_menu.visible IS '菜单状态（0显示 1隐藏）';
COMMENT ON COLUMN sys_menu.status IS '菜单状态（0正常 1停用）';
COMMENT ON COLUMN sys_menu.perms IS '权限标识';
COMMENT ON COLUMN sys_menu.icon IS '菜单图标';
COMMENT ON COLUMN sys_menu.create_by IS '创建者';
COMMENT ON COLUMN sys_menu.create_time IS '创建时间';
COMMENT ON COLUMN sys_menu.update_by IS '更新者';
COMMENT ON COLUMN sys_menu.update_time IS '更新时间';
COMMENT ON COLUMN sys_menu.remark IS '备注';

-- ----------------------------
-- 6. 用户和角色关联表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_user_role (
  user_id BIGINT NOT NULL,
  role_id BIGINT NOT NULL,
  PRIMARY KEY (user_id, role_id)
);
COMMENT ON TABLE sys_user_role IS '用户和角色关联表';
COMMENT ON COLUMN sys_user_role.user_id IS '用户ID';
COMMENT ON COLUMN sys_user_role.role_id IS '角色ID';

-- ----------------------------
-- 7. 角色和菜单关联表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_role_menu (
  role_id BIGINT NOT NULL,
  menu_id BIGINT NOT NULL,
  PRIMARY KEY (role_id, menu_id)
);
COMMENT ON TABLE sys_role_menu IS '角色和菜单关联表';
COMMENT ON COLUMN sys_role_menu.role_id IS '角色ID';
COMMENT ON COLUMN sys_role_menu.menu_id IS '菜单ID';

-- ----------------------------
-- 8. 角色和部门关联表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_role_dept (
  role_id BIGINT NOT NULL,
  dept_id BIGINT NOT NULL,
  PRIMARY KEY (role_id, dept_id)
);
COMMENT ON TABLE sys_role_dept IS '角色和部门关联表';
COMMENT ON COLUMN sys_role_dept.role_id IS '角色ID';
COMMENT ON COLUMN sys_role_dept.dept_id IS '部门ID';

-- ----------------------------
-- 9. 岗位和用户关联表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_user_post (
  user_id BIGINT NOT NULL,
  post_id BIGINT NOT NULL,
  PRIMARY KEY (user_id, post_id)
);
COMMENT ON TABLE sys_user_post IS '用户与岗位关联表';
COMMENT ON COLUMN sys_user_post.user_id IS '用户ID';
COMMENT ON COLUMN sys_user_post.post_id IS '岗位ID';

-- ----------------------------
-- 10. 操作日志记录
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_oper_log (
  oper_id BIGSERIAL PRIMARY KEY,
  title VARCHAR(50) DEFAULT '',
  business_type INT DEFAULT 0,
  method VARCHAR(100) DEFAULT '',
  request_method VARCHAR(10) DEFAULT '',
  operator_type INT DEFAULT 0,
  oper_name VARCHAR(50) DEFAULT '',
  dept_name VARCHAR(50) DEFAULT '',
  oper_url VARCHAR(255) DEFAULT '',
  oper_ip VARCHAR(128) DEFAULT '',
  oper_location VARCHAR(255) DEFAULT '',
  oper_param TEXT DEFAULT '',
  json_result TEXT DEFAULT '',
  status INT DEFAULT 0,
  error_msg TEXT DEFAULT '',
  oper_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE sys_oper_log IS '操作日志记录';
COMMENT ON COLUMN sys_oper_log.oper_id IS '日志主键';
COMMENT ON COLUMN sys_oper_log.title IS '模块标题';
COMMENT ON COLUMN sys_oper_log.business_type IS '业务类型（0其它 1新增 2修改 3删除）';
COMMENT ON COLUMN sys_oper_log.method IS '方法名称';
COMMENT ON COLUMN sys_oper_log.request_method IS '请求方式';
COMMENT ON COLUMN sys_oper_log.operator_type IS '操作类别（0其它 1后台用户 2手机端用户）';
COMMENT ON COLUMN sys_oper_log.oper_name IS '操作人员';
COMMENT ON COLUMN sys_oper_log.dept_name IS '部门名称';
COMMENT ON COLUMN sys_oper_log.oper_url IS '请求URL';
COMMENT ON COLUMN sys_oper_log.oper_ip IS '主机IP地址';
COMMENT ON COLUMN sys_oper_log.oper_location IS '操作地点';
COMMENT ON COLUMN sys_oper_log.oper_param IS '请求参数';
COMMENT ON COLUMN sys_oper_log.json_result IS '返回参数';
COMMENT ON COLUMN sys_oper_log.status IS '操作状态（0正常 1异常）';
COMMENT ON COLUMN sys_oper_log.error_msg IS '错误消息';
COMMENT ON COLUMN sys_oper_log.oper_time IS '操作时间';

-- ----------------------------
-- 11. 字典类型表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_dict_type (
  dict_id BIGSERIAL PRIMARY KEY,
  dict_name VARCHAR(100) DEFAULT '',
  dict_type VARCHAR(100) DEFAULT '',
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP,
  remark VARCHAR(500)
);
COMMENT ON TABLE sys_dict_type IS '字典类型表';
COMMENT ON COLUMN sys_dict_type.dict_id IS '字典主键';
COMMENT ON COLUMN sys_dict_type.dict_name IS '字典名称';
COMMENT ON COLUMN sys_dict_type.dict_type IS '字典类型';
COMMENT ON COLUMN sys_dict_type.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN sys_dict_type.create_by IS '创建者';
COMMENT ON COLUMN sys_dict_type.create_time IS '创建时间';
COMMENT ON COLUMN sys_dict_type.update_by IS '更新者';
COMMENT ON COLUMN sys_dict_type.update_time IS '更新时间';
COMMENT ON COLUMN sys_dict_type.remark IS '备注';

-- ----------------------------
-- 12. 字典数据表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_dict_data (
  dict_code BIGSERIAL PRIMARY KEY,
  dict_sort INT DEFAULT 0,
  dict_label VARCHAR(100) DEFAULT '',
  dict_value VARCHAR(100) DEFAULT '',
  dict_type VARCHAR(100) DEFAULT '',
  css_class VARCHAR(100),
  list_class VARCHAR(100),
  is_default CHAR(1) DEFAULT 'N',
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP,
  remark VARCHAR(500)
);
COMMENT ON TABLE sys_dict_data IS '字典数据表';
COMMENT ON COLUMN sys_dict_data.dict_code IS '字典编码';
COMMENT ON COLUMN sys_dict_data.dict_sort IS '字典排序';
COMMENT ON COLUMN sys_dict_data.dict_label IS '字典标签';
COMMENT ON COLUMN sys_dict_data.dict_value IS '字典键值';
COMMENT ON COLUMN sys_dict_data.dict_type IS '字典类型';
COMMENT ON COLUMN sys_dict_data.css_class IS '样式属性（其他样式扩展）';
COMMENT ON COLUMN sys_dict_data.list_class IS '表格回显样式';
COMMENT ON COLUMN sys_dict_data.is_default IS '是否默认（Y是 N否）';
COMMENT ON COLUMN sys_dict_data.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN sys_dict_data.create_by IS '创建者';
COMMENT ON COLUMN sys_dict_data.create_time IS '创建时间';
COMMENT ON COLUMN sys_dict_data.update_by IS '更新者';
COMMENT ON COLUMN sys_dict_data.update_time IS '更新时间';
COMMENT ON COLUMN sys_dict_data.remark IS '备注';

-- ----------------------------
-- 13. 参数配置表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_config (
  config_id BIGSERIAL PRIMARY KEY,
  config_name VARCHAR(100) DEFAULT '',
  config_key VARCHAR(100) DEFAULT '',
  config_value VARCHAR(500) DEFAULT '',
  config_type CHAR(1) DEFAULT 'N',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP,
  remark VARCHAR(500)
);
COMMENT ON TABLE sys_config IS '参数配置表';
COMMENT ON COLUMN sys_config.config_id IS '参数主键';
COMMENT ON COLUMN sys_config.config_name IS '参数名称';
COMMENT ON COLUMN sys_config.config_key IS '参数键名';
COMMENT ON COLUMN sys_config.config_value IS '参数键值';
COMMENT ON COLUMN sys_config.config_type IS '系统内置（Y是 N否）';
COMMENT ON COLUMN sys_config.create_by IS '创建者';
COMMENT ON COLUMN sys_config.create_time IS '创建时间';
COMMENT ON COLUMN sys_config.update_by IS '更新者';
COMMENT ON COLUMN sys_config.update_time IS '更新时间';
COMMENT ON COLUMN sys_config.remark IS '备注';

-- ----------------------------
-- 14. 系统访问记录(登录日志)
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_login_log (
  info_id BIGSERIAL PRIMARY KEY,
  user_name VARCHAR(50) DEFAULT '',
  ipaddr VARCHAR(128) DEFAULT '',
  login_location VARCHAR(255) DEFAULT '',
  browser VARCHAR(50) DEFAULT '',
  os VARCHAR(50) DEFAULT '',
  status CHAR(1) DEFAULT '0',
  msg VARCHAR(255) DEFAULT '',
  login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE sys_login_log IS '系统访问记录';
COMMENT ON COLUMN sys_login_log.info_id IS '访问ID';
COMMENT ON COLUMN sys_login_log.user_name IS '用户账号';
COMMENT ON COLUMN sys_login_log.ipaddr IS '登录IP地址';
COMMENT ON COLUMN sys_login_log.login_location IS '登录地点';
COMMENT ON COLUMN sys_login_log.browser IS '浏览器类型';
COMMENT ON COLUMN sys_login_log.os IS '操作系统';
COMMENT ON COLUMN sys_login_log.status IS '登录状态（0成功 1失败）';
COMMENT ON COLUMN sys_login_log.msg IS '提示消息';
COMMENT ON COLUMN sys_login_log.login_time IS '访问时间';

-- ----------------------------
-- 15. 通知公告表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_notice (
  notice_id BIGSERIAL PRIMARY KEY,
  notice_title VARCHAR(50) NOT NULL,
  notice_type CHAR(1) NOT NULL,
  notice_content TEXT,
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP,
  remark VARCHAR(255)
);
COMMENT ON TABLE sys_notice IS '通知公告表';
COMMENT ON COLUMN sys_notice.notice_id IS '公告ID';
COMMENT ON COLUMN sys_notice.notice_title IS '公告标题';
COMMENT ON COLUMN sys_notice.notice_type IS '公告类型（1通知 2公告）';
COMMENT ON COLUMN sys_notice.notice_content IS '公告内容';
COMMENT ON COLUMN sys_notice.status IS '公告状态（0正常 1关闭）';
COMMENT ON COLUMN sys_notice.create_by IS '创建者';
COMMENT ON COLUMN sys_notice.create_time IS '创建时间';
COMMENT ON COLUMN sys_notice.update_by IS '更新者';
COMMENT ON COLUMN sys_notice.update_time IS '更新时间';
COMMENT ON COLUMN sys_notice.remark IS '备注';

-- ----------------------------
-- 16. 定时任务调度表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_job (
  job_id BIGSERIAL PRIMARY KEY,
  job_name VARCHAR(64) DEFAULT '',
  job_group VARCHAR(64) DEFAULT 'DEFAULT',
  invoke_target VARCHAR(500) NOT NULL,
  cron_expression VARCHAR(255) DEFAULT '',
  misfire_policy VARCHAR(20) DEFAULT '3',
  concurrent CHAR(1) DEFAULT '1',
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP,
  remark VARCHAR(500)
);
COMMENT ON TABLE sys_job IS '定时任务调度表';
COMMENT ON COLUMN sys_job.job_id IS '任务ID';
COMMENT ON COLUMN sys_job.job_name IS '任务名称';
COMMENT ON COLUMN sys_job.job_group IS '任务组名';
COMMENT ON COLUMN sys_job.invoke_target IS '调用目标字符串';
COMMENT ON COLUMN sys_job.cron_expression IS 'cron执行表达式';
COMMENT ON COLUMN sys_job.misfire_policy IS '计划执行错误策略（1立即执行 2执行一次 3放弃执行）';
COMMENT ON COLUMN sys_job.concurrent IS '是否并发执行（0允许 1禁止）';
COMMENT ON COLUMN sys_job.status IS '状态（0正常 1暂停）';
COMMENT ON COLUMN sys_job.create_by IS '创建者';
COMMENT ON COLUMN sys_job.create_time IS '创建时间';
COMMENT ON COLUMN sys_job.update_by IS '更新者';
COMMENT ON COLUMN sys_job.update_time IS '更新时间';
COMMENT ON COLUMN sys_job.remark IS '备注信息';

-- ----------------------------
-- 17. 定时任务调度日志表
-- ----------------------------
CREATE TABLE IF NOT EXISTS sys_job_log (
  job_log_id BIGSERIAL PRIMARY KEY,
  job_name VARCHAR(64) NOT NULL,
  job_group VARCHAR(64) NOT NULL,
  invoke_target VARCHAR(500) NOT NULL,
  job_message VARCHAR(500),
  status CHAR(1) DEFAULT '0',
  exception_info TEXT DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE sys_job_log IS '定时任务调度日志表';
COMMENT ON COLUMN sys_job_log.job_log_id IS '任务日志ID';
COMMENT ON COLUMN sys_job_log.job_name IS '任务名称';
COMMENT ON COLUMN sys_job_log.job_group IS '任务组名';
COMMENT ON COLUMN sys_job_log.invoke_target IS '调用目标字符串';
COMMENT ON COLUMN sys_job_log.job_message IS '日志信息';
COMMENT ON COLUMN sys_job_log.status IS '执行状态（0正常 1失败）';
COMMENT ON COLUMN sys_job_log.exception_info IS '异常信息';
COMMENT ON COLUMN sys_job_log.create_time IS '创建时间';

-- =============================================
-- 索引定义（支持幂等执行）
-- =============================================

-- sys_dept 索引
CREATE INDEX IF NOT EXISTS idx_sys_dept_parent_id ON sys_dept(parent_id);
COMMENT ON INDEX idx_sys_dept_parent_id IS '部门父级ID索引，用于树形结构查询';
CREATE INDEX IF NOT EXISTS idx_sys_dept_status_del_flag ON sys_dept(status, del_flag);
COMMENT ON INDEX idx_sys_dept_status_del_flag IS '部门状态+删除标志复合索引';

-- sys_user 索引
CREATE UNIQUE INDEX IF NOT EXISTS idx_sys_user_user_name_del_flag ON sys_user(user_name, del_flag);
COMMENT ON INDEX idx_sys_user_user_name_del_flag IS '用户名+删除标志唯一索引，确保未删除用户名唯一';
CREATE INDEX IF NOT EXISTS idx_sys_user_dept_id ON sys_user(dept_id);
COMMENT ON INDEX idx_sys_user_dept_id IS '用户部门ID索引，用于按部门查询用户';
CREATE INDEX IF NOT EXISTS idx_sys_user_status_del_flag ON sys_user(status, del_flag);
COMMENT ON INDEX idx_sys_user_status_del_flag IS '用户状态+删除标志复合索引';
CREATE INDEX IF NOT EXISTS idx_sys_user_phonenumber ON sys_user(phonenumber);
COMMENT ON INDEX idx_sys_user_phonenumber IS '用户手机号索引';
CREATE INDEX IF NOT EXISTS idx_sys_user_email ON sys_user(email);
COMMENT ON INDEX idx_sys_user_email IS '用户邮箱索引';

-- sys_post 索引
CREATE UNIQUE INDEX IF NOT EXISTS idx_sys_post_post_code ON sys_post(post_code);
COMMENT ON INDEX idx_sys_post_post_code IS '岗位编码唯一索引';
CREATE INDEX IF NOT EXISTS idx_sys_post_status ON sys_post(status);
COMMENT ON INDEX idx_sys_post_status IS '岗位状态索引';

-- sys_role 索引
CREATE UNIQUE INDEX IF NOT EXISTS idx_sys_role_role_key_del_flag ON sys_role(role_key, del_flag);
COMMENT ON INDEX idx_sys_role_role_key_del_flag IS '角色标识+删除标志唯一索引';
CREATE INDEX IF NOT EXISTS idx_sys_role_status_del_flag ON sys_role(status, del_flag);
COMMENT ON INDEX idx_sys_role_status_del_flag IS '角色状态+删除标志复合索引';

-- sys_menu 索引
CREATE INDEX IF NOT EXISTS idx_sys_menu_parent_id ON sys_menu(parent_id);
COMMENT ON INDEX idx_sys_menu_parent_id IS '菜单父级ID索引，用于树形结构查询';
CREATE INDEX IF NOT EXISTS idx_sys_menu_status_visible ON sys_menu(status, visible);
COMMENT ON INDEX idx_sys_menu_status_visible IS '菜单状态+可见性复合索引';
CREATE INDEX IF NOT EXISTS idx_sys_menu_perms ON sys_menu(perms);
COMMENT ON INDEX idx_sys_menu_perms IS '菜单权限标识索引，用于权限校验';

-- sys_oper_log 索引
CREATE INDEX IF NOT EXISTS idx_sys_oper_log_oper_time ON sys_oper_log(oper_time);
COMMENT ON INDEX idx_sys_oper_log_oper_time IS '操作日志时间索引，用于按时间范围查询';
CREATE INDEX IF NOT EXISTS idx_sys_oper_log_oper_name ON sys_oper_log(oper_name);
COMMENT ON INDEX idx_sys_oper_log_oper_name IS '操作日志操作人索引';
CREATE INDEX IF NOT EXISTS idx_sys_oper_log_business_type ON sys_oper_log(business_type);
COMMENT ON INDEX idx_sys_oper_log_business_type IS '操作日志业务类型索引';
CREATE INDEX IF NOT EXISTS idx_sys_oper_log_status ON sys_oper_log(status);
COMMENT ON INDEX idx_sys_oper_log_status IS '操作日志状态索引';

-- sys_dict_type 索引
CREATE UNIQUE INDEX IF NOT EXISTS idx_sys_dict_type_dict_type ON sys_dict_type(dict_type);
COMMENT ON INDEX idx_sys_dict_type_dict_type IS '字典类型唯一索引';
CREATE INDEX IF NOT EXISTS idx_sys_dict_type_status ON sys_dict_type(status);
COMMENT ON INDEX idx_sys_dict_type_status IS '字典类型状态索引';

-- sys_dict_data 索引
CREATE INDEX IF NOT EXISTS idx_sys_dict_data_dict_type ON sys_dict_data(dict_type);
COMMENT ON INDEX idx_sys_dict_data_dict_type IS '字典数据类型索引，用于按类型查询字典项';
CREATE INDEX IF NOT EXISTS idx_sys_dict_data_status ON sys_dict_data(status);
COMMENT ON INDEX idx_sys_dict_data_status IS '字典数据状态索引';

-- sys_config 索引
CREATE UNIQUE INDEX IF NOT EXISTS idx_sys_config_config_key ON sys_config(config_key);
COMMENT ON INDEX idx_sys_config_config_key IS '系统配置键名唯一索引';

-- sys_login_log 索引
CREATE INDEX IF NOT EXISTS idx_sys_login_log_login_time ON sys_login_log(login_time);
COMMENT ON INDEX idx_sys_login_log_login_time IS '登录日志时间索引，用于按时间范围查询';
CREATE INDEX IF NOT EXISTS idx_sys_login_log_user_name ON sys_login_log(user_name);
COMMENT ON INDEX idx_sys_login_log_user_name IS '登录日志用户名索引';
CREATE INDEX IF NOT EXISTS idx_sys_login_log_status ON sys_login_log(status);
COMMENT ON INDEX idx_sys_login_log_status IS '登录日志状态索引';

-- sys_notice 索引
CREATE INDEX IF NOT EXISTS idx_sys_notice_status ON sys_notice(status);
COMMENT ON INDEX idx_sys_notice_status IS '通知公告状态索引';
CREATE INDEX IF NOT EXISTS idx_sys_notice_notice_type ON sys_notice(notice_type);
COMMENT ON INDEX idx_sys_notice_notice_type IS '通知公告类型索引';

-- sys_job 索引
CREATE INDEX IF NOT EXISTS idx_sys_job_status ON sys_job(status);
COMMENT ON INDEX idx_sys_job_status IS '定时任务状态索引';
CREATE INDEX IF NOT EXISTS idx_sys_job_job_group ON sys_job(job_group);
COMMENT ON INDEX idx_sys_job_job_group IS '定时任务分组索引';

-- sys_job_log 索引
CREATE INDEX IF NOT EXISTS idx_sys_job_log_create_time ON sys_job_log(create_time);
COMMENT ON INDEX idx_sys_job_log_create_time IS '任务日志创建时间索引';
CREATE INDEX IF NOT EXISTS idx_sys_job_log_job_name_group ON sys_job_log(job_name, job_group);
COMMENT ON INDEX idx_sys_job_log_job_name_group IS '任务日志名称+分组复合索引';
CREATE INDEX IF NOT EXISTS idx_sys_job_log_status ON sys_job_log(status);
COMMENT ON INDEX idx_sys_job_log_status IS '任务日志状态索引';
