import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import 'service_providers.dart';

/// 当前用户信息
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  try {
    final service = ref.watch(userServiceProvider);
    return await service.getCurrentUser();
  } catch (e) {
    return null;
  }
});

/// 用户统计
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final service = ref.watch(userServiceProvider);
  return service.getUserStats();
});

/// 认证状态
class AuthState {
  final bool isLoggedIn;
  final AppUser? user;
  final bool isLoading;

  AuthState({this.isLoggedIn = false, this.user, this.isLoading = false});

  AuthState copyWith({bool? isLoggedIn, AppUser? user, bool? isLoading}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 认证状态 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setLoggedIn(AppUser user) {
    state = AuthState(isLoggedIn: true, user: user, isLoading: false);
  }

  void setLoggedOut() {
    state = AuthState(isLoggedIn: false, user: null, isLoading: false);
  }
}

/// 认证状态 Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
