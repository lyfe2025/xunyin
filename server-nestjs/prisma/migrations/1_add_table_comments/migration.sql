-- 为核心业务表添加表和字段注释，便于在数据库中直观理解含义

-- sys_dept 部门表
COMMENT ON TABLE public.sys_dept IS '部门表';
COMMENT ON COLUMN public.sys_dept.dept_id IS '部门ID';
COMMENT ON COLUMN public.sys_dept.parent_id IS '父部门ID';
COMMENT ON COLUMN public.sys_dept.ancestors IS '祖级列表';
COMMENT ON COLUMN public.sys_dept.dept_name IS '部门名称';
COMMENT ON COLUMN public.sys_dept.order_num IS '显示顺序';
COMMENT ON COLUMN public.sys_dept.leader IS '负责人';
COMMENT ON COLUMN public.sys_dept.phone IS '联系电话';
COMMENT ON COLUMN public.sys_dept.email IS '邮箱';
COMMENT ON COLUMN public.sys_dept.status IS '部门状态（0正常 1停用）';
COMMENT ON COLUMN public.sys_dept.del_flag IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN public.sys_dept.create_by IS '创建者';
COMMENT ON COLUMN public.sys_dept.create_time IS '创建时间';
COMMENT ON COLUMN public.sys_dept.update_by IS '更新者';
COMMENT ON COLUMN public.sys_dept.update_time IS '更新时间';

-- sys_user 用户信息表
COMMENT ON TABLE public.sys_user IS '用户信息表';
COMMENT ON COLUMN public.sys_user.user_id IS '用户ID';
COMMENT ON COLUMN public.sys_user.dept_id IS '部门ID';
COMMENT ON COLUMN public.sys_user.user_name IS '用户账号';
COMMENT ON COLUMN public.sys_user.nick_name IS '用户昵称';
COMMENT ON COLUMN public.sys_user.user_type IS '用户类型（00系统用户）';
COMMENT ON COLUMN public.sys_user.email IS '用户邮箱';
COMMENT ON COLUMN public.sys_user.phonenumber IS '手机号码';
COMMENT ON COLUMN public.sys_user.sex IS '用户性别（0男 1女 2未知）';
COMMENT ON COLUMN public.sys_user.avatar IS '头像地址';
COMMENT ON COLUMN public.sys_user.password IS '密码';
COMMENT ON COLUMN public.sys_user.status IS '帐号状态（0正常 1停用）';
COMMENT ON COLUMN public.sys_user.del_flag IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN public.sys_user.login_ip IS '最后登录IP';
COMMENT ON COLUMN public.sys_user.login_date IS '最后登录时间';
COMMENT ON COLUMN public.sys_user.two_factor_secret IS '两步验证密钥';
COMMENT ON COLUMN public.sys_user.two_factor_enabled IS '两步验证是否启用';
COMMENT ON COLUMN public.sys_user.create_by IS '创建者';
COMMENT ON COLUMN public.sys_user.create_time IS '创建时间';
COMMENT ON COLUMN public.sys_user.update_by IS '更新者';
COMMENT ON COLUMN public.sys_user.update_time IS '更新时间';
COMMENT ON COLUMN public.sys_user.remark IS '备注';

-- sys_post 岗位信息表
COMMENT ON TABLE public.sys_post IS '岗位信息表';
COMMENT ON COLUMN public.sys_post.post_id IS '岗位ID';
COMMENT ON COLUMN public.sys_post.post_code IS '岗位编码';
COMMENT ON COLUMN public.sys_post.post_name IS '岗位名称';
COMMENT ON COLUMN public.sys_post.post_sort IS '显示顺序';
COMMENT ON COLUMN public.sys_post.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN public.sys_post.create_by IS '创建者';
COMMENT ON COLUMN public.sys_post.create_time IS '创建时间';
COMMENT ON COLUMN public.sys_post.update_by IS '更新者';
COMMENT ON COLUMN public.sys_post.update_time IS '更新时间';
COMMENT ON COLUMN public.sys_post.remark IS '备注';

