import {
  Controller,
  Get,
  Delete,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { RequirePermission } from '../../common/decorators/permission.decorator';
import { AdminPhotoService } from './admin-photo.service';
import { QueryPhotoDto } from './dto/admin-photo.dto';

@ApiTags('管理端-用户相册管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('admin/photos')
export class AdminPhotoController {
  constructor(private readonly adminPhotoService: AdminPhotoService) {}

  @Get()
  @ApiOperation({
    summary: '照片列表（分页）',
    description: '支持按用户/文化之旅/探索点/城市/时间筛选',
  })
  @ApiResponse({ status: 200, description: '成功' })
  @RequirePermission('xunyin:photo:query')
  async findAll(@Query() query: QueryPhotoDto) {
    return this.adminPhotoService.findAll(query);
  }

  @Get('stats')
  @ApiOperation({ summary: '相册统计' })
  @ApiResponse({ status: 200, description: '成功' })
  @RequirePermission('xunyin:photo:query')
  async getStats() {
    return this.adminPhotoService.getStats();
  }

  @Get(':id')
  @ApiOperation({ summary: '照片详情' })
  @ApiResponse({ status: 200, description: '成功' })
  @RequirePermission('xunyin:photo:query')
  async findOne(@Param('id') id: string) {
    return this.adminPhotoService.findOne(id);
  }

  @Delete(':id')
  @ApiOperation({ summary: '删除照片', description: '删除违规照片' })
  @ApiResponse({ status: 200, description: '成功' })
  @RequirePermission('xunyin:photo:remove')
  async remove(@Param('id') id: string) {
    return this.adminPhotoService.remove(id);
  }
}
