import { Controller, Get, Post, Param, Query, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { PermissionGuard } from '../../common/guards/permission.guard';
import { RequirePermission } from '../../common/decorators/permission.decorator';
import { AdminUserSealService } from './admin-user-seal.service';
import { QueryUserSealDto, UserSealListVo } from './dto/admin-user-seal.dto';

@ApiTags('管理端-用户印记管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionGuard)
@Controller('admin/user-seals')
export class AdminUserSealController {
  constructor(private readonly service: AdminUserSealService) {}

  @Get()
  @ApiOperation({ summary: '用户印记列表（分页）' })
  @RequirePermission('xunyin:userseal:query')
  @ApiResponse({ status: 200, description: '成功', type: [UserSealListVo] })
  async findAll(@Query() query: QueryUserSealDto) {
    return this.service.findAll(query);
  }

  @Get('stats')
  @ApiOperation({ summary: '用户印记统计' })
  @RequirePermission('xunyin:userseal:query')
  async getStats() {
    return this.service.getStats();
  }

  @Get(':id')
  @ApiOperation({ summary: '用户印记详情' })
  @RequirePermission('xunyin:userseal:query')
  async findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Post(':id/chain')
  @ApiOperation({ summary: '手动上链' })
  @RequirePermission('xunyin:userseal:chain')
  @ApiResponse({ status: 200, description: '上链成功' })
  async chainSeal(@Param('id') id: string) {
    return this.service.chainSeal(id);
  }
}
