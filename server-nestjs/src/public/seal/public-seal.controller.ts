import { Controller, Get, Param } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiParam } from '@nestjs/swagger'
import { PublicSealService } from './public-seal.service'
import { PublicSealDetailVo } from './dto/public-seal.dto'

@ApiTags('公开接口-印记')
@Controller('public/seals')
export class PublicSealController {
  constructor(private readonly publicSealService: PublicSealService) {}

  @Get(':id')
  @ApiOperation({ summary: '获取印记分享详情', description: '公开接口，无需登录' })
  @ApiParam({ name: 'id', description: '用户印记ID' })
  @ApiResponse({ status: 200, description: '成功', type: PublicSealDetailVo })
  @ApiResponse({ status: 404, description: '印记不存在' })
  async findOne(@Param('id') id: string) {
    return this.publicSealService.findOne(id)
  }
}
