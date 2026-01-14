-- AlterTable
ALTER TABLE "app_login_config" ADD COLUMN     "button_gradient_end_color" VARCHAR(20) DEFAULT '#9A1830',
ALTER COLUMN "button_radius" SET DEFAULT 'lg',
ALTER COLUMN "app_name_color" SET DEFAULT '#2D2D2D';
