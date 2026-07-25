import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_home_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/client/presentation/client_home_screen.dart';
import '../../features/livreur/presentation/livreur_home_screen.dart';
import '../session/session_providers.dart';
import 'app_routes.dart';

/// Bridges Riverpod state changes to GoRouter's refreshListenable so that
/// changing the current role triggers the redirect logic below.
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.listen(currentRoleProvider, (_, _) => refreshNotifier.notify());
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final role = ref.read(currentRoleProvider);
      final onAuthScreen = state.matchedLocation == AppRoutes.welcome ||
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;

      if (role == null) {
        return onAuthScreen ? null : AppRoutes.welcome;
      }
      if (onAuthScreen) {
        return role.homeRoute;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.client,
        builder: (context, state) => const ClientHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.livreur,
        builder: (context, state) => const LivreurHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminHomeScreen(),
      ),
    ],
  );
});
