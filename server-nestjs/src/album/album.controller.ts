import { Controller, Get, Post, Delete, Param, Query, Body, UseGuards } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody } from '@nestjs/swagger'
import { AlbumService } from './album.service'
import { AppAuthGuard } from '../app-auth/guards/app-auth.guard'
import { CurrentUser } from '../app-auth/decorators/current-user.decorator'
import type { CurrentAppUser } from '../app-auth/decorators/current-user.decorator'
import { QueryPhotoDto, CreatePhotoDto, PhotoVo, PhotoStatsVo } from './dto/photo.dto'

@ApiTags('相册')
@Controller('app/photos')
@UseGuards(AppAuthGuard)
@ApiBearerAuth()
export class AlbumController {
  constructor(private readonly albumService: AlbumService) {}

  @Get()
  @ApiOperation({
    summary: '获取照片列表',
    description: '支持按文化之旅/时间筛选',
  })
  @ApiResponse({ status: 200, description: '成功', type: [PhotoVo] })
  async findAll(@CurrentUser() user: CurrentAppUser, @Query() query: QueryPhotoDto) {
    return this.albumService.findAll(user.userId, query)
  }

  @Get('stats')
  @ApiOperation({ summary: '获取相册统计' })
  @ApiResponse({ status: 200, description: '成功', type: PhotoStatsVo })
  async getStats(@CurrentUser() user: CurrentAppUser) {
    return this.albumService.getStats(user.userId)
  }

  @Get('by-journey')
  @ApiOperation({ summary: '按文化之旅分组获取照片' })
  @ApiResponse({ status: 200, description: '成功' })
  async findByJourneyGrouped(@CurrentUser() user: CurrentAppUser) {
    return this.albumService.findByJourneyGrouped(user.userId)
  }

  @Get('journey/:journeyId')
  @ApiOperation({ summary: '获取文化之旅照片' })
  @ApiResponse({ status: 200, description: '成功', type: [PhotoVo] })
  async findByJourney(@CurrentUser() user: CurrentAppUser, @Param('journeyId') journeyId: string) {
    return this.albumService.findByJourney(user.userId, journeyId)
  }

  @Post()
  @ApiOperation({ summary: '上传照片' })
  @ApiBody({ type: CreatePhotoDto })
  @ApiResponse({ status: 201, description: '成功', type: PhotoVo })
  async create(@CurrentUser() user: CurrentAppUser, @Body() dto: CreatePhotoDto) {
    return this.albumService.create(user.userId, dto)
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除照片' })
  @ApiResponse({ status: 200, description: '成功' })
  async remove(@CurrentUser() user: CurrentAppUser, @Param('id') id: string) {
    return this.albumService.remove(user.userId, id)
  }
}
