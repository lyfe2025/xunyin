/*
  Warnings:

  - A unique constraint covering the columns `[invite_code]` on the table `app_user` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "app_user" ADD COLUMN     "bio" VARCHAR(255),
ADD COLUMN     "birthday" DATE,
ADD COLUMN     "gender" CHAR(1),
ADD COLUMN     "invite_code" VARCHAR(20),
ADD COLUMN     "invited_by" VARCHAR(30),
ADD COLUMN     "is_verified" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "last_login_ip" VARCHAR(50),
ADD COLUMN     "last_login_time" TIMESTAMP(3),
ADD COLUMN     "level" INTEGER NOT NULL DEFAULT 1,
ADD COLUMN     "password" VARCHAR(100);

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

-- CreateIndex
CREATE UNIQUE INDEX "user_verification_user_id_key" ON "user_verification"("user_id");

-- CreateIndex
CREATE INDEX "user_verification_status_idx" ON "user_verification"("status");

-- CreateIndex
CREATE UNIQUE INDEX "app_user_invite_code_key" ON "app_user"("invite_code");

-- CreateIndex
CREATE INDEX "app_user_invite_code_idx" ON "app_user"("invite_code");

-- AddForeignKey
ALTER TABLE "user_verification" ADD CONSTRAINT "user_verification_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
