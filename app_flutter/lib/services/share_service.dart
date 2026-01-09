import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/config/app_config.dart';

// ignore_for_file: unnecessary_import

/// 分享服务
class ShareService {
  /// 复制链接到剪贴板
  static Future<void> copyLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    Fluttertoast.showToast(msg: '链接已复制');
  }

  /// 生成印记分享链接
  /// [userSealId] 用户印记ID（不是 sealId）
  static String generateSealShareLink(String userSealId) {
    return '${AppConfig.shareBaseUrl}/seal/$userSealId';
  }

  /// 将 Widget 截图并保存到相册
  static Future<bool> captureAndSave(GlobalKey key) async {
    try {
      // 请求相册权限
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        Fluttertoast.showToast(msg: '需要相册权限才能保存图片');
        return false;
      }

      // 获取 RenderRepaintBoundary
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Fluttertoast.showToast(msg: '截图失败');
        return false;
      }

      // 渲染为图片
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        Fluttertoast.showToast(msg: '生成图片失败');
        return false;
      }

      final bytes = byteData.buffer.asUint8List();

      // 保存到相册
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(bytes),
        quality: 100,
        name: 'xunyin_seal_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        Fluttertoast.showToast(msg: '已保存到相册');
        return true;
      } else {
        Fluttertoast.showToast(msg: '保存失败');
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '保存失败: $e');
      return false;
    }
  }
}
