import { Controller, Get, Query, UseGuards } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger'
import { UserStatsService } from './user-stats.service'
import { AppAuthGuard } from '../app-auth/guards/app-auth.guard'
import { CurrentUser } from '../app-auth/decorators/current-user.decorator'
import type { CurrentAppUser } from '../app-auth/decorators/current-user.decorator'

@ApiTags('用户统计')
@Controller('app/stats')
@UseGuards(AppAuthGuard)
@ApiBearerAuth()
export class UserStatsController {
  constructor(private readonly userStatsService: UserStatsService) {}

  @Get('home')
  @ApiOperation({
    summary: '获取个人中心首页数据（聚合）',
    description: '一次请求返回用户信息、统计数据、进行中旅程、最近动态',
  })
  @ApiResponse({ status: 200, description: '成功' })
  async getHomeData(@CurrentUser() user: CurrentAppUser) {
    return this.userStatsService.getHomeData(user.userId)
  }

  @Get('overview')
  @ApiOperation({ summary: '获取用户统计概览' })
  @ApiResponse({ status: 200, description: '成功' })
  async getOverview(@CurrentUser() user: CurrentAppUser) {
    return this.userStatsService.getOverview(user.userId)
  }

  @Get('activities')
  @ApiOperation({ summary: '获取用户最近动态' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: '成功' })
  async getActivities(@CurrentUser() user: CurrentAppUser, @Query('limit') limit?: number) {
    return this.userStatsService.getActivities(user.userId, limit)
  }

  @Get('travel')
  @ApiOperation({ summary: '获取旅行统计详情' })
  @ApiResponse({ status: 200, description: '成功' })
  async getTravelStats(@CurrentUser() user: CurrentAppUser) {
    return this.userStatsService.getTravelStats(user.userId)
  }
}