-- sys_role 角色信息表
COMMENT ON TABLE public.sys_role IS '角色信息表';
COMMENT ON COLUMN public.sys_role.role_id IS '角色ID';
COMMENT ON COLUMN public.sys_role.role_name IS '角色名称';
COMMENT ON COLUMN public.sys_role.role_key IS '角色权限字符串';
COMMENT ON COLUMN public.sys_role.role_sort IS '显示顺序';
COMMENT ON COLUMN public.sys_role.data_scope IS '数据范围（1全部 2自定 3本部门 4本部门及以下）';
COMMENT ON COLUMN public.sys_role.menu_check_strictly IS '菜单树选择项是否关联显示';
COMMENT ON COLUMN public.sys_role.dept_check_strictly IS '部门树选择项是否关联显示';
COMMENT ON COLUMN public.sys_role.status IS '角色状态（0正常 1停用）';
COMMENT ON COLUMN public.sys_role.del_flag IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN public.sys_role.create_by IS '创建者';
COMMENT ON COLUMN public.sys_role.create_time IS '创建时间';
COMMENT ON COLUMN public.sys_role.update_by IS '更新者';
COMMENT ON COLUMN public.sys_role.update_time IS '更新时间';
COMMENT ON COLUMN public.sys_role.remark IS '备注';

-- sys_menu 菜单权限表
COMMENT ON TABLE public.sys_menu IS '菜单权限表';
COMMENT ON COLUMN public.sys_menu.menu_id IS '菜单ID';
COMMENT ON COLUMN public.sys_menu.menu_name IS '菜单名称';
COMMENT ON COLUMN public.sys_menu.parent_id IS '父菜单ID';
COMMENT ON COLUMN public.sys_menu.order_num IS '显示顺序';
COMMENT ON COLUMN public.sys_menu.path IS '路由地址';
COMMENT ON COLUMN public.sys_menu.component IS '组件路径';
COMMENT ON COLUMN public.sys_menu.is_frame IS '是否为外链（0是 1否）';
COMMENT ON COLUMN public.sys_menu.is_cache IS '是否缓存（0缓存 1不缓存）';
COMMENT ON COLUMN public.sys_menu.menu_type IS '菜单类型（M目录 C菜单 F按钮）';
COMMENT ON COLUMN public.sys_menu.visible IS '菜单状态（0显示 1隐藏）';
COMMENT ON COLUMN public.sys_menu.status IS '菜单状态（0正常 1停用）';
COMMENT ON COLUMN public.sys_menu.perms IS '权限标识';
COMMENT ON COLUMN public.sys_menu.icon IS '菜单图标';
COMMENT ON COLUMN public.sys_menu.create_by IS '创建者';
COMMENT ON COLUMN public.sys_menu.create_time IS '创建时间';
COMMENT ON COLUMN public.sys_menu.update_by IS '更新者';
COMMENT ON COLUMN public.sys_menu.update_time IS '更新时间';
COMMENT ON COLUMN public.sys_menu.remark IS '备注';

-- 关联与日志等常用表（可按需扩展）
COMMENT ON TABLE public.sys_user_role IS '用户与角色关联表';
COMMENT ON COLUMN public.sys_user_role.user_id IS '用户ID';
COMMENT ON COLUMN public.sys_user_role.role_id IS '角色ID';

COMMENT ON TABLE public.sys_role_menu IS '角色与菜单关联表';
COMMENT ON COLUMN public.sys_role_menu.role_id IS '角色ID';
COMMENT ON COLUMN public.sys_role_menu.menu_id IS '菜单ID';

COMMENT ON TABLE public.sys_role_dept IS '角色与部门关联表';
COMMENT ON COLUMN public.sys_role_dept.role_id IS '角色ID';
COMMENT ON COLUMN public.sys_role_dept.dept_id IS '部门ID';

COMMENT ON TABLE public.sys_user_post IS '用户与岗位关联表';
COMMENT ON COLUMN public.sys_user_post.user_id IS '用户ID';
COMMENT ON COLUMN public.sys_user_post.post_id IS '岗位ID';

