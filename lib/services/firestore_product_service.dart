import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service for persistent storage of artisan product catalogs in Cloud Firestore.
/// Uses collection `products/{productId}` with structured fields aligned with the Product model.
class FirestoreProductService {
  final FirebaseFirestore? firestoreInstance;

  FirestoreProductService({this.firestoreInstance});

  FirebaseFirestore get firestore => firestoreInstance ?? FirebaseFirestore.instance;

  /// Saves or merges product details in Firestore.
  Future<void> saveProduct({
    required String productId,
    required Map<String, dynamic> data,
  }) async {
    final docPath = 'products/$productId';
    try {
      debugPrint('[FirestoreProductService] [START] Saving document to $docPath');
      debugPrint('[FirestoreProductService] Payload summary: artisanId=${data['artisanId']}, isDemo=${data['isDemo']}, status=${data['status']}, imageUrl=${data['imageUrl']}');
      await firestore
          .collection('products')
          .doc(productId)
          .set(data, SetOptions(merge: true));
      debugPrint('[FirestoreProductService] [SUCCESS] Document $docPath written successfully.');
    } on FirebaseException catch (fe) {
      debugPrint('[FirestoreProductService] [FAIL] FirebaseException writing to $docPath: code=${fe.code}, message=${fe.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreProductService] [FAIL] Error saving product to $docPath: $e');
      rethrow;
    }
  }

  /// Updates status and pricing when artisan explicitly broadcasts or publishes.
  Future<void> updateProductStatus({
    required String productId,
    required String status,
    double? price,
  }) async {
    final docPath = 'products/$productId';
    try {
      debugPrint('[FirestoreProductService] [START] Updating product $docPath status to $status');
      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (price != null) {
        updateData['price'] = price;
      }
      // Use set with merge: true to avoid crashes if document was pending creation
      await firestore
          .collection('products')
          .doc(productId)
          .set(updateData, SetOptions(merge: true));
      debugPrint('[FirestoreProductService] [SUCCESS] Updated product $docPath status to $status');
    } on FirebaseException catch (fe) {
      debugPrint('[FirestoreProductService] [FAIL] FirebaseException updating $docPath: code=${fe.code}, message=${fe.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreProductService] [FAIL] Error updating product $docPath: $e');
      rethrow;
    }
  }

  /// Safely updates specific fields of an existing product in Firestore.
  /// Uses merge semantics and automatically sets updatedAt server timestamp.
  Future<void> updateProductFields({
    required String productId,
    required Map<String, dynamic> data,
  }) async {
    final docPath = 'products/$productId';
    try {
      debugPrint('[FirestoreProductService] [START] Updating fields on $docPath: ${data.keys.toList()}');
      final updateData = Map<String, dynamic>.from(data);
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await firestore
          .collection('products')
          .doc(productId)
          .set(updateData, SetOptions(merge: true));
      debugPrint('[FirestoreProductService] [SUCCESS] Updated fields on $docPath successfully');
    } on FirebaseException catch (fe) {
      debugPrint('[FirestoreProductService] [FAIL] FirebaseException updating fields on $docPath: code=${fe.code}, message=${fe.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreProductService] [FAIL] Error updating fields on $docPath: $e');
      rethrow;
    }
  }

  /// Retrieves product data from Firestore.
  Future<Map<String, dynamic>?> getProduct(String productId) async {
    final docPath = 'products/$productId';
    try {
      debugPrint('[FirestoreProductService] [START] Getting document $docPath');
      final doc = await firestore.collection('products').doc(productId).get();
      debugPrint('[FirestoreProductService] [SUCCESS] Got document $docPath, exists: ${doc.exists}');
      return doc.data();
    } on FirebaseException catch (fe) {
      debugPrint('[FirestoreProductService] [FAIL] FirebaseException getting $docPath: code=${fe.code}, message=${fe.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreProductService] [FAIL] Error fetching product $docPath: $e');
      rethrow;
    }
  }

  /// Queries products belonging specifically to an authenticated artisan.
  Future<List<Map<String, dynamic>>> getProductsForArtisan(String artisanId) async {
    try {
      debugPrint('[FirestoreProductService] [START] Querying products where artisanId == $artisanId');
      final querySnapshot = await firestore
          .collection('products')
          .where('artisanId', isEqualTo: artisanId)
          .get();

      final results = querySnapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] ??= doc.id;
        return data;
      }).toList();
      // Safely sort in memory by createdAt descending without requiring complex index creation
      results.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime);
        }
        return 0;
      });
      debugPrint('[FirestoreProductService] [SUCCESS] Query returned ${results.length} documents for artisanId == $artisanId');
      return results;
    } on FirebaseException catch (fe) {
      debugPrint('[FirestoreProductService] [FAIL] FirebaseException querying products for artisan $artisanId: code=${fe.code}, message=${fe.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreProductService] [FAIL] Error fetching products for artisan $artisanId: $e');
      rethrow;
    }
  }
}
