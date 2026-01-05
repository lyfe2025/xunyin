import {
    Controller,
    Get,
    Param,
    Res,
    NotFoundException,
    StreamableFile,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiParam } from '@nestjs/swagger';
import type { Response } from 'express';
import { PrismaService } from '../../prisma/prisma.service';
import { createReadStream, existsSync, statSync } from 'fs';
import { join } from 'path';

@ApiTags('文件下载')
@Controller('api/app/download')
export class DownloadController {
    constructor(private prisma: PrismaService) { }

    /**
     * 下载最新版本 APK
     */
    @Get('apk/latest')
    @ApiOperation({ summary: '下载最新版本 APK' })
    async downloadLatestApk(@Res({ passthrough: true }) res: Response) {
        const version = await this.prisma.appVersion.findFirst({
            where: { platform: 'android', status: '0' },
            orderBy: { createTime: 'desc' },
        });

        if (!version || !version.downloadUrl) {
            throw new NotFoundException('暂无可用的 APK 版本');
        }

        return this.streamApkFile(version.downloadUrl, version.versionName, res);
    }

    /**
     * 下载指定版本 APK
     */
    @Get('apk/:versionId')
    @ApiOperation({ summary: '下载指定版本 APK' })
    @ApiParam({ name: 'versionId', description: '版本ID' })
    async downloadApkByVersion(
        @Param('versionId') versionId: string,
        @Res({ passthrough: true }) res: Response,
    ) {
        const version = await this.prisma.appVersion.findUnique({
            where: { id: versionId },
        });

        if (!version || !version.downloadUrl) {
            throw new NotFoundException('版本不存在或无下载链接');
        }

        return this.streamApkFile(version.downloadUrl, version.versionName, res);
    }

    /**
     * 流式传输 APK 文件
     */
    private streamApkFile(
        downloadUrl: string,
        versionName: string,
        res: Response,
    ): StreamableFile {
        // 本地文件路径处理
        const relativePath = downloadUrl.replace(/^\/uploads\//, '');
        const filePath = join(process.cwd(), 'uploads', relativePath);

        if (!existsSync(filePath)) {
            throw new NotFoundException('APK 文件不存在');
        }

        const stat = statSync(filePath);
        const filename = `xunyin-${versionName}.apk`;

        res.set({
            'Content-Type': 'application/vnd.android.package-archive',
            'Content-Disposition': `attachment; filename="${encodeURIComponent(filename)}"`,
            'Content-Length': stat.size,
        });

        const fileStream = createReadStream(filePath);
        return new StreamableFile(fileStream);
    }
}
