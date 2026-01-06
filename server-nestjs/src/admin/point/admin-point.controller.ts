import {
  Controller,
  Get,
  Post,
  Put,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common'
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger'
import { JwtAuthGuard } from '../../auth/jwt-auth.guard'
import { RequirePermission } from '../../common/decorators/permission.decorator'
import { AdminPointService } from './admin-point.service'
import {
  QueryAdminPointDto,
  CreatePointDto,
  UpdatePointDto,
  UpdateStatusDto,
  BatchUpdateStatusDto,
} from './dto/admin-point.dto'

@ApiTags('管理端-探索点管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/points')
export class AdminPointController {
  constructor(private readonly adminPointService: AdminPointService) {}

  @Get()
  @ApiOperation({ summary: '探索点列表（分页）' })
  @RequirePermission('xunyin:point:query')
  async findAll(@Query() query: QueryAdminPointDto) {
    return this.adminPointService.findAll(query)
  }

  @Get(':id')
  @ApiOperation({ summary: '探索点详情' })
  @RequirePermission('xunyin:point:query')
  async findOne(@Param('id') id: string) {
    return this.adminPointService.findOne(id)
  }

  @Post()
  @ApiOperation({ summary: '创建探索点' })
  @RequirePermission('xunyin:point:add')
  async create(@Body() dto: CreatePointDto) {
    return this.adminPointService.create(dto)
  }

  @Put(':id')
  @ApiOperation({ summary: '更新探索点' })
  @RequirePermission('xunyin:point:edit')
  async update(@Param('id') id: string, @Body() dto: UpdatePointDto) {
    return this.adminPointService.update(id, dto)
  }

  @Patch(':id/status')
  @ApiOperation({ summary: '更新探索点状态' })
  @RequirePermission('xunyin:point:edit')
  async updateStatus(@Param('id') id: string, @Body() dto: UpdateStatusDto) {
    return this.adminPointService.updateStatus(id, dto.status)
  }

  @Patch('batch-status')
  @ApiOperation({ summary: '批量更新探索点状态' })
  @RequirePermission('xunyin:point:edit')
  async batchUpdateStatus(@Body() dto: BatchUpdateStatusDto) {
    return this.adminPointService.batchUpdateStatus(dto.ids, dto.status)
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除探索点' })
  @RequirePermission('xunyin:point:remove')
  async remove(@Param('id') id: string) {
    await this.adminPointService.remove(id)
  }
}
