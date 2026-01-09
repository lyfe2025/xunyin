import 'package:flutter/material.dart';

/// 设计 Token - 间距
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// 页面水平内边距
  static const double pageHorizontal = 16;

  /// 页面垂直内边距
  static const double pageVertical = 16;

  /// 卡片内边距
  static const double cardPadding = 20;

  /// 列表项间距
  static const double listItemSpacing = 12;
}

/// 设计 Token - 圆角
class AppRadius {
  AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 18;
  static const double xxl = 20;
  static const double xxxl = 24;

  /// 按钮圆角
  static const double button = 14;

  /// 卡片圆角
  static const double card = 16;

  /// 大卡片圆角
  static const double cardLarge = 20;

  /// 输入框圆角
  static const double input = 12;

  /// 底部弹窗圆角
  static const double bottomSheet = 24;

  /// 对话框圆角
  static const double dialog = 20;

  /// 图标按钮圆角
  static const double iconButton = 12;

  /// 标签圆角
  static const double tag = 8;

  /// 进度条圆角
  static const double progress = 4;
}

/// 设计 Token - 尺寸
class AppSize {
  AppSize._();

  /// 主按钮高度
  static const double buttonHeight = 52;

  /// 次要按钮高度
  static const double buttonHeightSmall = 44;

  /// 图标按钮尺寸
  static const double iconButtonSize = 42;

  /// 头像尺寸
  static const double avatarSmall = 32;
  static const double avatarMedium = 48;
  static const double avatarLarge = 72;

  /// AppBar 图标尺寸
  static const double appBarIconSize = 22;

  /// 列表项高度
  static const double listItemHeight = 52;

  /// 输入框高度
  static const double inputHeight = 48;
}

/// 设计 Token - 阴影
class AppShadow {
  AppShadow._();

  /// 轻微阴影 - 用于浮动按钮
  static List<BoxShadow> get light => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// 中等阴影 - 用于卡片
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// 强调阴影 - 用于主按钮
  static List<BoxShadow> accent(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// 玻璃态卡片阴影
  static List<BoxShadow> get glass => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];
}

/// 设计 Token - 透明度
class AppOpacity {
  AppOpacity._();

  /// 玻璃态卡片背景
  static const double glassCard = 0.88;

  /// 玻璃态卡片边框
  static const double glassBorder = 0.5;

  /// 禁用状态
  static const double disabled = 0.5;

  /// 次要内容
  static const double secondary = 0.7;

  /// 提示内容
  static const double hint = 0.5;
}
