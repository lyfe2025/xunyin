import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'
import { IsString, IsOptional, MaxLength } from 'class-validator'

/**
 * 更新用户资料 DTO
 */
export class UpdateProfileDto {
  @ApiPropertyOptional({ description: '昵称', maxLength: 50 })
  @IsOptional()
  @IsString()
  @MaxLength(50, { message: '昵称最长50个字符' })
  nickname?: string

  @ApiPropertyOptional({ description: '头像URL', maxLength: 255 })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  avatar?: string
}

/**
 * 用户信息响应 VO
 */
export class AppUserVo {
  @ApiProperty({ description: '用户ID' })
  id: string

  @ApiProperty({ description: '手机号' })
  phone: string | null

  @ApiProperty({ description: '昵称' })
  nickname: string

  @ApiProperty({ description: '头像' })
  avatar: string | null

  @ApiProperty({ description: '当前称号' })
  badgeTitle: string | null

  @ApiProperty({ description: '总积分' })
  totalPoints: number

  @ApiProperty({ description: '创建时间' })
  createTime: Date
}

/**
 * 登录响应 VO
 */
export class LoginResponseVo {
  @ApiProperty({ description: '访问令牌' })
  token: string

  @ApiProperty({ description: '刷新令牌' })
  refreshToken: string

  @ApiProperty({ description: '过期时间（秒）' })
  expiresIn: number
}
