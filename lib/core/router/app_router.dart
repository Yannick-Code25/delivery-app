import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_home_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/client/presentation/addresses_screen.dart';
import '../../features/client/presentation/cart_screen.dart';
import '../../features/client/presentation/client_home_screen.dart';
import '../../features/client/presentation/client_orders_screen.dart';
import '../../features/client/presentation/client_profile_screen.dart';
import '../../features/client/presentation/client_search_screen.dart';
import '../../features/client/presentation/client_shell.dart';
import '../../features/client/presentation/order_review_screen.dart';
import '../../features/client/presentation/order_tracking_screen.dart';
import '../../features/client/presentation/payment_methods_screen.dart';
import '../../features/client/presentation/product_customization_screen.dart';
import '../../features/client/presentation/restaurant_detail_screen.dart';
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
      final location = state.matchedLocation;
      final onAuthScreen = AppRoutes.authRoutes.contains(location);

      // Signed out: only the auth screens are reachable.
      if (role == null) {
        return onAuthScreen ? null : AppRoutes.welcome;
      }

      // Signed in: skip the auth screens, and keep each role inside its space.
      if (onAuthScreen) return role.homeRoute;
      if (!location.startsWith(role.homeRoute)) return role.homeRoute;

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
      // Client space: four tabs, each keeping its own navigation state.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ClientShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.client,
                builder: (context, state) => const ClientHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.clientSearch,
                builder: (context, state) => const ClientSearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.clientOrders,
                builder: (context, state) => const ClientOrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.clientProfile,
                builder: (context, state) => const ClientProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Client screens pushed above the shell, so they cover the bottom nav.
      GoRoute(
        path: AppRoutes.clientCart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.clientCheckout,
        builder: (context, state) => const CartScreen(showPayment: true),
      ),
      GoRoute(
        path: AppRoutes.clientAddresses,
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: AppRoutes.clientPaymentMethods,
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.client}/restaurant/:restaurantId',
        builder: (context, state) => RestaurantDetailScreen(
          restaurantId: state.pathParameters['restaurantId']!,
        ),
        routes: [
          GoRoute(
            path: 'produit/:itemId',
            builder: (context, state) => ProductCustomizationScreen(
              restaurantId: state.pathParameters['restaurantId']!,
              itemId: state.pathParameters['itemId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.client}/commande/:orderId/suivi',
        builder: (context, state) => OrderTrackingScreen(
          orderId: state.pathParameters['orderId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.client}/commande/:orderId/noter',
        builder: (context, state) => OrderReviewScreen(
          orderId: state.pathParameters['orderId']!,
        ),
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