COMMENT ON TABLE public.sys_oper_log IS '操作日志记录';
COMMENT ON COLUMN public.sys_oper_log.oper_id IS '日志主键';
COMMENT ON COLUMN public.sys_oper_log.title IS '模块标题';
COMMENT ON COLUMN public.sys_oper_log.business_type IS '业务类型（0其它 1新增 2修改 3删除）';
COMMENT ON COLUMN public.sys_oper_log.method IS '方法名称';
COMMENT ON COLUMN public.sys_oper_log.request_method IS '请求方式';
COMMENT ON COLUMN public.sys_oper_log.operator_type IS '操作类别（0其它 1后台用户 2手机端用户）';
COMMENT ON COLUMN public.sys_oper_log.oper_name IS '操作人员';
COMMENT ON COLUMN public.sys_oper_log.dept_name IS '部门名称';
COMMENT ON COLUMN public.sys_oper_log.oper_url IS '请求URL';
COMMENT ON COLUMN public.sys_oper_log.oper_ip IS '主机IP地址';
COMMENT ON COLUMN public.sys_oper_log.oper_location IS '操作地点';
COMMENT ON COLUMN public.sys_oper_log.oper_param IS '请求参数';
COMMENT ON COLUMN public.sys_oper_log.json_result IS '返回参数';
COMMENT ON COLUMN public.sys_oper_log.status IS '操作状态（0正常 1异常）';
COMMENT ON COLUMN public.sys_oper_log.error_msg IS '错误消息';
COMMENT ON COLUMN public.sys_oper_log.oper_time IS '操作时间';

COMMENT ON TABLE public.sys_dict_type IS '字典类型表';
COMMENT ON COLUMN public.sys_dict_type.dict_id IS '字典主键';
COMMENT ON COLUMN public.sys_dict_type.dict_name IS '字典名称';
COMMENT ON COLUMN public.sys_dict_type.dict_type IS '字典类型';
COMMENT ON COLUMN public.sys_dict_type.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN public.sys_dict_type.create_by IS '创建者';
COMMENT ON COLUMN public.sys_dict_type.create_time IS '创建时间';
COMMENT ON COLUMN public.sys_dict_type.update_by IS '更新者';
COMMENT ON COLUMN public.sys_dict_type.update_time IS '更新时间';
COMMENT ON COLUMN public.sys_dict_type.remark IS '备注';

COMMENT ON TABLE public.sys_dict_data IS '字典数据表';
COMMENT ON COLUMN public.sys_dict_data.dict_code IS '字典编码';
COMMENT ON COLUMN public.sys_dict_data.dict_sort IS '字典排序';
COMMENT ON COLUMN public.sys_dict_data.dict_label IS '字典标签';
COMMENT ON COLUMN public.sys_dict_data.dict_value IS '字典键值';
COMMENT ON COLUMN public.sys_dict_data.dict_type IS '字典类型';
COMMENT ON COLUMN public.sys_dict_data.css_class IS '样式属性';
COMMENT ON COLUMN public.sys_dict_data.list_class IS '表格回显样式';
COMMENT ON COLUMN public.sys_dict_data.is_default IS '是否默认（Y是 N否）';
COMMENT ON COLUMN public.sys_dict_data.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN public.sys_dict_data.create_by IS '创建者';
COMMENT ON COLUMN public.sys_dict_data.create_time IS '创建时间';
COMMENT ON COLUMN public.sys_dict_data.update_by IS '更新者';
COMMENT ON COLUMN public.sys_dict_data.update_time IS '更新时间';
COMMENT ON COLUMN public.sys_dict_data.remark IS '备注';

COMMENT ON TABLE public.sys_config IS '参数配置表';
COMMENT ON COLUMN public.sys_config.config_id IS '参数主键';
COMMENT ON COLUMN public.sys_config.config_name IS '参数名称';
COMMENT ON COLUMN public.sys_config.config_key IS '参数键名';
COMMENT ON COLUMN public.sys_config.config_value IS '参数键值';
COMMENT ON COLUMN public.sys_config.config_type IS '系统内置（Y是 N否）';
COMMENT ON COLUMN public.sys_config.create_by IS '创建者';
COMMENT ON COLUMN public.sys_config.create_time IS '创建时间';
COMMENT ON COLUMN public.sys_config.update_by IS '更新者';
COMMENT ON COLUMN public.sys_config.update_time IS '更新时间';
COMMENT ON COLUMN public.sys_config.remark IS '备注';

