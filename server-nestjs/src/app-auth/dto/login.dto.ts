import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, Length } from 'class-validator';

/**
 * 手机号验证码登录 DTO
 */
export class PhoneLoginDto {
  @ApiProperty({ description: '手机号', example: '13800138000' })
  @IsString()
  @IsNotEmpty({ message: '手机号不能为空' })
  @Length(11, 11, { message: '手机号格式不正确' })
  phone: string;

  @ApiProperty({ description: '验证码', example: '123456' })
  @IsString()
  @IsNotEmpty({ message: '验证码不能为空' })
  @Length(4, 6, { message: '验证码长度为4-6位' })
  code: string;
}

/**
 * 微信登录 DTO
 */
export class WechatLoginDto {
  @ApiProperty({ description: '微信授权码', example: 'wx_auth_code_xxx' })
  @IsString()
  @IsNotEmpty({ message: '授权码不能为空' })
  code: string;

  @ApiPropertyOptional({ description: '用户昵称（首次登录时）' })
  @IsOptional()
  @IsString()
  nickname?: string;

  @ApiPropertyOptional({ description: '用户头像（首次登录时）' })
  @IsOptional()
  @IsString()
  avatar?: string;
}

/**
 * 刷新 Token DTO
 */
export class RefreshTokenDto {
  @ApiProperty({ description: '刷新令牌' })
  @IsString()
  @IsNotEmpty({ message: '刷新令牌不能为空' })
  refreshToken: string;
}

/**
 * 发送验证码 DTO
 */
export class SendSmsCodeDto {
  @ApiProperty({ description: '手机号', example: '13800138000' })
  @IsString()
  @IsNotEmpty({ message: '手机号不能为空' })
  @Length(11, 11, { message: '手机号格式不正确' })
  phone: string;
}
