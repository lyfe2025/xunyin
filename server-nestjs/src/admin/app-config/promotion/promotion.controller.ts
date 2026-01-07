import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger'
import { JwtAuthGuard } from '../../../auth/jwt-auth.guard'
import { RequirePermission } from '../../../common/decorators/permission.decorator'
import { CurrentUser, type JwtUser } from '../../../common/decorators/user.decorator'
import { PromotionService } from './promotion.service'
import {
  QueryChannelDto,
  CreateChannelDto,
  UpdateChannelDto,
  QueryStatsDto,
  BatchDeleteDto,
} from './dto/promotion.dto'

@ApiTags('管理端-推广统计')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/app-config/promotion')
export class PromotionController {
  constructor(private readonly promotionService: PromotionService) {}

  // ========== 渠道管理 ==========

  @Get('channels')
  @ApiOperation({ summary: '推广渠道列表' })
  @RequirePermission('app:promotion:list')
  async findAllChannels(@Query() query: QueryChannelDto) {
    return this.promotionService.findAllChannels(query)
  }

  @Get('channels/:id')
  @ApiOperation({ summary: '推广渠道详情' })
  @RequirePermission('app:promotion:query')
  async findOneChannel(@Param('id') id: string) {
    return this.promotionService.findOneChannel(id)
  }

  @Post('channels')
  @ApiOperation({ summary: '创建推广渠道' })
  @RequirePermission('app:promotion:add')
  async createChannel(@Body() dto: CreateChannelDto, @CurrentUser() user: JwtUser) {
    return this.promotionService.createChannel(dto, user?.userName)
  }

  @Put('channels/:id')
  @ApiOperation({ summary: '更新推广渠道' })
  @RequirePermission('app:promotion:edit')
  async updateChannel(
    @Param('id') id: string,
    @Body() dto: UpdateChannelDto,
    @CurrentUser() user: JwtUser,
  ) {
    return this.promotionService.updateChannel(id, dto, user?.userName)
  }

  @Delete('channels/:id')
  @ApiOperation({ summary: '删除推广渠道' })
  @RequirePermission('app:promotion:remove')
  async removeChannel(@Param('id') id: string) {
    await this.promotionService.removeChannel(id)
  }

  @Post('channels/batch-delete')
  @ApiOperation({ summary: '批量删除推广渠道' })
  @RequirePermission('app:promotion:remove')
  async batchDeleteChannels(@Body() dto: BatchDeleteDto) {
    return this.promotionService.batchDeleteChannels(dto.ids)
  }

  // ========== 统计数据 ==========

  @Get('stats')
  @ApiOperation({ summary: '推广统计数据列表' })
  @RequirePermission('app:promotion:list')
  async findStats(@Query() query: QueryStatsDto) {
    return this.promotionService.findStats(query)
  }

  @Get('stats/summary')
  @ApiOperation({ summary: '推广统计汇总' })
  @RequirePermission('app:promotion:list')
  async getStatsSummary(@Query() query: QueryStatsDto) {
    return this.promotionService.getStatsSummary(query)
  }

  @Get('stats/ranking')
  @ApiOperation({ summary: '渠道排行榜' })
  @RequirePermission('app:promotion:list')
  async getChannelRanking(@Query() query: QueryStatsDto) {
    return this.promotionService.getChannelRanking(query)
  }
}
