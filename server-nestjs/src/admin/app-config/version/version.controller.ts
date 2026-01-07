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
import { JwtAuthGuard } from '../../../auth/jwt-auth.guard'
import { RequirePermission } from '../../../common/decorators/permission.decorator'
import { CurrentUser, type JwtUser } from '../../../common/decorators/user.decorator'
import { VersionService } from './version.service'
import {
  QueryVersionDto,
  CreateVersionDto,
  UpdateVersionDto,
  BatchDeleteDto,
} from './dto/version.dto'

@ApiTags('管理端-版本管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/app-config/versions')
export class VersionController {
  constructor(private readonly versionService: VersionService) {}

  @Get()
  @ApiOperation({ summary: '版本列表' })
  @RequirePermission('app:version:list')
  async findAll(@Query() query: QueryVersionDto) {
    return this.versionService.findAll(query)
  }

  @Get('latest/:platform')
  @ApiOperation({ summary: '获取最新版本' })
  @RequirePermission('app:version:query')
  async findLatest(@Param('platform') platform: string) {
    return this.versionService.findLatest(platform)
  }

  @Get(':id')
  @ApiOperation({ summary: '版本详情' })
  @RequirePermission('app:version:query')
  async findOne(@Param('id') id: string) {
    return this.versionService.findOne(id)
  }

  @Post()
  @ApiOperation({ summary: '创建版本' })
  @RequirePermission('app:version:add')
  async create(@Body() dto: CreateVersionDto, @CurrentUser() user: JwtUser) {
    return this.versionService.create(dto, user?.userName)
  }

  @Put(':id')
  @ApiOperation({ summary: '更新版本' })
  @RequirePermission('app:version:edit')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateVersionDto,
    @CurrentUser() user: JwtUser,
  ) {
    return this.versionService.update(id, dto, user?.userName)
  }

  @Patch(':id/status')
  @ApiOperation({ summary: '更新版本状态' })
  @RequirePermission('app:version:edit')
  async updateStatus(
    @Param('id') id: string,
    @Body('status') status: string,
    @CurrentUser() user: JwtUser,
  ) {
    return this.versionService.updateStatus(id, status, user?.userName)
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除版本' })
  @RequirePermission('app:version:remove')
  async remove(@Param('id') id: string) {
    await this.versionService.remove(id)
  }

  @Post('batch-delete')
  @ApiOperation({ summary: '批量删除版本' })
  @RequirePermission('app:version:remove')
  async batchDelete(@Body() dto: BatchDeleteDto) {
    return this.versionService.batchDelete(dto.ids)
  }
}
