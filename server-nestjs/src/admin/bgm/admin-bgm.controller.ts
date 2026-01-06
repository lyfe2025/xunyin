import {
  Controller,
  Get,
  Post,
  Put,
  Patch,
  Delete,
  Param,
  Query,
  Body,
  UseGuards,
} from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger'
import { JwtAuthGuard } from '../../auth/jwt-auth.guard'
import { PermissionGuard } from '../../common/guards/permission.guard'
import { RequirePermission } from '../../common/decorators/permission.decorator'
import { AdminBgmService } from './admin-bgm.service'
import {
  QueryBgmDto,
  CreateBgmDto,
  UpdateBgmDto,
  UpdateBgmStatusDto,
  BatchDeleteBgmDto,
  BatchUpdateStatusDto,
  BgmListVo,
} from './dto/admin-bgm.dto'

@ApiTags('管理端-背景音乐管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionGuard)
@Controller('admin/bgm')
export class AdminBgmController {
  constructor(private readonly service: AdminBgmService) {}

  @Get()
  @ApiOperation({ summary: '背景音乐列表（分页）' })
  @RequirePermission('xunyin:bgm:query')
  @ApiResponse({ status: 200, description: '成功', type: [BgmListVo] })
  async findAll(@Query() query: QueryBgmDto) {
    return this.service.findAll(query)
  }

  @Get('stats')
  @ApiOperation({ summary: '背景音乐统计' })
  @RequirePermission('xunyin:bgm:query')
  async getStats() {
    return this.service.getStats()
  }

  @Get(':id')
  @ApiOperation({ summary: '背景音乐详情' })
  @RequirePermission('xunyin:bgm:query')
  async findOne(@Param('id') id: string) {
    return this.service.findOne(id)
  }

  @Post()
  @ApiOperation({ summary: '新增背景音乐' })
  @RequirePermission('xunyin:bgm:add')
  @ApiResponse({ status: 201, description: '创建成功' })
  async create(@Body() dto: CreateBgmDto) {
    return this.service.create(dto)
  }

  @Put(':id')
  @ApiOperation({ summary: '修改背景音乐' })
  @RequirePermission('xunyin:bgm:edit')
  async update(@Param('id') id: string, @Body() dto: UpdateBgmDto) {
    return this.service.update(id, dto)
  }

  @Patch(':id/status')
  @ApiOperation({ summary: '切换背景音乐状态' })
  @RequirePermission('xunyin:bgm:edit')
  async updateStatus(@Param('id') id: string, @Body() dto: UpdateBgmStatusDto) {
    return this.service.updateStatus(id, dto.status)
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除背景音乐' })
  @RequirePermission('xunyin:bgm:remove')
  async remove(@Param('id') id: string) {
    return this.service.remove(id)
  }

  @Post('batch-delete')
  @ApiOperation({ summary: '批量删除背景音乐' })
  @RequirePermission('xunyin:bgm:remove')
  async batchDelete(@Body() dto: BatchDeleteBgmDto) {
    return this.service.batchDelete(dto.ids)
  }

  @Post('batch-status')
  @ApiOperation({ summary: '批量修改状态' })
  @RequirePermission('xunyin:bgm:edit')
  async batchUpdateStatus(@Body() dto: BatchUpdateStatusDto) {
    return this.service.batchUpdateStatus(dto.ids, dto.status)
  }
}
