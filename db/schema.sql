-- =============================================
-- Xunyin Admin - 数据库表结构
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
  config_value TEXT DEFAULT '',
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


-- =============================================
-- 寻印 App 业务表
-- 说明：与 Prisma schema.prisma 中的寻印模型对应
-- 同步日期：2025-12-29
-- =============================================

-- ----------------------------
-- 18. App用户表（与管理后台用户分离）
-- ----------------------------
CREATE TABLE IF NOT EXISTS app_user (
  id VARCHAR(30) PRIMARY KEY,
  phone VARCHAR(20) UNIQUE,
  email VARCHAR(100) UNIQUE,
  password VARCHAR(100),
  nickname VARCHAR(50) NOT NULL,
  avatar VARCHAR(255),
  gender CHAR(1),
  birthday DATE,
  bio VARCHAR(255),
  open_id VARCHAR(100) UNIQUE,
  union_id VARCHAR(100),
  google_id VARCHAR(100) UNIQUE,
  apple_id VARCHAR(100) UNIQUE,
  login_type VARCHAR(20) DEFAULT 'wechat',
  invite_code VARCHAR(20) UNIQUE,
  invited_by VARCHAR(30),
  badge_title VARCHAR(50),
  total_points INT DEFAULT 0,
  level INT DEFAULT 1,
  is_verified BOOLEAN DEFAULT FALSE,
  last_login_time TIMESTAMP,
  last_login_ip VARCHAR(50),
  status CHAR(1) DEFAULT '0',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP
);
COMMENT ON TABLE app_user IS 'App用户表（与管理后台用户分离）';
COMMENT ON COLUMN app_user.id IS '用户ID（CUID）';
COMMENT ON COLUMN app_user.phone IS '手机号';
COMMENT ON COLUMN app_user.email IS '邮箱';
COMMENT ON COLUMN app_user.password IS '密码（邮箱登录用）';
COMMENT ON COLUMN app_user.nickname IS '昵称';
COMMENT ON COLUMN app_user.avatar IS '头像URL';
COMMENT ON COLUMN app_user.gender IS '性别（0男 1女 2未知）';
COMMENT ON COLUMN app_user.birthday IS '生日';
COMMENT ON COLUMN app_user.bio IS '个人简介';
COMMENT ON COLUMN app_user.open_id IS '微信openId';
COMMENT ON COLUMN app_user.union_id IS '微信unionId';
COMMENT ON COLUMN app_user.google_id IS 'Google登录ID';
COMMENT ON COLUMN app_user.apple_id IS 'Apple登录ID';
COMMENT ON COLUMN app_user.login_type IS '登录方式（wechat/email/google/apple）';
COMMENT ON COLUMN app_user.invite_code IS '用户的邀请码';
COMMENT ON COLUMN app_user.invited_by IS '邀请人用户ID';
COMMENT ON COLUMN app_user.badge_title IS '当前称号';
COMMENT ON COLUMN app_user.total_points IS '总积分';
COMMENT ON COLUMN app_user.level IS '用户等级';
COMMENT ON COLUMN app_user.is_verified IS '是否已实名认证';
COMMENT ON COLUMN app_user.last_login_time IS '最后登录时间';
COMMENT ON COLUMN app_user.last_login_ip IS '最后登录IP';
COMMENT ON COLUMN app_user.status IS '状态（0正常 1禁用）';

CREATE INDEX IF NOT EXISTS idx_app_user_phone ON app_user(phone);
CREATE INDEX IF NOT EXISTS idx_app_user_email ON app_user(email);
CREATE INDEX IF NOT EXISTS idx_app_user_open_id ON app_user(open_id);
CREATE INDEX IF NOT EXISTS idx_app_user_google_id ON app_user(google_id);
CREATE INDEX IF NOT EXISTS idx_app_user_apple_id ON app_user(apple_id);
CREATE INDEX IF NOT EXISTS idx_app_user_login_type ON app_user(login_type);
CREATE INDEX IF NOT EXISTS idx_app_user_invite_code ON app_user(invite_code);

-- ----------------------------
-- 19. 用户实名认证表
-- ----------------------------
CREATE TABLE IF NOT EXISTS user_verification (
  id VARCHAR(30) PRIMARY KEY,
  user_id VARCHAR(30) NOT NULL UNIQUE,
  real_name VARCHAR(50) NOT NULL,
  id_card_no VARCHAR(100) NOT NULL,
  id_card_front VARCHAR(255),
  id_card_back VARCHAR(255),
  status VARCHAR(20) DEFAULT 'pending',
  reject_reason VARCHAR(255),
  verified_at TIMESTAMP,
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES app_user(id)
);
COMMENT ON TABLE user_verification IS '用户实名认证表';
COMMENT ON COLUMN user_verification.id IS '认证ID（CUID）';
COMMENT ON COLUMN user_verification.user_id IS '用户ID';
COMMENT ON COLUMN user_verification.real_name IS '真实姓名';
COMMENT ON COLUMN user_verification.id_card_no IS '身份证号（加密存储）';
COMMENT ON COLUMN user_verification.id_card_front IS '身份证正面照';
COMMENT ON COLUMN user_verification.id_card_back IS '身份证背面照';
COMMENT ON COLUMN user_verification.status IS '状态（pending/approved/rejected）';
COMMENT ON COLUMN user_verification.reject_reason IS '拒绝原因';
COMMENT ON COLUMN user_verification.verified_at IS '认证通过时间';

