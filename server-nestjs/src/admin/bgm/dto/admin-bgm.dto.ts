import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsInt, Min, IsIn, MaxLength } from 'class-validator';
import { Type } from 'class-transformer';

export class QueryBgmDto {
    @ApiPropertyOptional({ description: '名称' })
    @IsOptional()
    @IsString()
    name?: string;

    @ApiPropertyOptional({ description: '上下文类型', enum: ['home', 'city', 'journey'] })
    @IsOptional()
    @IsString()
    @IsIn(['home', 'city', 'journey'])
    context?: string;

    @ApiPropertyOptional({ description: '状态', enum: ['0', '1'] })
    @IsOptional()
    @IsString()
    status?: string;

    @ApiPropertyOptional({ description: '页码', default: 1 })
    @IsOptional()
    @Type(() => Number)
    @IsInt()
    @Min(1)
    pageNum?: number;

    @ApiPropertyOptional({ description: '每页数量', default: 10 })
    @IsOptional()
    @Type(() => Number)
    @IsInt()
    @Min(1)
    pageSize?: number;
}

export class CreateBgmDto {
    @ApiProperty({ description: '名称' })
    @IsString()
    @MaxLength(100)
    name: string;

    @ApiProperty({ description: '音频URL' })
    @IsString()
    @MaxLength(255)
    url: string;

    @ApiProperty({ description: '上下文类型', enum: ['home', 'city', 'journey'] })
    @IsString()
    @IsIn(['home', 'city', 'journey'])
    context: string;

    @ApiPropertyOptional({ description: '关联ID（城市ID或文化之旅ID）' })
    @IsOptional()
    @IsString()
    contextId?: string;

    @ApiPropertyOptional({ description: '时长（秒）' })
    @IsOptional()
    @Type(() => Number)
    @IsInt()
    @Min(0)
    duration?: number;

    @ApiPropertyOptional({ description: '排序', default: 0 })
    @IsOptional()
    @Type(() => Number)
    @IsInt()
    orderNum?: number;

    @ApiPropertyOptional({ description: '状态', enum: ['0', '1'], default: '0' })
    @IsOptional()
    @IsString()
    @IsIn(['0', '1'])
    status?: string;
}

export class UpdateBgmDto {
    @ApiPropertyOptional({ description: '名称' })
    @IsOptional()
    @IsString()
    @MaxLength(100)
    name?: string;

    @ApiPropertyOptional({ description: '音频URL' })
    @IsOptional()
    @IsString()
    @MaxLength(255)
    url?: string;

    @ApiPropertyOptional({ description: '上下文类型', enum: ['home', 'city', 'journey'] })
    @IsOptional()
    @IsString()
    @IsIn(['home', 'city', 'journey'])
    context?: string;

    @ApiPropertyOptional({ description: '关联ID' })
    @IsOptional()
    @IsString()
    contextId?: string;

    @ApiPropertyOptional({ description: '时长（秒）' })
    @IsOptional()
    @Type(() => Number)
    @IsInt()
    @Min(0)
    duration?: number;

    @ApiPropertyOptional({ description: '排序' })
    @IsOptional()
    @Type(() => Number)
    @IsInt()
    orderNum?: number;

    @ApiPropertyOptional({ description: '状态', enum: ['0', '1'] })
    @IsOptional()
    @IsString()
    @IsIn(['0', '1'])
    status?: string;
}

export class UpdateBgmStatusDto {
    @ApiProperty({ description: '状态', enum: ['0', '1'] })
    @IsString()
    @IsIn(['0', '1'])
    status: string;
}

export class BatchDeleteBgmDto {
    @ApiProperty({ description: 'ID列表', type: [String] })
    @IsString({ each: true })
    ids: string[];
}

export class BatchUpdateStatusDto {
    @ApiProperty({ description: 'ID列表', type: [String] })
    @IsString({ each: true })
    ids: string[];

    @ApiProperty({ description: '状态', enum: ['0', '1'] })
    @IsString()
    @IsIn(['0', '1'])
    status: string;
}

export class BgmListVo {
    @ApiProperty({ description: 'ID' })
    id: string;

    @ApiProperty({ description: '名称' })
    name: string;

    @ApiProperty({ description: '音频URL' })
    url: string;

    @ApiProperty({ description: '上下文类型' })
    context: string;

    @ApiProperty({ description: '关联ID' })
    contextId: string | null;

    @ApiProperty({ description: '关联名称（城市名或文化之旅名）' })
    contextName: string | null;

    @ApiProperty({ description: '关联城市名（仅文化之旅类型）' })
    contextCityName: string | null;

    @ApiProperty({ description: '时长（秒）' })
    duration: number | null;

    @ApiProperty({ description: '排序' })
    orderNum: number;

    @ApiProperty({ description: '状态' })
    status: string;

    @ApiProperty({ description: '创建时间' })
    createTime: Date;
}
