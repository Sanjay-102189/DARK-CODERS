import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:craftmitra/providers/providers.dart';
import 'package:craftmitra/services/firestore_order_service.dart';
import 'package:craftmitra/services/auth_service.dart';
import 'package:craftmitra/models/models.dart';

class FakeUser extends Fake implements User {
  @override
  final String uid;

  @override
  final String? email;

  FakeUser({required this.uid, this.email});
}

class FakeAuthService extends AuthService {
  User? _currentUser;

  FakeAuthService({User? user}) : _currentUser = user;

  @override
  User? get currentUser => _currentUser;

  @override
  String? get currentUserId => _currentUser?.uid;

  @override
  bool get isAuthenticated => _currentUser != null;

  void setMockUser(User? user) {
    _currentUser = user;
  }
}

class FakeFirestoreOrderService extends FirestoreOrderService {
  final List<Map<String, dynamic>> storedOrders = [];
  bool shouldThrow = false;
  String errorCode = 'permission-denied';
  String errorMessage = 'Permission denied on orders collection.';

  @override
  Future<void> createOrder({
    required String orderId,
    required Map<String, dynamic> data,
  }) async {
    if (shouldThrow) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: errorCode,
        message: errorMessage,
      );
    }
    final copy = Map<String, dynamic>.from(data);
    copy['id'] = orderId;
    copy['orderId'] = orderId;
    copy['createdAt'] = DateTime.now();
    copy['updatedAt'] = DateTime.now();
    storedOrders.add(copy);
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String artisanId,
    required String status,
  }) async {
    if (shouldThrow) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: errorCode,
        message: errorMessage,
      );
    }
    final index = storedOrders.indexWhere((o) => o['id'] == orderId || o['orderId'] == orderId);
    if (index != -1) {
      storedOrders[index]['status'] = status;
      storedOrders[index]['currentStatus'] = status;
      storedOrders[index]['artisanId'] = artisanId;
      storedOrders[index]['updatedAt'] = DateTime.now();
      if (status == 'completed' || status == 'delivered') {
        storedOrders[index]['completedAt'] = DateTime.now();
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrdersForArtisan(String artisanId) async {
    if (shouldThrow) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: errorCode,
        message: errorMessage,
      );
    }
    return storedOrders.where((o) => o['artisanId'] == artisanId).toList();
  }
}

