enum OrderStatus { placed, accepted, inProduction, pickup, delivered, completed, cancelled }

String orderStatusToString(OrderStatus status) {
  switch (status) {
    case OrderStatus.placed:
      return 'placed';
    case OrderStatus.accepted:
      return 'accepted';
    case OrderStatus.inProduction:
      return 'inProduction';
    case OrderStatus.pickup:
      return 'pickup';
    case OrderStatus.delivered:
      return 'delivered';
    case OrderStatus.completed:
      return 'completed';
    case OrderStatus.cancelled:
      return 'cancelled';
  }
}

OrderStatus orderStatusFromString(String? val) {
  if (val == null) return OrderStatus.placed;
  switch (val.toLowerCase()) {
    case 'accepted':
    case 'confirmed':
      return OrderStatus.accepted;
    case 'inproduction':
    case 'processing':
      return OrderStatus.inProduction;
    case 'pickup':
    case 'shipped':
      return OrderStatus.pickup;
    case 'delivered':
      return OrderStatus.delivered;
    case 'completed':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    case 'placed':
    case 'pending':
    default:
      return OrderStatus.placed;
  }
}

String orderStatusToLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.placed:
      return 'Placed';
    case OrderStatus.accepted:
      return 'Accepted';
    case OrderStatus.inProduction:
      return 'In Production';
    case OrderStatus.pickup:
      return 'Ready for Pickup';
    case OrderStatus.delivered:
      return 'Delivered';
    case OrderStatus.completed:
      return 'Completed';
    case OrderStatus.cancelled:
      return 'Cancelled';
  }
}

class OrderTimelineStep {
  final String title;
  final String subtitle;
  final String date;
  final OrderStatus status;

  const OrderTimelineStep({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.status,
  });
}

class CraftOrder {
  final String id;
  final String productId;
  final String artisanId;
  final String buyerId;
  final String buyerName;
  final String buyerLocation;
  final String productName;
  final int quantity;
  final double pricePerUnit;
  final double totalValue;
  final OrderStatus currentStatus;
  final String statusLabel;
  final String productImageUrl;
  final List<OrderTimelineStep> timeline;
  final int readyCount;
  final int totalCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final bool isTestOrder;

  const CraftOrder({
    required this.id,
    this.productId = '',
    this.artisanId = '',
    this.buyerId = '',
    required this.buyerName,
    this.buyerLocation = '',
    required this.productName,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalValue,
    required this.currentStatus,
    required this.statusLabel,
    this.productImageUrl = '',
    this.timeline = const [],
    this.readyCount = 0,
    this.totalCount = 0,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.isTestOrder = false,
  });

  bool get isCompleted =>
      currentStatus == OrderStatus.completed || currentStatus == OrderStatus.delivered;

  factory CraftOrder.fromFirestore(Map<String, dynamic> data, [String? docId]) {
    final rawStatus = data['status'] as String? ?? data['currentStatus'] as String?;
    final status = orderStatusFromString(rawStatus);

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      try {
        return (val as dynamic).toDate();
      } catch (_) {
        return DateTime.tryParse(val.toString());
      }
    }

    final createdAt = parseDate(data['createdAt']);
    final updatedAt = parseDate(data['updatedAt']);
    final completedAt = parseDate(data['completedAt']);

    final qty = (data['quantity'] as num?)?.toInt() ?? 1;
    final unitPrice = (data['unitPrice'] as num?)?.toDouble() ??
        (data['pricePerUnit'] as num?)?.toDouble() ??
        0.0;
    final total = (data['totalAmount'] as num?)?.toDouble() ??
        (data['totalValue'] as num?)?.toDouble() ??
        (qty * unitPrice);

    final statusLabel = data['statusLabel'] as String? ?? orderStatusToLabel(status);

    // Build timeline if not stored or empty
    final timeline = _buildDefaultTimeline(status, createdAt);

