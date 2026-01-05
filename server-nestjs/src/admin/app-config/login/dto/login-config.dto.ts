import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsBoolean, MaxLength, IsIn } from 'class-validator';

export class UpdateLoginConfigDto {
    // ========== 背景配置 ==========
    @ApiPropertyOptional({ description: '背景类型', enum: ['image', 'color', 'gradient'] })
    @IsOptional()
    @IsString()
    @IsIn(['image', 'color', 'gradient'])
    backgroundType?: string;

    @ApiPropertyOptional({ description: '背景图（backgroundType=image时使用）' })
    @IsOptional()
    @IsString()
    @MaxLength(500)
    backgroundImage?: string;

    @ApiPropertyOptional({ description: '纯色背景（backgroundType=color时使用）', example: '#1a1a2e' })
    @IsOptional()
    @IsString()
    @MaxLength(20)
    backgroundColor?: string;

    @ApiPropertyOptional({ description: '渐变起始色', example: '#667eea' })
    @IsOptional()
    @IsString()
    @MaxLength(20)
    gradientStart?: string;

    @ApiPropertyOptional({ description: '渐变结束色', example: '#764ba2' })
    @IsOptional()
    @IsString()
    @MaxLength(20)
    gradientEnd?: string;

    @ApiPropertyOptional({ description: '渐变方向', example: 'to bottom', enum: ['to bottom', 'to top', 'to right', 'to left', '45deg', '135deg'] })
    @IsOptional()
    @IsString()
    @MaxLength(30)
    gradientDirection?: string;

    // ========== Logo配置 ==========
    @ApiPropertyOptional({ description: 'Logo图片' })
    @IsOptional()
    @IsString()
    @MaxLength(500)
    logoImage?: string;

    @ApiPropertyOptional({ description: 'Logo尺寸', enum: ['small', 'normal', 'large'] })
    @IsOptional()
    @IsString()
    @IsIn(['small', 'normal', 'large'])
    logoSize?: string;

    // ========== 标语配置 ==========
    @ApiPropertyOptional({ description: '标语' })
    @IsOptional()
    @IsString()
    @MaxLength(200)
    slogan?: string;

    @ApiPropertyOptional({ description: '标语颜色', example: '#ffffff' })
    @IsOptional()
    @IsString()
    @MaxLength(20)
    sloganColor?: string;

    // ========== 按钮样式 ==========
    @ApiPropertyOptional({ description: '按钮风格', enum: ['filled', 'outlined', 'glass'] })
    @IsOptional()
    @IsString()
    @IsIn(['filled', 'outlined', 'glass'])
    buttonStyle?: string;

    @ApiPropertyOptional({ description: '主按钮颜色', example: '#C53D43' })
    @IsOptional()
    @IsString()
    @MaxLength(20)
    buttonPrimaryColor?: string;

    @ApiPropertyOptional({ description: '次要按钮颜色', example: 'rgba(255,255,255,0.2)' })
    @IsOptional()
    @IsString()
    @MaxLength(30)
    buttonSecondaryColor?: string;

    @ApiPropertyOptional({ description: '按钮圆角', enum: ['none', 'sm', 'md', 'lg', 'full'] })
    @IsOptional()
    @IsString()
    @IsIn(['none', 'sm', 'md', 'lg', 'full'])
    buttonRadius?: string;

    // ========== 按钮文本配置 ==========
    @ApiPropertyOptional({ description: '微信登录按钮文本', example: '微信登录' })
    @IsOptional()
    @IsString()
    @MaxLength(50)
    wechatButtonText?: string;

    @ApiPropertyOptional({ description: 'Apple登录按钮文本', example: 'Apple登录' })
    @IsOptional()
    @IsString()
    @MaxLength(50)
    appleButtonText?: string;

    @ApiPropertyOptional({ description: '手机号登录按钮文本', example: '手机号登录' })
    @IsOptional()
    @IsString()
    @MaxLength(50)
    phoneButtonText?: string;

    @ApiPropertyOptional({ description: '邮箱登录按钮文本', example: '邮箱登录' })
    @IsOptional()
    @IsString()
    @MaxLength(50)
    emailButtonText?: string;

    @ApiPropertyOptional({ description: '游客模式按钮文本', example: '游客体验' })
    @IsOptional()
    @IsString()
    @MaxLength(50)
    guestButtonText?: string;

    // ========== 登录方式开关 ==========
    @ApiPropertyOptional({ description: '微信登录开关' })
    @IsOptional()
    @IsBoolean()
    wechatLoginEnabled?: boolean;

    @ApiPropertyOptional({ description: 'Apple登录开关' })
    @IsOptional()
    @IsBoolean()
    appleLoginEnabled?: boolean;

    @ApiPropertyOptional({ description: 'Google登录开关' })
    @IsOptional()
    @IsBoolean()
    googleLoginEnabled?: boolean;

    @ApiPropertyOptional({ description: '手机号登录开关' })
    @IsOptional()
    @IsBoolean()
    phoneLoginEnabled?: boolean;

    @ApiPropertyOptional({ description: '邮箱登录开关' })
    @IsOptional()
    @IsBoolean()
    emailLoginEnabled?: boolean;

    @ApiPropertyOptional({ description: '游客模式开关' })
    @IsOptional()
    @IsBoolean()
    guestModeEnabled?: boolean;

    // ========== 协议配置 ==========
    @ApiPropertyOptional({ description: '协议来源', enum: ['builtin', 'external'] })
    @IsOptional()
    @IsString()
    @IsIn(['builtin', 'external'])
    agreementSource?: string;

    @ApiPropertyOptional({ description: '用户协议链接（外部链接时使用）' })
    @IsOptional()
    @IsString()
    @MaxLength(500)
    userAgreementUrl?: string;

    @ApiPropertyOptional({ description: '隐私政策链接（外部链接时使用）' })
    @IsOptional()
    @IsString()
    @MaxLength(500)
    privacyPolicyUrl?: string;
}

export class QueryLoginConfigDto {
    @ApiPropertyOptional({ description: '平台 all/ios/android' })
    @IsOptional()
    @IsString()
    platform?: string;
}
