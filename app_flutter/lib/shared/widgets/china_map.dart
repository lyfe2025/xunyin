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
    return Container(
      color: const Color(0xFFF5F0E6), // 宣纸色背景
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
                    painter: _MapBackgroundPainter(),
                    child: Stack(
                      children: widget.cities.map((city) {
                        return _CityMarker(
                          city: city,
                          isSelected: city.id == widget.selectedCityId,
                          onTap: () => widget.onCityTap?.call(city),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
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
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '点击城市图标查看详情',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

  const _CityMarker({required this.city, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    // 将经纬度转换为屏幕坐标（简化版）
    // 中国大致范围：经度 73-135，纬度 18-54
    final screenSize = MediaQuery.of(context).size;
    final x = ((city.longitude - 73) / 62) * screenSize.width;
    final y = ((54 - city.latitude) / 36) * screenSize.height;

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
                color: isSelected ? AppColors.accent : Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
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
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                city.name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
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
      '哈尔滨': Icons.ac_unit,
      '昆明': Icons.local_florist,
      '长沙': Icons.restaurant,
      '武汉': Icons.waves,
    };
    return iconMap[cityName] ?? Icons.location_on;
  }
}

class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E0D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 绘制简单的网格线作为地图背景
    const gridSize = 50.0;
    const gridColor = Color(0x80E8E0D0);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
