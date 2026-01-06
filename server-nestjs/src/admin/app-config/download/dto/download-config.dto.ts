import { ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, IsArray, MaxLength, IsIn } from 'class-validator'

export class FeatureItem {
  icon?: string
  title: string
  desc?: string
}

export class UpdateDownloadConfigDto {
  @ApiPropertyOptional({ description: '页面标题' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  pageTitle?: string

  @ApiPropertyOptional({ description: '页面描述' })
  @IsOptional()
  @IsString()
  pageDescription?: string

  @ApiPropertyOptional({ description: '页面favicon' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  favicon?: string

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
    example: '#2C2C2C',
  })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  backgroundColor?: string

  @ApiPropertyOptional({ description: '渐变起始色', example: '#8B4513' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  gradientStart?: string

  @ApiPropertyOptional({ description: '渐变结束色', example: '#2C2C2C' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  gradientEnd?: string

  @ApiPropertyOptional({ description: '渐变方向', example: '135deg' })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  gradientDirection?: string

  // ========== APP信息 ==========
  @ApiPropertyOptional({ description: 'APP图标' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  appIcon?: string

  @ApiPropertyOptional({ description: 'APP名称' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  appName?: string

  @ApiPropertyOptional({ description: 'APP标语' })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  appSlogan?: string

  @ApiPropertyOptional({ description: '标语颜色', example: '#F5F5DC' })
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

  @ApiPropertyOptional({ description: '主按钮颜色', example: '#C53D43' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  buttonPrimaryColor?: string

  @ApiPropertyOptional({ description: '次要按钮颜色', example: 'rgba(255,255,255,0.2)' })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  buttonSecondaryColor?: string

  @ApiPropertyOptional({ description: '按钮圆角', enum: ['none', 'sm', 'md', 'lg', 'full'] })
  @IsOptional()
  @IsString()
  @IsIn(['none', 'sm', 'md', 'lg', 'full'])
  buttonRadius?: string

  // ========== 按钮文本配置 ==========
  @ApiPropertyOptional({ description: 'iOS下载按钮文本', example: 'App Store 下载' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  iosButtonText?: string

  @ApiPropertyOptional({ description: 'Android下载按钮文本', example: 'Android 下载' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  androidButtonText?: string

  @ApiPropertyOptional({ description: '功能特点列表', type: [FeatureItem] })
  @IsOptional()
  @IsArray()
  featureList?: FeatureItem[]

  @ApiPropertyOptional({ description: 'iOS应用商店链接' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  iosStoreUrl?: string

  @ApiPropertyOptional({ description: 'Android应用商店链接' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  androidStoreUrl?: string

  @ApiPropertyOptional({ description: 'Android APK下载链接' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  androidApkUrl?: string

  @ApiPropertyOptional({ description: '下载二维码图片' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  qrcodeImage?: string

  @ApiPropertyOptional({ description: '页脚文字' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  footerText?: string
}
