import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Query,
  Body,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { PermissionGuard } from '../../common/guards/permission.guard';
import { RequirePermission } from '../../common/decorators/permission.decorator';
import { NoticeService } from './notice.service';
import { QueryNoticeDto } from './dto/query-notice.dto';
import { CreateNoticeDto } from './dto/create-notice.dto';
import { UpdateNoticeDto } from './dto/update-notice.dto';

@ApiTags('通知公告')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, PermissionGuard)
@Controller('system/notice')
export class NoticeController {
  constructor(private readonly service: NoticeService) {}

  @Get()
  @RequirePermission('system:notice:list')
  @ApiOperation({ summary: '查询通知公告列表' })
  list(@Query() query: QueryNoticeDto) {
    return this.service.findAll(query);
  }

  @Get(':noticeId')
  @RequirePermission('system:notice:query')
  @ApiOperation({ summary: '查询通知公告详情' })
  get(@Param('noticeId') noticeId: string) {
    return this.service.findOne(noticeId);
  }

  @Post()
  @RequirePermission('system:notice:add')
  @ApiOperation({ summary: '新增通知公告' })
  create(@Body() dto: CreateNoticeDto) {
    return this.service.create(dto);
  }

  @Put(':noticeId')
  @RequirePermission('system:notice:edit')
  @ApiOperation({ summary: '修改通知公告' })
  update(@Param('noticeId') noticeId: string, @Body() dto: UpdateNoticeDto) {
    return this.service.update(noticeId, dto);
  }

  @Delete()
  @RequirePermission('system:notice:remove')
  @ApiOperation({ summary: '删除通知公告' })
  remove(@Query('ids') ids: string) {
    const noticeIds = ids ? ids.split(',') : [];
    return this.service.remove(noticeIds);
  }
}
