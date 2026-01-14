import { Controller, Get } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger'
import { AppLoginConfigService } from './app-login-config.service'

@ApiTags('App端-登录页配置')
@Controller('app/config/login')
export class AppLoginConfigController {
  constructor(private readonly loginConfigService: AppLoginConfigService) {}

  @Get()
  @ApiOperation({
    summary: '获取登录页配置',
    description: '公开接口，无需登录。返回登录页的外观配置、登录方式开关等',
  })
  @ApiResponse({ status: 200, description: '成功返回登录页配置' })
  async getConfig() {
    return this.loginConfigService.getConfig()
  }
}
