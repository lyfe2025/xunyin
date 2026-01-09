import { Controller, Get, Post, Put, Param, UseGuards } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger'
import { JourneyService } from './journey.service'
import { AppAuthGuard } from '../app-auth/guards/app-auth.guard'
import { CurrentUser } from '../app-auth/decorators/current-user.decorator'
import type { CurrentAppUser } from '../app-auth/decorators/current-user.decorator'
import {
  JourneyDetailVo,
  ExplorationPointVo,
  JourneyProgressVo,
  StartJourneyVo,
} from './dto/journey.dto'

@ApiTags('文化之旅')
@Controller('app/journeys')
export class JourneyController {
  constructor(private readonly journeyService: JourneyService) {}

  @Get('progress')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取用户进行中的文化之旅' })
  @ApiResponse({ status: 200, description: '成功', type: [JourneyProgressVo] })
  async findUserProgress(@CurrentUser() user: CurrentAppUser) {
    return this.journeyService.findUserProgress(user.userId)
  }

  @Get('my')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取用户所有文化之旅（包括已完成）' })
  @ApiResponse({ status: 200, description: '成功', type: [JourneyProgressVo] })
  async findAllUserJourneys(@CurrentUser() user: CurrentAppUser) {
    return this.journeyService.findAllUserJourneys(user.userId)
  }

  @Get(':id')
  @ApiOperation({ summary: '获取文化之旅详情' })
  @ApiResponse({ status: 200, description: '成功', type: JourneyDetailVo })
  async findOne(@Param('id') id: string) {
    return this.journeyService.findOne(id)
  }

  @Get(':id/points')
  @ApiOperation({ summary: '获取探索点列表' })
  @ApiResponse({ status: 200, description: '成功', type: [ExplorationPointVo] })
  async findPoints(@Param('id') id: string) {
    return this.journeyService.findPoints(id)
  }

  @Post(':id/start')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '开始文化之旅' })
  @ApiResponse({ status: 200, description: '成功', type: StartJourneyVo })
  async startJourney(@CurrentUser() user: CurrentAppUser, @Param('id') id: string) {
    return this.journeyService.startJourney(user.userId, id)
  }

  @Put(':id/abandon')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '放弃文化之旅' })
  @ApiResponse({ status: 200, description: '成功' })
  async abandonJourney(@CurrentUser() user: CurrentAppUser, @Param('id') id: string) {
    return this.journeyService.abandonJourney(user.userId, id)
  }
}
