import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 照片滤镜类型
enum PhotoFilter {
  original, // 原图
  guFeng, // 古风
  shuiMo, // 水墨
}

/// 滤镜配置
class FilterConfig {
  final String name;
  final List<double>? colorMatrix;
  final double saturation;
  final double brightness;
  final double contrast;
  final Color? overlayColor;
  final BlendMode? overlayBlendMode;

  const FilterConfig({
    required this.name,
    this.colorMatrix,
    this.saturation = 1.0,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.overlayColor,
    this.overlayBlendMode,
  });

  /// 获取 ColorFilter
  ColorFilter? get colorFilter {
    if (colorMatrix != null) {
      return ColorFilter.matrix(colorMatrix!);
    }
    return null;
  }
}

/// 滤镜预设
class PhotoFilters {
  // 原图 - 无滤镜
  static const FilterConfig original = FilterConfig(name: '原图');

  // 古风 - 暖色调、低饱和、轻微泛黄
  static const FilterConfig guFeng = FilterConfig(
    name: '古风',
    colorMatrix: [
      1.1, 0.1, 0.0, 0, 15, // R
      0.05, 1.0, 0.05, 0, 10, // G
      0.0, 0.0, 0.85, 0, 0, // B
      0, 0, 0, 1, 0, // A
    ],
    overlayColor: Color(0x15D4A574), // 淡黄褐色叠加
    overlayBlendMode: BlendMode.overlay,
  );

  // 水墨 - 低饱和、高对比、偏冷色
  static const FilterConfig shuiMo = FilterConfig(
    name: '水墨',
    colorMatrix: [
      0.6, 0.3, 0.1, 0, 0, // R - 降低彩色
      0.2, 0.7, 0.1, 0, 0, // G
      0.1, 0.2, 0.7, 0, 10, // B - 轻微偏蓝
      0, 0, 0, 1, 0, // A
    ],
    overlayColor: Color(0x10FFFFFF), // 轻微提亮
    overlayBlendMode: BlendMode.softLight,
  );

  static FilterConfig getConfig(PhotoFilter filter) {
    switch (filter) {
      case PhotoFilter.original:
        return original;
      case PhotoFilter.guFeng:
        return guFeng;
      case PhotoFilter.shuiMo:
        return shuiMo;
    }
  }

  static List<PhotoFilter> get all => PhotoFilter.values;

  /// 根据滤镜名称获取滤镜类型
  static PhotoFilter? fromName(String? name) {
    if (name == null || name.isEmpty) return null;
    switch (name) {
      case '古风':
        return PhotoFilter.guFeng;
      case '水墨':
        return PhotoFilter.shuiMo;
      case '原图':
        return PhotoFilter.original;
      default:
        return null;
    }
  }
}

/// 实时滤镜预览组件 - 包裹相机预览使用
class FilteredCameraPreview extends StatelessWidget {
  final Widget child;
  final PhotoFilter filter;

  const FilteredCameraPreview({
    super.key,
    required this.child,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final config = PhotoFilters.getConfig(filter);

    Widget result = child;

    // 应用颜色矩阵滤镜
    if (config.colorFilter != null) {
      result = ColorFiltered(
        colorFilter: config.colorFilter!,
        child: result,
      );
    }

    // 应用叠加层
    if (config.overlayColor != null && config.overlayBlendMode != null) {
      result = Stack(
        fit: StackFit.expand,
        children: [
          result,
          IgnorePointer(
            child: Container(
              color: config.overlayColor,
            ),
          ),
        ],
      );
    }

    return result;
  }
}

/// 滤镜选择器组件
class FilterSelector extends StatelessWidget {
  final PhotoFilter selectedFilter;
  final ValueChanged<PhotoFilter> onFilterChanged;

  const FilterSelector({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: PhotoFilters.all.map((filter) {
        final config = PhotoFilters.getConfig(filter);
        final isSelected = filter == selectedFilter;

        return GestureDetector(
          onTap: () => onFilterChanged(filter),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.accent, Color(0xFFE85A4F)],
                    )
                  : null,
              color: !isSelected ? Colors.white.withValues(alpha: 0.1) : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              config.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 滤镜缩略图预览（用于滤镜选择时显示效果）
class FilterThumbnail extends StatelessWidget {
  final PhotoFilter filter;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? previewImage;

  const FilterThumbnail({
    super.key,
    required this.filter,
    required this.isSelected,
    required this.onTap,
    this.previewImage,
  });

  @override
  Widget build(BuildContext context) {
    final config = PhotoFilters.getConfig(filter);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.accent : Colors.white24,
                width: isSelected ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildPreview(config),
          ),
          const SizedBox(height: 6),
          Text(
            config.name,
            style: TextStyle(
              color: isSelected ? AppColors.accent : Colors.white70,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(FilterConfig config) {
    Widget content = previewImage ??
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade300,
                Colors.pink.shade200,
                Colors.blue.shade300,
              ],
            ),
          ),
        );

    if (config.colorFilter != null) {
      content = ColorFiltered(
        colorFilter: config.colorFilter!,
        child: content,
      );
    }

    return content;
  }
}

/// 高级滤镜选择器（带缩略图预览）
class AdvancedFilterSelector extends StatelessWidget {
  final PhotoFilter selectedFilter;
  final ValueChanged<PhotoFilter> onFilterChanged;
  final Widget? previewImage;

  const AdvancedFilterSelector({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.previewImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: PhotoFilters.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = PhotoFilters.all[index];
          return FilterThumbnail(
            filter: filter,
            isSelected: filter == selectedFilter,
            onTap: () => onFilterChanged(filter),
            previewImage: previewImage,
          );
        },
      ),
    );
  }
}
