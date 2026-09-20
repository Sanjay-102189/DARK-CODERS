import '../models/buyer.dart';
import '../models/catalog.dart';

/// Detailed scoring breakdown and recommendation for a matched buyer.
class BuyerMatchResult {
  final Buyer buyer;
  final int matchScore;
  final int categoryScore;
  final int materialScore;
  final int techniqueScore;
  final int priceScore;
  final int quantityScore;
  final int locationScore;
  final int completenessScore;
  final List<String> reasons;
  final String recommendation;

  const BuyerMatchResult({
    required this.buyer,
    required this.matchScore,
    required this.categoryScore,
    required this.materialScore,
    required this.techniqueScore,
    required this.priceScore,
    required this.quantityScore,
    required this.locationScore,
    required this.completenessScore,
    required this.reasons,
    required this.recommendation,
  });
}

/// Deterministic local Buyer Matching Engine for CraftMitra.
/// Evaluates product attributes against buyer requirements without requiring any backend.
class BuyerMatchingService {
  /// Category match (25% weight)
  /// Exact category match: 100
  /// Related category: 70
  /// No meaningful match: 20
  int calculateCategoryScore({
    required String productCategory,
    required List<String> buyerCategories,
    String? productTitle,
  }) {
    if (buyerCategories.isEmpty) return 70;
    final catLower = productCategory.trim().toLowerCase();
    final titleLower = (productTitle ?? '').trim().toLowerCase();

    for (final bc in buyerCategories) {
      final bcLower = bc.trim().toLowerCase();
      if (catLower == bcLower ||
          catLower.contains(bcLower) ||
          bcLower.contains(catLower) ||
          titleLower.contains(bcLower)) {
        return 100;
      }
    }

    // Related category keywords
    const relatedKeywords = [
      'decor',
      'craft',
      'home',
      'pottery',
      'living',
      'terracotta',
      'festive',
      'kitchenware',
      'artisan',
    ];
    final hasRelatedProd = relatedKeywords.any((r) => catLower.contains(r) || titleLower.contains(r));
    final hasRelatedBuyer = buyerCategories.any(
      (bc) => relatedKeywords.any((r) => bc.toLowerCase().contains(r)),
    );

    if (hasRelatedProd && hasRelatedBuyer) {
      return 70;
    }

    return 20;
  }

  /// Material match (15% weight)
  /// Exact material match: 100
  /// Buyer accepts multiple materials and product matches one: 90
  /// Related material: 70
  /// No match: 30
  int calculateMaterialScore({
    required String productMaterial,
    required List<String> buyerMaterials,
  }) {
    if (buyerMaterials.isEmpty) return 70;
    final matLower = productMaterial.trim().toLowerCase();

    final matched = buyerMaterials.where((bm) {
      final bmLower = bm.trim().toLowerCase();
      return matLower.contains(bmLower) || bmLower.contains(matLower);
    }).toList();

    if (matched.isNotEmpty) {
      return buyerMaterials.length == 1 ? 100 : 90;
    }

    // Related materials (clay family, ceramic, river clay, mud, earth)
    const ceramicFamily = [
      'clay',
      'terracotta',
      'ceramic',
      'river clay',
      'red clay',
      'earthenware',
      'earth',
      'mud',
    ];
    final isProdCeramic = ceramicFamily.any((c) => matLower.contains(c));
    final isBuyerCeramic = buyerMaterials.any(
      (bm) => ceramicFamily.any((c) => bm.toLowerCase().contains(c)),
    );

    if (isProdCeramic && isBuyerCeramic) {
      return 70;
    }

    return 30;
  }

  /// Technique match (10% weight)
  /// Exact technique: 100
  /// Traditional handmade accepted: 90
  /// Related technique: 70
  /// No match: 40
  int calculateTechniqueScore({
    required String productTechnique,
    required List<String> buyerTechniques,
  }) {
    if (buyerTechniques.isEmpty) return 70;
    final techLower = productTechnique.trim().toLowerCase();

    for (final bt in buyerTechniques) {
      final btLower = bt.trim().toLowerCase();
      if (techLower == btLower || techLower.contains(btLower) || btLower.contains(techLower)) {
        return 100;
      }
    }

    // Traditional handmade accepted
    final isHandmadeProd = techLower.contains('hand') ||
        techLower.contains('wheel') ||
        techLower.contains('traditional') ||
        techLower.contains('carv') ||
        techLower.contains('loom');
    final buyerAcceptsHandmade = buyerTechniques.any(
      (bt) =>
          bt.toLowerCase().contains('hand') ||
          bt.toLowerCase().contains('traditional') ||
          bt.toLowerCase().contains('wheel'),
    );

    if (isHandmadeProd && buyerAcceptsHandmade) {
      return 90;
    }

    // Related craft techniques
    const craftTechs = ['pottery', 'molding', 'casting', 'weaving', 'sculpting'];
    final isCraftProd = craftTechs.any((c) => techLower.contains(c));
    final isCraftBuyer = buyerTechniques.any(
      (bt) => craftTechs.any((c) => bt.toLowerCase().contains(c)),
    );

    if (isCraftProd && isCraftBuyer) {
      return 70;
    }

    return 40;
  }

