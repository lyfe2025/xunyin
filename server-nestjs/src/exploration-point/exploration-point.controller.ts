import { Controller, Get, Post, Param, Body, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiBody,
} from '@nestjs/swagger';
import { ExplorationPointService } from './exploration-point.service';
import { AppAuthGuard } from '../app-auth/guards/app-auth.guard';
import { CurrentUser } from '../app-auth/decorators/current-user.decorator';
import type { CurrentAppUser } from '../app-auth/decorators/current-user.decorator';
import {
  CompleteTaskDto,
  ValidateLocationDto,
  PointDetailVo,
  CompleteTaskVo,
  ValidateLocationVo,
} from './dto/complete-task.dto';

@ApiTags('探索点')
@Controller('app/points')
export class ExplorationPointController {
  constructor(
    private readonly explorationPointService: ExplorationPointService,
  ) { }

  @Get(':id')
  @ApiOperation({ summary: '获取探索点详情' })
  @ApiResponse({ status: 200, description: '成功', type: PointDetailVo })
  async findOne(@Param('id') id: string) {
    return this.explorationPointService.findOne(id);
  }

  @Post(':id/complete')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '完成探索点任务' })
  @ApiBody({ type: CompleteTaskDto })
  @ApiResponse({ status: 200, description: '成功', type: CompleteTaskVo })
  async completeTask(
    @CurrentUser() user: CurrentAppUser,
    @Param('id') id: string,
    @Body() dto: CompleteTaskDto,
  ) {
    return this.explorationPointService.completeTask(user.userId, id, dto);
  }

  @Post(':id/validate-location')
  @ApiOperation({ summary: '验证用户位置' })
  @ApiBody({ type: ValidateLocationDto })
  @ApiResponse({ status: 200, description: '成功', type: ValidateLocationVo })
  async validateLocation(
    @Param('id') id: string,
    @Body() dto: ValidateLocationDto,
  ) {
    return this.explorationPointService.validateLocation(id, dto);
  }
}
