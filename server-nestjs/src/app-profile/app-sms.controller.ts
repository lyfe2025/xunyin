import { Controller, Post, Body, UseGuards, BadRequestException } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger'
import { SmsService } from '../common/sms/sms.service'
import { AppProfileService } from './app-profile.service'
import { AppAuthGuard } from '../app-auth/guards/app-auth.guard'
import { CurrentUser } from '../app-auth/decorators/current-user.decorator'
import type { CurrentAppUser } from '../app-auth/decorators/current-user.decorator'
import { SendSmsCodeDto, BindPhoneDto } from './dto/sms.dto'

@ApiTags('App-短信验证')
@Controller('app/sms')
export class AppSmsController {
  constructor(
    private smsService: SmsService,
    private profileService: AppProfileService,
  ) {}

  @Post('send')
  @ApiOperation({ summary: '发送验证码' })
  async sendCode(@Body() dto: SendSmsCodeDto) {
    const result = await this.smsService.sendVerificationCode(dto.phone)
    if (!result.success) {
      throw new BadRequestException(result.message)
    }
    return { message: result.message }
  }

  @Post('bind')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '绑定手机号' })
  async bindPhone(@Body() dto: BindPhoneDto, @CurrentUser() user: CurrentAppUser) {
    // 验证验证码
    const isValid = await this.smsService.verifyCode(dto.phone, dto.code)
    if (!isValid) {
      throw new BadRequestException('验证码错误或已过期')
    }

    // 检查手机号是否已被其他用户绑定
    const existingUser = await this.profileService.findByPhone(dto.phone)
    if (existingUser && existingUser.id !== user.userId) {
      throw new BadRequestException('该手机号已被其他账号绑定')
    }

    // 绑定手机号
    await this.profileService.updatePhone(user.userId, dto.phone)

    return { message: '绑定成功' }
  }
}
