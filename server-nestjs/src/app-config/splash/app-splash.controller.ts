import { Controller, Get, Query } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger'
import { AppSplashService } from './app-splash.service'

@ApiTags('App端-启动页配置')
@Controller('app/config/splash')
export class AppSplashController {
  constructor(private readonly splashService: AppSplashService) {}

  @Get('current')
  @ApiOperation({
    summary: '获取当前启动页配置',
    description: '公开接口，无需登录。返回当前生效的启动页配置（品牌页或广告页）',
  })
  @ApiQuery({
    name: 'platform',
    required: false,
    enum: ['ios', 'android', 'all'],
    description: '平台类型',
  })
  @ApiResponse({ status: 200, description: '成功返回启动页配置' })
  async getCurrentConfig(@Query('platform') platform?: 'ios' | 'android' | 'all') {
    return this.splashService.getCurrentConfig(platform || 'all')
  }
}
