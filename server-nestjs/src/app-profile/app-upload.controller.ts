import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  BadRequestException,
  UseGuards,
} from '@nestjs/common'
import { FileInterceptor } from '@nestjs/platform-express'
import { memoryStorage } from 'multer'
import { extname } from 'path'
import { ApiTags, ApiOperation, ApiConsumes, ApiBody, ApiBearerAuth } from '@nestjs/swagger'
import { AppAuthGuard } from '../app-auth/guards/app-auth.guard'
import { StorageService } from '../common/upload/storage.service'

// 文件魔数签名
const FILE_SIGNATURES: Record<string, number[][]> = {
  'image/jpeg': [[0xff, 0xd8, 0xff]],
  'image/png': [[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]],
  'image/gif': [
    [0x47, 0x49, 0x46, 0x38, 0x37, 0x61],
    [0x47, 0x49, 0x46, 0x38, 0x39, 0x61],
  ],
  'image/webp': [[0x52, 0x49, 0x46, 0x46]],
}

function validateFileMagic(buffer: Buffer, allowedTypes: string[]): boolean {
  const header = Array.from(buffer.subarray(0, 16))
  for (const type of allowedTypes) {
    const signatures = FILE_SIGNATURES[type]
    if (!signatures) continue
    for (const sig of signatures) {
      const match = sig.every((byte, i) => header[i] === byte)
      if (match) return true
    }
  }
  return false
}

function sanitizeFilename(filename: string): string {
  const ext = extname(filename).toLowerCase()
  const allowedExts = ['.jpg', '.jpeg', '.png', '.gif', '.webp']
  if (!allowedExts.includes(ext)) {
    return '.png'
  }
  return ext
}

function generateFilename(prefix: string, originalname: string): string {
  const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9)
  const ext = sanitizeFilename(originalname)
  return `${prefix}-${uniqueSuffix}${ext}`
}

@ApiTags('App-文件上传')
@Controller('app/upload')
@UseGuards(AppAuthGuard)
@ApiBearerAuth('JWT-auth')
export class AppUploadController {
  constructor(private readonly storageService: StorageService) {}

  @Post('avatar')
  @ApiOperation({ summary: '上传用户头像' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: { file: { type: 'string', format: 'binary' } },
    },
  })
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      fileFilter: (_req, file, cb) => {
        const allowedMimes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
        if (!allowedMimes.includes(file.mimetype)) {
          cb(new BadRequestException('只支持图片格式 (jpg, png, gif, webp)'), false)
        } else {
          cb(null, true)
        }
      },
      limits: { fileSize: 2 * 1024 * 1024 }, // 2MB
    }),
  )
  async uploadAvatar(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('请选择要上传的文件')
    }

    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
    if (!validateFileMagic(file.buffer, allowedTypes)) {
      throw new BadRequestException('文件类型不合法，请上传真实的图片文件')
    }

    const filename = generateFilename('avatar', file.originalname)
    const result = await this.storageService.upload(file.buffer, filename, file.mimetype, 'avatars')

    return {
      url: result.url,
      filename: result.filename,
      size: result.size,
      mimetype: file.mimetype,
    }
  }
}
