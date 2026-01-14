-- AlterTable
ALTER TABLE "app_download_config" ADD COLUMN     "logo_animation_enabled" BOOLEAN DEFAULT true,
ALTER COLUMN "gradient_start" SET DEFAULT '#FDF8F5',
ALTER COLUMN "gradient_end" SET DEFAULT '#F5F0EB',
ALTER COLUMN "gradient_direction" SET DEFAULT 'to bottom',
ALTER COLUMN "slogan_color" SET DEFAULT '#666666',
ALTER COLUMN "button_primary_color" SET DEFAULT '#C41E3A',
ALTER COLUMN "button_secondary_color" SET DEFAULT 'rgba(196,30,58,0.08)',
ALTER COLUMN "button_radius" SET DEFAULT 'lg';
