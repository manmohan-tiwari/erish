import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/erish_button.dart';
import '../features/product/presentation/product_detail_page.dart';
import '../features/checkout/presentation/checkout_page.dart';
import '../features/orders/presentation/order_confirmation_page.dart';
import '../features/admin/presentation/admin_portal_page.dart';
import '../features/auth/presentation/auth_page.dart';

/// ERISH Official Application Router
/// Supports deep linking for web direct-load and navigation
class AppRouter {
  static const String home = '/';
  static const String collection = '/collections/:id';
  static const String product = '/product/:slug';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String admin = '/admin';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String auth = '/auth';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const ErishHomePage(),
      ),
      GoRoute(
        path: collection,
        name: 'collection',
        builder: (context, state) {
          final collectionId = state.pathParameters['id'] ?? 'all';
          return ErishHomePage(initialCategory: collectionId);
        },
      ),
      GoRoute(
        path: product,
        name: 'product',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return ProductDetailPage(slug: slug);
        },
      ),
      GoRoute(
        path: cart,
        name: 'cart',
        builder: (context, state) => const ErishHomePage(openCartOnLoad: true),
      ),
      GoRoute(
        path: checkout,
        name: 'checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: orderConfirmation,
        name: 'order-confirmation',
        builder: (context, state) {
          final details = state.extra as Map<String, dynamic>?;
          return OrderConfirmationPage(orderDetails: details);
        },
      ),
      GoRoute(
        path: admin,
        name: 'admin',
        builder: (context, state) => const AdminPortalPage(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const AuthPage(initialTab: AuthTab.signIn),
      ),
      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const AuthPage(initialTab: AuthTab.signUp),
      ),
      GoRoute(
        path: auth,
        name: 'auth',
        builder: (context, state) => const AuthPage(initialTab: AuthTab.signIn),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '404',
                style: AppTypography.displayHero(color: AppColors.espresso),
              ),
              const SizedBox(height: 12),
              Text(
                'The page you are looking for does not exist.',
                style: AppTypography.body(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              ErishButton(
                text: 'Return to Home',
                onPressed: () => context.go(home),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
