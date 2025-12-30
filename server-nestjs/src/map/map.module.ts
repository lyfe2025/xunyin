import { Module } from '@nestjs/common';
import { MapController } from './map.controller';
import { MapService } from './map.service';
import { AmapProvider } from './providers/amap.provider';

@Module({
  controllers: [MapController],
  providers: [MapService, AmapProvider],
  exports: [MapService],
})
export class MapModule {}
