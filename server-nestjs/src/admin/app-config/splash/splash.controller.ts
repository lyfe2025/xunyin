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
  Request,
} from '@nestjs/common'
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger'
import { JwtAuthGuard } from '../../../auth/jwt-auth.guard'
import { RequirePermission } from '../../../common/decorators/permission.decorator'
import { SplashService } from './splash.service'
import {
  QuerySplashDto,
  CreateSplashDto,
  UpdateSplashDto,
  UpdateStatusDto,
  BatchDeleteDto,
} from './dto/splash.dto'

@ApiTags('管理端-启动页配置')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/app-config/splash')
export class SplashController {
  constructor(private readonly splashService: SplashService) {}

  @Get()
  @ApiOperation({ summary: '启动页配置列表' })
  @RequirePermission('app:splash:list')
  async findAll(@Query() query: QuerySplashDto) {
    return this.splashService.findAll(query)
  }

  @Get(':id')
  @ApiOperation({ summary: '启动页配置详情' })
  @RequirePermission('app:splash:query')
  async findOne(@Param('id') id: string) {
    return this.splashService.findOne(id)
  }

  @Post()
  @ApiOperation({ summary: '创建启动页配置' })
  @RequirePermission('app:splash:add')
  async create(@Body() dto: CreateSplashDto, @Request() req: any) {
    return this.splashService.create(dto, req.user?.userName)
  }

  @Put(':id')
  @ApiOperation({ summary: '更新启动页配置' })
  @RequirePermission('app:splash:edit')
  async update(@Param('id') id: string, @Body() dto: UpdateSplashDto, @Request() req: any) {
    return this.splashService.update(id, dto, req.user?.userName)
  }

  @Patch(':id/status')
  @ApiOperation({ summary: '更新启动页状态' })
  @RequirePermission('app:splash:edit')
  async updateStatus(@Param('id') id: string, @Body() dto: UpdateStatusDto, @Request() req: any) {
    return this.splashService.updateStatus(id, dto.status, req.user?.userName)
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除启动页配置' })
  @RequirePermission('app:splash:remove')
  async remove(@Param('id') id: string) {
    await this.splashService.remove(id)
  }

  @Post('batch-delete')
  @ApiOperation({ summary: '批量删除启动页配置' })
  @RequirePermission('app:splash:remove')
  async batchDelete(@Body() dto: BatchDeleteDto) {
    return this.splashService.batchDelete(dto.ids)
  }
}