    return CraftOrder(
      id: docId ?? data['orderId'] as String? ?? data['id'] as String? ?? '',
      productId: data['productId'] as String? ?? '',
      artisanId: data['artisanId'] as String? ?? '',
      buyerId: data['buyerId'] as String? ?? '',
      buyerName: data['buyerName'] as String? ?? 'Verified Buyer',
      buyerLocation: data['buyerLocation'] as String? ?? data['location'] as String? ?? 'India',
      productName: data['productName'] as String? ?? 'Handcrafted Product',
      quantity: qty,
      pricePerUnit: unitPrice,
      totalValue: total,
      currentStatus: status,
      statusLabel: statusLabel,
      productImageUrl: data['productImageUrl'] as String? ?? data['imageUrl'] as String? ?? '',
      timeline: timeline,
      readyCount: (data['readyCount'] as num?)?.toInt() ?? (status == OrderStatus.completed || status == OrderStatus.delivered ? qty : 0),
      totalCount: (data['totalCount'] as num?)?.toInt() ?? qty,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
      isTestOrder: data['isTestOrder'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'orderId': id,
      'productId': productId,
      'artisanId': artisanId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerLocation': buyerLocation,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': pricePerUnit,
      'pricePerUnit': pricePerUnit,
      'totalAmount': totalValue,
      'totalValue': totalValue,
      'status': orderStatusToString(currentStatus),
      'currentStatus': orderStatusToString(currentStatus),
      'statusLabel': statusLabel,
      'productImageUrl': productImageUrl,
      'imageUrl': productImageUrl,
      'readyCount': readyCount,
      'totalCount': totalCount,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (completedAt != null) 'completedAt': completedAt,
      'isTestOrder': isTestOrder,
    };
  }

  static List<OrderTimelineStep> _buildDefaultTimeline(OrderStatus status, DateTime? date) {
    final dateStr = date != null ? '${date.day}/${date.month}/${date.year}' : 'Recent';
    return [
      OrderTimelineStep(
        title: 'Order Placed & Escrow Locked',
        subtitle: 'Digital escrow hold confirmed for artisan protection',
        date: dateStr,
        status: OrderStatus.placed,
      ),
      OrderTimelineStep(
        title: 'Artisan Accepted',
        subtitle: 'Raw materials prepared and production batch assigned',
        date: dateStr,
        status: OrderStatus.accepted,
      ),
      OrderTimelineStep(
        title: 'In Craft Production',
        subtitle: 'Handcrafting & kiln firing underway',
        date: dateStr,
        status: OrderStatus.inProduction,
      ),
      OrderTimelineStep(
        title: 'Packaging & Pickup Ready',
        subtitle: 'Straw carton protective packaging complete',
        date: dateStr,
        status: OrderStatus.pickup,
      ),
      OrderTimelineStep(
        title: 'Delivered & Payment Settled',
        subtitle: 'Buyer delivery verified, escrow payment released',
        date: dateStr,
        status: OrderStatus.delivered,
      ),
    ];
  }

  CraftOrder copyWith({
    String? id,
    String? productId,
    String? artisanId,
    String? buyerId,
    String? buyerName,
    String? buyerLocation,
    String? productName,
    int? quantity,
    double? pricePerUnit,
    double? totalValue,
    OrderStatus? currentStatus,
    String? statusLabel,
    String? productImageUrl,
    List<OrderTimelineStep>? timeline,
    int? readyCount,
    int? totalCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool? isTestOrder,
  }) {
    return CraftOrder(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      artisanId: artisanId ?? this.artisanId,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerLocation: buyerLocation ?? this.buyerLocation,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalValue: totalValue ?? this.totalValue,
      currentStatus: currentStatus ?? this.currentStatus,
      statusLabel: statusLabel ?? this.statusLabel,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      timeline: timeline ?? this.timeline,
      readyCount: readyCount ?? this.readyCount,
      totalCount: totalCount ?? this.totalCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      isTestOrder: isTestOrder ?? this.isTestOrder,
    );
  }
}
