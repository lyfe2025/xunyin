import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 全局错误处理器
class ErrorHandler {
  static final List<ErrorRecord> _errorLog = [];

  /// 初始化错误处理
  static void init() {
    // Flutter 框架错误（Widget 构建错误等）
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      reportError(
        details.exception,
        details.stack,
        reason: details.context?.toString(),
      );
    };

    // 平台调度器错误（异步错误）
    PlatformDispatcher.instance.onError = (error, stack) {
      reportError(error, stack, reason: 'Platform dispatcher error');
      return true;
    };
  }

  /// 上报错误
  static void reportError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
  }) {
    final record = ErrorRecord(
      error: error,
      stackTrace: stackTrace,
      reason: reason,
      timestamp: DateTime.now(),
    );

    // 保存到内存日志（最多保留 50 条）
    _errorLog.add(record);
    if (_errorLog.length > 50) {
      _errorLog.removeAt(0);
    }

    // 开发环境打印详细信息
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔴 ERROR: ${record.timestamp}');
      if (reason != null) debugPrint('📍 Context: $reason');
      debugPrint('💥 Exception: $error');
      if (stackTrace != null) {
        debugPrint('📚 Stack trace:');
        debugPrint(stackTrace.toString());
      }
      debugPrint('═══════════════════════════════════════════════════════════');
    }

    // TODO: 生产环境上报到 Sentry/Firebase Crashlytics
    // if (!kDebugMode) {
    //   Sentry.captureException(error, stackTrace: stackTrace);
    // }
  }

  /// 获取错误日志（用于调试页面）
  static List<ErrorRecord> get errorLog => List.unmodifiable(_errorLog);

  /// 清空错误日志
  static void clearLog() => _errorLog.clear();

  /// 包装异步操作，自动捕获错误
  static Future<T?> guard<T>(
    Future<T> Function() action, {
    String? context,
    T? fallback,
  }) async {
    try {
      return await action();
    } catch (e, stack) {
      reportError(e, stack, reason: context);
      return fallback;
    }
  }

  /// 显示用户友好的错误提示
  static void showErrorSnackBar(BuildContext context, Object error) {
    final message = _getUserFriendlyMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// 转换为用户友好的错误信息
  static String _getUserFriendlyMessage(Object error) {
    final errorStr = error.toString();

    if (errorStr.contains('SocketException') ||
        errorStr.contains('Connection refused') ||
        errorStr.contains('Failed host lookup')) {
      return '网络连接失败，请检查网络设置';
    }

    if (errorStr.contains('timeout') || errorStr.contains('Timeout')) {
      return '请求超时，请稍后重试';
    }

    if (errorStr.contains('401') || errorStr.contains('Unauthorized')) {
      return '登录已过期，请重新登录';
    }

    if (errorStr.contains('403') || errorStr.contains('Forbidden')) {
      return '没有权限执行此操作';
    }

    if (errorStr.contains('404')) {
      return '请求的资源不存在';
    }

    if (errorStr.contains('500')) {
      return '服务器错误，请稍后重试';
    }

    return '操作失败，请稍后重试';
  }
}

/// 错误记录
class ErrorRecord {
  final Object error;
  final StackTrace? stackTrace;
  final String? reason;
  final DateTime timestamp;

  ErrorRecord({
    required this.error,
    this.stackTrace,
    this.reason,
    required this.timestamp,
  });

  @override
  String toString() {
    return '[$timestamp] $error${reason != null ? ' ($reason)' : ''}';
  }
}