  /// Price compatibility (20% weight)
  /// Target price inside buyer budget: 100
  /// Slightly outside (within 10%): 80
  /// Moderately outside (within 25%): 60
  /// Far outside: 30
  int calculatePriceScore({
    required double targetPrice,
    required double minBudget,
    required double maxBudget,
  }) {
    if (targetPrice <= 0) return 60;
    if (minBudget <= 0 && maxBudget <= 0) return 100;

    final effectiveMin = minBudget > 0 ? minBudget : maxBudget * 0.7;
    final effectiveMax = maxBudget > 0 ? maxBudget : minBudget * 1.3;

    if (targetPrice >= effectiveMin && targetPrice <= effectiveMax) {
      return 100;
    }

    // Slightly outside: within 10% boundary
    final slightMin = effectiveMin * 0.90;
    final slightMax = effectiveMax * 1.10;
    if (targetPrice >= slightMin && targetPrice <= slightMax) {
      return 80;
    }

    // Moderately outside: within 25% boundary
    final modMin = effectiveMin * 0.75;
    final modMax = effectiveMax * 1.25;
    if (targetPrice >= modMin && targetPrice <= modMax) {
      return 60;
    }

    // Far outside
    return 30;
  }

  /// Quantity compatibility (10% weight)
  /// Full compatibility: 100
  /// Close: 80
  /// Partial: 60
  /// Poor: 30
  /// If buyer has no quantity restriction: 100
  int calculateQuantityScore({
    required int productQuantity,
    required int minQuantity,
    required int maxQuantity,
  }) {
    if (minQuantity <= 0 && maxQuantity <= 0) return 100;

    final effectiveMin = minQuantity > 0 ? minQuantity : 1;
    final effectiveMax = maxQuantity > 0 ? maxQuantity : 10000;

    if (productQuantity >= effectiveMin && productQuantity <= effectiveMax) {
      return 100;
    }

    // Close: within 30% boundary
    final closeMin = (effectiveMin * 0.70).floor();
    final closeMax = (effectiveMax * 1.30).ceil();
    if (productQuantity >= closeMin && productQuantity <= closeMax) {
      return 80;
    }

    // Partial: within 60% boundary
    final partialMin = (effectiveMin * 0.40).floor();
    final partialMax = (effectiveMax * 1.60).ceil();
    if (productQuantity >= partialMin && productQuantity <= partialMax) {
      return 60;
    }

    return 30;
  }

  /// Location suitability (5% weight)
  /// "Demo location suitability"
  /// Same/nearby region: 100
  /// Same state: 90
  /// Nearby state/region: 80
  /// Different region: 70
  int calculateLocationScore({
    required String buyerLocation,
    required String buyerState,
    required String buyerRegion,
    required double distanceKm,
    String artisanState = 'Rajasthan',
  }) {
    if (buyerState.toLowerCase() == artisanState.toLowerCase()) {
      return 90;
    }

    if (distanceKm > 0 && distanceKm <= 250) {
      return 100;
    }

    if (buyerRegion.toLowerCase().contains('north') ||
        buyerRegion.toLowerCase().contains('west') ||
        buyerState.toLowerCase().contains('delhi') ||
        buyerState.toLowerCase().contains('ncr') ||
        buyerState.toLowerCase().contains('gujarat') ||
        buyerState.toLowerCase().contains('haryana') ||
        buyerState.toLowerCase().contains('punjab')) {
      return 90;
    }

    if (distanceKm > 0 && distanceKm <= 600) {
      return 80;
    }

    if (buyerRegion.toLowerCase().contains('south') ||
        buyerRegion.toLowerCase().contains('east')) {
      return 70;
    }

    return 70;
  }

