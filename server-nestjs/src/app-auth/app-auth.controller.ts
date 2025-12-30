import { Controller, Post, Get, Put, Body, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBody,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { AppAuthService } from './app-auth.service';
import { AppAuthGuard } from './guards/app-auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';
import type { CurrentAppUser } from './decorators/current-user.decorator';
import {
  PhoneLoginDto,
  WechatLoginDto,
  RefreshTokenDto,
  SendSmsCodeDto,
} from './dto/login.dto';
import {
  UpdateProfileDto,
  LoginResponseVo,
  AppUserVo,
} from './dto/profile.dto';

@ApiTags('App认证')
@Controller('app/auth')
export class AppAuthController {
  constructor(private readonly appAuthService: AppAuthService) {}

  @Post('sms/send')
  @ApiOperation({ summary: '发送短信验证码' })
  @ApiBody({ type: SendSmsCodeDto })
  @ApiResponse({ status: 200, description: '发送成功' })
  async sendSmsCode(@Body() dto: SendSmsCodeDto) {
    return this.appAuthService.sendSmsCode(dto.phone);
  }

  @Post('login/phone')
  @ApiOperation({
    summary: '手机号验证码登录',
    description: '使用手机号和短信验证码登录，新用户自动注册',
  })
  @ApiBody({ type: PhoneLoginDto })
  @ApiResponse({ status: 200, description: '登录成功', type: LoginResponseVo })
  async loginByPhone(@Body() dto: PhoneLoginDto) {
    return this.appAuthService.loginByPhone(dto);
  }

  @Post('login/wechat')
  @ApiOperation({
    summary: '微信登录',
    description: '使用微信授权码登录，新用户自动注册',
  })
  @ApiBody({ type: WechatLoginDto })
  @ApiResponse({ status: 200, description: '登录成功', type: LoginResponseVo })
  async loginByWechat(@Body() dto: WechatLoginDto) {
    return this.appAuthService.loginByWechat(dto);
  }

  @Post('refresh')
  @ApiOperation({
    summary: '刷新Token',
    description: '使用 refreshToken 获取新的访问令牌',
  })
  @ApiBody({ type: RefreshTokenDto })
  @ApiResponse({ status: 200, description: '刷新成功', type: LoginResponseVo })
  async refreshToken(@Body() dto: RefreshTokenDto) {
    return this.appAuthService.refreshToken(dto);
  }

  @Get('me')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取当前用户信息' })
  @ApiResponse({ status: 200, description: '获取成功', type: AppUserVo })
  async getCurrentUser(@CurrentUser() user: CurrentAppUser) {
    return this.appAuthService.getCurrentUser(user.userId);
  }

  @Put('profile')
  @UseGuards(AppAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '更新用户资料' })
  @ApiBody({ type: UpdateProfileDto })
  @ApiResponse({ status: 200, description: '更新成功', type: AppUserVo })
  async updateProfile(
    @CurrentUser() user: CurrentAppUser,
    @Body() dto: UpdateProfileDto,
  ) {
    return this.appAuthService.updateProfile(user.userId, dto);
  }
}
