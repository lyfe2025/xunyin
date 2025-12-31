import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { BusinessException } from '../../common/exceptions';
import { ErrorCode } from '../../common/enums';
import type { QueryUserSealDto } from './dto/admin-user-seal.dto';

@Injectable()
export class AdminUserSealService {
    private readonly logger = new Logger(AdminUserSealService.name);
    constructor(private prisma: PrismaService) { }

    async findAll(query: QueryUserSealDto) {
        const {
            userId,
            nickname,
            sealId,
            sealName,
            sealType,
            isChained,
            pageNum = 1,
            pageSize = 20,
        } = query;

        const where: any = {};
        if (userId) where.userId = userId;
        if (sealId) where.sealId = sealId;
        if (isChained !== undefined) where.isChained = isChained;
        if (nickname) {
            where.user = { nickname: { contains: nickname } };
        }
        if (sealName) {
            where.seal = { ...where.seal, name: { contains: sealName } };
        }
        if (sealType) {
            where.seal = { ...where.seal, type: sealType };
        }

        const [list, total] = await Promise.all([
            this.prisma.userSeal.findMany({
                where,
                orderBy: { earnedTime: 'desc' },
                skip: (pageNum - 1) * pageSize,
                take: pageSize,
                include: {
                    user: { select: { id: true, nickname: true, avatar: true, phone: true } },
                    seal: { select: { id: true, name: true, imageAsset: true, type: true } },
                },
            }),
            this.prisma.userSeal.count({ where }),
        ]);

        return {
            list: list.map((us) => ({
                id: us.id,
                userId: us.userId,
                nickname: us.user.nickname,
                avatar: us.user.avatar,
                phone: us.user.phone,
                sealId: us.sealId,
                sealName: us.seal.name,
                sealImage: us.seal.imageAsset,
                sealType: us.seal.type,
                earnedTime: us.earnedTime,
                timeSpentMinutes: us.timeSpentMinutes,
                pointsEarned: us.pointsEarned,
                isChained: us.isChained,
                chainName: us.chainName,
                txHash: us.txHash,
                blockHeight: us.blockHeight?.toString(),
                chainTime: us.chainTime,
            })),
            total,
            pageNum,
            pageSize,
        };
    }

    async findOne(id: string) {
        const userSeal = await this.prisma.userSeal.findUnique({
            where: { id },
            include: {
                user: { select: { id: true, nickname: true, avatar: true, phone: true, email: true } },
                seal: true,
            },
        });

        if (!userSeal) {
            throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '用户印记不存在');
        }

        return {
            ...userSeal,
            nickname: userSeal.user.nickname,
            avatar: userSeal.user.avatar,
            sealName: userSeal.seal.name,
            sealImage: userSeal.seal.imageAsset,
            sealType: userSeal.seal.type,
            blockHeight: userSeal.blockHeight?.toString(),
        };
    }

    async getStats() {
        const [total, chained, unchained] = await Promise.all([
            this.prisma.userSeal.count(),
            this.prisma.userSeal.count({ where: { isChained: true } }),
            this.prisma.userSeal.count({ where: { isChained: false } }),
        ]);

        // 按印记类型统计
        const byType = await this.prisma.userSeal.groupBy({
            by: ['sealId'],
            _count: true,
        });

        // 获取印记类型信息
        const sealIds = byType.map((b) => b.sealId);
        const seals = await this.prisma.seal.findMany({
            where: { id: { in: sealIds } },
            select: { id: true, type: true },
        });

        const typeMap = new Map(seals.map((s) => [s.id, s.type]));
        const typeStats = { route: 0, city: 0, special: 0 };
        byType.forEach((b) => {
            const type = typeMap.get(b.sealId) as keyof typeof typeStats;
            if (type && typeStats[type] !== undefined) {
                typeStats[type] += b._count;
            }
        });

        return { total, chained, unchained, byType: typeStats };
    }

    /**
     * 手动上链
     */
    async chainSeal(id: string, chainName: string = 'antchain') {
        const userSeal = await this.prisma.userSeal.findUnique({
            where: { id },
            include: { seal: true, user: true },
        });

        if (!userSeal) {
            throw new BusinessException(ErrorCode.DATA_NOT_FOUND, '用户印记不存在');
        }

        if (userSeal.isChained) {
            throw new BusinessException(ErrorCode.DATA_ALREADY_EXISTS, '印记已上链');
        }

        // TODO: 调用区块链 API 进行上链
        // 模拟上链结果
        const txHash = `0x${Date.now().toString(16)}${Math.random().toString(16).slice(2, 10)}`;
        const blockHeight = BigInt(Math.floor(Math.random() * 1000000) + 10000000);
        const chainTime = new Date();

        const updated = await this.prisma.userSeal.update({
            where: { id },
            data: {
                isChained: true,
                chainName,
                txHash,
                blockHeight,
                chainTime,
            },
        });

        this.logger.log(`管理员手动上链成功: ${id}, txHash: ${txHash}`);

        return {
            id: updated.id,
            sealId: updated.sealId,
            sealName: userSeal.seal.name,
            userId: updated.userId,
            nickname: userSeal.user.nickname,
            isChained: updated.isChained,
            chainName: updated.chainName,
            txHash: updated.txHash,
            blockHeight: updated.blockHeight?.toString(),
            chainTime: updated.chainTime,
        };
    }
}
