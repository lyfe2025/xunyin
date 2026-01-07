import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/journey/pages/journey_detail_page.dart';
import '../../features/journey/pages/journey_progress_page.dart';
import '../../features/journey/pages/navigation_page.dart';
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
        builder: (context, state) => TaskCompletePage(
          pointId: state.pathParameters['pointId']!,
          photoPath: state.uri.queryParameters['photo'],
        ),
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

/// 启动页
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

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
    _checkAuth();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    // 开发阶段：跳转到登录页
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFC41E3A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    '寻',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '寻印',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '探索城市文化，收集专属印记',
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
