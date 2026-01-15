import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_config.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/journey/pages/journey_detail_page.dart';
import '../../features/journey/pages/journey_progress_page.dart';
import '../../features/journey/pages/navigation_page.dart';
import '../../features/journey/pages/my_journeys_page.dart';
import '../../features/ar/pages/ar_task_page.dart';
import '../../features/ar/pages/task_complete_page.dart';
import '../../features/journey/pages/journey_complete_page.dart';
import '../../features/seal/pages/seal_list_page.dart';
import '../../features/seal/pages/seal_detail_page.dart';
import '../../features/album/pages/album_page.dart';
import '../../features/album/pages/photo_detail_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/pages/settings_page.dart';
import '../../features/profile/pages/agreement_page.dart';
import '../../features/profile/pages/edit_nickname_page.dart';
import '../../features/profile/pages/edit_avatar_page.dart';
import '../../models/splash_config.dart';
import '../../providers/splash_config_provider.dart';
import '../../features/profile/pages/bind_phone_page.dart';
import '../../features/profile/pages/badges_page.dart';

/// 路由配置
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/journey/:id',
        builder: (context, state) =>
            JourneyDetailPage(journeyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/journey/:id/progress',
        builder: (context, state) =>
            JourneyProgressPage(journeyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/journey/:journeyId/navigate/:pointId',
        builder: (context, state) => NavigationPage(
          journeyId: state.pathParameters['journeyId']!,
          pointId: state.pathParameters['pointId']!,
        ),
      ),
      GoRoute(
        path: '/ar-task/:pointId',
        builder: (context, state) =>
            ARTaskPage(pointId: state.pathParameters['pointId']!),
      ),
      GoRoute(
        path: '/task-complete/:pointId',
        builder: (context, state) {
          final queryParams = state.uri.queryParameters;
          return TaskCompletePage(
            pointId: state.pathParameters['pointId']!,
            photoPath: queryParams['photo'],
            pointsEarned: queryParams['pointsEarned'] != null
                ? int.tryParse(queryParams['pointsEarned']!)
                : null,
            totalPoints: queryParams['totalPoints'] != null
                ? int.tryParse(queryParams['totalPoints']!)
                : null,
            journeyCompleted: queryParams['journeyCompleted'] == 'true',
            sealId: queryParams['sealId'],
            userSealId: queryParams['userSealId'],
          );
        },
      ),
      GoRoute(
        path: '/journey/:id/complete',
        builder: (context, state) =>
            JourneyCompletePage(journeyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/seals',
        builder: (context, state) => const SealListPage(),
      ),
      GoRoute(
        path: '/journeys',
        builder: (context, state) => const MyJourneysPage(),
      ),
      GoRoute(
        path: '/seal/:id',
        builder: (context, state) =>
            SealDetailPage(sealId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/album', builder: (context, state) => const AlbumPage()),
      GoRoute(
        path: '/photo/:id',
        builder: (context, state) =>
            PhotoDetailPage(photoId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/settings/nickname',
        builder: (context, state) => const EditNicknamePage(),
      ),
      GoRoute(
        path: '/settings/avatar',
        builder: (context, state) => const EditAvatarPage(),
      ),
      GoRoute(
        path: '/settings/phone',
        builder: (context, state) => const BindPhonePage(),
      ),
      GoRoute(
        path: '/badges',
        builder: (context, state) => const BadgesPage(),
      ),
      GoRoute(
        path: '/agreement/:type',
        builder: (context, state) {
          final typeStr = state.pathParameters['type']!;
          final type = AgreementType.values.firstWhere(
            (e) => e.value == typeStr,
            orElse: () => AgreementType.userAgreement,
          );
          return AgreementPage(type: type);
        },
      ),
    ],
  );
}

/// 启动页 - 支持从后台动态获取配置
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _countdown = 0;
  bool _canSkip = false;
  SplashConfig? _config;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startTimer(SplashConfig config) {
    if (_config != null) return; // 防止重复启动
    _config = config;
    _countdown = config.duration;
    _canSkip = config.skipDelay == 0;

    // 启动倒计时
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _countdown--;
        if (!_canSkip && config.skipDelay > 0) {
          final elapsed = config.duration - _countdown;
          _canSkip = elapsed >= config.skipDelay;
        }
      });

      if (_countdown <= 0) {
        _navigateNext();
        return false;
      }
      return true;
    });
  }

  void _navigateNext() {
    if (!mounted) return;
    context.go('/login');
  }

  void _skip() {
    if (_canSkip) {
      _navigateNext();
    }
  }

  Color _parseColor(String? colorStr, Color defaultColor) {
    if (colorStr == null || colorStr.isEmpty) return defaultColor;
    try {
      if (colorStr.startsWith('#')) {
        final hex = colorStr.replaceFirst('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        }
      }
    } catch (_) {}
    return defaultColor;
  }

  /// 获取服务器基础 URL（不含 /api/app）
  String get _serverBaseUrl {
    final baseUrl = AppConfig.apiBaseUrl;
    if (baseUrl.endsWith('/api/app')) {
      return baseUrl.substring(0, baseUrl.length - 8);
    }
    return baseUrl;
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(splashConfigProvider);

    return configAsync.when(
      data: (config) {
        _startTimer(config);
        return config.isAdMode
            ? _buildAdSplash(config)
            : _buildBrandSplash(config);
      },
      loading: () => _buildBrandSplash(const SplashConfig()),
      error: (_, __) {
        _startTimer(const SplashConfig());
        return _buildBrandSplash(const SplashConfig());
      },
    );
  }

  /// 品牌启动页
  Widget _buildBrandSplash(SplashConfig config) {
    final bgColor = _parseColor(config.backgroundColor, const Color(0xFFF8F5F0));
    final textColor = _parseColor(config.textColor, const Color(0xFF2D2D2D));
    final logoColor = _parseColor(config.logoColor, const Color(0xFFC41E3A));

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogo(config, logoColor),
              const SizedBox(height: 24),
              Text(
                config.appName ?? '寻印',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                config.slogan ?? '探索城市文化，收集专属印记',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 广告启动页
  Widget _buildAdSplash(SplashConfig config) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 广告媒体
          if (config.mediaUrl != null && config.mediaUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: '$_serverBaseUrl${config.mediaUrl}',
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildBrandSplash(config),
              errorWidget: (context, url, error) {
                debugPrint('[SplashPage] 广告图片加载失败: $url, error: $error');
                return _buildBrandSplash(config);
              },
            ),
          // 跳过按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: _canSkip ? _skip : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _canSkip ? '跳过 $_countdown' : '$_countdown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(SplashConfig config, Color logoColor) {
    // 优先级：远程图片 > 文字 Logo
    if (config.logoImage != null && config.logoImage!.isNotEmpty) {
      final fullUrl = '$_serverBaseUrl${config.logoImage}';
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: fullUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildDefaultLogo(config, logoColor),
          errorWidget: (context, url, error) {
            debugPrint('[SplashPage] Logo 加载失败: $fullUrl, error: $error');
            return _buildDefaultLogo(config, logoColor);
          },
        ),
      );
    }
    // logoImage 为空时，直接显示文字 Logo
    return _buildDefaultLogo(config, logoColor);
  }

  Widget _buildDefaultLogo(SplashConfig config, Color logoColor) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: logoColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          config.logoText ?? '印',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
