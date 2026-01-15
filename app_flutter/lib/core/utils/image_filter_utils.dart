import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../features/ar/widgets/photo_filter.dart';

/// 图片滤镜处理工具
class ImageFilterUtils {
  /// 对图片文件应用滤镜并保存
  ///
  /// [inputPath] 原图路径
  /// [filter] 滤镜类型
  /// [outputPath] 输出路径（可选，默认覆盖原图）
  static Future<String> applyFilterToFile(
    String inputPath,
    PhotoFilter filter, {
    String? outputPath,
  }) async {
    // 原图滤镜不需要处理
    if (filter == PhotoFilter.original) {
      return inputPath;
    }

    final file = File(inputPath);
    final bytes = await file.readAsBytes();

    // 解码图片
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('无法解码图片');
    }

    // 应用滤镜
    final filteredImage = _applyFilter(image, filter);

    // 编码并保存
    final output = outputPath ?? inputPath;
    final outputFile = File(output);

    // 根据扩展名选择编码格式
    final ext = output.toLowerCase();
    Uint8List outputBytes;
    if (ext.endsWith('.png')) {
      outputBytes = Uint8List.fromList(img.encodePng(filteredImage));
    } else {
      outputBytes = Uint8List.fromList(img.encodeJpg(filteredImage, quality: 95));
    }

    await outputFile.writeAsBytes(outputBytes);
    return output;
  }

  /// 对图片应用滤镜
  static img.Image _applyFilter(img.Image image, PhotoFilter filter) {
    final config = PhotoFilters.getConfig(filter);

    if (config.colorMatrix == null) {
      return image;
    }

    final matrix = config.colorMatrix!;

    // 遍历每个像素应用颜色矩阵
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();
        final a = pixel.a.toDouble();

        // 应用 5x4 颜色矩阵
        // [R']   [m0  m1  m2  m3  m4 ]   [R]
        // [G'] = [m5  m6  m7  m8  m9 ] * [G]
        // [B']   [m10 m11 m12 m13 m14]   [B]
        // [A']   [m15 m16 m17 m18 m19]   [A]
        //                                [1]
        final newR = (matrix[0] * r + matrix[1] * g + matrix[2] * b + matrix[3] * a + matrix[4])
            .clamp(0, 255)
            .toInt();
        final newG = (matrix[5] * r + matrix[6] * g + matrix[7] * b + matrix[8] * a + matrix[9])
            .clamp(0, 255)
            .toInt();
        final newB = (matrix[10] * r + matrix[11] * g + matrix[12] * b + matrix[13] * a + matrix[14])
            .clamp(0, 255)
            .toInt();
        final newA = (matrix[15] * r + matrix[16] * g + matrix[17] * b + matrix[18] * a + matrix[19])
            .clamp(0, 255)
            .toInt();

        image.setPixelRgba(x, y, newR, newG, newB, newA);
      }
    }

    // 应用叠加色（如果有）
    if (config.overlayColor != null) {
      final overlay = config.overlayColor!;
      final overlayR = (overlay.r * 255.0).round() & 0xff;
      final overlayG = (overlay.g * 255.0).round() & 0xff;
      final overlayB = (overlay.b * 255.0).round() & 0xff;
      final overlayA = overlay.a;

      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);

          // 简单的叠加混合
          final newR = (pixel.r * (1 - overlayA) + overlayR * overlayA).clamp(0, 255).toInt();
          final newG = (pixel.g * (1 - overlayA) + overlayG * overlayA).clamp(0, 255).toInt();
          final newB = (pixel.b * (1 - overlayA) + overlayB * overlayA).clamp(0, 255).toInt();

          image.setPixelRgba(x, y, newR, newG, newB, pixel.a.toInt());
        }
      }
    }

    return image;
  }
}