CREATE INDEX IF NOT EXISTS idx_user_verification_status ON user_verification(status);

-- ----------------------------
-- 20. 城市表
-- ----------------------------
CREATE TABLE IF NOT EXISTS city (
  id VARCHAR(30) PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  province VARCHAR(50) NOT NULL,
  latitude DECIMAL(10, 7) NOT NULL,
  longitude DECIMAL(10, 7) NOT NULL,
  icon_asset VARCHAR(255),
  cover_image VARCHAR(255),
  description TEXT,
  explorer_count INT DEFAULT 0,
  bgm_url VARCHAR(255),
  order_num INT DEFAULT 0,
  status CHAR(1) DEFAULT '0',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP
);
COMMENT ON TABLE city IS '城市表';
COMMENT ON COLUMN city.id IS '城市ID（CUID）';
COMMENT ON COLUMN city.name IS '城市名称';
COMMENT ON COLUMN city.province IS '省份';
COMMENT ON COLUMN city.latitude IS '纬度';
COMMENT ON COLUMN city.longitude IS '经度';
COMMENT ON COLUMN city.icon_asset IS '图标资源';
COMMENT ON COLUMN city.cover_image IS '封面图';
COMMENT ON COLUMN city.description IS '描述';
COMMENT ON COLUMN city.explorer_count IS '探索人数';
COMMENT ON COLUMN city.bgm_url IS '背景音乐URL';
COMMENT ON COLUMN city.order_num IS '排序';
COMMENT ON COLUMN city.status IS '状态（0正常 1停用）';

CREATE INDEX IF NOT EXISTS idx_city_province ON city(province);
CREATE INDEX IF NOT EXISTS idx_city_status ON city(status);

-- ----------------------------
-- 21. 文化之旅表
-- ----------------------------
CREATE TABLE IF NOT EXISTS journey (
  id VARCHAR(30) PRIMARY KEY,
  city_id VARCHAR(30) NOT NULL,
  name VARCHAR(100) NOT NULL,
  theme VARCHAR(100) NOT NULL,
  cover_image VARCHAR(255),
  description TEXT,
  rating INT DEFAULT 5,
  estimated_minutes INT NOT NULL,
  total_distance DECIMAL(10, 2) NOT NULL,
  completed_count INT DEFAULT 0,
  is_locked BOOLEAN DEFAULT FALSE,
  unlock_condition VARCHAR(255),
  bgm_url VARCHAR(255),
  order_num INT DEFAULT 0,
  status CHAR(1) DEFAULT '0',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP,
  FOREIGN KEY (city_id) REFERENCES city(id)
);
COMMENT ON TABLE journey IS '文化之旅表';
COMMENT ON COLUMN journey.id IS '文化之旅ID（CUID）';
COMMENT ON COLUMN journey.city_id IS '城市ID';
COMMENT ON COLUMN journey.name IS '名称';
COMMENT ON COLUMN journey.theme IS '主题';
COMMENT ON COLUMN journey.cover_image IS '封面图';
COMMENT ON COLUMN journey.description IS '描述';
COMMENT ON COLUMN journey.rating IS '星级（1-5）';
COMMENT ON COLUMN journey.estimated_minutes IS '预计时长（分钟）';
COMMENT ON COLUMN journey.total_distance IS '总距离（米）';
COMMENT ON COLUMN journey.completed_count IS '完成人数';
COMMENT ON COLUMN journey.is_locked IS '是否锁定';
COMMENT ON COLUMN journey.unlock_condition IS '解锁条件';
COMMENT ON COLUMN journey.bgm_url IS '背景音乐URL';
COMMENT ON COLUMN journey.order_num IS '排序';
COMMENT ON COLUMN journey.status IS '状态（0正常 1停用）';

CREATE INDEX IF NOT EXISTS idx_journey_city_id ON journey(city_id);
CREATE INDEX IF NOT EXISTS idx_journey_status ON journey(status);

-- ----------------------------
-- 22. 探索点表
-- ----------------------------
CREATE TABLE IF NOT EXISTS exploration_point (
  id VARCHAR(30) PRIMARY KEY,
  journey_id VARCHAR(30) NOT NULL,
  name VARCHAR(100) NOT NULL,
  latitude DECIMAL(10, 7) NOT NULL,
  longitude DECIMAL(10, 7) NOT NULL,
  task_type VARCHAR(20) NOT NULL,
  task_description VARCHAR(255) NOT NULL,
  target_gesture VARCHAR(50),
  ar_asset_url VARCHAR(255),
  cultural_background TEXT,
  cultural_knowledge TEXT,
  distance_from_prev DECIMAL(10, 2),
  points_reward INT DEFAULT 50,
  bgm_id VARCHAR(30),
  order_num INT NOT NULL,
  status CHAR(1) DEFAULT '0',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP,
  FOREIGN KEY (journey_id) REFERENCES journey(id),
  FOREIGN KEY (bgm_id) REFERENCES background_music(id)
);
COMMENT ON TABLE exploration_point IS '探索点表';
COMMENT ON COLUMN exploration_point.id IS '探索点ID（CUID）';
COMMENT ON COLUMN exploration_point.journey_id IS '文化之旅ID';
COMMENT ON COLUMN exploration_point.name IS '名称';
COMMENT ON COLUMN exploration_point.latitude IS '纬度';
COMMENT ON COLUMN exploration_point.longitude IS '经度';
COMMENT ON COLUMN exploration_point.task_type IS '任务类型（gesture/photo/treasure）';
COMMENT ON COLUMN exploration_point.task_description IS '任务描述';
COMMENT ON COLUMN exploration_point.target_gesture IS '目标手势';
COMMENT ON COLUMN exploration_point.ar_asset_url IS 'AR资源URL';
COMMENT ON COLUMN exploration_point.cultural_background IS '文化背景';
COMMENT ON COLUMN exploration_point.cultural_knowledge IS '文化小知识';
COMMENT ON COLUMN exploration_point.distance_from_prev IS '距上一点距离（米）';
COMMENT ON COLUMN exploration_point.points_reward IS '积分奖励';
COMMENT ON COLUMN exploration_point.bgm_id IS '背景音乐ID';
COMMENT ON COLUMN exploration_point.order_num IS '排序';
COMMENT ON COLUMN exploration_point.status IS '状态（0正常 1停用）';

