import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/shell/app_shell.dart';
import '../../features/home/home_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/products/product_detail_screen.dart';
import '../../features/buyers/buyers_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/orders/order_detail_screen.dart';
import '../../features/sales/sales_screen.dart';
import '../../features/ai_assistant/ai_assistant_screen.dart';
import '../../features/product_creation/add_product_screen.dart';
import '../../features/product_creation/image_studio_screen.dart';
import '../../features/product_creation/voice_catalog_screen.dart';
import '../../features/product_creation/ai_processing_screen.dart';
import '../../features/product_creation/catalog_preview_screen.dart';
import '../../features/product_creation/pricing_screen.dart';
import '../../features/product_creation/buyer_match_screen.dart';
import '../../features/product_creation/publish_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  errorBuilder: (context, state) => _RouteErrorScreen(
    message: state.error?.message ?? 'Route not found',
  ),
  routes: [
    // Shell route for bottom navigation tabs
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/products',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const ProductsScreen(),
          ),
        ),
        GoRoute(
          path: '/buyers',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const BuyersScreen(),
          ),
        ),
        GoRoute(
          path: '/orders',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const OrdersScreen(),
          ),
        ),
      ],
    ),
    // Full-screen routes (no bottom nav)
    GoRoute(
      path: '/product/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        if (id == null || id.isEmpty) {
          return const _RouteErrorScreen(message: 'Product ID not specified');
        }
        return ProductDetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/order/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        if (id == null || id.isEmpty) {
          return const _RouteErrorScreen(message: 'Order ID not specified');
        }
        return OrderDetailScreen(orderId: id);
      },
    ),
    GoRoute(
      path: '/sales',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SalesScreen(),
    ),
    GoRoute(
      path: '/ai-assistant',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AiAssistantScreen(),
    ),
    // Product creation flow
    GoRoute(
      path: '/add-product',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddProductScreen(),
    ),
    GoRoute(
      path: '/image-studio',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ImageStudioScreen(),
    ),
    GoRoute(
      path: '/voice-catalog',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const VoiceCatalogScreen(),
    ),
    GoRoute(
      path: '/ai-processing',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AiProcessingScreen(),
    ),
    GoRoute(
      path: '/catalog-preview',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CatalogPreviewScreen(),
    ),
    GoRoute(
      path: '/pricing',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PricingScreen(),
    ),
    GoRoute(
      path: '/buyer-match',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BuyerMatchScreen(),
    ),
    GoRoute(
      path: '/publish',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PublishScreen(),
    ),
  ],
);

class _RouteErrorScreen extends StatelessWidget {
  final String message;
  const _RouteErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invalid Route'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : context.go('/home'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home (होम)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
