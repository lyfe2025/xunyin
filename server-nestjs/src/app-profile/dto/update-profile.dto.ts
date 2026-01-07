import { ApiPropertyOptional } from '@nestjs/swagger'
import { IsOptional, IsString, MaxLength } from 'class-validator'

export class UpdateProfileDto {
  @ApiPropertyOptional({ description: '昵称', maxLength: 50 })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  nickname?: string

  @ApiPropertyOptional({ description: '头像URL', maxLength: 255 })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  avatar?: string

  @ApiPropertyOptional({ description: '个人简介', maxLength: 255 })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  bio?: string

  @ApiPropertyOptional({ description: '性别：0男 1女 2未知' })
  @IsOptional()
  @IsString()
  @MaxLength(1)
  gender?: string
}
