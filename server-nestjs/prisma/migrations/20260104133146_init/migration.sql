-- CreateTable
CREATE TABLE "sys_dept" (
    "dept_id" BIGSERIAL NOT NULL,
    "parent_id" BIGINT,
    "ancestors" VARCHAR(500) DEFAULT '',
    "dept_name" VARCHAR(50) NOT NULL,
    "order_num" INTEGER DEFAULT 0,
    "leader" VARCHAR(20),
    "phone" VARCHAR(11),
    "email" VARCHAR(50),
    "status" CHAR(1) DEFAULT '0',
    "del_flag" CHAR(1) DEFAULT '0',
    "create_by" VARCHAR(64) DEFAULT '',
    "create_time" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "update_by" VARCHAR(64) DEFAULT '',
    "update_time" TIMESTAMP(6),

    CONSTRAINT "sys_dept_pkey" PRIMARY KEY ("dept_id")
);

-- CreateTable
CREATE TABLE "sys_user" (
    "user_id" BIGSERIAL NOT NULL,
    "dept_id" BIGINT,
    "user_name" VARCHAR(30) NOT NULL,
    "nick_name" VARCHAR(30) NOT NULL,
    "user_type" VARCHAR(2) DEFAULT '00',
    "email" VARCHAR(50) DEFAULT '',
    "phonenumber" VARCHAR(11) DEFAULT '',
    "sex" CHAR(1) DEFAULT '0',
    "avatar" VARCHAR(100) DEFAULT '',
    "password" VARCHAR(100) DEFAULT '',
    "status" CHAR(1) DEFAULT '0',
    "del_flag" CHAR(1) DEFAULT '0',
    "login_ip" VARCHAR(128) DEFAULT '',
    "login_date" TIMESTAMP(6),
    "two_factor_secret" VARCHAR(100),
    "two_factor_enabled" BOOLEAN DEFAULT false,
    "create_by" VARCHAR(64) DEFAULT '',
    "create_time" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "update_by" VARCHAR(64) DEFAULT '',
    "update_time" TIMESTAMP(6),
    "remark" VARCHAR(500),

    CONSTRAINT "sys_user_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "sys_post" (
    "post_id" BIGSERIAL NOT NULL,
    "post_code" VARCHAR(64) NOT NULL,
    "post_name" VARCHAR(50) NOT NULL,
    "post_sort" INTEGER NOT NULL,
    "status" CHAR(1) NOT NULL,
    "create_by" VARCHAR(64) DEFAULT '',
    "create_time" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "update_by" VARCHAR(64) DEFAULT '',
    "update_time" TIMESTAMP(6),
    "remark" VARCHAR(500),

    CONSTRAINT "sys_post_pkey" PRIMARY KEY ("post_id")
);

-- CreateTable
CREATE TABLE "sys_role" (
    "role_id" BIGSERIAL NOT NULL,
    "role_name" VARCHAR(30) NOT NULL,
    "role_key" VARCHAR(100) NOT NULL,
    "role_sort" INTEGER NOT NULL,
    "data_scope" CHAR(1) DEFAULT '1',
    "menu_check_strictly" BOOLEAN DEFAULT true,
    "dept_check_strictly" BOOLEAN DEFAULT true,
    "status" CHAR(1) NOT NULL,
    "del_flag" CHAR(1) DEFAULT '0',
    "create_by" VARCHAR(64) DEFAULT '',
    "create_time" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "update_by" VARCHAR(64) DEFAULT '',
    "update_time" TIMESTAMP(6),
    "remark" VARCHAR(500),

    CONSTRAINT "sys_role_pkey" PRIMARY KEY ("role_id")
);

-- CreateTable
CREATE TABLE "sys_menu" (
    "menu_id" BIGSERIAL NOT NULL,
    "menu_name" VARCHAR(50) NOT NULL,
    "parent_id" BIGINT,
    "order_num" INTEGER DEFAULT 0,
    "path" VARCHAR(200) DEFAULT '',
    "component" VARCHAR(255),
    "is_frame" INTEGER DEFAULT 1,
    "is_cache" INTEGER DEFAULT 0,
    "menu_type" CHAR(1) DEFAULT '',
    "visible" CHAR(1) DEFAULT '0',
    "status" CHAR(1) DEFAULT '0',
    "perms" VARCHAR(100),
    "icon" VARCHAR(100) DEFAULT '#',
    "create_by" VARCHAR(64) DEFAULT '',
    "create_time" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "update_by" VARCHAR(64) DEFAULT '',
    "update_time" TIMESTAMP(6),
    "remark" VARCHAR(500),

    CONSTRAINT "sys_menu_pkey" PRIMARY KEY ("menu_id")
);

-- CreateTable
CREATE TABLE "sys_user_role" (
    "user_id" BIGINT NOT NULL,
    "role_id" BIGINT NOT NULL,

    CONSTRAINT "sys_user_role_pkey" PRIMARY KEY ("user_id","role_id")
);

-- CreateTable
CREATE TABLE "sys_role_menu" (
    "role_id" BIGINT NOT NULL,
    "menu_id" BIGINT NOT NULL,

    CONSTRAINT "sys_role_menu_pkey" PRIMARY KEY ("role_id","menu_id")
);

-- CreateTable
CREATE TABLE "sys_role_dept" (
    "role_id" BIGINT NOT NULL,
    "dept_id" BIGINT NOT NULL,

    CONSTRAINT "sys_role_dept_pkey" PRIMARY KEY ("role_id","dept_id")
);

-- CreateTable
CREATE TABLE "sys_user_post" (
    "user_id" BIGINT NOT NULL,
    "post_id" BIGINT NOT NULL,

    CONSTRAINT "sys_user_post_pkey" PRIMARY KEY ("user_id","post_id")
);

-- CreateTable
CREATE TABLE "sys_oper_log" (
    "oper_id" BIGSERIAL NOT NULL,
    "title" VARCHAR(50) DEFAULT '',
    "business_type" INTEGER DEFAULT 0,
    "method" VARCHAR(100) DEFAULT '',
    "request_method" VARCHAR(10) DEFAULT '',
    "operator_type" INTEGER DEFAULT 0,
    "oper_name" VARCHAR(50) DEFAULT '',
    "dept_name" VARCHAR(50) DEFAULT '',
    "oper_url" VARCHAR(255) DEFAULT '',
    "oper_ip" VARCHAR(128) DEFAULT '',
    "oper_location" VARCHAR(255) DEFAULT '',
    "oper_param" TEXT DEFAULT '',
    "json_result" TEXT DEFAULT '',
    "status" INTEGER DEFAULT 0,
    "error_msg" TEXT DEFAULT '',
    "oper_time" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sys_oper_log_pkey" PRIMARY KEY ("oper_id")
);