void main() {
  group('Phase 5: FirestoreOrderService & OrdersProvider Tests', () {
    late FakeFirestoreOrderService fakeFirestoreService;
    late FakeAuthService fakeAuthService;
    late OrdersProvider ordersProvider;

    const testProduct = Product(
      id: 'PROD-POT-101',
      name: 'Handcrafted Terracotta Pot',
      price: 850.0,
    );

    setUp(() {
      fakeFirestoreService = FakeFirestoreOrderService();
      fakeAuthService = FakeAuthService(
        user: FakeUser(uid: 'artisan-owner-999', email: 'artisan@craftmitra.in'),
      );
      ordersProvider = OrdersProvider(
        firestoreService: fakeFirestoreService,
        authService: fakeAuthService,
      );
    });

    test('1. Creates order with correct artisanId, productId, and calculated totalAmount', () async {
      final success = await ordersProvider.createTestOrder(
        product: testProduct,
        buyerName: 'FabIndia Sourcing',
        buyerLocation: 'New Delhi',
        buyerId: 'buyer-001',
        quantity: 10,
      );

      expect(success, isTrue);
      expect(ordersProvider.cloudOrders.length, equals(1));
      expect(fakeFirestoreService.storedOrders.length, equals(1));

      final saved = fakeFirestoreService.storedOrders.first;
      expect(saved['artisanId'], equals('artisan-owner-999'), reason: 'Artisan UID must come from auth');
      expect(saved['productId'], equals('PROD-POT-101'));
      expect(saved['quantity'], equals(10));
      expect(saved['unitPrice'], equals(850.0));
      expect(saved['totalAmount'], equals(8500.0), reason: 'quantity * unitPrice = 10 * 850');
      expect(saved['status'], equals('placed'));
      expect(saved['isTestOrder'], isTrue);
    });

    test('2. Unauthenticated order creation is blocked without writing to Firestore', () async {
      fakeAuthService.setMockUser(null);

      final success = await ordersProvider.createTestOrder(
        product: testProduct,
        buyerName: 'Demo Buyer',
        buyerLocation: 'Mumbai',
        quantity: 5,
      );

      expect(success, isFalse);
      expect(ordersProvider.createOrderError, contains('Authentication required'));
      expect(fakeFirestoreService.storedOrders.isEmpty, isTrue);
    });

    test('3. Prevents duplicate order creation when in-progress', () async {
      // Start order creation
      final future1 = ordersProvider.createTestOrder(
        product: testProduct,
        buyerName: 'Buyer A',
        buyerLocation: 'Chennai',
        quantity: 5,
      );

      // Attempt immediate duplicate creation while first is running
      final future2 = ordersProvider.createTestOrder(
        product: testProduct,
        buyerName: 'Buyer B',
        buyerLocation: 'Bengaluru',
        quantity: 5,
      );

      final results = await Future.wait([future1, future2]);
      expect(results.contains(true), isTrue);
      expect(fakeFirestoreService.storedOrders.length, equals(1));
    });

    test('4. Order status update preserves artisan ownership and sets completedAt when delivered', () async {
      await ordersProvider.createTestOrder(
        product: testProduct,
        buyerName: 'Delhi Haat Retailer',
        buyerLocation: 'New Delhi',
        quantity: 8,
      );

      final createdOrder = ordersProvider.cloudOrders.first;
      expect(createdOrder.currentStatus, equals(OrderStatus.placed));

      // Advance through lifecycle
      final okAccepted = await ordersProvider.updateOrderStatus(createdOrder.id, OrderStatus.accepted);
      expect(okAccepted, isTrue);
      expect(fakeFirestoreService.storedOrders.first['status'], equals('accepted'));
      expect(fakeFirestoreService.storedOrders.first['artisanId'], equals('artisan-owner-999'));

      final okDelivered = await ordersProvider.updateOrderStatus(createdOrder.id, OrderStatus.delivered);
      expect(okDelivered, isTrue);

      final updated = fakeFirestoreService.storedOrders.first;
      expect(updated['status'], equals('delivered'));
      expect(updated['completedAt'], isNotNull, reason: 'completedAt must be timestamped');
      expect(updated['artisanId'], equals('artisan-owner-999'), reason: 'Artisan ownership preserved on update');
    });

    test('5. Orders loaded from Firestore filter strictly by artisanId and survive reload', () async {
      // Preload fake Firestore with orders belonging to two different artisans
      fakeFirestoreService.storedOrders.add({
        'id': 'ORD-101',
        'artisanId': 'artisan-owner-999',
        'productId': 'P-1',
        'buyerName': 'My Buyer',
        'productName': 'Terracotta Vase',
        'quantity': 10,
        'unitPrice': 500.0,
        'totalAmount': 5000.0,
        'status': 'delivered',
        'createdAt': DateTime(2026, 9, 1),
        'completedAt': DateTime(2026, 9, 3),
      });

      fakeFirestoreService.storedOrders.add({
        'id': 'ORD-999',
        'artisanId': 'other-artisan-444',
        'productId': 'P-2',
        'buyerName': 'Other Buyer',
        'productName': 'Silk Shawl',
        'quantity': 2,
        'unitPrice': 3000.0,
        'totalAmount': 6000.0,
        'status': 'delivered',
        'createdAt': DateTime(2026, 9, 2),
      });

      // Simulate app restart / login fetch
      await ordersProvider.fetchCloudOrders('artisan-owner-999');

      expect(ordersProvider.orders.length, equals(1));
      expect(ordersProvider.orders.first.id, equals('ORD-101'));
      expect(ordersProvider.orders.first.buyerName, equals('My Buyer'));
      expect(ordersProvider.orders.first.totalValue, equals(5000.0));
      expect(ordersProvider.orders.first.isCompleted, isTrue);
    });

    test('6. Sales calculations strictly derive from completed orders without inventing growth percent', () async {
      // 1. Pending order (should NOT count in finalized sales)
      await ordersProvider.createTestOrder(
        product: testProduct,
        buyerName: 'Pending Buyer',
        buyerLocation: 'Jaipur',
        quantity: 10, // 10 * 850 = 8500 pending
      );

      // 2. Another order that gets completed
      await ordersProvider.createTestOrder(
        product: testProduct,
        buyerName: 'Completed Buyer',
        buyerLocation: 'Kolkata',
        quantity: 20, // 20 * 850 = 17000 completed
      );

      final completedOrder = ordersProvider.cloudOrders.first; // Last inserted is Completed Buyer
      await ordersProvider.updateOrderStatus(completedOrder.id, OrderStatus.completed);

      final sales = ordersProvider.salesData;

      // Finalized sales must strictly include only the completed order (₹17,000), NOT pending (₹8,500)
      expect(sales.totalEarnings, equals(17000.0));
      expect(sales.totalOrders, equals(1));
      expect(sales.totalPieces, equals(20));
      expect(sales.averageOrderValue, equals(17000.0));
      expect(sales.growthPercent, equals(0.0), reason: 'Must not invent growth percentages');
      expect(sales.estimatedProfit, equals(17000.0 * 0.35));
    });

    test('7. Multiple completed orders aggregate total sales, pieces, and average order value correctly', () {
      final orders = [
        const CraftOrder(
          id: 'O-1',
          buyerName: 'Buyer 1',
          productName: 'Item 1',
          quantity: 10,
          pricePerUnit: 500,
          totalValue: 5000,
          currentStatus: OrderStatus.completed,
          statusLabel: 'Completed',
        ),
        const CraftOrder(
          id: 'O-2',
          buyerName: 'Buyer 2',
          productName: 'Item 2',
          quantity: 15,
          pricePerUnit: 1000,
          totalValue: 15000,
          currentStatus: OrderStatus.delivered,
          statusLabel: 'Delivered',
        ),
        const CraftOrder(
          id: 'O-3',
          buyerName: 'Buyer 3',
          productName: 'Item 3',
          quantity: 50,
          pricePerUnit: 200,
          totalValue: 10000,
          currentStatus: OrderStatus.inProduction, // Not completed
          statusLabel: 'In Production',
        ),
      ];

      final sales = SalesData.fromOrders(orders);

      // Completed total: 5000 + 15000 = 20000
      expect(sales.totalEarnings, equals(20000.0));
      expect(sales.totalOrders, equals(2));
      expect(sales.totalPieces, equals(25)); // 10 + 15
      expect(sales.averageOrderValue, equals(10000.0)); // 20000 / 2
      expect(sales.growthPercent, equals(0.0));
    });

    test('8. Firestore error is caught and surfaces clear error message', () async {
      fakeFirestoreService.shouldThrow = true;
      fakeFirestoreService.errorCode = 'unavailable';
      fakeFirestoreService.errorMessage = 'Network unavailable.';

      final success = await ordersProvider.createTestOrder(
        product: testProduct,
        buyerName: 'Buyer',
        buyerLocation: 'Location',
        quantity: 5,
      );

      expect(success, isFalse);
      expect(ordersProvider.createOrderError, contains('unavailable'));
      expect(ordersProvider.isCreatingOrder, isFalse);
    });
  });
}
