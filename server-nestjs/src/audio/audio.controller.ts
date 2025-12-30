import { Controller, Get, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AudioService } from './audio.service';

@ApiTags('背景音乐')
@Controller('app/audio')
export class AudioController {
  constructor(private readonly audioService: AudioService) {}

  @Get('home')
  @ApiOperation({ summary: '获取首页背景音乐' })
  @ApiResponse({ status: 200, description: '成功' })
  async getHomeAudio() {
    return this.audioService.getHomeAudio();
  }

  @Get('city/:cityId')
  @ApiOperation({ summary: '获取城市背景音乐' })
  @ApiResponse({ status: 200, description: '成功' })
  async getCityAudio(@Param('cityId') cityId: string) {
    return this.audioService.getCityAudio(cityId);
  }

  @Get('journey/:journeyId')
  @ApiOperation({ summary: '获取文化之旅背景音乐' })
  @ApiResponse({ status: 200, description: '成功' })
  async getJourneyAudio(@Param('journeyId') journeyId: string) {
    return this.audioService.getJourneyAudio(journeyId);
  }
}
