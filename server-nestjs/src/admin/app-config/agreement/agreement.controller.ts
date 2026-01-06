import { Controller, Get, Put, Body, Param, UseGuards } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger'
import { JwtAuthGuard } from '../../../auth/jwt-auth.guard'
import { RequirePermission } from '../../../common/decorators/permission.decorator'
import { CurrentUser, JwtUser } from '../../../common/decorators/user.decorator'
import { AgreementService } from './agreement.service'
import { UpdateAgreementDto } from './dto/agreement.dto'

@ApiTags('管理端-协议管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/app-config/agreements')
export class AgreementController {
  constructor(private readonly agreementService: AgreementService) {}

  @Get()
  @ApiOperation({ summary: '获取所有协议' })
  @RequirePermission('app:agreement:list')
  async findAll() {
    return this.agreementService.findAll()
  }

  @Get(':type')
  @ApiOperation({ summary: '获取指定类型协议' })
  @RequirePermission('app:agreement:query')
  async findByType(@Param('type') type: string) {
    return this.agreementService.findByType(type)
  }

  @Put(':type')
  @ApiOperation({ summary: '更新协议内容' })
  @RequirePermission('app:agreement:edit')
  async update(
    @Param('type') type: string,
    @Body() dto: UpdateAgreementDto,
    @CurrentUser() user: JwtUser,
  ) {
    return this.agreementService.update(type, dto, user?.userName)
  }
}
