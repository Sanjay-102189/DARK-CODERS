import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:craftmitra/providers/providers.dart';
import 'package:craftmitra/services/firestore_product_service.dart';
import 'package:craftmitra/services/auth_service.dart';
import 'package:craftmitra/models/models.dart';
import 'package:craftmitra/core/constants/demo_data.dart';

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
  String? get currentUserEmail => _currentUser?.email;

  @override
  bool get isAuthenticated => _currentUser != null;

  void setMockUser(User? user) {
    _currentUser = user;
  }
}

class FakeFirestoreProductService extends FirestoreProductService {
  Map<String, dynamic>? lastSavedData;
  String? lastSavedProductId;
  String? lastUpdatedStatus;
  double? lastUpdatedPrice;
  bool shouldThrow = false;
  String errorCode = 'permission-denied';
  String errorMessage = 'Cloud Firestore security rules denied write access.';

  final List<Map<String, dynamic>> _storedProducts = [];

  void addStoredProduct(Map<String, dynamic> product) {
    _storedProducts.add(product);
  }

  @override
  Future<void> saveProduct({
    required String productId,
    required Map<String, dynamic> data,
  }) async {
    if (shouldThrow) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: errorCode,
        message: errorMessage,
      );
    }
    lastSavedProductId = productId;
    lastSavedData = Map<String, dynamic>.from(data);
    _storedProducts.add(lastSavedData!);
  }

  @override
  Future<void> updateProductStatus({
    required String productId,
    required String status,
    double? price,
  }) async {
    if (shouldThrow) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: errorCode,
        message: errorMessage,
      );
    }
    lastUpdatedStatus = status;
    lastUpdatedPrice = price;
    if (lastSavedData != null) {
      lastSavedData!['status'] = status;
      if (price != null) lastSavedData!['price'] = price;
    }
  }

  @override
  Future<void> updateProductFields({
    required String productId,
    required Map<String, dynamic> data,
  }) async {
    if (shouldThrow) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: errorCode,
        message: errorMessage,
      );
    }
    lastSavedProductId = productId;
    lastSavedData ??= <String, dynamic>{};
    lastSavedData!.addAll(data);
    if (data.containsKey('status')) {
      lastUpdatedStatus = data['status'] as String?;
    }
    if (data.containsKey('price')) {
      lastUpdatedPrice = (data['price'] as num?)?.toDouble();
    }
  }

  @override
  Future<Map<String, dynamic>?> getProduct(String productId) async {
    if (shouldThrow) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: errorCode,
        message: errorMessage,
      );
    }
    if (lastSavedProductId == productId) {
      return lastSavedData;
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getProductsForArtisan(String artisanId) async {
    if (shouldThrow) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: errorCode,
        message: errorMessage,
      );
    }
    final filtered = _storedProducts.where((p) => p['artisanId'] == artisanId).toList();
    filtered.sort((a, b) {
      final aTime = a['createdAt'];
      final bTime = b['createdAt'];
      if (aTime is DateTime && bTime is DateTime) {
        return bTime.compareTo(aTime);
      }
      return 0;
    });
    return filtered;
  }
}

