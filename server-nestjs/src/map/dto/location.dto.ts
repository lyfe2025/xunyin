import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNumber, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

export class ValidateLocationDto {
  @ApiProperty({ description: '探索点ID' })
  @IsString()
  pointId: string;

  @ApiProperty({ description: '用户纬度', example: 30.2741 })
  @Type(() => Number)
  @IsNumber()
  @Min(-90)
  @Max(90)
  userLat: number;

  @ApiProperty({ description: '用户经度', example: 120.1551 })
  @Type(() => Number)
  @IsNumber()
  @Min(-180)
  @Max(180)
  userLng: number;
}

export class ValidateLocationVo {
  @ApiProperty({ description: '是否在范围内' })
  isInRange: boolean;

  @ApiProperty({ description: '距离(米)' })
  distance: number;

  @ApiProperty({ description: '阈值(米)' })
  threshold: number;
}
