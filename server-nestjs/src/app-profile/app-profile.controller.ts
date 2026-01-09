import { Body, Controller, Delete, Get, Patch, UseGuards } from '@nestjs/common'
import { ApiOperation, ApiTags } from '@nestjs/swagger'
import { AppAuthGuard } from '../app-auth/guards/app-auth.guard'
import { CurrentUser } from '../app-auth/decorators/current-user.decorator'
import type { CurrentAppUser } from '../app-auth/decorators/current-user.decorator'
import { AppProfileService } from './app-profile.service'
import { UpdateProfileDto } from './dto/update-profile.dto'

@ApiTags('App-用户资料')
@Controller('app/profile')
@UseGuards(AppAuthGuard)
export class AppProfileController {
  constructor(private readonly profileService: AppProfileService) {}

  @Get()
  @ApiOperation({ summary: '获取当前用户资料' })
  async getProfile(@CurrentUser() user: CurrentAppUser) {
    return this.profileService.getProfile(user.userId)
  }

  @Patch()
  @ApiOperation({ summary: '更新用户资料' })
  async updateProfile(@CurrentUser() user: CurrentAppUser, @Body() dto: UpdateProfileDto) {
    return this.profileService.updateProfile(user.userId, dto)
  }

  @Patch('nickname')
  @ApiOperation({ summary: '更新昵称' })
  async updateNickname(@CurrentUser() user: CurrentAppUser, @Body('nickname') nickname: string) {
    return this.profileService.updateNickname(user.userId, nickname)
  }

  @Patch('avatar')
  @ApiOperation({ summary: '更新头像' })
  async updateAvatar(@CurrentUser() user: CurrentAppUser, @Body('avatar') avatar: string) {
    return this.profileService.updateAvatar(user.userId, avatar)
  }

  @Delete()
  @ApiOperation({ summary: '注销账户' })
  async deleteAccount(@CurrentUser() user: CurrentAppUser): Promise<{ message: string }> {
    return this.profileService.deleteAccount(user.userId)
  }
}
