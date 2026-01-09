-- AlterTable
ALTER TABLE "seal" ADD COLUMN     "rarity" VARCHAR(20) NOT NULL DEFAULT 'common';

-- CreateIndex
CREATE INDEX "seal_rarity_idx" ON "seal"("rarity");
