import { Controller, Get, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { AdminBlockchainService } from './admin-blockchain.service';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { ChainProviderInfoVo } from './dto/blockchain-config.dto';

@ApiTags('区块链配置-管理端')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/blockchain')
export class AdminBlockchainController {
  constructor(
    private readonly adminBlockchainService: AdminBlockchainService,
  ) {}

  @Get('provider-info')
  @ApiOperation({ summary: '获取当前链服务配置信息' })
  @ApiResponse({ status: 200, description: '成功', type: ChainProviderInfoVo })
  async getChainProviderInfo() {
    return this.adminBlockchainService.getChainProviderInfo();
  }
}
