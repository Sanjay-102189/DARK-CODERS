import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:craftmitra/core/routing/app_router.dart';
import 'package:craftmitra/features/products/product_detail_screen.dart';
import 'package:craftmitra/features/orders/order_detail_screen.dart';
import 'package:craftmitra/providers/providers.dart';
import 'package:craftmitra/services/firestore_order_service.dart';
import 'package:craftmitra/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

class MockUser extends Fake implements User {
  @override
  final String uid = 'test-artisan-999';
  @override
  final String email = 'artisan@test.com';
}

class MockAuthService extends AuthService {
  final User? user;
  MockAuthService({this.user});

  @override
  User? get currentUser => user;
  @override
  String? get currentUserId => user?.uid;
  @override
  bool get isAuthenticated => user != null;
}

class MockFirestoreOrderService extends FirestoreOrderService {
  int createOrderCalls = 0;
  Map<String, dynamic>? lastCreatedData;

  @override
  Future<void> createOrder({
    required String orderId,
    required Map<String, dynamic> data,
  }) async {
    createOrderCalls++;
    lastCreatedData = data;
  }

  @override
  Future<List<Map<String, dynamic>>> getOrdersForArtisan(String artisanId) async {
    return [];
  }
}

void main() {
  group('Navigation & Router Crash Regression Tests', () {
    Widget buildTestApp({Widget? child, String? initialLocation}) {
      final mockAuth = MockAuthService(user: MockUser());
      final mockFirestore = MockFirestoreOrderService();
      final ordersProvider = OrdersProvider(
        authService: mockAuth,
        firestoreService: mockFirestore,
      );
      final appStateProvider = AppStateProvider();
      final authProvider = AuthProvider(authService: mockAuth);
      final productCreationProvider = ProductCreationProvider();

      return MultiProvider(
        providers: [
          ChangeNotifierProvider<OrdersProvider>.value(value: ordersProvider),
          ChangeNotifierProvider<AppStateProvider>.value(value: appStateProvider),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ProductCreationProvider>.value(value: productCreationProvider),
        ],
        child: child ??
            MaterialApp.router(
              routerConfig: appRouter,
            ),
      );
    }

    testWidgets('1. Invalid route renders RouteErrorScreen gracefully without unhandled crash',
        (tester) async {
      await tester.pumpWidget(buildTestApp());

      appRouter.go('/invalid-craftmitra-path');
      await tester.pumpAndSettle();

      expect(find.text('Invalid Route'), findsOneWidget);
      expect(find.text('Go Home (होम)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('2. Full-screen /product/:id and /order/:id routes build without crash',
        (tester) async {
      await tester.pumpWidget(buildTestApp());

      appRouter.go('/product/CM-123');
      await tester.pumpAndSettle();

      expect(find.byType(ProductDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      appRouter.go('/order/ORD-999');
      await tester.pumpAndSettle();

      expect(find.byType(OrderDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('3. ProductDetailScreen test order dialog does not crash on order creation',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockAuth = MockAuthService(user: MockUser());
      final mockFirestore = MockFirestoreOrderService();
      final ordersProvider = OrdersProvider(
        authService: mockAuth,
        firestoreService: mockFirestore,
      );
      final appStateProvider = AppStateProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<OrdersProvider>.value(value: ordersProvider),
            ChangeNotifierProvider<AppStateProvider>.value(value: appStateProvider),
          ],
          child: const MaterialApp(
            home: ProductDetailScreen(productId: 'p-reg-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Simulate Test Order button
      final simulateBtn = find.text('Simulate Test Order (परीक्षण ऑर्डर बनाएं)');
      expect(simulateBtn, findsOneWidget);
      await tester.tap(simulateBtn);
      await tester.pumpAndSettle();

      // Confirm Test Order button inside bottom sheet
      final confirmBtn = find.text('Confirm Test Order (ऑर्डर दर्ज करें)');
      expect(confirmBtn, findsOneWidget);

      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Bottom sheet should dismiss and order should be created
      expect(mockFirestore.createOrderCalls, equals(1));
      expect(find.textContaining('Test order created successfully'), findsOneWidget);

      // Verify compact professional SnackBar attributes
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.duration, equals(const Duration(seconds: 3)));
      expect(snackBar.behavior, equals(SnackBarBehavior.floating));
      expect(find.text('View Orders'), findsOneWidget);
      expect(snackBar.action?.label, equals('View Orders'));
      expect(tester.takeException(), isNull);

      // Verify finite duration (3 seconds, not permanent or indefinite)
      expect(snackBar.duration, equals(const Duration(seconds: 3)));
      expect(snackBar.duration.isNegative, isFalse);

      // Verify hideCurrentSnackBar safely dismisses the SnackBar without ancestor lookup issues
      final scaffoldMessenger = ScaffoldMessenger.of(tester.element(find.byType(ProductDetailScreen)));
      scaffoldMessenger.hideCurrentSnackBar();
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('4. OrderDetailScreen back button works safely with GoRouter navigation',
        (tester) async {
      await tester.pumpWidget(buildTestApp());

      appRouter.go('/order/ORD-TEST-123');
      await tester.pumpAndSettle();

      final backBtn = find.byIcon(Icons.arrow_back);
      expect(backBtn, findsOneWidget);
      // Tap back button
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