-- CreateTable
CREATE TABLE "sys_dict_type" (
    "dict_id" BIGSERIAL NOT NULL,
    "dict_name" VARCHAR(100) DEFAULT '',
    "dict_type" VARCHAR(100) DEFAULT '',
    "status" CHAR(1) DEFAULT '0',
    "create_by" VARCHAR(64) DEFAULT '',
    "create_time" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "update_by" VARCHAR(64) DEFAULT '',
    "update_time" TIMESTAMP(6),
    "remark" VARCHAR(500),

    CONSTRAINT "sys_dict_type_pkey" PRIMARY KEY ("dict_id")
);

-- CreateTable
CREATE TABLE "sys_dict_data" (
    "dict_code" BIGSERIAL NOT NULL,
    "dict_sort" INTEGER DEFAULT 0,
    "dict_label" VARCHAR(100) DEFAULT '',
    "dict_value" VARCHAR(100) DEFAULT '',
    "dict_type" VARCHAR(100) DEFAULT '',
    "css_class" VARCHAR(100),
    "list_class" VARCHAR(100),
    "is_default" CHAR(1) DEFAULT 'N',
    "status" CHAR(1) DEFAULT '0',
    "create_by" VARCHAR(64) DEFAULT '',
    "create_time" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "update_by" VARCHAR(64) DEFAULT '',
    "update_time" TIMESTAMP(6),
    "remark" VARCHAR(500),

    CONSTRAINT "sys_dict_data_pkey" PRIMARY KEY ("dict_code")
);

-- CreateTable
CREATE TABLE "sys_config" (
    "config_id" BIGSERIAL NOT NULL,
    "config_name" VARCHAR(100) DEFAULT '',
    "config_key" VARCHAR(100) DEFAULT '',
    "config_value" TEXT DEFAULT '',
    "config_type" CHAR(1) DEFAULT 'N',
    "create_by" VARCHAR(64) DEFAULT '',
    "create_time" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "update_by" VARCHAR(64) DEFAULT '',
    "update_time" TIMESTAMP(6),
    "remark" VARCHAR(500),

    CONSTRAINT "sys_config_pkey" PRIMARY KEY ("config_id")
);

-- CreateTable
CREATE TABLE "sys_login_log" (
    "info_id" BIGSERIAL NOT NULL,
    "user_name" VARCHAR(50) DEFAULT '',
    "ipaddr" VARCHAR(128) DEFAULT '',
    "login_location" VARCHAR(255) DEFAULT '',
    "browser" VARCHAR(50) DEFAULT '',
    "os" VARCHAR(50) DEFAULT '',
    "status" CHAR(1) DEFAULT '0',
    "msg" VARCHAR(255) DEFAULT '',
    "login_time" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sys_login_log_pkey" PRIMARY KEY ("info_id")
);

-- CreateTable
CREATE TABLE "sys_notice" (
    "notice_id" BIGSERIAL NOT NULL,
    "notice_title" VARCHAR(50) NOT NULL,
    "notice_type" CHAR(1) NOT NULL,
    "notice_content" TEXT,
    "status" CHAR(1) DEFAULT '0',
    "create_by" VARCHAR(64) DEFAULT '',
    "create_time" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "update_by" VARCHAR(64) DEFAULT '',
    "update_time" TIMESTAMP(6),
    "remark" VARCHAR(255),

    CONSTRAINT "sys_notice_pkey" PRIMARY KEY ("notice_id")
);

-- CreateTable
CREATE TABLE "sys_job" (
    "job_id" BIGSERIAL NOT NULL,
    "job_name" VARCHAR(64) DEFAULT '',
    "job_group" VARCHAR(64) DEFAULT 'DEFAULT',
    "invoke_target" VARCHAR(500) NOT NULL,
    "cron_expression" VARCHAR(255) DEFAULT '',
    "misfire_policy" VARCHAR(20) DEFAULT '3',
    "concurrent" CHAR(1) DEFAULT '1',
    "status" CHAR(1) DEFAULT '0',
    "create_by" VARCHAR(64) DEFAULT '',
    "create_time" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "update_by" VARCHAR(64) DEFAULT '',
    "update_time" TIMESTAMP(6),
    "remark" VARCHAR(500),

    CONSTRAINT "sys_job_pkey" PRIMARY KEY ("job_id")
);

-- CreateTable
CREATE TABLE "sys_job_log" (
    "job_log_id" BIGSERIAL NOT NULL,
    "job_name" VARCHAR(64) NOT NULL,
    "job_group" VARCHAR(64) NOT NULL,
    "invoke_target" VARCHAR(500) NOT NULL,
    "job_message" VARCHAR(500),
    "status" CHAR(1) DEFAULT '0',
    "exception_info" TEXT,
    "create_time" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sys_job_log_pkey" PRIMARY KEY ("job_log_id")
);

