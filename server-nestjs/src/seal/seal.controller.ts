import { Controller, Get, Param, Query, Put, Delete, Body, UseGuards } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger'
import { SealService } from './seal.service'
import { AppAuthGuard } from '../app-auth/guards/app-auth.guard'
import { CurrentUser } from '../app-auth/decorators/current-user.decorator'
import type { CurrentAppUser } from '../app-auth/decorators/current-user.decorator'
import {
  QuerySealDto,
  UserSealVo,
  SealDetailVo,
  SealProgressVo,
  AvailableSealVo,
} from './dto/seal.dto'
import { UserBadgeVo, SetBadgeTitleDto } from './dto/badge.dto'

@ApiTags('印记')
@Controller('app/seals')
export class SealController {
  constructor(private readonly sealService: SealService) {}

  @Get('badges')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取用户已解锁的称号列表' })
  @ApiResponse({ status: 200, description: '成功', type: [UserBadgeVo] })
  async getUserBadges(@CurrentUser() user: CurrentAppUser) {
    return this.sealService.getUserBadges(user.userId)
  }

  @Put('badges/current')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '设置当前展示的称号' })
  @ApiResponse({ status: 200, description: '成功' })
  async setBadgeTitle(@CurrentUser() user: CurrentAppUser, @Body() dto: SetBadgeTitleDto) {
    await this.sealService.setBadgeTitle(user.userId, dto.badgeTitle)
    return { success: true }
  }

  @Delete('badges/current')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '清除当前称号' })
  @ApiResponse({ status: 200, description: '成功' })
  async clearBadgeTitle(@CurrentUser() user: CurrentAppUser) {
    await this.sealService.clearBadgeTitle(user.userId)
    return { success: true }
  }

  @Get()
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取用户印记列表', description: '支持按类型筛选' })
  @ApiQuery({
    name: 'type',
    required: false,
    enum: ['route', 'city', 'special'],
  })
  @ApiResponse({ status: 200, description: '成功', type: [UserSealVo] })
  async findUserSeals(@CurrentUser() user: CurrentAppUser, @Query() query: QuerySealDto) {
    return this.sealService.findUserSeals(user.userId, query)
  }

  @Get('progress')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取印记收集进度' })
  @ApiResponse({ status: 200, description: '成功', type: SealProgressVo })
  async getProgress(@CurrentUser() user: CurrentAppUser) {
    return this.sealService.getProgress(user.userId)
  }

  @Get('available')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取所有可收集印记', description: '含锁定状态' })
  @ApiQuery({
    name: 'type',
    required: false,
    enum: ['route', 'city', 'special'],
  })
  @ApiResponse({ status: 200, description: '成功', type: [AvailableSealVo] })
  async findAvailable(@CurrentUser() user: CurrentAppUser, @Query() query: QuerySealDto) {
    return this.sealService.findAvailable(user.userId, query)
  }

  @Get(':id')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取印记详情' })
  @ApiResponse({ status: 200, description: '成功', type: SealDetailVo })
  async findOne(@CurrentUser() user: CurrentAppUser, @Param('id') id: string) {
    return this.sealService.findOne(user.userId, id)
  }
}