COMMENT ON TABLE public.sys_login_log IS '系统访问记录';
COMMENT ON COLUMN public.sys_login_log.info_id IS '访问ID';
COMMENT ON COLUMN public.sys_login_log.user_name IS '用户账号';
COMMENT ON COLUMN public.sys_login_log.ipaddr IS '登录IP地址';
COMMENT ON COLUMN public.sys_login_log.login_location IS '登录地点';
COMMENT ON COLUMN public.sys_login_log.browser IS '浏览器类型';
COMMENT ON COLUMN public.sys_login_log.os IS '操作系统';
COMMENT ON COLUMN public.sys_login_log.status IS '登录状态（0成功 1失败）';
COMMENT ON COLUMN public.sys_login_log.msg IS '提示消息';
COMMENT ON COLUMN public.sys_login_log.login_time IS '访问时间';

COMMENT ON TABLE public.sys_notice IS '通知公告表';
COMMENT ON COLUMN public.sys_notice.notice_id IS '公告ID';
COMMENT ON COLUMN public.sys_notice.notice_title IS '公告标题';
COMMENT ON COLUMN public.sys_notice.notice_type IS '公告类型（1通知 2公告）';
COMMENT ON COLUMN public.sys_notice.notice_content IS '公告内容';
COMMENT ON COLUMN public.sys_notice.status IS '公告状态（0正常 1关闭）';
COMMENT ON COLUMN public.sys_notice.create_by IS '创建者';
COMMENT ON COLUMN public.sys_notice.create_time IS '创建时间';
COMMENT ON COLUMN public.sys_notice.update_by IS '更新者';
COMMENT ON COLUMN public.sys_notice.update_time IS '更新时间';
COMMENT ON COLUMN public.sys_notice.remark IS '备注';

COMMENT ON TABLE public.sys_job IS '定时任务调度表';
COMMENT ON COLUMN public.sys_job.job_id IS '任务ID';
COMMENT ON COLUMN public.sys_job.job_name IS '任务名称';
COMMENT ON COLUMN public.sys_job.job_group IS '任务组名';
COMMENT ON COLUMN public.sys_job.invoke_target IS '调用目标字符串';
COMMENT ON COLUMN public.sys_job.cron_expression IS 'cron执行表达式';
COMMENT ON COLUMN public.sys_job.misfire_policy IS '计划执行错误策略（1立即执行 2执行一次 3放弃执行）';
COMMENT ON COLUMN public.sys_job.concurrent IS '是否并发执行（0允许 1禁止）';
COMMENT ON COLUMN public.sys_job.status IS '状态（0正常 1暂停）';
COMMENT ON COLUMN public.sys_job.create_by IS '创建者';
COMMENT ON COLUMN public.sys_job.create_time IS '创建时间';
COMMENT ON COLUMN public.sys_job.update_by IS '更新者';
COMMENT ON COLUMN public.sys_job.update_time IS '更新时间';
COMMENT ON COLUMN public.sys_job.remark IS '备注信息';

COMMENT ON TABLE public.sys_job_log IS '定时任务调度日志表';
COMMENT ON COLUMN public.sys_job_log.job_log_id IS '任务日志ID';
COMMENT ON COLUMN public.sys_job_log.job_name IS '任务名称';
COMMENT ON COLUMN public.sys_job_log.job_group IS '任务组名';
COMMENT ON COLUMN public.sys_job_log.invoke_target IS '调用目标字符串';
COMMENT ON COLUMN public.sys_job_log.job_message IS '日志信息';
COMMENT ON COLUMN public.sys_job_log.status IS '执行状态（0正常 1失败）';
COMMENT ON COLUMN public.sys_job_log.exception_info IS '异常信息';
COMMENT ON COLUMN public.sys_job_log.create_time IS '创建时间';



