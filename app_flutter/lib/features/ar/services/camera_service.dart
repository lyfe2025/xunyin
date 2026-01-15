import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// camera 包
import 'package:camera/camera.dart';

/// 拍照结果
class CaptureResult {
  final String localPath;      // 应用内路径
  final String? galleryPath;   // 相册路径（如果保存成功）
  final bool savedToGallery;   // 是否已保存到相册

  CaptureResult({
    required this.localPath,
    this.galleryPath,
    this.savedToGallery = false,
  });
}

/// 相机服务 - 管理相机初始化、预览和拍照
class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isRecording => _controller?.value.isRecordingVideo ?? false;

  /// 初始化相机
  Future<void> initialize({
    CameraLensDirection direction = CameraLensDirection.back,
    ResolutionPreset resolution = ResolutionPreset.high,
  }) async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('没有可用的相机');
      }

      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == direction,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        camera,
        resolution,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('相机初始化失败: $e');
      rethrow;
    }
  }

  /// 切换前后摄像头
  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;

    final currentDirection = _controller?.description.lensDirection;
    final newDirection = currentDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    await dispose();
    await initialize(direction: newDirection);
  }

  /// 拍照（仅保存到应用目录）
  Future<String?> takePicture() async {
    if (_controller == null || !_isInitialized) return null;

    try {
      final XFile file = await _controller!.takePicture();

      // 保存到应用目录
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'xunyin_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${directory.path}/$fileName';

      await File(file.path).copy(savedPath);
      return savedPath;
    } catch (e) {
      debugPrint('拍照失败: $e');
      return null;
    }
  }

  /// 拍照并保存到相册
  Future<CaptureResult?> takePictureAndSaveToGallery({
    bool saveToGallery = true,
    String albumName = '寻印',
  }) async {
    if (_controller == null || !_isInitialized) return null;

    try {
      final XFile file = await _controller!.takePicture();

      // 保存到应用目录
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'xunyin_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${directory.path}/$fileName';
      await File(file.path).copy(savedPath);

      // 保存到相册
      String? galleryPath;
      bool savedToGallery = false;

      if (saveToGallery) {
        final hasPermission = await _requestGalleryPermission();
        if (hasPermission) {
          final bytes = await File(savedPath).readAsBytes();
          final result = await ImageGallerySaverPlus.saveImage(
            bytes,
            quality: 95,
            name: fileName,
          );

          if (result != null && result['isSuccess'] == true) {
            savedToGallery = true;
            galleryPath = result['filePath'] as String?;
            debugPrint('照片已保存到相册: $galleryPath');
          }
        }
      }

      return CaptureResult(
        localPath: savedPath,
        galleryPath: galleryPath,
        savedToGallery: savedToGallery,
      );
    } catch (e) {
      debugPrint('拍照失败: $e');
      return null;
    }
  }

  /// 将已有图片保存到相册
  Future<bool> saveToGallery(String imagePath, {String albumName = '寻印'}) async {
    try {
      final hasPermission = await _requestGalleryPermission();
      if (!hasPermission) return false;

      final bytes = await File(imagePath).readAsBytes();
      final fileName = 'xunyin_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 95,
        name: fileName,
      );

      return result != null && result['isSuccess'] == true;
    } catch (e) {
      debugPrint('保存到相册失败: $e');
      return false;
    }
  }

  /// 请求相册权限
  Future<bool> _requestGalleryPermission() async {
    if (Platform.isAndroid) {
      // Android 13+ 使用 photos 权限
      final status = await Permission.photos.request();
      if (status.isGranted) return true;

      // 旧版本 Android 使用 storage 权限
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      return status.isGranted;
    }
    return false;
  }

  /// 设置闪光灯模式
  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller == null || !_isInitialized) return;
    await _controller!.setFlashMode(mode);
  }

  /// 设置缩放级别
  Future<void> setZoomLevel(double zoom) async {
    if (_controller == null || !_isInitialized) return;
    final minZoom = await _controller!.getMinZoomLevel();
    final maxZoom = await _controller!.getMaxZoomLevel();
    await _controller!.setZoomLevel(zoom.clamp(minZoom, maxZoom));
  }

  /// 获取缩放范围
  Future<(double, double)> getZoomRange() async {
    if (_controller == null || !_isInitialized) return (1.0, 1.0);
    final minZoom = await _controller!.getMinZoomLevel();
    final maxZoom = await _controller!.getMaxZoomLevel();
    return (minZoom, maxZoom);
  }

  /// 开始图像流（用于 ML Kit）
  Future<void> startImageStream(Function(CameraImage) onImage) async {
    if (_controller == null || !_isInitialized) return;
    await _controller!.startImageStream(onImage);
  }

  /// 停止图像流
  Future<void> stopImageStream() async {
    if (_controller == null || !_isInitialized) return;
    try {
      await _controller!.stopImageStream();
    } catch (e) {
      debugPrint('停止图像流失败: $e');
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
