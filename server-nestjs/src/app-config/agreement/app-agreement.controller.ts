import { Controller, Get, Param } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiParam, ApiResponse } from '@nestjs/swagger'
import { AppAgreementService } from './app-agreement.service'

@ApiTags('App端-协议与关于')
@Controller('app/agreements')
export class AppAgreementController {
  constructor(private readonly agreementService: AppAgreementService) {}

  @Get(':type')
  @ApiOperation({
    summary: '获取协议/关于内容',
    description:
      '公开接口，无需登录。支持类型：user_agreement（用户协议）、privacy_policy（隐私政策）、about_us（关于我们）',
  })
  @ApiParam({
    name: 'type',
    description: '协议类型',
    enum: ['user_agreement', 'privacy_policy', 'about_us'],
  })
  @ApiResponse({ status: 200, description: '成功返回协议内容' })
  async findByType(@Param('type') type: string) {
    return this.agreementService.findByType(type)
  }
}
