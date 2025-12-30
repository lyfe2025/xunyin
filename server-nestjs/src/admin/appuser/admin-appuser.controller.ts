import {
  Controller,
  Get,
  Put,
  Param,
  Query,
  Body,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { RequirePermission } from '../../common/decorators/permission.decorator';
import { AdminAppUserService } from './admin-appuser.service';
import { QueryAppUserDto, ChangeStatusDto } from './dto/admin-appuser.dto';

@ApiTags('管理端-App用户管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/appusers')
export class AdminAppUserController {
  constructor(private readonly adminAppUserService: AdminAppUserService) {}

  @Get()
  @ApiOperation({ summary: 'App用户列表（分页）' })
  @RequirePermission('xunyin:appuser:query')
  async findAll(@Query() query: QueryAppUserDto) {
    return this.adminAppUserService.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'App用户详情' })
  @RequirePermission('xunyin:appuser:query')
  async findOne(@Param('id') id: string) {
    return this.adminAppUserService.findOne(id);
  }

  @Put(':id/status')
  @ApiOperation({ summary: '变更App用户状态' })
  @RequirePermission('xunyin:appuser:edit')
  async changeStatus(@Param('id') id: string, @Body() dto: ChangeStatusDto) {
    return this.adminAppUserService.changeStatus(id, dto.status);
  }
}
