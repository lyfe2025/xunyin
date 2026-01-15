import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/config/app_config.dart';
import '../shared/widgets/app_snackbar.dart';

/// 分享服务
class ShareService {
  /// 复制链接到剪贴板
  static Future<void> copyLink(BuildContext context, String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (context.mounted) {
      AppSnackBar.success(context, '链接已复制');
    }
  }

  /// 生成印记分享链接
  /// [userSealId] 用户印记ID（不是 sealId）
  static String generateSealShareLink(String userSealId) {
    return '${AppConfig.shareBaseUrl}/seal/$userSealId';
  }

  /// 将 Widget 截图并保存到相册
  static Future<bool> captureAndSave(BuildContext context, GlobalKey key) async {
    try {
      // iOS 14+ 使用 photosAddOnly 权限（仅写入），其他平台使用 photos
      Permission permission;
      if (await Permission.photosAddOnly.status.isGranted ||
          await Permission.photosAddOnly.status.isLimited) {
        // 已有权限，直接保存
        if (!context.mounted) return false;
        return _doCapture(context, key);
      }

      // 请求权限 - 优先使用 photosAddOnly（iOS 14+）
      permission = Permission.photosAddOnly;
      var status = await permission.status;

      // 如果未授权，请求权限
      if (!status.isGranted && !status.isLimited) {
        status = await permission.request();
      }

      // 权限仍未授权
      if (!status.isGranted && !status.isLimited) {
        if (!context.mounted) return false;

        // 永久拒绝 -> 引导去设置
        if (status.isPermanentlyDenied) {
          AppSnackBar.withAction(
            context,
            message: '需要相册权限才能保存图片',
            actionLabel: '去设置',
            onAction: () => openAppSettings(),
          );
          return false;
        }

        // 用户拒绝
        if (context.mounted) {
          AppSnackBar.warning(context, '需要相册权限才能保存图片');
        }
        return false;
      }

      if (!context.mounted) return false;
      return _doCapture(context, key);
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, '保存失败: $e');
      }
      return false;
    }
  }

  /// 执行实际的截图保存操作
  static Future<bool> _doCapture(BuildContext context, GlobalKey key) async {
    try {
      // 获取 RenderRepaintBoundary
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (context.mounted) {
          AppSnackBar.error(context, '截图失败');
        }
        return false;
      }

      // 渲染为图片
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (context.mounted) {
          AppSnackBar.error(context, '生成图片失败');
        }
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
        if (context.mounted) {
          AppSnackBar.success(context, '已保存到相册');
        }
        return true;
      } else {
        if (context.mounted) {
          AppSnackBar.error(context, '保存失败');
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, '保存失败: $e');
      }
      return false;
    }
  }
}
