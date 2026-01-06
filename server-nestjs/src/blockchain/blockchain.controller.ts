import { Controller, Get, Post, Param, UseGuards } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger'
import { BlockchainService } from './blockchain.service'
import { AppAuthGuard } from '../app-auth/guards/app-auth.guard'
import { CurrentUser } from '../app-auth/decorators/current-user.decorator'
import type { CurrentAppUser } from '../app-auth/decorators/current-user.decorator'
import { ChainSealVo, VerifyChainVo, ChainStatusVo } from './dto/chain-seal.dto'

@ApiTags('区块链存证')
@Controller('api/app/blockchain')
export class BlockchainController {
  constructor(private readonly blockchainService: BlockchainService) {}

  @Post('chain/:sealId')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '印记上链' })
  @ApiResponse({ status: 200, description: '成功', type: ChainSealVo })
  async chainSeal(@CurrentUser() user: CurrentAppUser, @Param('sealId') sealId: string) {
    return this.blockchainService.chainSeal(user.userId, sealId)
  }

  @Get('verify/:txHash')
  @ApiOperation({ summary: '验证链上记录' })
  @ApiResponse({ status: 200, description: '成功', type: VerifyChainVo })
  async verifyChain(@Param('txHash') txHash: string) {
    return this.blockchainService.verifyChain(txHash)
  }

  @Get('status/:sealId')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '查询上链状态' })
  @ApiResponse({ status: 200, description: '成功', type: ChainStatusVo })
  async getChainStatus(@CurrentUser() user: CurrentAppUser, @Param('sealId') sealId: string) {
    return this.blockchainService.getChainStatus(user.userId, sealId)
  }
}
