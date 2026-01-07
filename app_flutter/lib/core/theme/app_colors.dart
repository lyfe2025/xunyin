import 'package:flutter/material.dart';

/// 寻印 App 配色 - 中国传统色系
class AppColors {
  AppColors._();

  // 主色调 - 黛青（深青色，沉稳大气）
  static const Color primary = Color(0xFF425066);
  static const Color primaryLight = Color(0xFF5A6B82);
  static const Color primaryDark = Color(0xFF2D3A4D);

  // 强调色 - 朱砂（印章红）
  static const Color accent = Color(0xFFCF4526);
  static const Color accentLight = Color(0xFFE86B4A);
  static const Color accentDark = Color(0xFFA33518);

  // 辅助色
  static const Color secondary = Color(0xFF8B7355); // 驼色
  static const Color tertiary = Color(0xFF7BA08C); // 竹青

  // 背景色
  static const Color background = Color(0xFFF8F5F0); // 米白/宣纸色
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2EDE6);

  // 文字色
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // 边框/分割线
  static const Color border = Color(0xFFE5E0D8);
  static const Color divider = Color(0xFFEBE6DE);

  // 状态色
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFAAD14);
  static const Color error = Color(0xFFFF4D4F);
  static const Color info = Color(0xFF1890FF);

  // 印记相关
  static const Color sealGold = Color(0xFFD4AF37); // 金色印记
  static const Color sealSilver = Color(0xFFC0C0C0); // 银色印记
  static const Color sealBronze = Color(0xFFCD7F32); // 铜色印记
  static const Color sealLocked = Color(0xFFCCCCCC); // 未解锁
}
