import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsNumber,
  MaxLength,
  Min,
  Max,
} from 'class-validator';
import { Type } from 'class-transformer';

export class QueryAdminCityDto {
  @ApiPropertyOptional({ description: '城市名称' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ description: '省份' })
  @IsOptional()
  @IsString()
  province?: string;

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

export class CreateCityDto {
  @ApiProperty({ description: '城市名称' })
  @IsString()
  @MaxLength(50)
  name: string;

  @ApiProperty({ description: '省份' })
  @IsString()
  @MaxLength(50)
  province: string;

  @ApiProperty({ description: '纬度' })
  @Type(() => Number)
  @IsNumber()
  latitude: number;

  @ApiProperty({ description: '经度' })
  @Type(() => Number)
  @IsNumber()
  longitude: number;

  @ApiPropertyOptional({ description: '图标资源' })
  @IsOptional()
  @IsString()
  iconAsset?: string;

  @ApiPropertyOptional({ description: '封面图片' })
  @IsOptional()
  @IsString()
  coverImage?: string;

  @ApiPropertyOptional({ description: '描述' })
  @IsOptional()
  @IsString()
  description?: string;

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

export class UpdateCityDto {
  @ApiPropertyOptional({ description: '城市名称' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  name?: string;

  @ApiPropertyOptional({ description: '省份' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  province?: string;

  @ApiPropertyOptional({ description: '纬度' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  latitude?: number;

  @ApiPropertyOptional({ description: '经度' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  longitude?: number;

  @ApiPropertyOptional({ description: '图标资源' })
  @IsOptional()
  @IsString()
  iconAsset?: string;

  @ApiPropertyOptional({ description: '封面图片' })
  @IsOptional()
  @IsString()
  coverImage?: string;

  @ApiPropertyOptional({ description: '描述' })
  @IsOptional()
  @IsString()
  description?: string;

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
