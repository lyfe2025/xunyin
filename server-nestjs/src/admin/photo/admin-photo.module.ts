import { Module } from '@nestjs/common';
import { AdminPhotoController } from './admin-photo.controller';
import { AdminPhotoService } from './admin-photo.service';

@Module({
  controllers: [AdminPhotoController],
  providers: [AdminPhotoService],
})
export class AdminPhotoModule {}
