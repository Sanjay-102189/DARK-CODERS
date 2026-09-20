enum ProductStatus { draft, catalogReady, priceReady, buyerMatched, published, outOfStock }

class Product {
  final String id;
  final String artisanId;
  final String name;
  final String nameHindi;
  final String description;
  final String category;
  final String craftTechnique;
  final String material;
  final String origin;
  final double price;
  final int views;
  final int orders;
  final ProductStatus status;
  final String imageUrl;
  final List<String> keywords;
  final DateTime? createdAt;
  final DateTime? publishedAt;
  final double completionPercent;
  final String? voiceTranscript;
  final double? baseCost;
  final double? profit;
  final int? marginPercent;
  final List<Map<String, dynamic>>? topBuyerMatches;
  final int? buyerMatchCount;

  const Product({
    required this.id,
    this.artisanId = '',
    required this.name,
    this.nameHindi = '',
    this.description = '',
    this.category = '',
    this.craftTechnique = '',
    this.material = '',
    this.origin = '',
    this.price = 0,
    this.views = 0,
    this.orders = 0,
    this.status = ProductStatus.draft,
    this.imageUrl = '',
    this.keywords = const [],
    this.createdAt,
    this.publishedAt,
    this.completionPercent = 0,
    this.voiceTranscript,
    this.baseCost,
    this.profit,
    this.marginPercent,
    this.topBuyerMatches,
    this.buyerMatchCount,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, [String? docId]) {
    final statusStr = data['status'] as String? ?? 'draft';
    ProductStatus status = ProductStatus.draft;
    if (statusStr == 'published') {
      status = ProductStatus.published;
    } else if (statusStr == 'catalogReady') {
      status = ProductStatus.catalogReady;
    } else if (statusStr == 'priceReady') {
      status = ProductStatus.priceReady;
    } else if (statusStr == 'buyerMatched') {
      status = ProductStatus.buyerMatched;
    } else if (statusStr == 'outOfStock') {
      status = ProductStatus.outOfStock;
    }

    DateTime? parsedCreatedAt;
    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt != null) {
      if (rawCreatedAt is DateTime) {
        parsedCreatedAt = rawCreatedAt;
      } else {
        try {
          parsedCreatedAt = (rawCreatedAt as dynamic).toDate();
        } catch (_) {
          parsedCreatedAt = DateTime.tryParse(rawCreatedAt.toString());
        }
      }
    }

    DateTime? parsedPublishedAt;
    final rawPublishedAt = data['publishedAt'];
    if (rawPublishedAt != null) {
      if (rawPublishedAt is DateTime) {
        parsedPublishedAt = rawPublishedAt;
      } else {
        try {
          parsedPublishedAt = (rawPublishedAt as dynamic).toDate();
        } catch (_) {
          parsedPublishedAt = DateTime.tryParse(rawPublishedAt.toString());
        }
      }
    }

    final rawMatches = data['topBuyerMatches'] ?? data['buyerMatches'];
    List<Map<String, dynamic>>? matchesList;
    if (rawMatches is List) {
      matchesList = rawMatches.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    return Product(
      id: docId ?? (data['id'] as String? ?? ''),
      artisanId: data['artisanId'] as String? ?? '',
      name: data['productTitle'] as String? ?? data['name'] as String? ?? 'Handcrafted Item',
      nameHindi: data['hindiTitle'] as String? ?? data['nameHindi'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      craftTechnique: data['craftTechnique'] as String? ?? '',
      material: data['material'] as String? ?? '',
      origin: data['origin'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      views: (data['views'] as num?)?.toInt() ?? 0,
      orders: (data['orders'] as num?)?.toInt() ?? 0,
      status: status,
      imageUrl: data['imageUrl'] as String? ?? '',
      keywords: (data['keywords'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: parsedCreatedAt,
      publishedAt: parsedPublishedAt,
      completionPercent: (data['completionPercent'] as num?)?.toDouble() ??
          (status == ProductStatus.published
              ? 1.0
              : (status == ProductStatus.buyerMatched
                  ? 0.9
                  : (status == ProductStatus.priceReady ? 0.8 : 0.6))),
      voiceTranscript: data['voiceTranscript'] as String? ?? data['voiceDescription'] as String?,
      baseCost: (data['baseCost'] as num?)?.toDouble() ??
          (data['pricing'] is Map ? (data['pricing']['baseCost'] as num?)?.toDouble() : null),
      profit: (data['profit'] as num?)?.toDouble(),
      marginPercent: (data['marginPercent'] as num?)?.toInt() ??
          (data['pricing'] is Map ? (data['pricing']['desiredMargin'] as num?)?.toInt() : null),
      topBuyerMatches: matchesList,
      buyerMatchCount: (data['buyerMatchCount'] as num?)?.toInt() ?? matchesList?.length,
    );
  }

  Product copyWith({
    String? id,
    String? artisanId,
    String? name,
    String? nameHindi,
    String? description,
    String? category,
    String? craftTechnique,
    String? material,
    String? origin,
    double? price,
    int? views,
    int? orders,
    ProductStatus? status,
    String? imageUrl,
    List<String>? keywords,
    DateTime? createdAt,
    DateTime? publishedAt,
    double? completionPercent,
    String? voiceTranscript,
    double? baseCost,
    double? profit,
    int? marginPercent,
    List<Map<String, dynamic>>? topBuyerMatches,
    int? buyerMatchCount,
  }) {
    return Product(
      id: id ?? this.id,
      artisanId: artisanId ?? this.artisanId,
      name: name ?? this.name,
      nameHindi: nameHindi ?? this.nameHindi,
      description: description ?? this.description,
      category: category ?? this.category,
      craftTechnique: craftTechnique ?? this.craftTechnique,
      material: material ?? this.material,
      origin: origin ?? this.origin,
      price: price ?? this.price,
      views: views ?? this.views,
      orders: orders ?? this.orders,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      keywords: keywords ?? this.keywords,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      completionPercent: completionPercent ?? this.completionPercent,
      voiceTranscript: voiceTranscript ?? this.voiceTranscript,
      baseCost: baseCost ?? this.baseCost,
      profit: profit ?? this.profit,
      marginPercent: marginPercent ?? this.marginPercent,
      topBuyerMatches: topBuyerMatches ?? this.topBuyerMatches,
      buyerMatchCount: buyerMatchCount ?? this.buyerMatchCount,
    );
  }
}
