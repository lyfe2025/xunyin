import { Controller, Get, Put, Body, UseGuards, Request } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger'
import { JwtAuthGuard } from '../../../auth/jwt-auth.guard'
import { RequirePermission } from '../../../common/decorators/permission.decorator'
import { LoginConfigService } from './login-config.service'
import { UpdateLoginConfigDto } from './dto/login-config.dto'

@ApiTags('管理端-登录页配置')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/app-config/login')
export class LoginConfigController {
  constructor(private readonly loginConfigService: LoginConfigService) {}

  @Get()
  @ApiOperation({ summary: '获取登录页配置' })
  @RequirePermission('app:login:list')
  async findOne() {
    return this.loginConfigService.findOne()
  }

  @Put()
  @ApiOperation({ summary: '更新登录页配置' })
  @RequirePermission('app:login:edit')
  async update(@Body() dto: UpdateLoginConfigDto, @Request() req: any) {
    return this.loginConfigService.update(dto, req.user?.userName)
  }
}
