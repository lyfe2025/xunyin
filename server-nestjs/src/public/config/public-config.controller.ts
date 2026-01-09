import { Controller, Get } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger'
import { PublicConfigService } from './public-config.service'

@ApiTags('公开接口-配置')
@Controller('public/config')
export class PublicConfigController {
  constructor(private readonly publicConfigService: PublicConfigService) {}

  @Get('download')
  @ApiOperation({ summary: '获取下载页配置', description: '公开接口，无需登录' })
  @ApiResponse({ status: 200, description: '成功' })
  async getDownloadConfig() {
    return this.publicConfigService.getDownloadConfig()
  }
}
