-- AlterTable
ALTER TABLE "exploration_point" ADD COLUMN     "bgm_id" TEXT;

-- CreateIndex
CREATE INDEX "exploration_point_bgm_id_idx" ON "exploration_point"("bgm_id");

-- AddForeignKey
ALTER TABLE "exploration_point" ADD CONSTRAINT "exploration_point_bgm_id_fkey" FOREIGN KEY ("bgm_id") REFERENCES "background_music"("id") ON DELETE SET NULL ON UPDATE CASCADE;
