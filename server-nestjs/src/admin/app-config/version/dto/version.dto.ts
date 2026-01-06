import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import {
  IsString,
  IsOptional,
  IsNumber,
  IsBoolean,
  IsDateString,
  MaxLength,
  Min,
  Max,
  IsIn,
  Matches,
} from 'class-validator'
import { Type } from 'class-transformer'

export class QueryVersionDto {
  @ApiPropertyOptional({ description: '平台 ios/android' })
  @IsOptional()
  @IsString()
  platform?: string

  @ApiPropertyOptional({ description: '状态 0启用 1停用' })
  @IsOptional()
  @IsString()
  status?: string

  @ApiPropertyOptional({ description: '页码', default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  pageNum?: number = 1

  @ApiPropertyOptional({ description: '每页数量', default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(100)
  pageSize?: number = 10
}

export class CreateVersionDto {
  @ApiProperty({ description: '版本号（如 1.0.0）' })
  @IsString()
  @MaxLength(20)
  @Matches(/^\d+\.\d+\.\d+$/, { message: '版本号格式应为 x.x.x' })
  versionCode: string

  @ApiProperty({ description: '版本名称' })
  @IsString()
  @MaxLength(50)
  versionName: string

  @ApiProperty({ description: '平台 ios/android' })
  @IsString()
  @IsIn(['ios', 'android'])
  platform: string

  @ApiPropertyOptional({ description: '下载地址' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  downloadUrl?: string

  @ApiPropertyOptional({ description: '文件大小' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  fileSize?: string

  @ApiPropertyOptional({ description: '更新内容' })
  @IsOptional()
  @IsString()
  updateContent?: string

  @ApiPropertyOptional({ description: '是否强制更新', default: false })
  @IsOptional()
  @IsBoolean()
  isForceUpdate?: boolean = false

  @ApiPropertyOptional({ description: '最低支持版本' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  minSupportVersion?: string

  @ApiPropertyOptional({ description: '发布时间' })
  @IsOptional()
  @IsDateString()
  publishTime?: string

  @ApiPropertyOptional({ description: '状态 0启用 1停用', default: '0' })
  @IsOptional()
  @IsString()
  status?: string = '0'
}

export class UpdateVersionDto {
  @ApiPropertyOptional({ description: '版本号（如 1.0.0）' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  @Matches(/^\d+\.\d+\.\d+$/, { message: '版本号格式应为 x.x.x' })
  versionCode?: string

  @ApiPropertyOptional({ description: '版本名称' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  versionName?: string

  @ApiPropertyOptional({ description: '平台 ios/android' })
  @IsOptional()
  @IsString()
  @IsIn(['ios', 'android'])
  platform?: string

  @ApiPropertyOptional({ description: '下载地址' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  downloadUrl?: string

  @ApiPropertyOptional({ description: '文件大小' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  fileSize?: string

  @ApiPropertyOptional({ description: '更新内容' })
  @IsOptional()
  @IsString()
  updateContent?: string

  @ApiPropertyOptional({ description: '是否强制更新' })
  @IsOptional()
  @IsBoolean()
  isForceUpdate?: boolean

  @ApiPropertyOptional({ description: '最低支持版本' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  minSupportVersion?: string

  @ApiPropertyOptional({ description: '发布时间' })
  @IsOptional()
  @IsDateString()
  publishTime?: string

  @ApiPropertyOptional({ description: '状态 0启用 1停用' })
  @IsOptional()
  @IsString()
  status?: string
}

export class BatchDeleteDto {
  @ApiProperty({ description: 'ID列表', type: [String] })
  @IsString({ each: true })
  ids: string[]
}