-- CreateTable
CREATE TABLE "app_user" (
    "id" TEXT NOT NULL,
    "phone" VARCHAR(20),
    "email" VARCHAR(100),
    "password" VARCHAR(100),
    "nickname" VARCHAR(50) NOT NULL,
    "avatar" VARCHAR(255),
    "gender" CHAR(1),
    "birthday" DATE,
    "bio" VARCHAR(255),
    "open_id" VARCHAR(100),
    "union_id" VARCHAR(100),
    "google_id" VARCHAR(100),
    "apple_id" VARCHAR(100),
    "login_type" VARCHAR(20) NOT NULL DEFAULT 'wechat',
    "invite_code" VARCHAR(20),
    "invited_by" VARCHAR(30),
    "badge_title" VARCHAR(50),
    "total_points" INTEGER NOT NULL DEFAULT 0,
    "level" INTEGER NOT NULL DEFAULT 1,
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "last_login_time" TIMESTAMP(3),
    "last_login_ip" VARCHAR(50),
    "status" CHAR(1) NOT NULL DEFAULT '0',
    "create_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "app_user_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_verification" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "real_name" VARCHAR(50) NOT NULL,
    "id_card_no" VARCHAR(100) NOT NULL,
    "id_card_front" VARCHAR(255),
    "id_card_back" VARCHAR(255),
    "status" VARCHAR(20) NOT NULL DEFAULT 'pending',
    "reject_reason" VARCHAR(255),
    "verified_at" TIMESTAMP(3),
    "create_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_verification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "city" (
    "id" TEXT NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "province" VARCHAR(50) NOT NULL,
    "latitude" DECIMAL(10,7) NOT NULL,
    "longitude" DECIMAL(10,7) NOT NULL,
    "icon_asset" VARCHAR(255),
    "cover_image" VARCHAR(255),
    "description" TEXT,
    "explorer_count" INTEGER NOT NULL DEFAULT 0,
    "bgm_url" VARCHAR(255),
    "order_num" INTEGER NOT NULL DEFAULT 0,
    "status" CHAR(1) NOT NULL DEFAULT '0',
    "create_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "city_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "journey" (
    "id" TEXT NOT NULL,
    "city_id" TEXT NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "theme" VARCHAR(100) NOT NULL,
    "cover_image" VARCHAR(255),
    "description" TEXT,
    "rating" INTEGER NOT NULL DEFAULT 5,
    "estimated_minutes" INTEGER NOT NULL,
    "total_distance" DECIMAL(10,2) NOT NULL,
    "completed_count" INTEGER NOT NULL DEFAULT 0,
    "is_locked" BOOLEAN NOT NULL DEFAULT false,
    "unlock_condition" VARCHAR(255),
    "bgm_url" VARCHAR(255),
    "order_num" INTEGER NOT NULL DEFAULT 0,
    "status" CHAR(1) NOT NULL DEFAULT '0',
    "create_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "journey_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "exploration_point" (
    "id" TEXT NOT NULL,
    "journey_id" TEXT NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "latitude" DECIMAL(10,7) NOT NULL,
    "longitude" DECIMAL(10,7) NOT NULL,
    "task_type" VARCHAR(20) NOT NULL,
    "task_description" VARCHAR(255) NOT NULL,
    "target_gesture" VARCHAR(50),
    "ar_asset_url" VARCHAR(255),
    "cultural_background" TEXT,
    "cultural_knowledge" TEXT,
    "distance_from_prev" DECIMAL(10,2),
    "points_reward" INTEGER NOT NULL DEFAULT 50,
    "bgm_id" TEXT,
    "order_num" INTEGER NOT NULL,
    "status" CHAR(1) NOT NULL DEFAULT '0',
    "create_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "exploration_point_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "journey_progress" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "journey_id" TEXT NOT NULL,
    "status" VARCHAR(20) NOT NULL DEFAULT 'in_progress',
    "start_time" TIMESTAMP(3) NOT NULL,
    "complete_time" TIMESTAMP(3),
    "time_spent_minutes" INTEGER,
    "create_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "journey_progress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "point_completion" (
    "id" TEXT NOT NULL,
    "progress_id" TEXT NOT NULL,
    "point_id" TEXT NOT NULL,
    "complete_time" TIMESTAMP(3) NOT NULL,
    "points_earned" INTEGER NOT NULL,
    "photo_url" VARCHAR(255),
    "create_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "point_completion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "seal" (
    "id" TEXT NOT NULL,
    "type" VARCHAR(20) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "image_asset" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "unlock_condition" VARCHAR(255),
    "badge_title" VARCHAR(50),
    "journey_id" TEXT,
    "city_id" TEXT,
    "order_num" INTEGER NOT NULL DEFAULT 0,
    "status" CHAR(1) NOT NULL DEFAULT '0',
    "create_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "seal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_seal" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "seal_id" TEXT NOT NULL,
    "earned_time" TIMESTAMP(3) NOT NULL,
    "time_spent_minutes" INTEGER,
    "points_earned" INTEGER NOT NULL DEFAULT 0,
    "is_chained" BOOLEAN NOT NULL DEFAULT false,
    "chain_name" VARCHAR(50),
    "tx_hash" VARCHAR(100),
    "block_height" BIGINT,
    "chain_time" TIMESTAMP(3),
    "chain_certificate" JSONB,
    "create_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_seal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "exploration_photo" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "journey_id" TEXT NOT NULL,
    "point_id" TEXT NOT NULL,
    "photo_url" VARCHAR(255) NOT NULL,
    "thumbnail_url" VARCHAR(255),
    "filter" VARCHAR(20),
    "latitude" DECIMAL(10,7),
    "longitude" DECIMAL(10,7),
    "taken_time" TIMESTAMP(3) NOT NULL,
    "create_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "exploration_photo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_activity" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "type" VARCHAR(50) NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "related_id" TEXT,
    "create_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_activity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "background_music" (
    "id" TEXT NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "url" VARCHAR(255) NOT NULL,
    "context" VARCHAR(20) NOT NULL,
    "context_id" TEXT,
    "duration" INTEGER,
    "order_num" INTEGER NOT NULL DEFAULT 0,
    "status" CHAR(1) NOT NULL DEFAULT '0',
    "create_time" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "background_music_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "sys_dept_parent_id_idx" ON "sys_dept"("parent_id");

-- CreateIndex
CREATE INDEX "sys_dept_status_del_flag_idx" ON "sys_dept"("status", "del_flag");

-- CreateIndex
CREATE INDEX "sys_user_dept_id_idx" ON "sys_user"("dept_id");

-- CreateIndex
CREATE INDEX "sys_user_status_del_flag_idx" ON "sys_user"("status", "del_flag");

-- CreateIndex
CREATE INDEX "sys_user_phonenumber_idx" ON "sys_user"("phonenumber");

-- CreateIndex
CREATE INDEX "sys_user_email_idx" ON "sys_user"("email");

-- CreateIndex
CREATE UNIQUE INDEX "sys_user_user_name_del_flag_key" ON "sys_user"("user_name", "del_flag");

-- CreateIndex
CREATE INDEX "sys_post_status_idx" ON "sys_post"("status");

-- CreateIndex
CREATE UNIQUE INDEX "sys_post_post_code_key" ON "sys_post"("post_code");

-- CreateIndex
CREATE INDEX "sys_role_status_del_flag_idx" ON "sys_role"("status", "del_flag");

-- CreateIndex
CREATE UNIQUE INDEX "sys_role_role_key_del_flag_key" ON "sys_role"("role_key", "del_flag");

-- CreateIndex
CREATE INDEX "sys_menu_parent_id_idx" ON "sys_menu"("parent_id");

-- CreateIndex
CREATE INDEX "sys_menu_status_visible_idx" ON "sys_menu"("status", "visible");

-- CreateIndex
CREATE INDEX "sys_menu_perms_idx" ON "sys_menu"("perms");

-- CreateIndex
CREATE INDEX "sys_oper_log_oper_time_idx" ON "sys_oper_log"("oper_time");

-- CreateIndex
CREATE INDEX "sys_oper_log_oper_name_idx" ON "sys_oper_log"("oper_name");

-- CreateIndex
CREATE INDEX "sys_oper_log_business_type_idx" ON "sys_oper_log"("business_type");

-- CreateIndex
CREATE INDEX "sys_oper_log_status_idx" ON "sys_oper_log"("status");

-- CreateIndex
CREATE INDEX "sys_dict_type_status_idx" ON "sys_dict_type"("status");

-- CreateIndex
CREATE UNIQUE INDEX "sys_dict_type_dict_type_key" ON "sys_dict_type"("dict_type");

-- CreateIndex
CREATE INDEX "sys_dict_data_dict_type_idx" ON "sys_dict_data"("dict_type");

-- CreateIndex
CREATE INDEX "sys_dict_data_status_idx" ON "sys_dict_data"("status");

-- CreateIndex
CREATE UNIQUE INDEX "sys_config_config_key_key" ON "sys_config"("config_key");

-- CreateIndex
CREATE INDEX "sys_login_log_login_time_idx" ON "sys_login_log"("login_time");

-- CreateIndex
CREATE INDEX "sys_login_log_user_name_idx" ON "sys_login_log"("user_name");

-- CreateIndex
CREATE INDEX "sys_login_log_status_idx" ON "sys_login_log"("status");

-- CreateIndex
CREATE INDEX "sys_notice_status_idx" ON "sys_notice"("status");

-- CreateIndex
CREATE INDEX "sys_notice_notice_type_idx" ON "sys_notice"("notice_type");

-- CreateIndex
CREATE INDEX "sys_job_status_idx" ON "sys_job"("status");

-- CreateIndex
CREATE INDEX "sys_job_job_group_idx" ON "sys_job"("job_group");

-- CreateIndex
CREATE INDEX "sys_job_log_create_time_idx" ON "sys_job_log"("create_time");

-- CreateIndex
CREATE INDEX "sys_job_log_job_name_job_group_idx" ON "sys_job_log"("job_name", "job_group");

-- CreateIndex
CREATE INDEX "sys_job_log_status_idx" ON "sys_job_log"("status");

-- CreateIndex
CREATE UNIQUE INDEX "app_user_phone_key" ON "app_user"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "app_user_email_key" ON "app_user"("email");

-- CreateIndex
CREATE UNIQUE INDEX "app_user_open_id_key" ON "app_user"("open_id");

-- CreateIndex
CREATE UNIQUE INDEX "app_user_google_id_key" ON "app_user"("google_id");

-- CreateIndex
CREATE UNIQUE INDEX "app_user_apple_id_key" ON "app_user"("apple_id");

-- CreateIndex
CREATE UNIQUE INDEX "app_user_invite_code_key" ON "app_user"("invite_code");

-- CreateIndex
CREATE INDEX "app_user_phone_idx" ON "app_user"("phone");

-- CreateIndex
CREATE INDEX "app_user_email_idx" ON "app_user"("email");

-- CreateIndex
CREATE INDEX "app_user_open_id_idx" ON "app_user"("open_id");

-- CreateIndex
CREATE INDEX "app_user_google_id_idx" ON "app_user"("google_id");

-- CreateIndex
CREATE INDEX "app_user_apple_id_idx" ON "app_user"("apple_id");

-- CreateIndex
CREATE INDEX "app_user_login_type_idx" ON "app_user"("login_type");

-- CreateIndex
CREATE INDEX "app_user_invite_code_idx" ON "app_user"("invite_code");

-- CreateIndex
CREATE UNIQUE INDEX "user_verification_user_id_key" ON "user_verification"("user_id");

-- CreateIndex
CREATE INDEX "user_verification_status_idx" ON "user_verification"("status");

-- CreateIndex
CREATE INDEX "city_province_idx" ON "city"("province");

-- CreateIndex
CREATE INDEX "city_status_idx" ON "city"("status");

-- CreateIndex
CREATE INDEX "journey_city_id_idx" ON "journey"("city_id");

-- CreateIndex
CREATE INDEX "journey_status_idx" ON "journey"("status");

-- CreateIndex
CREATE INDEX "exploration_point_journey_id_idx" ON "exploration_point"("journey_id");

-- CreateIndex
CREATE INDEX "exploration_point_bgm_id_idx" ON "exploration_point"("bgm_id");

-- CreateIndex
CREATE INDEX "exploration_point_status_idx" ON "exploration_point"("status");

-- CreateIndex
CREATE INDEX "journey_progress_user_id_idx" ON "journey_progress"("user_id");

-- CreateIndex
CREATE INDEX "journey_progress_journey_id_idx" ON "journey_progress"("journey_id");

-- CreateIndex
CREATE INDEX "journey_progress_status_idx" ON "journey_progress"("status");

-- CreateIndex
CREATE UNIQUE INDEX "journey_progress_user_id_journey_id_key" ON "journey_progress"("user_id", "journey_id");

-- CreateIndex
CREATE INDEX "point_completion_progress_id_idx" ON "point_completion"("progress_id");

-- CreateIndex
CREATE INDEX "point_completion_point_id_idx" ON "point_completion"("point_id");

-- CreateIndex
CREATE UNIQUE INDEX "point_completion_progress_id_point_id_key" ON "point_completion"("progress_id", "point_id");

-- CreateIndex
CREATE INDEX "seal_type_idx" ON "seal"("type");

-- CreateIndex
CREATE INDEX "seal_journey_id_idx" ON "seal"("journey_id");

-- CreateIndex
CREATE INDEX "seal_city_id_idx" ON "seal"("city_id");

-- CreateIndex
CREATE INDEX "seal_status_idx" ON "seal"("status");

-- CreateIndex
CREATE INDEX "user_seal_user_id_idx" ON "user_seal"("user_id");

-- CreateIndex
CREATE INDEX "user_seal_seal_id_idx" ON "user_seal"("seal_id");

-- CreateIndex
CREATE INDEX "user_seal_is_chained_idx" ON "user_seal"("is_chained");

-- CreateIndex
CREATE UNIQUE INDEX "user_seal_user_id_seal_id_key" ON "user_seal"("user_id", "seal_id");

-- CreateIndex
CREATE INDEX "exploration_photo_user_id_idx" ON "exploration_photo"("user_id");

-- CreateIndex
CREATE INDEX "exploration_photo_journey_id_idx" ON "exploration_photo"("journey_id");

-- CreateIndex
CREATE INDEX "exploration_photo_point_id_idx" ON "exploration_photo"("point_id");

-- CreateIndex
CREATE INDEX "exploration_photo_taken_time_idx" ON "exploration_photo"("taken_time");

-- CreateIndex
CREATE INDEX "user_activity_user_id_idx" ON "user_activity"("user_id");

-- CreateIndex
CREATE INDEX "user_activity_create_time_idx" ON "user_activity"("create_time");

-- CreateIndex
CREATE INDEX "background_music_context_context_id_idx" ON "background_music"("context", "context_id");

-- CreateIndex
CREATE INDEX "background_music_status_idx" ON "background_music"("status");

-- AddForeignKey
ALTER TABLE "sys_dept" ADD CONSTRAINT "sys_dept_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "sys_dept"("dept_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sys_user" ADD CONSTRAINT "sys_user_dept_id_fkey" FOREIGN KEY ("dept_id") REFERENCES "sys_dept"("dept_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sys_menu" ADD CONSTRAINT "sys_menu_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "sys_menu"("menu_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sys_user_role" ADD CONSTRAINT "sys_user_role_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "sys_role"("role_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sys_user_role" ADD CONSTRAINT "sys_user_role_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "sys_user"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sys_role_menu" ADD CONSTRAINT "sys_role_menu_menu_id_fkey" FOREIGN KEY ("menu_id") REFERENCES "sys_menu"("menu_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sys_role_menu" ADD CONSTRAINT "sys_role_menu_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "sys_role"("role_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sys_role_dept" ADD CONSTRAINT "sys_role_dept_dept_id_fkey" FOREIGN KEY ("dept_id") REFERENCES "sys_dept"("dept_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sys_role_dept" ADD CONSTRAINT "sys_role_dept_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "sys_role"("role_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sys_user_post" ADD CONSTRAINT "sys_user_post_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "sys_post"("post_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sys_user_post" ADD CONSTRAINT "sys_user_post_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "sys_user"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_verification" ADD CONSTRAINT "user_verification_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journey" ADD CONSTRAINT "journey_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "city"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exploration_point" ADD CONSTRAINT "exploration_point_journey_id_fkey" FOREIGN KEY ("journey_id") REFERENCES "journey"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exploration_point" ADD CONSTRAINT "exploration_point_bgm_id_fkey" FOREIGN KEY ("bgm_id") REFERENCES "background_music"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journey_progress" ADD CONSTRAINT "journey_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journey_progress" ADD CONSTRAINT "journey_progress_journey_id_fkey" FOREIGN KEY ("journey_id") REFERENCES "journey"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "point_completion" ADD CONSTRAINT "point_completion_progress_id_fkey" FOREIGN KEY ("progress_id") REFERENCES "journey_progress"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "point_completion" ADD CONSTRAINT "point_completion_point_id_fkey" FOREIGN KEY ("point_id") REFERENCES "exploration_point"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "seal" ADD CONSTRAINT "seal_journey_id_fkey" FOREIGN KEY ("journey_id") REFERENCES "journey"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "seal" ADD CONSTRAINT "seal_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "city"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_seal" ADD CONSTRAINT "user_seal_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_seal" ADD CONSTRAINT "user_seal_seal_id_fkey" FOREIGN KEY ("seal_id") REFERENCES "seal"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exploration_photo" ADD CONSTRAINT "exploration_photo_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exploration_photo" ADD CONSTRAINT "exploration_photo_journey_id_fkey" FOREIGN KEY ("journey_id") REFERENCES "journey"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exploration_photo" ADD CONSTRAINT "exploration_photo_point_id_fkey" FOREIGN KEY ("point_id") REFERENCES "exploration_point"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_activity" ADD CONSTRAINT "user_activity_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- ============================================================================
-- 表和字段中文注释
-- ============================================================================

-- ==================== 系统管理表 ====================

-- 部门表
COMMENT ON TABLE sys_dept IS '部门表';
COMMENT ON COLUMN sys_dept.dept_id IS '部门ID';
COMMENT ON COLUMN sys_dept.parent_id IS '父部门ID';
COMMENT ON COLUMN sys_dept.ancestors IS '祖级列表';
COMMENT ON COLUMN sys_dept.dept_name IS '部门名称';
COMMENT ON COLUMN sys_dept.order_num IS '显示顺序';
COMMENT ON COLUMN sys_dept.leader IS '负责人';
COMMENT ON COLUMN sys_dept.phone IS '联系电话';
COMMENT ON COLUMN sys_dept.email IS '邮箱';
COMMENT ON COLUMN sys_dept.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN sys_dept.del_flag IS '删除标志（0存在 2删除）';
COMMENT ON COLUMN sys_dept.create_by IS '创建者';
COMMENT ON COLUMN sys_dept.create_time IS '创建时间';
COMMENT ON COLUMN sys_dept.update_by IS '更新者';
COMMENT ON COLUMN sys_dept.update_time IS '更新时间';

-- 用户表
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
COMMENT ON COLUMN sys_user.del_flag IS '删除标志（0存在 2删除）';
COMMENT ON COLUMN sys_user.login_ip IS '最后登录IP';
COMMENT ON COLUMN sys_user.login_date IS '最后登录时间';
COMMENT ON COLUMN sys_user.two_factor_secret IS '两步验证密钥';
COMMENT ON COLUMN sys_user.two_factor_enabled IS '是否启用两步验证';
COMMENT ON COLUMN sys_user.create_by IS '创建者';
COMMENT ON COLUMN sys_user.create_time IS '创建时间';
COMMENT ON COLUMN sys_user.update_by IS '更新者';
COMMENT ON COLUMN sys_user.update_time IS '更新时间';
COMMENT ON COLUMN sys_user.remark IS '备注';

-- 岗位表
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

-- 角色表
COMMENT ON TABLE sys_role IS '角色信息表';
COMMENT ON COLUMN sys_role.role_id IS '角色ID';
COMMENT ON COLUMN sys_role.role_name IS '角色名称';
COMMENT ON COLUMN sys_role.role_key IS '角色权限字符串';
COMMENT ON COLUMN sys_role.role_sort IS '显示顺序';
COMMENT ON COLUMN sys_role.data_scope IS '数据范围（1全部 2自定义 3本部门 4本部门及以下 5仅本人）';
COMMENT ON COLUMN sys_role.menu_check_strictly IS '菜单树选择项是否关联显示';
COMMENT ON COLUMN sys_role.dept_check_strictly IS '部门树选择项是否关联显示';
COMMENT ON COLUMN sys_role.status IS '角色状态（0正常 1停用）';
COMMENT ON COLUMN sys_role.del_flag IS '删除标志（0存在 2删除）';
COMMENT ON COLUMN sys_role.create_by IS '创建者';
COMMENT ON COLUMN sys_role.create_time IS '创建时间';
COMMENT ON COLUMN sys_role.update_by IS '更新者';
COMMENT ON COLUMN sys_role.update_time IS '更新时间';
COMMENT ON COLUMN sys_role.remark IS '备注';

-- 菜单表
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

-- 用户角色关联表
COMMENT ON TABLE sys_user_role IS '用户和角色关联表';
COMMENT ON COLUMN sys_user_role.user_id IS '用户ID';
COMMENT ON COLUMN sys_user_role.role_id IS '角色ID';

-- 角色菜单关联表
COMMENT ON TABLE sys_role_menu IS '角色和菜单关联表';
COMMENT ON COLUMN sys_role_menu.role_id IS '角色ID';
COMMENT ON COLUMN sys_role_menu.menu_id IS '菜单ID';

-- 角色部门关联表
COMMENT ON TABLE sys_role_dept IS '角色和部门关联表';
COMMENT ON COLUMN sys_role_dept.role_id IS '角色ID';
COMMENT ON COLUMN sys_role_dept.dept_id IS '部门ID';

-- 用户岗位关联表
COMMENT ON TABLE sys_user_post IS '用户与岗位关联表';
COMMENT ON COLUMN sys_user_post.user_id IS '用户ID';
COMMENT ON COLUMN sys_user_post.post_id IS '岗位ID';

-- 操作日志表
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
COMMENT ON COLUMN sys_oper_log.oper_ip IS '主机地址';
COMMENT ON COLUMN sys_oper_log.oper_location IS '操作地点';
COMMENT ON COLUMN sys_oper_log.oper_param IS '请求参数';
COMMENT ON COLUMN sys_oper_log.json_result IS '返回参数';
COMMENT ON COLUMN sys_oper_log.status IS '操作状态（0正常 1异常）';
COMMENT ON COLUMN sys_oper_log.error_msg IS '错误消息';
COMMENT ON COLUMN sys_oper_log.oper_time IS '操作时间';

-- 字典类型表
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

-- 字典数据表
COMMENT ON TABLE sys_dict_data IS '字典数据表';
COMMENT ON COLUMN sys_dict_data.dict_code IS '字典编码';
COMMENT ON COLUMN sys_dict_data.dict_sort IS '字典排序';
COMMENT ON COLUMN sys_dict_data.dict_label IS '字典标签';
COMMENT ON COLUMN sys_dict_data.dict_value IS '字典键值';
COMMENT ON COLUMN sys_dict_data.dict_type IS '字典类型';
COMMENT ON COLUMN sys_dict_data.css_class IS '样式属性';
COMMENT ON COLUMN sys_dict_data.list_class IS '表格回显样式';
COMMENT ON COLUMN sys_dict_data.is_default IS '是否默认（Y是 N否）';
COMMENT ON COLUMN sys_dict_data.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN sys_dict_data.create_by IS '创建者';
COMMENT ON COLUMN sys_dict_data.create_time IS '创建时间';
COMMENT ON COLUMN sys_dict_data.update_by IS '更新者';
COMMENT ON COLUMN sys_dict_data.update_time IS '更新时间';
COMMENT ON COLUMN sys_dict_data.remark IS '备注';

-- 参数配置表
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

-- 登录日志表
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

-- 通知公告表
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

-- 定时任务表
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
COMMENT ON COLUMN sys_job.remark IS '备注';

-- 定时任务日志表
COMMENT ON TABLE sys_job_log IS '定时任务调度日志表';
COMMENT ON COLUMN sys_job_log.job_log_id IS '任务日志ID';
COMMENT ON COLUMN sys_job_log.job_name IS '任务名称';
COMMENT ON COLUMN sys_job_log.job_group IS '任务组名';
COMMENT ON COLUMN sys_job_log.invoke_target IS '调用目标字符串';
COMMENT ON COLUMN sys_job_log.job_message IS '日志信息';
COMMENT ON COLUMN sys_job_log.status IS '执行状态（0正常 1失败）';
COMMENT ON COLUMN sys_job_log.exception_info IS '异常信息';
COMMENT ON COLUMN sys_job_log.create_time IS '创建时间';

-- ==================== 寻印业务表 ====================

-- App用户表
COMMENT ON TABLE app_user IS 'App用户表';
COMMENT ON COLUMN app_user.id IS '用户ID';
COMMENT ON COLUMN app_user.phone IS '手机号';
COMMENT ON COLUMN app_user.email IS '邮箱';
COMMENT ON COLUMN app_user.password IS '密码（邮箱登录用）';
COMMENT ON COLUMN app_user.nickname IS '昵称';
COMMENT ON COLUMN app_user.avatar IS '头像URL';
COMMENT ON COLUMN app_user.gender IS '性别（0男 1女 2未知）';
COMMENT ON COLUMN app_user.birthday IS '生日';
COMMENT ON COLUMN app_user.bio IS '个人简介';
COMMENT ON COLUMN app_user.open_id IS '微信OpenID';
COMMENT ON COLUMN app_user.union_id IS '微信UnionID';
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
COMMENT ON COLUMN app_user.create_time IS '创建时间';
COMMENT ON COLUMN app_user.update_time IS '更新时间';

-- 用户实名认证表
COMMENT ON TABLE user_verification IS '用户实名认证表';
COMMENT ON COLUMN user_verification.id IS '认证ID';
COMMENT ON COLUMN user_verification.user_id IS '用户ID';
COMMENT ON COLUMN user_verification.real_name IS '真实姓名';
COMMENT ON COLUMN user_verification.id_card_no IS '身份证号（加密存储）';
COMMENT ON COLUMN user_verification.id_card_front IS '身份证正面照';
COMMENT ON COLUMN user_verification.id_card_back IS '身份证背面照';
COMMENT ON COLUMN user_verification.status IS '状态（pending/approved/rejected）';
COMMENT ON COLUMN user_verification.reject_reason IS '拒绝原因';
COMMENT ON COLUMN user_verification.verified_at IS '认证通过时间';
COMMENT ON COLUMN user_verification.create_time IS '创建时间';
COMMENT ON COLUMN user_verification.update_time IS '更新时间';

-- 城市表
COMMENT ON TABLE city IS '城市表';
COMMENT ON COLUMN city.id IS '城市ID';
COMMENT ON COLUMN city.name IS '城市名称';
COMMENT ON COLUMN city.province IS '省份';
COMMENT ON COLUMN city.latitude IS '纬度';
COMMENT ON COLUMN city.longitude IS '经度';
COMMENT ON COLUMN city.icon_asset IS '图标资源';
COMMENT ON COLUMN city.cover_image IS '封面图片';
COMMENT ON COLUMN city.description IS '城市描述';
COMMENT ON COLUMN city.explorer_count IS '探索人数';
COMMENT ON COLUMN city.bgm_url IS '背景音乐URL';
COMMENT ON COLUMN city.order_num IS '显示顺序';
COMMENT ON COLUMN city.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN city.create_time IS '创建时间';
COMMENT ON COLUMN city.update_time IS '更新时间';

-- 文化之旅表
COMMENT ON TABLE journey IS '文化之旅表';
COMMENT ON COLUMN journey.id IS '路线ID';
COMMENT ON COLUMN journey.city_id IS '所属城市ID';
COMMENT ON COLUMN journey.name IS '路线名称';
COMMENT ON COLUMN journey.theme IS '主题';
COMMENT ON COLUMN journey.cover_image IS '封面图片';
COMMENT ON COLUMN journey.description IS '路线描述';
COMMENT ON COLUMN journey.rating IS '难度评级（1-5）';
COMMENT ON COLUMN journey.estimated_minutes IS '预计时长（分钟）';
COMMENT ON COLUMN journey.total_distance IS '总距离（米）';
COMMENT ON COLUMN journey.completed_count IS '完成人数';
COMMENT ON COLUMN journey.is_locked IS '是否锁定';
COMMENT ON COLUMN journey.unlock_condition IS '解锁条件';
COMMENT ON COLUMN journey.bgm_url IS '背景音乐URL';
COMMENT ON COLUMN journey.order_num IS '显示顺序';
COMMENT ON COLUMN journey.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN journey.create_time IS '创建时间';
COMMENT ON COLUMN journey.update_time IS '更新时间';

-- 探索点表
COMMENT ON TABLE exploration_point IS '探索点表';
COMMENT ON COLUMN exploration_point.id IS '探索点ID';
COMMENT ON COLUMN exploration_point.journey_id IS '所属路线ID';
COMMENT ON COLUMN exploration_point.name IS '探索点名称';
COMMENT ON COLUMN exploration_point.latitude IS '纬度';
COMMENT ON COLUMN exploration_point.longitude IS '经度';
COMMENT ON COLUMN exploration_point.task_type IS '任务类型（gesture/photo/treasure）';
COMMENT ON COLUMN exploration_point.task_description IS '任务描述';
COMMENT ON COLUMN exploration_point.target_gesture IS '目标手势';
COMMENT ON COLUMN exploration_point.ar_asset_url IS 'AR资源URL';
COMMENT ON COLUMN exploration_point.cultural_background IS '文化背景';
COMMENT ON COLUMN exploration_point.cultural_knowledge IS '文化知识';
COMMENT ON COLUMN exploration_point.distance_from_prev IS '距上一点距离（米）';
COMMENT ON COLUMN exploration_point.points_reward IS '积分奖励';
COMMENT ON COLUMN exploration_point.bgm_id IS '背景音乐ID';
COMMENT ON COLUMN exploration_point.order_num IS '顺序号';
COMMENT ON COLUMN exploration_point.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN exploration_point.create_time IS '创建时间';
COMMENT ON COLUMN exploration_point.update_time IS '更新时间';

-- 用户路线进度表
COMMENT ON TABLE journey_progress IS '用户路线进度表';
COMMENT ON COLUMN journey_progress.id IS '进度ID';
COMMENT ON COLUMN journey_progress.user_id IS '用户ID';
COMMENT ON COLUMN journey_progress.journey_id IS '路线ID';
COMMENT ON COLUMN journey_progress.status IS '状态（in_progress/completed/abandoned）';
COMMENT ON COLUMN journey_progress.start_time IS '开始时间';
COMMENT ON COLUMN journey_progress.complete_time IS '完成时间';
COMMENT ON COLUMN journey_progress.time_spent_minutes IS '花费时间（分钟）';
COMMENT ON COLUMN journey_progress.create_time IS '创建时间';
COMMENT ON COLUMN journey_progress.update_time IS '更新时间';

-- 探索点完成记录表
COMMENT ON TABLE point_completion IS '探索点完成记录表';
COMMENT ON COLUMN point_completion.id IS '记录ID';
COMMENT ON COLUMN point_completion.progress_id IS '进度ID';
COMMENT ON COLUMN point_completion.point_id IS '探索点ID';
COMMENT ON COLUMN point_completion.complete_time IS '完成时间';
COMMENT ON COLUMN point_completion.points_earned IS '获得积分';
COMMENT ON COLUMN point_completion.photo_url IS '照片URL';
COMMENT ON COLUMN point_completion.create_time IS '创建时间';

-- 印记表
COMMENT ON TABLE seal IS '印记表';
COMMENT ON COLUMN seal.id IS '印记ID';
COMMENT ON COLUMN seal.type IS '印记类型（route/city/special）';
COMMENT ON COLUMN seal.name IS '印记名称';
COMMENT ON COLUMN seal.image_asset IS '印记图片';
COMMENT ON COLUMN seal.description IS '印记描述';
COMMENT ON COLUMN seal.unlock_condition IS '解锁条件';
COMMENT ON COLUMN seal.badge_title IS '授予称号';
COMMENT ON COLUMN seal.journey_id IS '关联路线ID';
COMMENT ON COLUMN seal.city_id IS '关联城市ID';
COMMENT ON COLUMN seal.order_num IS '显示顺序';
COMMENT ON COLUMN seal.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN seal.create_time IS '创建时间';
COMMENT ON COLUMN seal.update_time IS '更新时间';

-- 用户印记表
COMMENT ON TABLE user_seal IS '用户印记表';
COMMENT ON COLUMN user_seal.id IS '记录ID';
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
COMMENT ON COLUMN user_seal.create_time IS '创建时间';
COMMENT ON COLUMN user_seal.update_time IS '更新时间';

-- 探索照片表
COMMENT ON TABLE exploration_photo IS '探索照片表';
COMMENT ON COLUMN exploration_photo.id IS '照片ID';
COMMENT ON COLUMN exploration_photo.user_id IS '用户ID';
COMMENT ON COLUMN exploration_photo.journey_id IS '路线ID';
COMMENT ON COLUMN exploration_photo.point_id IS '探索点ID';
COMMENT ON COLUMN exploration_photo.photo_url IS '照片URL';
COMMENT ON COLUMN exploration_photo.thumbnail_url IS '缩略图URL';
COMMENT ON COLUMN exploration_photo.filter IS '滤镜';
COMMENT ON COLUMN exploration_photo.latitude IS '拍摄纬度';
COMMENT ON COLUMN exploration_photo.longitude IS '拍摄经度';
COMMENT ON COLUMN exploration_photo.taken_time IS '拍摄时间';
COMMENT ON COLUMN exploration_photo.create_time IS '创建时间';

-- 用户活动记录表
COMMENT ON TABLE user_activity IS '用户活动记录表';
COMMENT ON COLUMN user_activity.id IS '活动ID';
COMMENT ON COLUMN user_activity.user_id IS '用户ID';
COMMENT ON COLUMN user_activity.type IS '活动类型';
COMMENT ON COLUMN user_activity.title IS '活动标题';
COMMENT ON COLUMN user_activity.related_id IS '关联ID';
COMMENT ON COLUMN user_activity.create_time IS '创建时间';

-- 背景音乐表
COMMENT ON TABLE background_music IS '背景音乐表';
COMMENT ON COLUMN background_music.id IS '音乐ID';
COMMENT ON COLUMN background_music.name IS '音乐名称';
COMMENT ON COLUMN background_music.url IS '音乐URL';
COMMENT ON COLUMN background_music.context IS '使用场景（home/city/journey/point）';
COMMENT ON COLUMN background_music.context_id IS '场景关联ID';
COMMENT ON COLUMN background_music.duration IS '时长（秒）';
COMMENT ON COLUMN background_music.order_num IS '显示顺序';
COMMENT ON COLUMN background_music.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN background_music.create_time IS '创建时间';
COMMENT ON COLUMN background_music.update_time IS '更新时间';

-- ==================== 索引注释 ====================

-- 系统表索引
COMMENT ON INDEX sys_dept_parent_id_idx IS '部门父级索引';
COMMENT ON INDEX sys_dept_status_del_flag_idx IS '部门状态删除标志索引';
COMMENT ON INDEX sys_user_dept_id_idx IS '用户部门索引';
COMMENT ON INDEX sys_user_status_del_flag_idx IS '用户状态删除标志索引';
COMMENT ON INDEX sys_user_phonenumber_idx IS '用户手机号索引';
COMMENT ON INDEX sys_user_email_idx IS '用户邮箱索引';
COMMENT ON INDEX sys_post_status_idx IS '岗位状态索引';
COMMENT ON INDEX sys_role_status_del_flag_idx IS '角色状态删除标志索引';
COMMENT ON INDEX sys_menu_parent_id_idx IS '菜单父级索引';
COMMENT ON INDEX sys_menu_status_visible_idx IS '菜单状态可见性索引';
COMMENT ON INDEX sys_menu_perms_idx IS '菜单权限标识索引';
COMMENT ON INDEX sys_oper_log_oper_time_idx IS '操作日志时间索引';
COMMENT ON INDEX sys_oper_log_oper_name_idx IS '操作日志操作人索引';
COMMENT ON INDEX sys_oper_log_business_type_idx IS '操作日志业务类型索引';
COMMENT ON INDEX sys_oper_log_status_idx IS '操作日志状态索引';
COMMENT ON INDEX sys_dict_type_status_idx IS '字典类型状态索引';
COMMENT ON INDEX sys_dict_data_dict_type_idx IS '字典数据类型索引';
COMMENT ON INDEX sys_dict_data_status_idx IS '字典数据状态索引';
COMMENT ON INDEX sys_login_log_login_time_idx IS '登录日志时间索引';
COMMENT ON INDEX sys_login_log_user_name_idx IS '登录日志用户名索引';
COMMENT ON INDEX sys_login_log_status_idx IS '登录日志状态索引';
COMMENT ON INDEX sys_notice_status_idx IS '通知公告状态索引';
COMMENT ON INDEX sys_notice_notice_type_idx IS '通知公告类型索引';
COMMENT ON INDEX sys_job_status_idx IS '定时任务状态索引';
COMMENT ON INDEX sys_job_job_group_idx IS '定时任务组名索引';
COMMENT ON INDEX sys_job_log_create_time_idx IS '任务日志时间索引';
COMMENT ON INDEX sys_job_log_job_name_job_group_idx IS '任务日志名称组名索引';
COMMENT ON INDEX sys_job_log_status_idx IS '任务日志状态索引';

-- 寻印业务表索引
COMMENT ON INDEX app_user_phone_idx IS 'App用户手机号索引';
COMMENT ON INDEX app_user_email_idx IS 'App用户邮箱索引';
COMMENT ON INDEX app_user_open_id_idx IS 'App用户微信OpenID索引';
COMMENT ON INDEX app_user_google_id_idx IS 'App用户Google ID索引';
COMMENT ON INDEX app_user_apple_id_idx IS 'App用户Apple ID索引';
COMMENT ON INDEX app_user_login_type_idx IS 'App用户登录方式索引';
COMMENT ON INDEX app_user_invite_code_idx IS 'App用户邀请码索引';
COMMENT ON INDEX user_verification_status_idx IS '用户认证状态索引';
COMMENT ON INDEX city_province_idx IS '城市省份索引';
COMMENT ON INDEX city_status_idx IS '城市状态索引';
COMMENT ON INDEX journey_city_id_idx IS '路线城市索引';
COMMENT ON INDEX journey_status_idx IS '路线状态索引';
COMMENT ON INDEX exploration_point_journey_id_idx IS '探索点路线索引';
COMMENT ON INDEX exploration_point_bgm_id_idx IS '探索点背景音乐索引';
COMMENT ON INDEX exploration_point_status_idx IS '探索点状态索引';
COMMENT ON INDEX journey_progress_user_id_idx IS '进度用户索引';
COMMENT ON INDEX journey_progress_journey_id_idx IS '进度路线索引';
COMMENT ON INDEX journey_progress_status_idx IS '进度状态索引';
COMMENT ON INDEX point_completion_progress_id_idx IS '完成记录进度索引';
COMMENT ON INDEX point_completion_point_id_idx IS '完成记录探索点索引';
COMMENT ON INDEX seal_type_idx IS '印记类型索引';
COMMENT ON INDEX seal_journey_id_idx IS '印记路线索引';
COMMENT ON INDEX seal_city_id_idx IS '印记城市索引';
COMMENT ON INDEX seal_status_idx IS '印记状态索引';
COMMENT ON INDEX user_seal_user_id_idx IS '用户印记用户索引';
COMMENT ON INDEX user_seal_seal_id_idx IS '用户印记印记索引';
COMMENT ON INDEX user_seal_is_chained_idx IS '用户印记上链状态索引';
COMMENT ON INDEX exploration_photo_user_id_idx IS '探索照片用户索引';
COMMENT ON INDEX exploration_photo_journey_id_idx IS '探索照片路线索引';
COMMENT ON INDEX exploration_photo_point_id_idx IS '探索照片探索点索引';
COMMENT ON INDEX exploration_photo_taken_time_idx IS '探索照片拍摄时间索引';
COMMENT ON INDEX user_activity_user_id_idx IS '用户活动用户索引';
COMMENT ON INDEX user_activity_create_time_idx IS '用户活动时间索引';
COMMENT ON INDEX background_music_context_context_id_idx IS '背景音乐场景索引';
COMMENT ON INDEX background_music_status_idx IS '背景音乐状态索引';