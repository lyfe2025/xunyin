import { Controller, Get, Param, Query } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger'
import { CityService } from './city.service'
import {
  QueryCityDto,
  NearbyCityDto,
  CityVo,
  CityDetailVo,
  JourneyBriefVo,
  NearbyCityVo,
} from './dto/city.dto'

@ApiTags('App-城市')
@Controller('app/cities')
export class CityController {
  constructor(private readonly cityService: CityService) {}

  @Get()
  @ApiOperation({ summary: '获取城市列表', description: '支持按省份筛选' })
  @ApiQuery({ name: 'province', required: false, description: '省份名称' })
  @ApiResponse({ status: 200, description: '成功', type: [CityVo] })
  async findAll(@Query() query: QueryCityDto) {
    return this.cityService.findAll(query)
  }

  @Get('nearby')
  @ApiOperation({
    summary: '获取附近城市',
    description: '基于经纬度获取附近城市列表',
  })
  @ApiResponse({ status: 200, description: '成功', type: [NearbyCityVo] })
  async findNearby(@Query() query: NearbyCityDto) {
    return this.cityService.findNearby(query)
  }

  @Get(':id')
  @ApiOperation({ summary: '获取城市详情' })
  @ApiResponse({ status: 200, description: '成功', type: CityDetailVo })
  async findOne(@Param('id') id: string) {
    return this.cityService.findOne(id)
  }

  @Get(':id/journeys')
  @ApiOperation({ summary: '获取城市文化之旅列表' })
  @ApiResponse({ status: 200, description: '成功', type: [JourneyBriefVo] })
  async findJourneys(@Param('id') id: string) {
    return this.cityService.findJourneys(id)
  }
}
