import { Controller, Get, Put, Body, UseGuards, Request } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger'
import { JwtAuthGuard } from '../../../auth/jwt-auth.guard'
import { RequirePermission } from '../../../common/decorators/permission.decorator'
import { DownloadConfigService } from './download-config.service'
import { UpdateDownloadConfigDto } from './dto/download-config.dto'

@ApiTags('管理端-下载页配置')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/app-config/download')
export class DownloadConfigController {
  constructor(private readonly downloadConfigService: DownloadConfigService) {}

  @Get()
  @ApiOperation({ summary: '获取下载页配置' })
  @RequirePermission('app:download:query')
  async findOne() {
    return this.downloadConfigService.findOne()
  }

  @Put()
  @ApiOperation({ summary: '更新下载页配置' })
  @RequirePermission('app:download:edit')
  async update(@Body() dto: UpdateDownloadConfigDto, @Request() req: any) {
    return this.downloadConfigService.update(dto, req.user?.userName)
  }
}
