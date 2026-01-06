import { Controller, Get, Put, Param, Query, Body, UseGuards } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger'
import { JwtAuthGuard } from '../../auth/jwt-auth.guard'
import { RequirePermission } from '../../common/decorators/permission.decorator'
import { AdminAppUserService } from './admin-appuser.service'
import {
  QueryAppUserDto,
  ChangeStatusDto,
  QueryVerificationDto,
  AuditVerificationDto,
  BatchAuditVerificationDto,
} from './dto/admin-appuser.dto'

@ApiTags('管理端-App用户管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/appusers')
export class AdminAppUserController {
  constructor(private readonly adminAppUserService: AdminAppUserService) {}

  @Get()
  @ApiOperation({ summary: 'App用户列表（分页）' })
  @RequirePermission('xunyin:appuser:query')
  async findAll(@Query() query: QueryAppUserDto) {
    return this.adminAppUserService.findAll(query)
  }

  @Get('stats')
  @ApiOperation({ summary: 'App用户统计' })
  @RequirePermission('xunyin:appuser:query')
  async getAppUserStats() {
    return this.adminAppUserService.getAppUserStats()
  }

  @Get(':id')
  @ApiOperation({ summary: 'App用户详情' })
  @RequirePermission('xunyin:appuser:query')
  async findOne(@Param('id') id: string) {
    return this.adminAppUserService.findOne(id)
  }

  @Put(':id/status')
  @ApiOperation({ summary: '变更App用户状态' })
  @RequirePermission('xunyin:appuser:edit')
  async changeStatus(@Param('id') id: string, @Body() dto: ChangeStatusDto) {
    return this.adminAppUserService.changeStatus(id, dto.status)
  }

  // ========== 实名认证管理 ==========

  @Get('verifications/list')
  @ApiOperation({ summary: '实名认证列表（分页）' })
  @RequirePermission('xunyin:appuser:query')
  async findVerifications(@Query() query: QueryVerificationDto) {
    return this.adminAppUserService.findVerifications(query)
  }

  @Get('verifications/stats')
  @ApiOperation({ summary: '实名认证统计' })
  @RequirePermission('xunyin:appuser:query')
  async getVerificationStats() {
    return this.adminAppUserService.getVerificationStats()
  }

  @Put('verifications/batch-audit')
  @ApiOperation({ summary: '批量审核实名认证' })
  @RequirePermission('xunyin:appuser:edit')
  async batchAuditVerifications(@Body() dto: BatchAuditVerificationDto) {
    return this.adminAppUserService.batchAuditVerifications(dto)
  }

  @Get('verifications/:id')
  @ApiOperation({ summary: '实名认证详情' })
  @RequirePermission('xunyin:appuser:query')
  async findVerification(@Param('id') id: string) {
    return this.adminAppUserService.findVerification(id)
  }

  @Put('verifications/:id/audit')
  @ApiOperation({ summary: '审核实名认证' })
  @RequirePermission('xunyin:appuser:edit')
  async auditVerification(@Param('id') id: string, @Body() dto: AuditVerificationDto) {
    return this.adminAppUserService.auditVerification(id, dto)
  }
}