-- =============================================
-- 索引注释
-- =============================================

-- sys_dept 索引
COMMENT ON INDEX public.sys_dept_parent_id_idx IS '部门父级ID索引，用于树形结构查询';
COMMENT ON INDEX public.sys_dept_status_del_flag_idx IS '部门状态+删除标志复合索引';

-- sys_user 索引
COMMENT ON INDEX public.sys_user_user_name_del_flag_key IS '用户名+删除标志唯一索引，确保未删除用户名唯一';
COMMENT ON INDEX public.sys_user_dept_id_idx IS '用户部门ID索引，用于按部门查询用户';
COMMENT ON INDEX public.sys_user_status_del_flag_idx IS '用户状态+删除标志复合索引';
COMMENT ON INDEX public.sys_user_phonenumber_idx IS '用户手机号索引';
COMMENT ON INDEX public.sys_user_email_idx IS '用户邮箱索引';

-- sys_post 索引
COMMENT ON INDEX public.sys_post_post_code_key IS '岗位编码唯一索引';
COMMENT ON INDEX public.sys_post_status_idx IS '岗位状态索引';

-- sys_role 索引
COMMENT ON INDEX public.sys_role_role_key_del_flag_key IS '角色标识+删除标志唯一索引';
COMMENT ON INDEX public.sys_role_status_del_flag_idx IS '角色状态+删除标志复合索引';

-- sys_menu 索引
COMMENT ON INDEX public.sys_menu_parent_id_idx IS '菜单父级ID索引，用于树形结构查询';
COMMENT ON INDEX public.sys_menu_status_visible_idx IS '菜单状态+可见性复合索引';
COMMENT ON INDEX public.sys_menu_perms_idx IS '菜单权限标识索引，用于权限校验';

-- sys_oper_log 索引
COMMENT ON INDEX public.sys_oper_log_oper_time_idx IS '操作日志时间索引，用于按时间范围查询';
COMMENT ON INDEX public.sys_oper_log_oper_name_idx IS '操作日志操作人索引';
COMMENT ON INDEX public.sys_oper_log_business_type_idx IS '操作日志业务类型索引';
COMMENT ON INDEX public.sys_oper_log_status_idx IS '操作日志状态索引';

-- sys_dict_type 索引
COMMENT ON INDEX public.sys_dict_type_dict_type_key IS '字典类型唯一索引';
COMMENT ON INDEX public.sys_dict_type_status_idx IS '字典类型状态索引';

-- sys_dict_data 索引
COMMENT ON INDEX public.sys_dict_data_dict_type_idx IS '字典数据类型索引，用于按类型查询字典项';
COMMENT ON INDEX public.sys_dict_data_status_idx IS '字典数据状态索引';

-- sys_config 索引
COMMENT ON INDEX public.sys_config_config_key_key IS '系统配置键名唯一索引';

-- sys_login_log 索引
COMMENT ON INDEX public.sys_login_log_login_time_idx IS '登录日志时间索引，用于按时间范围查询';
COMMENT ON INDEX public.sys_login_log_user_name_idx IS '登录日志用户名索引';
COMMENT ON INDEX public.sys_login_log_status_idx IS '登录日志状态索引';

-- sys_notice 索引
COMMENT ON INDEX public.sys_notice_status_idx IS '通知公告状态索引';
COMMENT ON INDEX public.sys_notice_notice_type_idx IS '通知公告类型索引';

-- sys_job 索引
COMMENT ON INDEX public.sys_job_status_idx IS '定时任务状态索引';
COMMENT ON INDEX public.sys_job_job_group_idx IS '定时任务分组索引';

-- sys_job_log 索引
COMMENT ON INDEX public.sys_job_log_create_time_idx IS '任务日志创建时间索引';
COMMENT ON INDEX public.sys_job_log_job_name_job_group_idx IS '任务日志名称+分组复合索引';
COMMENT ON INDEX public.sys_job_log_status_idx IS '任务日志状态索引';

