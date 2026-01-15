import 'dart:math';
import 'dart:ui' show Size;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// 手势类型枚举
enum GestureType {
  none,
  wave,           // 挥手
  thumbsUp,       // 点赞
  peace,          // 剪刀手/胜利
  heart,          // 比心
  moonGaze,       // 赏月手势（双手举起望月）
  prayerHands,    // 合十
  pointUp,        // 指向上方
  openPalm,       // 张开手掌
}

/// 手势识别结果
class GestureResult {
  final GestureType gesture;
  final double confidence;
  final List<PoseLandmark> landmarks;

  GestureResult({
    required this.gesture,
    required this.confidence,
    this.landmarks = const [],
  });

  bool get isDetected => gesture != GestureType.none && confidence > 0.7;
}

/// 手势识别服务 - 基于 ML Kit Pose Detection
class GestureRecognitionService {
  PoseDetector? _poseDetector;
  bool _isProcessing = false;

  /// 初始化
  Future<void> initialize() async {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.base,
    );
    _poseDetector = PoseDetector(options: options);
  }

  /// 从相机图像识别手势
  Future<GestureResult> recognizeFromCameraImage(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (_poseDetector == null || _isProcessing) {
      return GestureResult(gesture: GestureType.none, confidence: 0);
    }

    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image, camera);
      if (inputImage == null) {
        return GestureResult(gesture: GestureType.none, confidence: 0);
      }

      final poses = await _poseDetector!.processImage(inputImage);
      if (poses.isEmpty) {
        return GestureResult(gesture: GestureType.none, confidence: 0);
      }

      return _analyzeGesture(poses.first);
    } catch (e) {
      debugPrint('手势识别错误: $e');
      return GestureResult(gesture: GestureType.none, confidence: 0);
    } finally {
      _isProcessing = false;
    }
  }

  /// 转换相机图像为 ML Kit 输入格式
  InputImage? _convertCameraImage(CameraImage image, CameraDescription camera) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;

    return InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  /// 分析姿态识别手势
  GestureResult _analyzeGesture(Pose pose) {
    final landmarks = pose.landmarks.values.toList();
    
    // 获取关键点
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final nose = pose.landmarks[PoseLandmarkType.nose];

    if (leftWrist == null || rightWrist == null || nose == null) {
      return GestureResult(gesture: GestureType.none, confidence: 0);
    }

    // 赏月手势：双手举过头顶
    if (_isMoonGazeGesture(leftWrist, rightWrist, leftShoulder, rightShoulder, nose)) {
      return GestureResult(
        gesture: GestureType.moonGaze,
        confidence: 0.85,
        landmarks: landmarks,
      );
    }

    // 合十手势：双手在胸前合拢
    if (_isPrayerGesture(leftWrist, rightWrist, leftShoulder, rightShoulder)) {
      return GestureResult(
        gesture: GestureType.prayerHands,
        confidence: 0.82,
        landmarks: landmarks,
      );
    }

    // 挥手：单手举起且在肩膀上方
    if (_isWaveGesture(leftWrist, rightWrist, leftShoulder, rightShoulder, leftElbow, rightElbow)) {
      return GestureResult(
        gesture: GestureType.wave,
        confidence: 0.80,
        landmarks: landmarks,
      );
    }

    // 点赞：手腕在肩膀附近，手臂弯曲
    if (_isThumbsUpGesture(leftWrist, rightWrist, leftElbow, rightElbow, leftShoulder, rightShoulder)) {
      return GestureResult(
        gesture: GestureType.thumbsUp,
        confidence: 0.75,
        landmarks: landmarks,
      );
    }

    return GestureResult(gesture: GestureType.none, confidence: 0, landmarks: landmarks);
  }

  /// 赏月手势检测
  bool _isMoonGazeGesture(
    PoseLandmark leftWrist,
    PoseLandmark rightWrist,
    PoseLandmark? leftShoulder,
    PoseLandmark? rightShoulder,
    PoseLandmark nose,
  ) {
    if (leftShoulder == null || rightShoulder == null) return false;

    // 双手都在头顶上方
    final handsAboveHead = leftWrist.y < nose.y && rightWrist.y < nose.y;
    
    // 双手距离适中（不太近也不太远）
    final handDistance = (leftWrist.x - rightWrist.x).abs();
    final shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
    final handsSpreadProperly = handDistance > shoulderWidth * 0.3 && 
                                 handDistance < shoulderWidth * 2.0;

    return handsAboveHead && handsSpreadProperly;
  }

  /// 合十手势检测
  bool _isPrayerGesture(
    PoseLandmark leftWrist,
    PoseLandmark rightWrist,
    PoseLandmark? leftShoulder,
    PoseLandmark? rightShoulder,
  ) {
    if (leftShoulder == null || rightShoulder == null) return false;

    // 双手靠近
    final handDistance = sqrt(
      pow(leftWrist.x - rightWrist.x, 2) + pow(leftWrist.y - rightWrist.y, 2),
    );
    final shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
    
    // 双手在胸前位置
    final handsInFront = leftWrist.y > leftShoulder.y && rightWrist.y > rightShoulder.y;
    final handsCentered = (leftWrist.x + rightWrist.x) / 2 > leftShoulder.x &&
                          (leftWrist.x + rightWrist.x) / 2 < rightShoulder.x;

    return handDistance < shoulderWidth * 0.5 && handsInFront && handsCentered;
  }

  /// 挥手手势检测
  bool _isWaveGesture(
    PoseLandmark leftWrist,
    PoseLandmark rightWrist,
    PoseLandmark? leftShoulder,
    PoseLandmark? rightShoulder,
    PoseLandmark? leftElbow,
    PoseLandmark? rightElbow,
  ) {
    if (leftShoulder == null || rightShoulder == null) return false;

    // 至少一只手举过肩膀
    final leftHandUp = leftWrist.y < leftShoulder.y;
    final rightHandUp = rightWrist.y < rightShoulder.y;

    // 只有一只手举起（区别于赏月）
    return (leftHandUp && !rightHandUp) || (!leftHandUp && rightHandUp);
  }

  /// 点赞手势检测
  bool _isThumbsUpGesture(
    PoseLandmark leftWrist,
    PoseLandmark rightWrist,
    PoseLandmark? leftElbow,
    PoseLandmark? rightElbow,
    PoseLandmark? leftShoulder,
    PoseLandmark? rightShoulder,
  ) {
    if (leftElbow == null || rightElbow == null ||
        leftShoulder == null || rightShoulder == null) {
      return false;
    }

    // 手腕在肘部上方，手臂弯曲
    final leftArmBent = leftWrist.y < leftElbow.y && leftElbow.y < leftShoulder.y;
    final rightArmBent = rightWrist.y < rightElbow.y && rightElbow.y < rightShoulder.y;

    return leftArmBent || rightArmBent;
  }

  /// 释放资源
  Future<void> dispose() async {
    await _poseDetector?.close();
    _poseDetector = null;
  }
}

