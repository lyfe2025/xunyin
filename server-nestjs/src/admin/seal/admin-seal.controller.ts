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
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { RequirePermission } from '../../common/decorators/permission.decorator';
import { AdminSealService } from './admin-seal.service';
import {
  QueryAdminSealDto,
  CreateSealDto,
  UpdateSealDto,
  UpdateStatusDto,
  BatchDeleteDto,
  BatchUpdateStatusDto,
} from './dto/admin-seal.dto';

@ApiTags('管理端-印记管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/seals')
export class AdminSealController {
  constructor(private readonly adminSealService: AdminSealService) { }

  @Get()
  @ApiOperation({ summary: '印记列表（分页）' })
  @RequirePermission('xunyin:seal:query')
  async findAll(@Query() query: QueryAdminSealDto) {
    return this.adminSealService.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: '印记详情' })
  @RequirePermission('xunyin:seal:query')
  async findOne(@Param('id') id: string) {
    return this.adminSealService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: '创建印记' })
  @RequirePermission('xunyin:seal:add')
  async create(@Body() dto: CreateSealDto) {
    return this.adminSealService.create(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: '更新印记' })
  @RequirePermission('xunyin:seal:edit')
  async update(@Param('id') id: string, @Body() dto: UpdateSealDto) {
    return this.adminSealService.update(id, dto);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: '更新印记状态' })
  @RequirePermission('xunyin:seal:edit')
  async updateStatus(@Param('id') id: string, @Body() dto: UpdateStatusDto) {
    return this.adminSealService.updateStatus(id, dto.status);
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除印记' })
  @RequirePermission('xunyin:seal:remove')
  async remove(@Param('id') id: string) {
    await this.adminSealService.remove(id);
  }

  @Post('batch-delete')
  @ApiOperation({ summary: '批量删除印记' })
  @RequirePermission('xunyin:seal:remove')
  async batchDelete(@Body() dto: BatchDeleteDto) {
    return this.adminSealService.batchDelete(dto.ids);
  }

  @Post('batch-status')
  @ApiOperation({ summary: '批量修改印记状态' })
  @RequirePermission('xunyin:seal:edit')
  async batchUpdateStatus(@Body() dto: BatchUpdateStatusDto) {
    return this.adminSealService.batchUpdateStatus(dto.ids, dto.status);
  }
}
