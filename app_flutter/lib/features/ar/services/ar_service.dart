import 'package:flutter/foundation.dart';

/// AR 场景类型
enum ARSceneType {
  planeDetection,   // 平面检测
  imageTracking,    // 图像追踪
  objectPlacement,  // 物体放置
}

/// AR 物体信息
class ARObject {
  final String id;
  final String name;
  final String modelUrl;
  final double scale;
  final bool isAnimated;

  ARObject({
    required this.id,
    required this.name,
    required this.modelUrl,
    this.scale = 1.0,
    this.isAnimated = false,
  });
}

/// AR 平面信息
class ARPlane {
  final String id;
  final double width;
  final double height;
  final List<double> center;
  final bool isHorizontal;

  ARPlane({
    required this.id,
    required this.width,
    required this.height,
    required this.center,
    this.isHorizontal = true,
  });
}

/// AR 服务 - 管理 AR 场景和物体
/// 注意：ar_flutter_plugin 需要在实际设备上运行
class ARService {
  bool _isInitialized = false;
  final List<ARObject> _placedObjects = [];
  final List<ARPlane> _detectedPlanes = [];

  bool get isInitialized => _isInitialized;
  List<ARObject> get placedObjects => List.unmodifiable(_placedObjects);
  List<ARPlane> get detectedPlanes => List.unmodifiable(_detectedPlanes);

  /// 初始化 AR 会话
  Future<bool> initialize() async {
    try {
      // AR 插件会在 ARView widget 中自动初始化
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('AR 初始化失败: $e');
      return false;
    }
  }

  /// 添加 AR 物体到场景
  Future<bool> placeObject(ARObject object, List<double> position) async {
    if (!_isInitialized) return false;

    try {
      _placedObjects.add(object);
      debugPrint('放置 AR 物体: ${object.name} at $position');
      return true;
    } catch (e) {
      debugPrint('放置物体失败: $e');
      return false;
    }
  }

  /// 移除 AR 物体
  Future<bool> removeObject(String objectId) async {
    if (!_isInitialized) return false;

    try {
      _placedObjects.removeWhere((o) => o.id == objectId);
      return true;
    } catch (e) {
      debugPrint('移除物体失败: $e');
      return false;
    }
  }

  /// 清除所有物体
  Future<void> clearAllObjects() async {
    _placedObjects.clear();
  }

  /// 处理平面检测回调
  void onPlaneDetected(ARPlane plane) {
    if (!_detectedPlanes.any((p) => p.id == plane.id)) {
      _detectedPlanes.add(plane);
      debugPrint('检测到平面: ${plane.id}');
    }
  }

  /// 获取寻宝任务的 AR 物体
  static ARObject getTreasureObject(String? assetUrl, String pointName) {
    return ARObject(
      id: 'treasure_${DateTime.now().millisecondsSinceEpoch}',
      name: pointName,
      modelUrl: assetUrl ?? 'assets/ar/default_treasure.glb',
      scale: 0.5,
      isAnimated: true,
    );
  }

  /// 释放资源
  Future<void> dispose() async {
    _placedObjects.clear();
    _detectedPlanes.clear();
    _isInitialized = false;
  }
}
