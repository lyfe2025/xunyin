import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import '../../core/config/amap_config.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/map_providers.dart';

/// 高德地图组件（自动从 API 获取 Key）
class AMapView extends ConsumerWidget {
  /// 初始中心点
  final LatLng? initialPosition;

  /// 初始缩放级别 (3-19)
  final double initialZoom;

  /// 标记点列表
  final List<AMapMarker>? markers;

  /// 路线点列表
  final List<LatLng>? polylinePoints;

  /// 地图创建完成回调
  final void Function(AMapController controller)? onMapCreated;

  /// 点击标记回调
  final void Function(String markerId)? onMarkerTap;

  /// 是否显示用户位置
  final bool showUserLocation;

  /// 是否显示指南针
  final bool showCompass;

  const AMapView({
    super.key,
    this.initialPosition,
    this.initialZoom = 12.0,
    this.markers,
    this.polylinePoints,
    this.onMapCreated,
    this.onMarkerTap,
    this.showUserLocation = false,
    this.showCompass = true,
  });

  /// 默认中心点（杭州）
  static const LatLng defaultPosition = LatLng(30.2741, 120.1551);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(mapConfigProvider);

    return configAsync.when(
      data: (config) {
        // 设置 Key 到静态配置
        AMapConfig.setKeys(
          androidKey: config.amap.androidKey,
          iosKey: config.amap.iosKey,
        );

        return _buildMap(config.amap.androidKey, config.amap.iosKey);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: AppColors.textHintAdaptive(context),
            ),
            const SizedBox(height: 8),
            Text(
              '地图加载失败',
              style: TextStyle(color: AppColors.textHintAdaptive(context)),
            ),
            const SizedBox(height: 4),
            Text(
              error.toString(),
              style: TextStyle(
                color: AppColors.textHintAdaptive(context),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(String androidKey, String iosKey) {
    // 构建标记点
    final mapMarkers = <Marker>{};
    if (markers != null) {
      for (final m in markers!) {
        mapMarkers.add(
          Marker(
            position: m.position,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              m.isSelected
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueAzure,
            ),
            infoWindow: m.title != null
                ? InfoWindow(title: m.title!)
                : InfoWindow.noText,
          ),
        );
      }
    }

    // 构建路线
    final polylines = <Polyline>{};
    if (polylinePoints != null && polylinePoints!.length >= 2) {
      polylines.add(
        Polyline(
          points: polylinePoints!,
          width: 6,
          color: AppColors.primary,
          capType: CapType.round,
          joinType: JoinType.round,
        ),
      );
    }

    return AMapWidget(
      apiKey: AMapApiKey(androidKey: androidKey, iosKey: iosKey),
      privacyStatement: const AMapPrivacyStatement(
        hasShow: AMapConfig.privacyShow,
        hasAgree: AMapConfig.privacyAgree,
        hasContains: true,
      ),
      initialCameraPosition: CameraPosition(
        target: initialPosition ?? defaultPosition,
        zoom: initialZoom,
      ),
      markers: mapMarkers,
      polylines: polylines,
      myLocationStyleOptions: showUserLocation
          ? MyLocationStyleOptions(
              true,
              circleFillColor: AppColors.primary.withValues(alpha: 0.1),
              circleStrokeColor: AppColors.primary,
              circleStrokeWidth: 1,
            )
          : null,
      compassEnabled: showCompass,
      scaleEnabled: true,
      onMapCreated: (controller) {
        onMapCreated?.call(controller);
      },
    );
  }
}

/// 地图标记点数据
class AMapMarker {
  final String id;
  final LatLng position;
  final String? title;
  final bool isSelected;

  const AMapMarker({
    required this.id,
    required this.position,
    this.title,
    this.isSelected = false,
  });
}
