import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsNumber,
  IsBoolean,
  MaxLength,
  Min,
  Max,
} from 'class-validator';
import { Type } from 'class-transformer';

export class QueryAdminJourneyDto {
  @ApiPropertyOptional({ description: '城市ID' })
  @IsOptional()
  @IsString()
  cityId?: string;

  @ApiPropertyOptional({ description: '文化之旅名称' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ description: '状态 0正常 1停用' })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ description: '页码', default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  pageNum?: number = 1;

  @ApiPropertyOptional({ description: '每页数量', default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(100)
  pageSize?: number = 20;
}

export class CreateJourneyDto {
  @ApiProperty({ description: '城市ID' })
  @IsString()
  cityId: string;

  @ApiProperty({ description: '文化之旅名称' })
  @IsString()
  @MaxLength(100)
  name: string;

  @ApiProperty({ description: '主题' })
  @IsString()
  @MaxLength(100)
  theme: string;

  @ApiPropertyOptional({ description: '封面图片' })
  @IsOptional()
  @IsString()
  coverImage?: string;

  @ApiPropertyOptional({ description: '描述' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ description: '星级 1-5', default: 5 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(5)
  rating?: number = 5;

  @ApiProperty({ description: '预计时长(分钟)' })
  @Type(() => Number)
  @IsNumber()
  estimatedMinutes: number;

  @ApiProperty({ description: '总距离(米)' })
  @Type(() => Number)
  @IsNumber()
  totalDistance: number;

  @ApiPropertyOptional({ description: '是否锁定', default: false })
  @IsOptional()
  @IsBoolean()
  isLocked?: boolean = false;

  @ApiPropertyOptional({ description: '解锁条件' })
  @IsOptional()
  @IsString()
  unlockCondition?: string;

  @ApiPropertyOptional({ description: '背景音乐URL' })
  @IsOptional()
  @IsString()
  bgmUrl?: string;

  @ApiPropertyOptional({ description: '排序号', default: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  orderNum?: number = 0;

  @ApiPropertyOptional({ description: '状态 0正常 1停用', default: '0' })
  @IsOptional()
  @IsString()
  status?: string = '0';
}

export class UpdateJourneyDto {
  @ApiPropertyOptional({ description: '城市ID' })
  @IsOptional()
  @IsString()
  cityId?: string;

  @ApiPropertyOptional({ description: '文化之旅名称' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  name?: string;

  @ApiPropertyOptional({ description: '主题' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  theme?: string;

  @ApiPropertyOptional({ description: '封面图片' })
  @IsOptional()
  @IsString()
  coverImage?: string;

  @ApiPropertyOptional({ description: '描述' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ description: '星级 1-5' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(5)
  rating?: number;

  @ApiPropertyOptional({ description: '预计时长(分钟)' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  estimatedMinutes?: number;

  @ApiPropertyOptional({ description: '总距离(米)' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  totalDistance?: number;

  @ApiPropertyOptional({ description: '是否锁定' })
  @IsOptional()
  @IsBoolean()
  isLocked?: boolean;

  @ApiPropertyOptional({ description: '解锁条件' })
  @IsOptional()
  @IsString()
  unlockCondition?: string;

  @ApiPropertyOptional({ description: '背景音乐URL' })
  @IsOptional()
  @IsString()
  bgmUrl?: string;

  @ApiPropertyOptional({ description: '排序号' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  orderNum?: number;

  @ApiPropertyOptional({ description: '状态 0正常 1停用' })
  @IsOptional()
  @IsString()
  status?: string;
}

export class UpdateStatusDto {
  @ApiProperty({ description: '状态 0正常 1停用' })
  @IsString()
  status: string;
}