/// 手势名称映射
extension GestureTypeExtension on GestureType {
  String get displayName {
    switch (this) {
      case GestureType.none:
        return '无';
      case GestureType.wave:
        return '挥手';
      case GestureType.thumbsUp:
        return '点赞';
      case GestureType.peace:
        return '剪刀手';
      case GestureType.heart:
        return '比心';
      case GestureType.moonGaze:
        return '赏月';
      case GestureType.prayerHands:
        return '合十';
      case GestureType.pointUp:
        return '指向上方';
      case GestureType.openPalm:
        return '张开手掌';
    }
  }

  String get targetGestureKey {
    switch (this) {
      case GestureType.moonGaze:
        return 'moon_gaze';
      case GestureType.prayerHands:
        return 'prayer_hands';
      case GestureType.wave:
        return 'wave';
      case GestureType.thumbsUp:
        return 'thumbs_up';
      case GestureType.peace:
        return 'peace';
      case GestureType.heart:
        return 'heart';
      case GestureType.pointUp:
        return 'point_up';
      case GestureType.openPalm:
        return 'open_palm';
      default:
        return '';
    }
  }

  static GestureType fromKey(String? key) {
    switch (key) {
      case 'moon_gaze':
        return GestureType.moonGaze;
      case 'prayer_hands':
        return GestureType.prayerHands;
      case 'wave':
        return GestureType.wave;
      case 'thumbs_up':
        return GestureType.thumbsUp;
      case 'peace':
        return GestureType.peace;
      case 'heart':
        return GestureType.heart;
      case 'point_up':
        return GestureType.pointUp;
      case 'open_palm':
        return GestureType.openPalm;
      default:
        return GestureType.none;
    }
  }
}
