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
import { AdminCityService } from './admin-city.service';
import {
  QueryAdminCityDto,
  CreateCityDto,
  UpdateCityDto,
  UpdateStatusDto,
} from './dto/admin-city.dto';

@ApiTags('管理端-城市管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/cities')
export class AdminCityController {
  constructor(private readonly adminCityService: AdminCityService) { }

  @Get()
  @ApiOperation({ summary: '城市列表（分页）' })
  @RequirePermission('xunyin:city:query')
  async findAll(@Query() query: QueryAdminCityDto) {
    return this.adminCityService.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: '城市详情' })
  @RequirePermission('xunyin:city:query')
  async findOne(@Param('id') id: string) {
    return this.adminCityService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: '创建城市' })
  @RequirePermission('xunyin:city:add')
  async create(@Body() dto: CreateCityDto) {
    return this.adminCityService.create(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: '更新城市' })
  @RequirePermission('xunyin:city:edit')
  async update(@Param('id') id: string, @Body() dto: UpdateCityDto) {
    return this.adminCityService.update(id, dto);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: '更新城市状态' })
  @RequirePermission('xunyin:city:edit')
  async updateStatus(@Param('id') id: string, @Body() dto: UpdateStatusDto) {
    return this.adminCityService.updateStatus(id, dto.status);
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除城市' })
  @RequirePermission('xunyin:city:remove')
  async remove(@Param('id') id: string) {
    await this.adminCityService.remove(id);
  }
}
