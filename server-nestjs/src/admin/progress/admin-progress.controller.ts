import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger'
import { JwtAuthGuard } from '../../auth/jwt-auth.guard'
import { PermissionGuard } from '../../common/guards/permission.guard'
import { RequirePermission } from '../../common/decorators/permission.decorator'
import { AdminProgressService } from './admin-progress.service'
import { QueryProgressDto, ProgressListVo } from './dto/admin-progress.dto'

@ApiTags('管理端-用户进度管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionGuard)
@Controller('admin/progress')
export class AdminProgressController {
  constructor(private readonly service: AdminProgressService) {}

  @Get()
  @ApiOperation({ summary: '用户进度列表（分页）' })
  @RequirePermission('xunyin:progress:query')
  @ApiResponse({ status: 200, description: '成功', type: [ProgressListVo] })
  async findAll(@Query() query: QueryProgressDto) {
    return this.service.findAll(query)
  }

  @Get('stats')
  @ApiOperation({ summary: '进度统计' })
  @RequirePermission('xunyin:progress:query')
  async getStats() {
    return this.service.getStats()
  }

  @Get(':id')
  @ApiOperation({ summary: '进度详情' })
  @RequirePermission('xunyin:progress:query')
  async findOne(@Param('id') id: string) {
    return this.service.findOne(id)
  }
}
