import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/error_handler.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

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

class XunyinApp extends StatelessWidget {
  const XunyinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '寻印',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