CREATE INDEX IF NOT EXISTS idx_exploration_point_journey_id ON exploration_point(journey_id);
CREATE INDEX IF NOT EXISTS idx_exploration_point_bgm_id ON exploration_point(bgm_id);
CREATE INDEX IF NOT EXISTS idx_exploration_point_status ON exploration_point(status);

-- ----------------------------
-- 23. 用户文化之旅进度表
-- ----------------------------
CREATE TABLE IF NOT EXISTS journey_progress (
  id VARCHAR(30) PRIMARY KEY,
  user_id VARCHAR(30) NOT NULL,
  journey_id VARCHAR(30) NOT NULL,
  status VARCHAR(20) DEFAULT 'in_progress',
  start_time TIMESTAMP NOT NULL,
  complete_time TIMESTAMP,
  time_spent_minutes INT,
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES app_user(id),
  FOREIGN KEY (journey_id) REFERENCES journey(id),
  UNIQUE (user_id, journey_id)
);
COMMENT ON TABLE journey_progress IS '用户文化之旅进度表';
COMMENT ON COLUMN journey_progress.id IS '进度ID（CUID）';
COMMENT ON COLUMN journey_progress.user_id IS '用户ID';
COMMENT ON COLUMN journey_progress.journey_id IS '文化之旅ID';
COMMENT ON COLUMN journey_progress.status IS '状态（in_progress/completed/abandoned）';
COMMENT ON COLUMN journey_progress.start_time IS '开始时间';
COMMENT ON COLUMN journey_progress.complete_time IS '完成时间';
COMMENT ON COLUMN journey_progress.time_spent_minutes IS '花费时间（分钟）';

CREATE INDEX IF NOT EXISTS idx_journey_progress_user_id ON journey_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_journey_progress_journey_id ON journey_progress(journey_id);
CREATE INDEX IF NOT EXISTS idx_journey_progress_status ON journey_progress(status);

-- ----------------------------
-- 24. 探索点完成记录表
-- ----------------------------
CREATE TABLE IF NOT EXISTS point_completion (
  id VARCHAR(30) PRIMARY KEY,
  progress_id VARCHAR(30) NOT NULL,
  point_id VARCHAR(30) NOT NULL,
  complete_time TIMESTAMP NOT NULL,
  points_earned INT NOT NULL,
  photo_url VARCHAR(255),
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (progress_id) REFERENCES journey_progress(id),
  FOREIGN KEY (point_id) REFERENCES exploration_point(id),
  UNIQUE (progress_id, point_id)
);
COMMENT ON TABLE point_completion IS '探索点完成记录表';
COMMENT ON COLUMN point_completion.id IS '记录ID（CUID）';
COMMENT ON COLUMN point_completion.progress_id IS '进度ID';
COMMENT ON COLUMN point_completion.point_id IS '探索点ID';
COMMENT ON COLUMN point_completion.complete_time IS '完成时间';
COMMENT ON COLUMN point_completion.points_earned IS '获得积分';
COMMENT ON COLUMN point_completion.photo_url IS '照片URL';

CREATE INDEX IF NOT EXISTS idx_point_completion_progress_id ON point_completion(progress_id);
CREATE INDEX IF NOT EXISTS idx_point_completion_point_id ON point_completion(point_id);

-- ----------------------------
-- 25. 印记表
-- ----------------------------
CREATE TABLE IF NOT EXISTS seal (
  id VARCHAR(30) PRIMARY KEY,
  type VARCHAR(20) NOT NULL,
  name VARCHAR(100) NOT NULL,
  image_asset VARCHAR(255) NOT NULL,
  description TEXT,
  unlock_condition VARCHAR(255),
  badge_title VARCHAR(50),
  journey_id VARCHAR(30),
  city_id VARCHAR(30),
  order_num INT DEFAULT 0,
  status CHAR(1) DEFAULT '0',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP,
  FOREIGN KEY (journey_id) REFERENCES journey(id),
  FOREIGN KEY (city_id) REFERENCES city(id)
);
COMMENT ON TABLE seal IS '印记表';
COMMENT ON COLUMN seal.id IS '印记ID（CUID）';
COMMENT ON COLUMN seal.type IS '类型（route/city/special）';
COMMENT ON COLUMN seal.name IS '名称';
COMMENT ON COLUMN seal.image_asset IS '图片资源';
COMMENT ON COLUMN seal.description IS '描述';
COMMENT ON COLUMN seal.unlock_condition IS '解锁条件';
COMMENT ON COLUMN seal.badge_title IS '解锁的称号';
COMMENT ON COLUMN seal.journey_id IS '关联文化之旅ID';
COMMENT ON COLUMN seal.city_id IS '关联城市ID';
COMMENT ON COLUMN seal.order_num IS '排序';
COMMENT ON COLUMN seal.status IS '状态（0正常 1停用）';