void main() {
  group('FirestoreProductService & ProductCreationProvider Auth + Firestore Tests', () {
    late FakeFirestoreProductService fakeFirestoreService;
    late FakeAuthService fakeAuthService;
    late ProductCreationProvider provider;

    setUp(() {
      fakeFirestoreService = FakeFirestoreProductService();
      fakeAuthService = FakeAuthService(
        user: FakeUser(uid: 'artisan-owner-999', email: 'artisan@craftmitra.in'),
      );
      provider = ProductCreationProvider(
        firestoreService: fakeFirestoreService,
        authService: fakeAuthService,
      );
    });

    test('1. Initial Firestore save state is empty and idle', () {
      expect(provider.isSavingToFirestore, isFalse);
      expect(provider.isSavedToFirestore, isFalse);
      expect(provider.firestoreSaveError, isNull);
      expect(provider.savedFirestoreProductId, isNull);
    });

    test('2. Saves authenticated real product with artisanId and structured schema', () async {
      provider.updateCatalog(
        const GeneratedCatalog(
          title: 'Handcrafted Blue Pottery Plate',
          titleHindi: 'हस्तनिर्मित ब्लू पॉटरी प्लेट',
          category: 'Pottery',
          craftTechnique: 'Quartz Clay Fired Pottery',
          material: 'Quartz Clay',
          origin: 'Jaipur, Rajasthan',
          description: 'Traditional Jaipur blue pottery artisan plate.',
          keywords: ['blue pottery', 'jaipur', 'ceramic'],
        ),
      );

      final success = await provider.saveProductToFirestore();

      expect(success, isTrue);
      expect(provider.isSavedToFirestore, isTrue);
      expect(provider.isSavingToFirestore, isFalse);
      expect(provider.firestoreSaveError, isNull);
      expect(provider.savedFirestoreProductId, isNotEmpty);

      // Verify payload received by service has artisanId
      final savedData = fakeFirestoreService.lastSavedData;
      expect(savedData, isNotNull);
      expect(savedData!['artisanId'], equals('artisan-owner-999'));
      expect(savedData['artisanEmail'], equals('artisan@craftmitra.in'));
      expect(savedData['name'], equals('Handcrafted Blue Pottery Plate'));
      expect(savedData['nameHindi'], equals('हस्तनिर्मित ब्लू पॉटरी प्लेट'));
      expect(savedData['category'], equals('Pottery'));
      expect(savedData['status'], equals('catalogReady'));
      expect(savedData['isDemo'], isFalse);
      expect(savedData['createdAt'], isA<FieldValue>());
    });

    test('3. Unauthenticated real product save is rejected before Firestore write', () async {
      // Simulate unauthenticated artisan
      fakeAuthService.setMockUser(null);

      provider.updateCatalog(
        const GeneratedCatalog(
          title: 'Carved Wooden Box',
          titleHindi: 'नक्काशीदार लकड़ी का डिब्बा',
          category: 'Woodcraft',
          craftTechnique: 'Hand carving',
          material: 'Sheesham Wood',
          origin: 'Saharanpur',
          description: 'Carved box',
          keywords: ['wood', 'box'],
        ),
      );

      final success = await provider.saveProductToFirestore();

      // Must be rejected
      expect(success, isFalse);
      expect(provider.isSavedToFirestore, isFalse);
      expect(provider.isSavingToFirestore, isFalse);
      expect(provider.firestoreSaveError, contains('Authentication required'));
      // Verify no write occurred in firestore
      expect(fakeFirestoreService.lastSavedProductId, isNull);
    });

    test('4. Demo mode allows save with isDemo: true without requiring auth', () async {
      fakeAuthService.setMockUser(null); // No auth
      provider.selectDemoProduct(); // Switch to demo mode

      final success = await provider.saveProductToFirestore();

      expect(success, isTrue);
      expect(provider.isSavedToFirestore, isTrue);
      final savedData = fakeFirestoreService.lastSavedData;
      expect(savedData, isNotNull);
      expect(savedData!['isDemo'], isTrue);
      expect(savedData['artisanId'], equals('artisan-demo'));
    });

    test('4b. Authenticated artisan saving demo product binds artisanId to currentUser.uid for rule compliance', () async {
      fakeAuthService.setMockUser(FakeUser(uid: 'artisan-real-123', email: 'artisan@real.in'));
      provider.selectDemoProduct();

      final success = await provider.saveProductToFirestore();

      expect(success, isTrue);
      expect(provider.isSavedToFirestore, isTrue);
      final savedData = fakeFirestoreService.lastSavedData;
      expect(savedData, isNotNull);
      expect(savedData!['isDemo'], isTrue);
      expect(savedData['artisanId'], equals('artisan-real-123'));
    });

    test('5. Lifecycle: Only explicit publish updates status from catalogReady to published', () async {
      provider.updateCatalog(
        const GeneratedCatalog(
          title: 'Terracotta Vase',
          titleHindi: 'टेराकोटा फूलदान',
          category: 'Terracotta',
          craftTechnique: 'Wheel thrown',
          material: 'Clay',
          origin: 'Alwar',
          description: 'Vase',
          keywords: ['vase'],
        ),
      );

      // 1. Initial save at catalogReady
      await provider.saveProductToFirestore();
      expect(fakeFirestoreService.lastSavedData!['status'], equals('catalogReady'));

      // 2. Explicit publish call (triggered by Publish & Broadcast button)
      final publishSuccess = await provider.publishProductToFirestore();
      expect(publishSuccess, isTrue);
      expect(provider.published, isTrue);
      expect(fakeFirestoreService.lastUpdatedStatus, equals('published'));
      expect(fakeFirestoreService.lastSavedData!['status'], equals('published'));
    });

    test('6. Security rules error handling gracefully catches permission denied without crash', () async {
      fakeFirestoreService.shouldThrow = true;
      fakeFirestoreService.errorCode = 'permission-denied';
      fakeFirestoreService.errorMessage = 'Missing or insufficient permissions.';

      final success = await provider.saveProductToFirestore();

      expect(success, isFalse);
      expect(provider.isSavedToFirestore, isFalse);
      expect(provider.isSavingToFirestore, isFalse);
      expect(provider.firestoreSaveError, contains('permission-denied'));
    });

    test('7. Reset properly clears all Firestore save states', () async {
      await provider.saveProductToFirestore();
      expect(provider.isSavedToFirestore, isTrue);

      provider.reset();

      expect(provider.isSavingToFirestore, isFalse);
      expect(provider.isSavedToFirestore, isFalse);
      expect(provider.firestoreSaveError, isNull);
      expect(provider.savedFirestoreProductId, isNull);
    });

    test('8. getProductsForArtisan queries only products owned by that artisan', () async {
      fakeFirestoreService.addStoredProduct({
        'id': 'PROD-1',
        'artisanId': 'artisan-owner-999',
        'name': 'My Pot',
        'price': 850.0,
        'status': 'published',
        'createdAt': DateTime(2026, 9, 1),
      });
      fakeFirestoreService.addStoredProduct({
        'id': 'PROD-2',
        'artisanId': 'another-artisan-555',
        'name': 'Other Artisan Carpet',
        'price': 4500.0,
        'status': 'published',
        'createdAt': DateTime(2026, 9, 2),
      });

      final myProducts = await fakeFirestoreService.getProductsForArtisan('artisan-owner-999');

      expect(myProducts.length, equals(1));
      expect(myProducts.first['id'], equals('PROD-1'));
      expect(myProducts.first['name'], equals('My Pot'));
    });

    test('9. Phase 4: Pricing persistence updates existing product document without changing productId', () async {
      // 1. Initial product save
      provider.updateCatalog(
        const GeneratedCatalog(
          title: 'Handcrafted Terracotta Vase',
          titleHindi: 'टेराकोटा फूलदान',
          category: 'Terracotta',
          craftTechnique: 'Wheel thrown',
          material: 'Clay',
          origin: 'Khurja',
          description: 'Finely crafted terracotta vase',
        ),
      );
      final saveCatalogOk = await provider.saveProductToFirestore(status: 'catalogReady');
      expect(saveCatalogOk, isTrue);

      final initialProductId = provider.productId;
      expect(initialProductId, isNotEmpty);
      expect(fakeFirestoreService.lastSavedProductId, equals(initialProductId));
      expect(fakeFirestoreService.lastSavedData!['status'], equals('catalogReady'));

      // 2. Adjust margin and save pricing
      provider.setMargin(35);
      final savePricingOk = await provider.savePricingToFirestore();

      expect(savePricingOk, isTrue);
      expect(provider.isPricingSaved, isTrue);
      expect(provider.productId, equals(initialProductId), reason: 'Product ID must not change');
      expect(fakeFirestoreService.lastSavedProductId, equals(initialProductId));

      // Verify pricing breakdown stored
      final updatedData = fakeFirestoreService.lastSavedData!;
      expect(updatedData['artisanId'], equals('artisan-owner-999'));
      expect(updatedData['status'], equals('priceReady'));
      expect(updatedData['completionPercent'], equals(0.8));
      expect(updatedData['marginPercent'], equals(35));
      expect(updatedData['baseCost'], isNotNull);
      expect(updatedData['profit'], isNotNull);
      expect(updatedData['pricing'], isA<Map>());
      expect(updatedData['pricing']['materialCost'], isNotNull);
      expect(updatedData['pricing']['laborCost'], isNotNull);
      expect(updatedData['pricing']['packagingCost'], isNotNull);
      expect(updatedData['pricing']['desiredMargin'], equals(35));
      expect(updatedData['pricing']['marketBenchmark'], isNotNull);
      expect(updatedData['pricing']['reasoning'], isNotNull);
    });

    test('10. Phase 4: Buyer matches persistence updates same product document with summary', () async {
      provider.updateCatalog(DemoData.demoCatalog);
      await provider.saveProductToFirestore(status: 'priceReady');
      final currentProductId = provider.productId;

      // Save buyer matches
      final saveMatchesOk = await provider.saveBuyerMatchesToFirestore();

      expect(saveMatchesOk, isTrue);
      expect(provider.isBuyerMatchesSaved, isTrue);
      expect(provider.productId, equals(currentProductId), reason: 'Product ID must be preserved');
      expect(fakeFirestoreService.lastSavedProductId, equals(currentProductId));

      final updatedData = fakeFirestoreService.lastSavedData!;
      expect(updatedData['artisanId'], equals('artisan-owner-999'));
      expect(updatedData['status'], equals('buyerMatched'));
      expect(updatedData['completionPercent'], equals(0.9));
      expect(updatedData['topBuyerMatches'], isA<List>());
      final matchesList = updatedData['topBuyerMatches'] as List;
      expect(matchesList, isNotEmpty);
      expect(matchesList.first['buyerName'], isNotNull);
      expect(matchesList.first['matchPercent'], isNotNull);
    });

    test('11. Phase 4: Publish updates existing product to published with 100% completion & publishedAt', () async {
      provider.updateCatalog(DemoData.demoCatalog);
      await provider.saveProductToFirestore(status: 'buyerMatched');
      final currentProductId = provider.productId;

      // Publish product
      final publishOk = await provider.publishProductToFirestore();

      expect(publishOk, isTrue);
      expect(provider.published, isTrue);
      expect(provider.isPublishedInFirestore, isTrue);
      expect(provider.productId, equals(currentProductId), reason: 'Product ID must be preserved on publish');
      expect(fakeFirestoreService.lastSavedProductId, equals(currentProductId));

      final publishedData = fakeFirestoreService.lastSavedData!;
      expect(publishedData['artisanId'], equals('artisan-owner-999'));
      expect(publishedData['status'], equals('published'));
      expect(publishedData['completionPercent'], equals(1.0));
      expect(publishedData['publishedAt'], isA<FieldValue>());
    });

    test('12. Phase 4: Reload persistence test — Product.fromFirestore retains pricing, buyer matches, and status', () async {
      provider.updateCatalog(
        const GeneratedCatalog(
          title: 'Handcrafted Terracotta Pot',
          titleHindi: 'टेराकोटा फूलदान',
          category: 'Terracotta & Clay',
          craftTechnique: 'Wheel thrown',
          material: 'Natural Clay',
          origin: 'Khurja',
          description: 'A beautifully fired terracotta piece.',
        ),
      );
      provider.setTranscript('Made using clay from riverbed and fired in traditional kiln');
      provider.setMargin(30);

      // Step through lifecycle
      await provider.saveProductToFirestore(status: 'catalogReady');
      final prodId = provider.productId;
      await provider.savePricingToFirestore();
      await provider.saveBuyerMatchesToFirestore();
      await provider.publishProductToFirestore();

      // Retrieve persisted Firestore data representation
      final rawFirestoreDoc = Map<String, dynamic>.from(fakeFirestoreService.lastSavedData!);
      rawFirestoreDoc['id'] = prodId;
      rawFirestoreDoc['publishedAt'] = DateTime(2026, 9, 8, 12, 0);

      // Reconstitute Product as AppStateProvider does on reload
      final reloaded = Product.fromFirestore(rawFirestoreDoc, prodId);

      expect(reloaded.id, equals(prodId));
      expect(reloaded.name, equals('Handcrafted Terracotta Pot'));
      expect(reloaded.description, equals('A beautifully fired terracotta piece.'));
      expect(reloaded.voiceTranscript, equals('Made using clay from riverbed and fired in traditional kiln'));
      expect(reloaded.status, equals(ProductStatus.published));
      expect(reloaded.completionPercent, equals(1.0));
      expect(reloaded.baseCost, isNotNull);
      expect(reloaded.baseCost! > 0, isTrue);
      expect(reloaded.profit, isNotNull);
      expect(reloaded.marginPercent, equals(30));
      expect(reloaded.topBuyerMatches, isNotNull);
      expect(reloaded.topBuyerMatches!.isNotEmpty, isTrue);
      expect(reloaded.topBuyerMatches!.first['buyerName'], isNotNull);
      expect(reloaded.publishedAt, isNotNull);
    });

    test('13. Phase 4: Firestore failure does not claim success and surfaces error', () async {
      await provider.saveProductToFirestore(status: 'catalogReady');
      expect(provider.isSavedToFirestore, isTrue);

      // Simulate network / permission error on pricing update
      fakeFirestoreService.shouldThrow = true;
      fakeFirestoreService.errorCode = 'unavailable';
      fakeFirestoreService.errorMessage = 'The service is currently unavailable.';

      final pricingOk = await provider.savePricingToFirestore();
      expect(pricingOk, isFalse);
      expect(provider.isPricingSaved, isFalse);
      expect(provider.firestoreSaveError, contains('unavailable'));

      // Simulate failure on buyer matching update
      final buyerMatchesOk = await provider.saveBuyerMatchesToFirestore();
      expect(buyerMatchesOk, isFalse);
      expect(provider.isBuyerMatchesSaved, isFalse);
      expect(provider.firestoreSaveError, contains('unavailable'));

      // Simulate failure on publish
      final publishOk = await provider.publishProductToFirestore();
      expect(publishOk, isFalse);
      expect(provider.isPublishedInFirestore, isFalse);
      expect(provider.firestoreSaveError, contains('unavailable'));
    });
  });
}
