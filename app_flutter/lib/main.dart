import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_info.dart';
import 'core/utils/error_handler.dart';
import 'providers/settings_providers.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // 初始化应用信息
      await AppInfo.init();

      // 初始化全局错误处理
      ErrorHandler.init();

      // 设置状态栏样式
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );

      runApp(const ProviderScope(child: XunyinApp()));
    },
    (error, stackTrace) {
      // 捕获 Zone 内未处理的异步错误
      ErrorHandler.reportError(
        error,
        stackTrace,
        reason: 'Uncaught async error',
      );
    },
  );
}

class XunyinApp extends ConsumerWidget {
  const XunyinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: '寻印',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.flutterThemeMode,
      routerConfig: AppRouter.router,
    );
  }
}
