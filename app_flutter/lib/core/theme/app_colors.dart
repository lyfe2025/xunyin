import 'package:flutter/material.dart';

/// 寻印 App 配色 - 中国传统色系
class AppColors {
  AppColors._();

  // 主色调 - 黛青（深青色，沉稳大气）
  static const Color primary = Color(0xFF425066);
  static const Color primaryLight = Color(0xFF5A6B82);
  static const Color primaryDark = Color(0xFF2D3A4D);

  // 强调色 - 中国红（品牌色）
  static const Color accent = Color(0xFFC41E3A);
  static const Color accentLight = Color(0xFFE04358);
  static const Color accentDark = Color(0xFF9A1830);

  // 辅助色
  static const Color secondary = Color(0xFF8B7355); // 驼色
  static const Color tertiary = Color(0xFF7BA08C); // 竹青

  // 背景色
  static const Color background = Color(0xFFF8F5F0); // 米白/宣纸色
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2EDE6);

  // 深色模式背景色
  static const Color darkBackground = Color(0xFF121218);
  static const Color darkSurface = Color(0xFF1E1E26);
  static const Color darkSurfaceVariant = Color(0xFF2A2A34);

  // 文字色
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // 深色模式文字色
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB8B8B8);
  static const Color darkTextHint = Color(0xFF9A9A9A);

  // 边框/分割线
  static const Color border = Color(0xFFE5E0D8);
  static const Color divider = Color(0xFFEBE6DE);
  static const Color darkBorder = Color(0xFF3A3A44);

  // 状态色
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFAAD14);
  static const Color error = Color(0xFFFF4D4F);
  static const Color info = Color(0xFF1890FF);

  // 印记相关
  static const Color sealGold = Color(0xFFE6B422); // 金色印记（更亮）
  static const Color sealSilver = Color(0xFFC0C0C0); // 银色印记
  static const Color sealBronze = Color(0xFFCD7F32); // 铜色印记
  static const Color sealLocked = Color(0xFFCCCCCC); // 未解锁

  /// 根据亮度获取适配的颜色
  static Color adaptive(BuildContext context, Color light, Color dark) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  /// 获取卡片背景色（适配深色模式）
  static Color cardBackground(BuildContext context) {
    return adaptive(context, Colors.white, darkSurface);
  }

  /// 获取页面背景色（适配深色模式）
  static Color pageBackground(BuildContext context) {
    return adaptive(context, background, darkBackground);
  }

  /// 获取主要文字颜色（适配深色模式）
  static Color textPrimaryAdaptive(BuildContext context) {
    return adaptive(context, textPrimary, darkTextPrimary);
  }

  /// 获取次要文字颜色（适配深色模式）
  static Color textSecondaryAdaptive(BuildContext context) {
    return adaptive(context, textSecondary, darkTextSecondary);
  }

  /// 获取提示文字颜色（适配深色模式）
  static Color textHintAdaptive(BuildContext context) {
    return adaptive(context, textHint, darkTextHint);
  }

  /// 获取边框颜色（适配深色模式）
  static Color borderAdaptive(BuildContext context) {
    return adaptive(context, border, darkBorder);
  }

  /// 获取表面变体颜色（适配深色模式）
  static Color surfaceVariantAdaptive(BuildContext context) {
    return adaptive(context, surfaceVariant, darkSurfaceVariant);
  }
}

/// 便捷扩展 - 判断当前是否为深色模式
extension BrightnessExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
