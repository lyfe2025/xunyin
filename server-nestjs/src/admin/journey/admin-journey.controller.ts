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
import { AdminJourneyService } from './admin-journey.service';
import {
  QueryAdminJourneyDto,
  CreateJourneyDto,
  UpdateJourneyDto,
  UpdateStatusDto,
} from './dto/admin-journey.dto';

@ApiTags('管理端-文化之旅管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/journeys')
export class AdminJourneyController {
  constructor(private readonly adminJourneyService: AdminJourneyService) { }

  @Get()
  @ApiOperation({ summary: '文化之旅列表（分页）' })
  @RequirePermission('xunyin:journey:query')
  async findAll(@Query() query: QueryAdminJourneyDto) {
    return this.adminJourneyService.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: '文化之旅详情' })
  @RequirePermission('xunyin:journey:query')
  async findOne(@Param('id') id: string) {
    return this.adminJourneyService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: '创建文化之旅' })
  @RequirePermission('xunyin:journey:add')
  async create(@Body() dto: CreateJourneyDto) {
    return this.adminJourneyService.create(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: '更新文化之旅' })
  @RequirePermission('xunyin:journey:edit')
  async update(@Param('id') id: string, @Body() dto: UpdateJourneyDto) {
    return this.adminJourneyService.update(id, dto);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: '更新文化之旅状态' })
  @RequirePermission('xunyin:journey:edit')
  async updateStatus(@Param('id') id: string, @Body() dto: UpdateStatusDto) {
    return this.adminJourneyService.updateStatus(id, dto.status);
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除文化之旅' })
  @RequirePermission('xunyin:journey:remove')
  async remove(@Param('id') id: string) {
    await this.adminJourneyService.remove(id);
  }
}
