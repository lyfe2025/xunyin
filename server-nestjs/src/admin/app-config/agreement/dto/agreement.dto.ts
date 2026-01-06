import { ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, MaxLength, IsIn } from 'class-validator'

export class UpdateAgreementDto {
  @ApiPropertyOptional({ description: '标题' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  title?: string

  @ApiPropertyOptional({ description: '内容' })
  @IsOptional()
  @IsString()
  content?: string

  @ApiPropertyOptional({ description: '版本号' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  version?: string
}

export class QueryAgreementDto {
  @ApiPropertyOptional({ description: '类型 user_agreement/privacy_policy' })
  @IsOptional()
  @IsString()
  @IsIn(['user_agreement', 'privacy_policy'])
  type?: string
}
