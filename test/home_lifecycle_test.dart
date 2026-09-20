import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:craftmitra/features/home/home_screen.dart';
import 'package:craftmitra/providers/providers.dart';
import 'package:craftmitra/services/firestore_product_service.dart';
import 'package:craftmitra/services/firestore_order_service.dart';
import 'package:craftmitra/services/auth_service.dart';

class MockFirestoreOrderService extends FirestoreOrderService {
  @override
  Future<List<Map<String, dynamic>>> getOrdersForArtisan(String artisanId) async {
    return [];
  }
}

class MockUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;

  MockUser({required this.uid, this.email});
}

class MockAuthService extends AuthService {
  User? _currentUser;
  MockAuthService({User? user}) : _currentUser = user;

  @override
  User? get currentUser => _currentUser;
  String? get currentUid => _currentUser?.uid;
  @override
  String? get currentUserId => _currentUser?.uid;
  @override
  bool get isAuthenticated => _currentUser != null;

  void setUser(User? user) {
    _currentUser = user;
  }
}

class MockFirestoreService extends FirestoreProductService {
  int fetchCallCount = 0;
  String? lastFetchedUid;

  @override
  Future<List<Map<String, dynamic>>> getProductsForArtisan(String artisanId) async {
    fetchCallCount++;
    lastFetchedUid = artisanId;
    return [
      {
        'id': 'p-test-1',
        'artisanId': artisanId,
        'name': 'Terracotta Pitcher',
        'price': 450.0,
        'status': 'published',
        'imageUrl': 'assets/images/terracotta_vase.jpg',
      }
    ];
  }
}

void main() {
  testWidgets('HomeScreen didChangeDependencies triggers fetchCloudProducts without build-phase exception', (WidgetTester tester) async {
    final mockAuthService = MockAuthService(
      user: MockUser(uid: 'artisan-123', email: 'artisan@craftmitra.org'),
    );
    final authProvider = AuthProvider(authService: mockAuthService);
    final mockFirestore = MockFirestoreService();
    final appStateProvider = AppStateProvider(firestoreService: mockFirestore);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<AppStateProvider>.value(value: appStateProvider),
          ChangeNotifierProvider(create: (_) => ProductCreationProvider()),
          ChangeNotifierProvider(create: (_) => OrdersProvider(firestoreService: MockFirestoreOrderService(), authService: mockAuthService)),
          ChangeNotifierProvider(create: (_) => SalesProvider()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial pump completed without any "setState() or markNeedsBuild() called during build" exception.
    expect(tester.takeException(), isNull);

    // Let post-frame callback execute and Firestore future complete
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(mockFirestore.fetchCallCount, equals(1));
    expect(mockFirestore.lastFetchedUid, equals('artisan-123'));
    expect(appStateProvider.cloudProducts.length, equals(1));
    expect(appStateProvider.cloudProducts.first.name, equals('Terracotta Pitcher'));
  });

  testWidgets('AppStateProvider _safeNotifyListeners does not throw if called during build', (WidgetTester tester) async {
    final mockFirestore = MockFirestoreService();
    final appStateProvider = AppStateProvider(firestoreService: mockFirestore);

    // A test widget that deliberately triggers fetchCloudProducts directly in its build method
    await tester.pumpWidget(
      ChangeNotifierProvider<AppStateProvider>.value(
        value: appStateProvider,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              final prov = context.watch<AppStateProvider>();
              // If not yet called, trigger fetchCloudProducts directly during build
              if (!prov.isLoadingCloudProducts && prov.cloudProducts.isEmpty) {
                prov.fetchCloudProducts('direct-build-uid');
              }
              return const Text('Test Passed');
            },
          ),
        ),
      ),
    );

    // Must not throw "setState() or markNeedsBuild() called during build"
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
