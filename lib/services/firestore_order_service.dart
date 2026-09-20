import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service for persistent storage and management of artisan orders in Cloud Firestore.
/// Uses collection `orders/{orderId}` secured by artisan ownership rules.
class FirestoreOrderService {
  final FirebaseFirestore? firestoreInstance;

  FirestoreOrderService({this.firestoreInstance});

  FirebaseFirestore get firestore => firestoreInstance ?? FirebaseFirestore.instance;

  /// Creates a new order in Cloud Firestore.
  /// Automatically sets createdAt and updatedAt server timestamps.
  Future<void> createOrder({
    required String orderId,
    required Map<String, dynamic> data,
  }) async {
    final docPath = 'orders/$orderId';
    try {
      debugPrint('[FirestoreOrderService] [START] Creating order at $docPath');
      debugPrint('  - artisanId: ${data['artisanId']}, productId: ${data['productId']}');
      debugPrint('  - buyerName: ${data['buyerName']}, quantity: ${data['quantity']}, totalAmount: ${data['totalAmount']}');

      final orderData = Map<String, dynamic>.from(data);
      orderData['id'] = orderId;
      orderData['orderId'] = orderId;
      orderData['createdAt'] = FieldValue.serverTimestamp();
      orderData['updatedAt'] = FieldValue.serverTimestamp();

      await firestore
          .collection('orders')
          .doc(orderId)
          .set(orderData, SetOptions(merge: true));

      debugPrint('[FirestoreOrderService] [SUCCESS] Order $docPath created successfully.');
    } on FirebaseException catch (fe) {
      debugPrint('[FirestoreOrderService] [FAIL] FirebaseException creating $docPath: code=${fe.code}, message=${fe.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreOrderService] [FAIL] Error creating order $docPath: $e');
      rethrow;
    }
  }

  /// Updates order status while strictly preserving artisan ownership.
  /// Sets completedAt when status reaches completed or delivered.
  Future<void> updateOrderStatus({
    required String orderId,
    required String artisanId,
    required String status,
  }) async {
    final docPath = 'orders/$orderId';
    try {
      debugPrint('[FirestoreOrderService] [START] Updating order $docPath to status=$status');
      final updateData = <String, dynamic>{
        'artisanId': artisanId, // Crucial for Firestore security rule compliance
        'status': status,
        'currentStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status.toLowerCase() == 'completed' || status.toLowerCase() == 'delivered') {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      }

      await firestore
          .collection('orders')
          .doc(orderId)
          .set(updateData, SetOptions(merge: true));

      debugPrint('[FirestoreOrderService] [SUCCESS] Updated order $docPath status to $status');
    } on FirebaseException catch (fe) {
      debugPrint('[FirestoreOrderService] [FAIL] FirebaseException updating order $docPath: code=${fe.code}, message=${fe.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreOrderService] [FAIL] Error updating order $docPath: $e');
      rethrow;
    }
  }

  /// Retrieves all orders for the authenticated artisan.
  Future<List<Map<String, dynamic>>> getOrdersForArtisan(String artisanId) async {
    try {
      debugPrint('[FirestoreOrderService] [START] Querying orders for artisanId=$artisanId');
      final snapshot = await firestore
          .collection('orders')
          .where('artisanId', isEqualTo: artisanId)
          .get();

      debugPrint('[FirestoreOrderService] [SUCCESS] Retrieved ${snapshot.docs.length} orders for artisanId=$artisanId');

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort by createdAt descending in memory
      list.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime);
        } else if (aTime is DateTime && bTime is DateTime) {
          return bTime.compareTo(aTime);
        }
        return 0;
      });

      return list;
    } on FirebaseException catch (fe) {
      debugPrint('[FirestoreOrderService] [FAIL] FirebaseException fetching orders: code=${fe.code}, message=${fe.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreOrderService] [FAIL] Error fetching orders for artisan: $e');
      rethrow;
    }
  }

  /// Retrieves a specific order by ID.
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    final docPath = 'orders/$orderId';
    try {
      debugPrint('[FirestoreOrderService] [START] Getting order $docPath');
      final doc = await firestore.collection('orders').doc(orderId).get();
      debugPrint('[FirestoreOrderService] [SUCCESS] Got order $docPath, exists: ${doc.exists}');
      return doc.data();
    } on FirebaseException catch (fe) {
      debugPrint('[FirestoreOrderService] [FAIL] FirebaseException getting order $docPath: code=${fe.code}, message=${fe.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreOrderService] [FAIL] Error getting order $docPath: $e');
      rethrow;
    }
  }
}
