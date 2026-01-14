/*
  Warnings:

  - You are about to drop the column `email_button_text` on the `app_login_config` table. All the data in the column will be lost.
  - You are about to drop the column `email_login_enabled` on the `app_login_config` table. All the data in the column will be lost.
  - You are about to drop the column `guest_button_text` on the `app_login_config` table. All the data in the column will be lost.
  - You are about to drop the column `guest_mode_enabled` on the `app_login_config` table. All the data in the column will be lost.
  - You are about to drop the column `phone_button_text` on the `app_login_config` table. All the data in the column will be lost.
  - You are about to drop the column `wechat_button_text` on the `app_login_config` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "app_login_config" DROP COLUMN "email_button_text",
DROP COLUMN "email_login_enabled",
DROP COLUMN "guest_button_text",
DROP COLUMN "guest_mode_enabled",
DROP COLUMN "phone_button_text",
DROP COLUMN "wechat_button_text";