CREATE INDEX IF NOT EXISTS idx_seal_type ON seal(type);
CREATE INDEX IF NOT EXISTS idx_seal_journey_id ON seal(journey_id);
CREATE INDEX IF NOT EXISTS idx_seal_city_id ON seal(city_id);
CREATE INDEX IF NOT EXISTS idx_seal_status ON seal(status);

-- ----------------------------
-- 26. 用户印记表
-- ----------------------------
CREATE TABLE IF NOT EXISTS user_seal (
  id VARCHAR(30) PRIMARY KEY,
  user_id VARCHAR(30) NOT NULL,
  seal_id VARCHAR(30) NOT NULL,
  earned_time TIMESTAMP NOT NULL,
  time_spent_minutes INT,
  points_earned INT DEFAULT 0,
  is_chained BOOLEAN DEFAULT FALSE,
  chain_name VARCHAR(50),
  tx_hash VARCHAR(100),
  block_height BIGINT,
  chain_time TIMESTAMP,
  chain_certificate JSONB,
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES app_user(id),
  FOREIGN KEY (seal_id) REFERENCES seal(id),
  UNIQUE (user_id, seal_id)
);
COMMENT ON TABLE user_seal IS '用户印记表';
COMMENT ON COLUMN user_seal.id IS '记录ID（CUID）';
COMMENT ON COLUMN user_seal.user_id IS '用户ID';
COMMENT ON COLUMN user_seal.seal_id IS '印记ID';
COMMENT ON COLUMN user_seal.earned_time IS '获得时间';
COMMENT ON COLUMN user_seal.time_spent_minutes IS '花费时间（分钟）';
COMMENT ON COLUMN user_seal.points_earned IS '获得积分';
COMMENT ON COLUMN user_seal.is_chained IS '是否已上链';
COMMENT ON COLUMN user_seal.chain_name IS '链名称: LocalChain(本地哈希存证)/Timestamp(时间戳存证)/AntChain(蚂蚁链)/ZhixinChain(腾讯至信链)/BSN(BSN开放联盟链)/Polygon(Polygon公链)';
COMMENT ON COLUMN user_seal.tx_hash IS '交易哈希';
COMMENT ON COLUMN user_seal.block_height IS '区块高度';
COMMENT ON COLUMN user_seal.chain_time IS '上链时间';
COMMENT ON COLUMN user_seal.chain_certificate IS '存证原始数据，用于验证';

CREATE INDEX IF NOT EXISTS idx_user_seal_user_id ON user_seal(user_id);
CREATE INDEX IF NOT EXISTS idx_user_seal_seal_id ON user_seal(seal_id);
CREATE INDEX IF NOT EXISTS idx_user_seal_is_chained ON user_seal(is_chained);

-- ----------------------------
-- 27. 探索照片表
-- ----------------------------
CREATE TABLE IF NOT EXISTS exploration_photo (
  id VARCHAR(30) PRIMARY KEY,
  user_id VARCHAR(30) NOT NULL,
  journey_id VARCHAR(30) NOT NULL,
  point_id VARCHAR(30) NOT NULL,
  photo_url VARCHAR(255) NOT NULL,
  thumbnail_url VARCHAR(255),
  filter VARCHAR(20),
  latitude DECIMAL(10, 7),
  longitude DECIMAL(10, 7),
  taken_time TIMESTAMP NOT NULL,
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES app_user(id),
  FOREIGN KEY (journey_id) REFERENCES journey(id),
  FOREIGN KEY (point_id) REFERENCES exploration_point(id)
);
COMMENT ON TABLE exploration_photo IS '探索照片表';
COMMENT ON COLUMN exploration_photo.id IS '照片ID（CUID）';
COMMENT ON COLUMN exploration_photo.user_id IS '用户ID';
COMMENT ON COLUMN exploration_photo.journey_id IS '文化之旅ID';
COMMENT ON COLUMN exploration_photo.point_id IS '探索点ID';
COMMENT ON COLUMN exploration_photo.photo_url IS '照片URL';
COMMENT ON COLUMN exploration_photo.thumbnail_url IS '缩略图URL';
COMMENT ON COLUMN exploration_photo.filter IS '使用的滤镜';
COMMENT ON COLUMN exploration_photo.latitude IS '拍摄纬度';
COMMENT ON COLUMN exploration_photo.longitude IS '拍摄经度';
COMMENT ON COLUMN exploration_photo.taken_time IS '拍摄时间';

CREATE INDEX IF NOT EXISTS idx_exploration_photo_user_id ON exploration_photo(user_id);
CREATE INDEX IF NOT EXISTS idx_exploration_photo_journey_id ON exploration_photo(journey_id);
CREATE INDEX IF NOT EXISTS idx_exploration_photo_point_id ON exploration_photo(point_id);
CREATE INDEX IF NOT EXISTS idx_exploration_photo_taken_time ON exploration_photo(taken_time);