  /// Product completeness (15% weight)
  /// Evaluates: title, category, material, technique, origin, description, keywords, image
  /// 8/8 = 100, 7/8 = 90, 6/8 = 80, 5/8 = 70, etc.
  int calculateCompletenessScore({
    String? title,
    String? category,
    String? material,
    String? technique,
    String? origin,
    String? description,
    List<String>? keywords,
    bool hasImage = false,
  }) {
    int count = 0;
    if (title != null && title.trim().isNotEmpty) count++;
    if (category != null && category.trim().isNotEmpty) count++;
    if (material != null && material.trim().isNotEmpty) count++;
    if (technique != null && technique.trim().isNotEmpty) count++;
    if (origin != null && origin.trim().isNotEmpty) count++;
    if (description != null && description.trim().isNotEmpty) count++;
    if (keywords != null && keywords.isNotEmpty) count++;
    if (hasImage) count++;

    switch (count) {
      case 8:
        return 100;
      case 7:
        return 90;
      case 6:
        return 80;
      case 5:
        return 70;
      case 4:
        return 60;
      case 3:
        return 50;
      case 2:
        return 40;
      default:
        return 30;
    }
  }

  /// Calculates the final weighted match score
  /// Category = 25%, Material = 15%, Technique = 10%, Price = 20%, Quantity = 10%, Location = 5%, Completeness = 15%
  int calculateFinalScore({
    required int categoryScore,
    required int materialScore,
    required int techniqueScore,
    required int priceScore,
    required int quantityScore,
    required int locationScore,
    required int completenessScore,
  }) {
    final weighted = (categoryScore * 0.25) +
        (materialScore * 0.15) +
        (techniqueScore * 0.10) +
        (priceScore * 0.20) +
        (quantityScore * 0.10) +
        (locationScore * 0.05) +
        (completenessScore * 0.15);

    return weighted.round().clamp(0, 100);
  }

  /// Returns a human-friendly match tier based on the match percentage.
  /// 90–100 -> Excellent Match
  /// 75–89  -> Good Match
  /// 60–74  -> Moderate Match
  /// <60    -> Low Match
  static String matchQualityLabel(int score) {
    if (score >= 90) return 'Excellent Match';
    if (score >= 75) return 'Good Match';
    if (score >= 60) return 'Moderate Match';
    return 'Low Match';
  }

  /// Generates explainable bullet-point reasons for the match.
  List<String> generateReasons({
    required Buyer buyer,
    required int matchScore,
    required int categoryScore,
    required int materialScore,
    required int techniqueScore,
    required int priceScore,
    required int quantityScore,
    required double targetPrice,
    required int quantity,
  }) {
    final reasons = <String>[];

    // Category / Material specialization
    if (categoryScore >= 90 && materialScore >= 70) {
      final leadMat = buyer.preferredMaterials.isNotEmpty ? buyer.preferredMaterials.first : 'Craft';
      reasons.add('$leadMat Craft Specialization');
    } else if (categoryScore >= 70) {
      final isBuyerDecor = buyer.preferredCategories.any((c) =>
          c.toLowerCase().contains('decor') || c.toLowerCase().contains('home'));
      if (isBuyerDecor) {
        reasons.add('Home & Decor Portfolio Fit');
      } else {
        reasons.add('Category Portfolio Fit');
      }
    } else {
      reasons.add('Limited Category Fit');
    }

    // Advance escrow assurance
    reasons.add('50% advance via escrow');

    // Price compatibility
    if (priceScore == 100) {
      reasons.add('Budget fits ₹${targetPrice.toInt()} sweetspot');
    } else if (priceScore == 80) {
      reasons.add('Close to budget (${buyer.budgetRange})');
    } else {
      reasons.add('Negotiable budget (${buyer.budgetRange})');
    }

    // Technique preference
    if (techniqueScore >= 90) {
      reasons.add('Traditional handmade preferred');
    }

    // Quantity alignment
    if (quantityScore >= 80) {
      reasons.add('Batch size ($quantity pcs) aligned');
    }

    return reasons;
  }

