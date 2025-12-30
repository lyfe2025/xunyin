import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { RequirePermission } from '../../common/decorators/permission.decorator';
import { AdminDashboardService } from './admin-dashboard.service';
import { TrendQueryDto } from './dto/admin-dashboard.dto';

@ApiTags('管理端-数据统计')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/dashboard')
export class AdminDashboardController {
  constructor(private readonly adminDashboardService: AdminDashboardService) {}

  @Get('stats')
  @ApiOperation({ summary: '仪表盘统计数据' })
  @RequirePermission('xunyin:stats:view')
  async getStats() {
    return this.adminDashboardService.getStats();
  }

  @Get('trends')
  @ApiOperation({ summary: '趋势数据' })
  @RequirePermission('xunyin:stats:view')
  async getTrends(@Query() query: TrendQueryDto) {
    return this.adminDashboardService.getTrends(query);
  }
}
