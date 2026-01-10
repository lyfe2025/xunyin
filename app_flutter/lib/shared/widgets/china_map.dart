import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/city.dart';

/// 中国地图占位组件（后续替换为高德地图）
class ChinaMap extends StatefulWidget {
  final List<City> cities;
  final Function(City city)? onCityTap;
  final String? selectedCityId;

  const ChinaMap({
    super.key,
    required this.cities,
    this.onCityTap,
    this.selectedCityId,
  });

  @override
  State<ChinaMap> createState() => _ChinaMapState();
}

class _ChinaMapState extends State<ChinaMap> {
  Offset _offset = Offset.zero;
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      color: isDark ? AppColors.darkBackground : const Color(0xFFF5F0E6), // 宣纸色背景
      child: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _scale = (_scale * details.scale).clamp(0.5, 3.0);
            _offset += details.focalPointDelta;
          });
        },
        behavior: HitTestBehavior.translucent, // 允许点击事件穿透到父级
        child: Stack(
          children: [
            // 地图背景
            Positioned.fill(
              child: Transform.translate(
                offset: _offset,
                child: Transform.scale(
                  scale: _scale,
                  child: CustomPaint(
                    painter: _MapBackgroundPainter(isDark: isDark),
                  ),
                ),
              ),
            ),
            // 城市标记（独立于背景变换）
            ...widget.cities.map((city) {
              return _CityMarker(
                city: city,
                isSelected: city.id == widget.selectedCityId,
                onTap: () => widget.onCityTap?.call(city),
                scale: _scale,
                offset: _offset,
              );
            }),
            // 地图说明
            Positioned(
              left: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: isDark
                      ? Border.all(color: AppColors.darkBorder.withValues(alpha: 0.5))
                      : null,
                ),
                child: Text(
                  '点击城市图标查看详情',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryAdaptive(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityMarker extends StatelessWidget {
  final City city;
  final bool isSelected;
  final VoidCallback? onTap;
  final double scale;
  final Offset offset;

  const _CityMarker({
    required this.city,
    required this.scale,
    required this.offset,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    // 将经纬度转换为屏幕坐标（简化版）
    // 中国大致范围：经度 73-135，纬度 18-54
    final screenSize = MediaQuery.of(context).size;
    final baseX = ((city.longitude - 73) / 62) * screenSize.width;
    final baseY = ((54 - city.latitude) / 36) * screenSize.height;

    // 应用缩放和偏移
    final x = baseX * scale + offset.dx + screenSize.width * (1 - scale) / 2;
    final y = baseY * scale + offset.dy + screenSize.height * (1 - scale) / 2;

    return Positioned(
      left: x - 24,
      top: y - 32,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent
                    : (isDark ? AppColors.darkSurface : Colors.white),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.borderAdaptive(context),
                  width: 2,
                ),
              ),
              child: Icon(
                _getCityIcon(city.name),
                size: 20,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent
                    : (isDark
                        ? AppColors.darkSurface.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.9)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                city.name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textPrimaryAdaptive(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCityIcon(String cityName) {
    // 根据城市名返回特色图标
    final iconMap = {
      '北京': Icons.account_balance,
      '上海': Icons.location_city,
      '杭州': Icons.water,
      '西安': Icons.temple_buddhist,
      '成都': Icons.pets, // 熊猫
      '重庆': Icons.terrain,
      '广州': Icons.local_florist,
      '深圳': Icons.business,
      '南京': Icons.park,
      '苏州': Icons.yard,
      '福州': Icons.forest, // 榕城
      '哈尔滨': Icons.ac_unit,
      '昆明': Icons.local_florist,
      '长沙': Icons.restaurant,
      '武汉': Icons.waves,
    };
    return iconMap[cityName] ?? Icons.location_on;
  }
}

class _MapBackgroundPainter extends CustomPainter {
  final bool isDark;
  _MapBackgroundPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xFF2A2A34) : const Color(0xFFE8E0D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 绘制简单的网格线作为地图背景
    const gridSize = 50.0;
    final gridColor = isDark
        ? const Color(0xFF3A3A44).withValues(alpha: 0.5)
        : const Color(0x80E8E0D0);
    for (var x = 0.0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint..color = gridColor,
      );
    }
    for (var y = 0.0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint..color = gridColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MapBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