  /// Generates a cohesive human-readable recommendation string.
  String generateRecommendation({
    required Buyer buyer,
    required int matchScore,
    required int categoryScore,
    required int materialScore,
    required int techniqueScore,
    required int priceScore,
    required double targetPrice,
  }) {
    final sb = StringBuffer();
    sb.write('$matchScore% match because ');

    if (categoryScore < 70) {
      if (priceScore >= 80) {
        sb.write("the target price fits the buyer budget, but category compatibility is limited.");
      } else {
        sb.write("category compatibility is limited and pricing terms require mutual alignment.");
      }
      return sb.toString();
    }

    if (categoryScore >= 90 && materialScore >= 90) {
      sb.write("the product category and material match the buyer's requirements, ");
    } else if (categoryScore >= 70) {
      final isBuyerDecor = buyer.preferredCategories.any((c) =>
          c.toLowerCase().contains('decor') || c.toLowerCase().contains('home'));
      if (isBuyerDecor) {
        sb.write("the product aligns with the buyer's decor catalog, ");
      } else {
        sb.write("the product aligns with the buyer's catalog, ");
      }
    }

    if (priceScore == 100) {
      sb.write("the ₹${targetPrice.toInt()} target price falls within the buyer's ${buyer.budgetRange} budget, ");
    } else if (priceScore == 80) {
      sb.write("the ₹${targetPrice.toInt()} target price is slightly outside the buyer's ${buyer.budgetRange} budget, ");
    } else {
      sb.write("the recommended price is slightly above the buyer's preferred range (${buyer.budgetRange}), ");
    }

    if (techniqueScore >= 90) {
      sb.write("and the traditional handmade technique is preferred.");
    } else {
      sb.write("with recurring B2B reorder potential.");
    }

    return sb.toString();
  }

  /// Runs the full matching evaluation for a list of buyers and returns sorted results.
  List<BuyerMatchResult> matchBuyers({
    required List<Buyer> buyers,
    GeneratedCatalog? catalog,
    required double targetPrice,
    required int quantity,
    dynamic imageBytes,
    String? productTitle,
    String artisanState = 'Rajasthan',
  }) {
    final title = catalog?.title ?? productTitle ?? 'Handcrafted Terracotta Pot';
    final category = catalog?.category ?? 'Home Decor';
    final material = catalog?.material ?? 'Natural River Clay';
    final technique = catalog?.craftTechnique ?? 'Wheel Pottery';
    final origin = catalog?.origin ?? 'Rajasthan, India';
    final description = catalog?.description ?? '';
    final keywords = catalog?.keywords ?? const <String>[];
    final hasImage = imageBytes != null;

    final completenessScore = calculateCompletenessScore(
      title: title,
      category: category,
      material: material,
      technique: technique,
      origin: origin,
      description: description,
      keywords: keywords,
      hasImage: hasImage,
    );

    final results = <BuyerMatchResult>[];

    for (final buyer in buyers) {
      final categoryScore = calculateCategoryScore(
        productCategory: category,
        buyerCategories: buyer.preferredCategories,
        productTitle: title,
      );

      final materialScore = calculateMaterialScore(
        productMaterial: material,
        buyerMaterials: buyer.preferredMaterials,
      );

      final techniqueScore = calculateTechniqueScore(
        productTechnique: technique,
        buyerTechniques: buyer.preferredTechniques,
      );

      final priceScore = calculatePriceScore(
        targetPrice: targetPrice,
        minBudget: buyer.minBudget,
        maxBudget: buyer.maxBudget,
      );

      final quantityScore = calculateQuantityScore(
        productQuantity: quantity,
        minQuantity: buyer.minQuantity,
        maxQuantity: buyer.maxQuantity,
      );

      final locationScore = calculateLocationScore(
        buyerLocation: buyer.location,
        buyerState: buyer.state,
        buyerRegion: buyer.region,
        distanceKm: buyer.distanceKm,
        artisanState: artisanState,
      );

      final matchScore = calculateFinalScore(
        categoryScore: categoryScore,
        materialScore: materialScore,
        techniqueScore: techniqueScore,
        priceScore: priceScore,
        quantityScore: quantityScore,
        locationScore: locationScore,
        completenessScore: completenessScore,
      );

      final reasons = generateReasons(
        buyer: buyer,
        matchScore: matchScore,
        categoryScore: categoryScore,
        materialScore: materialScore,
        techniqueScore: techniqueScore,
        priceScore: priceScore,
        quantityScore: quantityScore,
        targetPrice: targetPrice,
        quantity: quantity,
      );

      final recommendation = generateRecommendation(
        buyer: buyer,
        matchScore: matchScore,
        categoryScore: categoryScore,
        materialScore: materialScore,
        techniqueScore: techniqueScore,
        priceScore: priceScore,
        targetPrice: targetPrice,
      );

      final updatedBuyer = buyer.copyWith(
        matchPercent: matchScore,
        matchReasons: reasons,
      );

      results.add(BuyerMatchResult(
        buyer: updatedBuyer,
        matchScore: matchScore,
        categoryScore: categoryScore,
        materialScore: materialScore,
        techniqueScore: techniqueScore,
        priceScore: priceScore,
        quantityScore: quantityScore,
        locationScore: locationScore,
        completenessScore: completenessScore,
        reasons: reasons,
        recommendation: recommendation,
      ));
    }

    // Sort by highest matchScore first
    results.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return results;
  }
}