-- ----------------------------
-- 28. 用户动态表
-- ----------------------------
CREATE TABLE IF NOT EXISTS user_activity (
  id VARCHAR(30) PRIMARY KEY,
  user_id VARCHAR(30) NOT NULL,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  related_id VARCHAR(30),
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES app_user(id)
);
COMMENT ON TABLE user_activity IS '用户动态表';
COMMENT ON COLUMN user_activity.id IS '动态ID（CUID）';
COMMENT ON COLUMN user_activity.user_id IS '用户ID';
COMMENT ON COLUMN user_activity.type IS '类型（seal_earned/journey_completed等）';
COMMENT ON COLUMN user_activity.title IS '标题';
COMMENT ON COLUMN user_activity.related_id IS '关联ID';

CREATE INDEX IF NOT EXISTS idx_user_activity_user_id ON user_activity(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_create_time ON user_activity(create_time);

-- ----------------------------
-- 29. 背景音乐表
-- ----------------------------
CREATE TABLE IF NOT EXISTS background_music (
  id VARCHAR(30) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  url VARCHAR(255) NOT NULL,
  context VARCHAR(20) NOT NULL,
  context_id VARCHAR(30),
  duration INT,
  order_num INT DEFAULT 0,
  status CHAR(1) DEFAULT '0',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_time TIMESTAMP
);
COMMENT ON TABLE background_music IS '背景音乐表';
COMMENT ON COLUMN background_music.id IS '音乐ID（CUID）';
COMMENT ON COLUMN background_music.name IS '名称';
COMMENT ON COLUMN background_music.url IS 'URL';
COMMENT ON COLUMN background_music.context IS '场景（home/city/journey）';
COMMENT ON COLUMN background_music.context_id IS '关联ID';
COMMENT ON COLUMN background_music.duration IS '时长（秒）';
COMMENT ON COLUMN background_music.order_num IS '排序';
COMMENT ON COLUMN background_music.status IS '状态（0正常 1停用）';

CREATE INDEX IF NOT EXISTS idx_background_music_context ON background_music(context, context_id);
CREATE INDEX IF NOT EXISTS idx_background_music_status ON background_music(status);


-- =============================================
-- APP 配置相关表
-- 说明：APP 启动页、登录页、下载页、推广统计、版本管理
-- =============================================

-- ----------------------------
-- APP启动页配置表
-- ----------------------------
CREATE TABLE IF NOT EXISTS app_splash_config (
  id VARCHAR(30) PRIMARY KEY,
  title VARCHAR(100),
  type VARCHAR(20) NOT NULL DEFAULT 'image',
  media_url VARCHAR(500) NOT NULL,
  link_type VARCHAR(20),
  link_url VARCHAR(500),
  duration INT DEFAULT 3,
  skip_delay INT DEFAULT 0,
  platform VARCHAR(20) DEFAULT 'all',
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  order_num INT DEFAULT 0,
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP
);
COMMENT ON TABLE app_splash_config IS 'APP启动页配置表';
COMMENT ON COLUMN app_splash_config.id IS '配置ID';
COMMENT ON COLUMN app_splash_config.title IS '标题';
COMMENT ON COLUMN app_splash_config.type IS '类型：image-图片 video-视频';
COMMENT ON COLUMN app_splash_config.media_url IS '媒体资源URL';
COMMENT ON COLUMN app_splash_config.link_type IS '跳转类型：none-不跳转 internal-内部页面 external-外部链接';
COMMENT ON COLUMN app_splash_config.link_url IS '跳转链接';
COMMENT ON COLUMN app_splash_config.duration IS '展示时长（秒）';
COMMENT ON COLUMN app_splash_config.skip_delay IS '跳过按钮延迟显示（秒）';
COMMENT ON COLUMN app_splash_config.platform IS '平台：all-全部 ios-仅iOS android-仅Android';
COMMENT ON COLUMN app_splash_config.start_time IS '生效开始时间';
COMMENT ON COLUMN app_splash_config.end_time IS '生效结束时间';
COMMENT ON COLUMN app_splash_config.order_num IS '显示顺序';
COMMENT ON COLUMN app_splash_config.status IS '状态（0启用 1停用）';
COMMENT ON COLUMN app_splash_config.create_by IS '创建者';
COMMENT ON COLUMN app_splash_config.create_time IS '创建时间';
COMMENT ON COLUMN app_splash_config.update_by IS '更新者';
COMMENT ON COLUMN app_splash_config.update_time IS '更新时间';

CREATE INDEX IF NOT EXISTS idx_app_splash_status ON app_splash_config(status);
CREATE INDEX IF NOT EXISTS idx_app_splash_platform ON app_splash_config(platform);
CREATE INDEX IF NOT EXISTS idx_app_splash_time ON app_splash_config(start_time, end_time);

-- ----------------------------
-- APP登录页配置表
-- ----------------------------
CREATE TABLE IF NOT EXISTS app_login_config (
  id VARCHAR(30) PRIMARY KEY,
  -- 背景配置（Aurora warm 3色渐变）
  background_type VARCHAR(20) DEFAULT 'gradient',
  background_image VARCHAR(500),
  background_color VARCHAR(20),
  gradient_start VARCHAR(20) DEFAULT '#FDF8F5',
  gradient_middle VARCHAR(20) DEFAULT '#F8F5F0',
  gradient_end VARCHAR(20) DEFAULT '#F5F0EB',
  gradient_direction VARCHAR(30) DEFAULT 'to bottom',
  -- Aurora 底纹配置
  aurora_enabled BOOLEAN DEFAULT TRUE,
  aurora_preset VARCHAR(20) DEFAULT 'warm',
  -- Logo配置
  logo_image VARCHAR(500),
  logo_size VARCHAR(20) DEFAULT 'normal',
  logo_animation_enabled BOOLEAN DEFAULT TRUE,
  -- 应用名称配置
  app_name VARCHAR(50) DEFAULT '寻印',
  app_name_color VARCHAR(20) DEFAULT '#1a1a1a',
  -- 标语配置
  slogan VARCHAR(200) DEFAULT '探索城市文化，收集专属印记',
  slogan_color VARCHAR(20) DEFAULT '#666666',
  -- 按钮样式
  button_style VARCHAR(20) DEFAULT 'filled',
  button_primary_color VARCHAR(20) DEFAULT '#C41E3A',
  button_gradient_end_color VARCHAR(20) DEFAULT '#9A1830',
  button_secondary_color VARCHAR(30) DEFAULT 'rgba(196,30,58,0.08)',
  button_radius VARCHAR(20) DEFAULT 'lg',
  -- 登录方式开关
  wechat_login_enabled BOOLEAN DEFAULT TRUE,
  apple_login_enabled BOOLEAN DEFAULT TRUE,
  google_login_enabled BOOLEAN DEFAULT TRUE,
  phone_login_enabled BOOLEAN DEFAULT TRUE,
  -- 协议配置
  agreement_source VARCHAR(20) DEFAULT 'builtin',
  user_agreement_url VARCHAR(500),
  privacy_policy_url VARCHAR(500),
  -- 系统字段
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP
);
COMMENT ON TABLE app_login_config IS 'APP登录页配置表';
COMMENT ON COLUMN app_login_config.id IS '配置ID';
COMMENT ON COLUMN app_login_config.background_type IS '背景类型: image-图片, color-纯色, gradient-渐变';
COMMENT ON COLUMN app_login_config.background_image IS '背景图（backgroundType=image时使用）';
COMMENT ON COLUMN app_login_config.background_color IS '纯色背景（backgroundType=color时使用）';
COMMENT ON COLUMN app_login_config.gradient_start IS '渐变起始色（Aurora warm）';
COMMENT ON COLUMN app_login_config.gradient_middle IS '渐变中间色（Aurora warm）';
COMMENT ON COLUMN app_login_config.gradient_end IS '渐变结束色（Aurora warm）';
COMMENT ON COLUMN app_login_config.gradient_direction IS '渐变方向: to bottom, to top, to right, to left, 45deg, 135deg';
COMMENT ON COLUMN app_login_config.aurora_enabled IS 'Aurora底纹是否启用';
COMMENT ON COLUMN app_login_config.aurora_preset IS 'Aurora预设: warm-暖色, standard-标准, golden-金色, celebration-庆祝';
COMMENT ON COLUMN app_login_config.logo_image IS 'Logo图片';
COMMENT ON COLUMN app_login_config.logo_size IS 'Logo尺寸: small-小, normal-正常, large-大';
COMMENT ON COLUMN app_login_config.logo_animation_enabled IS 'Logo浮动动画是否启用';
COMMENT ON COLUMN app_login_config.app_name IS '应用名称';
COMMENT ON COLUMN app_login_config.app_name_color IS '应用名称颜色';
COMMENT ON COLUMN app_login_config.slogan IS '标语';
COMMENT ON COLUMN app_login_config.slogan_color IS '标语颜色';
COMMENT ON COLUMN app_login_config.button_style IS '按钮风格: filled-填充, outlined-描边, glass-毛玻璃';
COMMENT ON COLUMN app_login_config.button_primary_color IS '主按钮颜色（品牌红）';
COMMENT ON COLUMN app_login_config.button_gradient_end_color IS '按钮渐变结束色（品牌红暗色）';
COMMENT ON COLUMN app_login_config.button_secondary_color IS '次按钮颜色';
COMMENT ON COLUMN app_login_config.button_radius IS '按钮圆角: none-无, sm-小, md-中, lg-大, full-全圆角';
COMMENT ON COLUMN app_login_config.wechat_login_enabled IS '微信登录是否启用';
COMMENT ON COLUMN app_login_config.apple_login_enabled IS 'Apple登录是否启用';
COMMENT ON COLUMN app_login_config.google_login_enabled IS 'Google登录是否启用';
COMMENT ON COLUMN app_login_config.phone_login_enabled IS '手机号登录是否启用';
COMMENT ON COLUMN app_login_config.agreement_source IS '协议来源: builtin-内置协议, external-外部链接';
COMMENT ON COLUMN app_login_config.user_agreement_url IS '用户协议外部链接';
COMMENT ON COLUMN app_login_config.privacy_policy_url IS '隐私政策外部链接';
COMMENT ON COLUMN app_login_config.status IS '状态（0启用 1停用）';
COMMENT ON COLUMN app_login_config.create_by IS '创建者';
COMMENT ON COLUMN app_login_config.create_time IS '创建时间';
COMMENT ON COLUMN app_login_config.update_by IS '更新者';
COMMENT ON COLUMN app_login_config.update_time IS '更新时间';

-- ----------------------------
-- APP下载页配置表
-- ----------------------------
CREATE TABLE IF NOT EXISTS app_download_config (
  id VARCHAR(30) PRIMARY KEY,
  page_title VARCHAR(100),
  page_description TEXT,
  favicon VARCHAR(500),
  -- 背景配置
  background_type VARCHAR(20) NOT NULL DEFAULT 'gradient',
  background_image VARCHAR(500),
  background_color VARCHAR(20),
  gradient_start VARCHAR(20) DEFAULT '#FDF8F5',
  gradient_end VARCHAR(20) DEFAULT '#F5F0EB',
  gradient_direction VARCHAR(30) DEFAULT 'to bottom',
  -- APP信息
  app_icon VARCHAR(500),
  app_name VARCHAR(100),
  app_slogan VARCHAR(200),
  slogan_color VARCHAR(30) DEFAULT '#666666',
  logo_animation_enabled BOOLEAN DEFAULT true,
  -- 按钮样式
  button_style VARCHAR(20) DEFAULT 'filled',
  button_primary_color VARCHAR(20) DEFAULT '#C41E3A',
  button_secondary_color VARCHAR(30) DEFAULT 'rgba(196,30,58,0.08)',
  button_radius VARCHAR(20) DEFAULT 'lg',
  -- 按钮文本配置
  ios_button_text VARCHAR(50),
  android_button_text VARCHAR(50),
  feature_list JSONB,
  ios_store_url VARCHAR(500),
  android_store_url VARCHAR(500),
  android_apk_url VARCHAR(500),
  qrcode_image VARCHAR(500),
  footer_text VARCHAR(500),
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP
);
COMMENT ON TABLE app_download_config IS 'APP下载页配置表';
COMMENT ON COLUMN app_download_config.id IS '配置ID';
COMMENT ON COLUMN app_download_config.page_title IS '页面标题';
COMMENT ON COLUMN app_download_config.page_description IS '页面描述';
COMMENT ON COLUMN app_download_config.favicon IS '页面favicon';
COMMENT ON COLUMN app_download_config.background_type IS '背景类型: image-图片, color-纯色, gradient-渐变';
COMMENT ON COLUMN app_download_config.background_image IS '背景图（backgroundType=image时使用）';
COMMENT ON COLUMN app_download_config.background_color IS '纯色背景（backgroundType=color时使用）';
COMMENT ON COLUMN app_download_config.gradient_start IS '渐变起始色（Aurora warm）';
COMMENT ON COLUMN app_download_config.gradient_end IS '渐变结束色（Aurora warm）';
COMMENT ON COLUMN app_download_config.gradient_direction IS '渐变方向';
COMMENT ON COLUMN app_download_config.app_icon IS 'APP图标';
COMMENT ON COLUMN app_download_config.app_name IS 'APP名称';
COMMENT ON COLUMN app_download_config.app_slogan IS 'APP标语';
COMMENT ON COLUMN app_download_config.slogan_color IS '标语颜色';
COMMENT ON COLUMN app_download_config.logo_animation_enabled IS 'Logo浮动动画开关';
COMMENT ON COLUMN app_download_config.button_style IS '按钮风格: filled-填充, outlined-描边, glass-毛玻璃';
COMMENT ON COLUMN app_download_config.button_primary_color IS '主按钮颜色（品牌红）';
COMMENT ON COLUMN app_download_config.button_secondary_color IS '次按钮颜色';
COMMENT ON COLUMN app_download_config.button_radius IS '按钮圆角: none-无, sm-小, md-中, lg-大, full-全圆角';
COMMENT ON COLUMN app_download_config.ios_button_text IS 'iOS下载按钮文本';
COMMENT ON COLUMN app_download_config.android_button_text IS 'Android下载按钮文本';
COMMENT ON COLUMN app_download_config.feature_list IS '功能特点JSON数组';
COMMENT ON COLUMN app_download_config.ios_store_url IS 'iOS商店链接';
COMMENT ON COLUMN app_download_config.android_store_url IS 'Android商店链接';
COMMENT ON COLUMN app_download_config.android_apk_url IS 'Android APK下载链接';
COMMENT ON COLUMN app_download_config.qrcode_image IS '二维码图片';
COMMENT ON COLUMN app_download_config.footer_text IS '页脚文字';
COMMENT ON COLUMN app_download_config.status IS '状态（0启用 1停用）';
COMMENT ON COLUMN app_download_config.create_by IS '创建者';
COMMENT ON COLUMN app_download_config.create_time IS '创建时间';
COMMENT ON COLUMN app_download_config.update_by IS '更新者';
COMMENT ON COLUMN app_download_config.update_time IS '更新时间';

-- ----------------------------
-- APP推广渠道表
-- ----------------------------
CREATE TABLE IF NOT EXISTS app_promotion_channel (
  id VARCHAR(30) PRIMARY KEY,
  channel_code VARCHAR(50) NOT NULL UNIQUE,
  channel_name VARCHAR(100) NOT NULL,
  channel_type VARCHAR(20),
  description VARCHAR(500),
  download_url VARCHAR(500),
  qrcode_image VARCHAR(500),
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP
);
COMMENT ON TABLE app_promotion_channel IS 'APP推广渠道表';
COMMENT ON COLUMN app_promotion_channel.id IS '渠道ID';
COMMENT ON COLUMN app_promotion_channel.channel_code IS '渠道编码';
COMMENT ON COLUMN app_promotion_channel.channel_name IS '渠道名称';
COMMENT ON COLUMN app_promotion_channel.channel_type IS '渠道类型：social-社交媒体 ad-广告投放 offline-线下推广 other-其他';
COMMENT ON COLUMN app_promotion_channel.description IS '描述';
COMMENT ON COLUMN app_promotion_channel.download_url IS '下载链接';
COMMENT ON COLUMN app_promotion_channel.qrcode_image IS '二维码图片';
COMMENT ON COLUMN app_promotion_channel.status IS '状态（0启用 1停用）';
COMMENT ON COLUMN app_promotion_channel.create_by IS '创建者';
COMMENT ON COLUMN app_promotion_channel.create_time IS '创建时间';
COMMENT ON COLUMN app_promotion_channel.update_by IS '更新者';
COMMENT ON COLUMN app_promotion_channel.update_time IS '更新时间';

CREATE UNIQUE INDEX IF NOT EXISTS idx_app_channel_code ON app_promotion_channel(channel_code);
CREATE INDEX IF NOT EXISTS idx_app_channel_type ON app_promotion_channel(channel_type);

-- ----------------------------
-- APP推广统计表
-- ----------------------------
CREATE TABLE IF NOT EXISTS app_promotion_stats (
  id VARCHAR(30) PRIMARY KEY,
  channel_id VARCHAR(30) NOT NULL,
  stat_date DATE NOT NULL,
  page_views INT DEFAULT 0,
  download_clicks INT DEFAULT 0,
  install_count INT DEFAULT 0,
  register_count INT DEFAULT 0,
  active_count INT DEFAULT 0,
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (channel_id) REFERENCES app_promotion_channel(id)
);
COMMENT ON TABLE app_promotion_stats IS 'APP推广统计表';
COMMENT ON COLUMN app_promotion_stats.id IS '统计ID';
COMMENT ON COLUMN app_promotion_stats.channel_id IS '渠道ID';
COMMENT ON COLUMN app_promotion_stats.stat_date IS '统计日期';
COMMENT ON COLUMN app_promotion_stats.page_views IS '页面浏览量';
COMMENT ON COLUMN app_promotion_stats.download_clicks IS '下载点击数';
COMMENT ON COLUMN app_promotion_stats.install_count IS '安装数';
COMMENT ON COLUMN app_promotion_stats.register_count IS '注册数';
COMMENT ON COLUMN app_promotion_stats.active_count IS '活跃数';
COMMENT ON COLUMN app_promotion_stats.create_time IS '创建时间';

CREATE UNIQUE INDEX IF NOT EXISTS idx_app_stats_channel_date ON app_promotion_stats(channel_id, stat_date);
CREATE INDEX IF NOT EXISTS idx_app_stats_date ON app_promotion_stats(stat_date);

-- ----------------------------
-- APP版本管理表
-- ----------------------------
CREATE TABLE IF NOT EXISTS app_version (
  id VARCHAR(30) PRIMARY KEY,
  version_code VARCHAR(20) NOT NULL,
  version_name VARCHAR(50) NOT NULL,
  platform VARCHAR(20) NOT NULL,
  download_url VARCHAR(500),
  file_size VARCHAR(20),
  update_content TEXT,
  is_force_update BOOLEAN DEFAULT FALSE,
  min_support_version VARCHAR(20),
  publish_time TIMESTAMP,
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP
);
COMMENT ON TABLE app_version IS 'APP版本管理表';
COMMENT ON COLUMN app_version.id IS '版本ID';
COMMENT ON COLUMN app_version.version_code IS '版本号';
COMMENT ON COLUMN app_version.version_name IS '版本名称';
COMMENT ON COLUMN app_version.platform IS '平台：ios/android';
COMMENT ON COLUMN app_version.download_url IS '下载链接';
COMMENT ON COLUMN app_version.file_size IS '文件大小';
COMMENT ON COLUMN app_version.update_content IS '更新内容';
COMMENT ON COLUMN app_version.is_force_update IS '是否强制更新';
COMMENT ON COLUMN app_version.min_support_version IS '最低支持版本';
COMMENT ON COLUMN app_version.publish_time IS '发布时间';
COMMENT ON COLUMN app_version.status IS '状态（0启用 1停用）';
COMMENT ON COLUMN app_version.create_by IS '创建者';
COMMENT ON COLUMN app_version.create_time IS '创建时间';
COMMENT ON COLUMN app_version.update_by IS '更新者';
COMMENT ON COLUMN app_version.update_time IS '更新时间';

CREATE INDEX IF NOT EXISTS idx_app_version_platform ON app_version(platform);
CREATE INDEX IF NOT EXISTS idx_app_version_code ON app_version(version_code);

-- ----------------------------
-- APP协议内容表
-- ----------------------------
CREATE TABLE IF NOT EXISTS app_agreement (
  id VARCHAR(30) PRIMARY KEY,
  type VARCHAR(30) NOT NULL UNIQUE,
  title VARCHAR(100) NOT NULL,
  content TEXT NOT NULL,
  version VARCHAR(20) DEFAULT '1.0',
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time TIMESTAMP
);
COMMENT ON TABLE app_agreement IS 'APP协议内容表';
COMMENT ON COLUMN app_agreement.id IS '协议ID';
COMMENT ON COLUMN app_agreement.type IS '协议类型：user_agreement-用户协议 privacy_policy-隐私政策';
COMMENT ON COLUMN app_agreement.title IS '协议标题';
COMMENT ON COLUMN app_agreement.content IS '协议内容';
COMMENT ON COLUMN app_agreement.version IS '版本号';
COMMENT ON COLUMN app_agreement.status IS '状态（0启用 1停用）';
COMMENT ON COLUMN app_agreement.create_by IS '创建者';
COMMENT ON COLUMN app_agreement.create_time IS '创建时间';
COMMENT ON COLUMN app_agreement.update_by IS '更新者';
COMMENT ON COLUMN app_agreement.update_time IS '更新时间';

CREATE INDEX IF NOT EXISTS idx_app_agreement_type ON app_agreement(type);
