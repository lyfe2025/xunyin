import { ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, IsBoolean, MaxLength, IsIn } from 'class-validator'

export class UpdateLoginConfigDto {
  // ========== 背景配置 ==========
  @ApiPropertyOptional({ description: '背景类型', enum: ['image', 'color', 'gradient'] })
  @IsOptional()
  @IsString()
  @IsIn(['image', 'color', 'gradient'])
  backgroundType?: string

  @ApiPropertyOptional({ description: '背景图（backgroundType=image时使用）' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  backgroundImage?: string

  @ApiPropertyOptional({
    description: '纯色背景（backgroundType=color时使用）',
    example: '#FDF8F5',
  })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  backgroundColor?: string

  @ApiPropertyOptional({ description: '渐变起始色', example: '#FDF8F5' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  gradientStart?: string

  @ApiPropertyOptional({ description: '渐变中间色（可选，3色渐变）', example: '#F8F5F0' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  gradientMiddle?: string

  @ApiPropertyOptional({ description: '渐变结束色', example: '#F5F0EB' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  gradientEnd?: string

  @ApiPropertyOptional({
    description: '渐变方向',
    example: 'to bottom',
    enum: ['to bottom', 'to top', 'to right', 'to left', '45deg', '135deg'],
  })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  gradientDirection?: string

  // ========== Aurora 底纹配置 ==========
  @ApiPropertyOptional({ description: '是否启用 Aurora 光晕效果', default: true })
  @IsOptional()
  @IsBoolean()
  auroraEnabled?: boolean

  @ApiPropertyOptional({
    description: 'Aurora 预设样式',
    enum: ['warm', 'standard', 'golden', 'custom'],
    default: 'warm',
  })
  @IsOptional()
  @IsString()
  @IsIn(['warm', 'standard', 'golden', 'custom'])
  auroraPreset?: string

  // ========== Logo配置 ==========
  @ApiPropertyOptional({ description: 'Logo图片' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  logoImage?: string

  @ApiPropertyOptional({ description: 'Logo尺寸', enum: ['small', 'normal', 'large'] })
  @IsOptional()
  @IsString()
  @IsIn(['small', 'normal', 'large'])
  logoSize?: string

  @ApiPropertyOptional({ description: '是否启用 Logo 浮动动画', default: true })
  @IsOptional()
  @IsBoolean()
  logoAnimationEnabled?: boolean

  // ========== 应用名称配置 ==========
  @ApiPropertyOptional({ description: '应用名称（Logo下方）', example: '寻印' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  appName?: string

  @ApiPropertyOptional({ description: '应用名称颜色', example: '#1a1a1a' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  appNameColor?: string

  // ========== 标语配置 ==========
  @ApiPropertyOptional({ description: '标语' })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  slogan?: string

  @ApiPropertyOptional({ description: '标语颜色', example: '#666666' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  sloganColor?: string

  // ========== 按钮样式 ==========
  @ApiPropertyOptional({ description: '按钮风格', enum: ['filled', 'outlined', 'glass'] })
  @IsOptional()
  @IsString()
  @IsIn(['filled', 'outlined', 'glass'])
  buttonStyle?: string

  @ApiPropertyOptional({ description: '主按钮颜色（渐变起始色）', example: '#C41E3A' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  buttonPrimaryColor?: string

  @ApiPropertyOptional({ description: '按钮渐变结束色', example: '#9A1830' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  buttonGradientEndColor?: string

  @ApiPropertyOptional({ description: '次要按钮颜色', example: 'rgba(196,30,58,0.08)' })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  buttonSecondaryColor?: string

  @ApiPropertyOptional({ description: '按钮圆角', enum: ['none', 'sm', 'md', 'lg', 'full'] })
  @IsOptional()
  @IsString()
  @IsIn(['none', 'sm', 'md', 'lg', 'full'])
  buttonRadius?: string

  // ========== 登录方式开关 ==========
  @ApiPropertyOptional({ description: '微信登录开关' })
  @IsOptional()
  @IsBoolean()
  wechatLoginEnabled?: boolean

  @ApiPropertyOptional({ description: 'Apple登录开关' })
  @IsOptional()
  @IsBoolean()
  appleLoginEnabled?: boolean

  @ApiPropertyOptional({ description: 'Google登录开关' })
  @IsOptional()
  @IsBoolean()
  googleLoginEnabled?: boolean

  @ApiPropertyOptional({ description: '手机号登录开关' })
  @IsOptional()
  @IsBoolean()
  phoneLoginEnabled?: boolean

  // ========== 协议配置 ==========
  @ApiPropertyOptional({ description: '协议来源', enum: ['builtin', 'external'] })
  @IsOptional()
  @IsString()
  @IsIn(['builtin', 'external'])
  agreementSource?: string

  @ApiPropertyOptional({ description: '用户协议链接（外部链接时使用）' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  userAgreementUrl?: string

  @ApiPropertyOptional({ description: '隐私政策链接（外部链接时使用）' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  privacyPolicyUrl?: string
}

export class QueryLoginConfigDto {
  @ApiPropertyOptional({ description: '平台 all/ios/android' })
  @IsOptional()
  @IsString()
  platform?: string
}
