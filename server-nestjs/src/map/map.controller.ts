import { Controller, Get, Post, Query, Body } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBody } from '@nestjs/swagger';
import { MapService } from './map.service';
import { ValidateLocationDto, ValidateLocationVo } from './dto/location.dto';
import {
  WalkingRouteDto,
  SearchPoiDto,
  WalkingRouteVo,
  PoiVo,
  MapConfigVo,
} from './dto/route.dto';

@ApiTags('地图服务')
@Controller('app/map')
export class MapController {
  constructor(private readonly mapService: MapService) {}

  @Get('config')
  @ApiOperation({ summary: '获取地图配置' })
  @ApiResponse({ status: 200, description: '成功', type: MapConfigVo })
  async getConfig() {
    return this.mapService.getConfig();
  }

  @Post('validate-location')
  @ApiOperation({ summary: '验证用户位置' })
  @ApiBody({ type: ValidateLocationDto })
  @ApiResponse({ status: 200, description: '成功', type: ValidateLocationVo })
  async validateLocation(@Body() dto: ValidateLocationDto) {
    return this.mapService.validateLocation(dto);
  }

  @Post('route/walking')
  @ApiOperation({ summary: '步行路径规划' })
  @ApiBody({ type: WalkingRouteDto })
  @ApiResponse({ status: 200, description: '成功', type: WalkingRouteVo })
  async walkingRoute(@Body() dto: WalkingRouteDto) {
    return this.mapService.walkingRoute(dto);
  }

  @Get('search')
  @ApiOperation({ summary: 'POI搜索' })
  @ApiResponse({ status: 200, description: '成功' })
  async searchPoi(@Query() dto: SearchPoiDto) {
    return this.mapService.searchPoi(dto);
  }
}
