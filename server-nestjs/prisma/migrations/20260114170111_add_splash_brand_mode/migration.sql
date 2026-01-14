-- AlterTable
ALTER TABLE "app_splash_config" ADD COLUMN     "app_name" VARCHAR(50),
ADD COLUMN     "background_color" VARCHAR(20),
ADD COLUMN     "logo_color" VARCHAR(20),
ADD COLUMN     "logo_image" VARCHAR(500),
ADD COLUMN     "logo_text" VARCHAR(10),
ADD COLUMN     "mode" VARCHAR(20) NOT NULL DEFAULT 'ad',
ADD COLUMN     "slogan" VARCHAR(200),
ADD COLUMN     "text_color" VARCHAR(20),
ALTER COLUMN "media_url" DROP NOT NULL;

-- CreateIndex
CREATE INDEX "app_splash_config_mode_idx" ON "app_splash_config"("mode");
