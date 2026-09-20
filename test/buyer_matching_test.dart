import 'package:flutter_test/flutter_test.dart';
import 'package:craftmitra/models/models.dart';
import 'package:craftmitra/services/buyer_matching_service.dart';
import 'package:craftmitra/core/constants/demo_data.dart';
import 'package:craftmitra/providers/providers.dart';

void main() {
  group('BuyerMatchingService Tests', () {
    late BuyerMatchingService service;

    setUp(() {
      service = BuyerMatchingService();
    });

    test('1. Exact category match yields 100, related yields 70, no match yields 20', () {
      final exactScore = service.calculateCategoryScore(
        productCategory: 'Home Decor',
        buyerCategories: ['Home Decor', 'Terracotta'],
        productTitle: 'Handcrafted Terracotta Vase',
      );
      expect(exactScore, equals(100));

      final relatedScore = service.calculateCategoryScore(
        productCategory: 'Kitchenware',
        buyerCategories: ['Living', 'Decor'],
        productTitle: 'Clay Bowl',
      );
      expect(relatedScore, equals(70));

      final noMatchScore = service.calculateCategoryScore(
        productCategory: 'Automotive',
        buyerCategories: ['Jewelry', 'Apparel'],
        productTitle: 'Steel Tool',
      );
      expect(noMatchScore, equals(20));
    });

    test('2. Material match scores: exact 100, multi-option 90, related 70, none 30', () {
      final exactScore = service.calculateMaterialScore(
        productMaterial: 'Terracotta',
        buyerMaterials: ['Terracotta'],
      );
      expect(exactScore, equals(100));

      final multiScore = service.calculateMaterialScore(
        productMaterial: 'Natural River Clay',
        buyerMaterials: ['Terracotta', 'Clay'],
      );
      expect(multiScore, equals(90));

      final relatedScore = service.calculateMaterialScore(
        productMaterial: 'Earthenware',
        buyerMaterials: ['Clay', 'Terracotta'],
      );
      expect(relatedScore, equals(70));

      final noMatch = service.calculateMaterialScore(
        productMaterial: 'Plastic',
        buyerMaterials: ['Clay', 'Terracotta'],
      );
      expect(noMatch, equals(30));
    });

    test('3. Technique match: exact 100, traditional handmade 90, related 70, none 40', () {
      final exact = service.calculateTechniqueScore(
        productTechnique: 'Wheel Pottery',
        buyerTechniques: ['Wheel Pottery', 'Handmade'],
      );
      expect(exact, equals(100));

      final handmade = service.calculateTechniqueScore(
        productTechnique: 'Handcrafted generational shaping',
        buyerTechniques: ['Traditional Handmade'],
      );
      expect(handmade, equals(90));

      final related = service.calculateTechniqueScore(
        productTechnique: 'Casting and shaping',
        buyerTechniques: ['Molding', 'Pottery'],
      );
      expect(related, equals(70));

      final none = service.calculateTechniqueScore(
        productTechnique: 'CNC Laser Machine',
        buyerTechniques: ['Handmade'],
      );
      expect(none, equals(40));
    });

    test('4. Price inside budget yields 100', () {
      final score = service.calculatePriceScore(
        targetPrice: 850.0,
        minBudget: 800.0,
        maxBudget: 900.0,
      );
      expect(score, equals(100));
    });

    test('5. Price outside budget: slightly outside yields 80, far outside yields 30', () {
      // Slightly outside (₹780 when budget is 800-900, 780 >= 720)
      final slightlyOutside = service.calculatePriceScore(
        targetPrice: 780.0,
        minBudget: 800.0,
        maxBudget: 900.0,
      );
      expect(slightlyOutside, equals(80));

      // Far outside (₹1500 when budget is 800-900)
      final farOutside = service.calculatePriceScore(
        targetPrice: 1500.0,
        minBudget: 800.0,
        maxBudget: 900.0,
      );
      expect(farOutside, equals(30));
    });

    test('6. Quantity compatibility scores correctly', () {
      // Inside range (50 in 20-100)
      final inside = service.calculateQuantityScore(
        productQuantity: 50,
        minQuantity: 20,
        maxQuantity: 100,
      );
      expect(inside, equals(100));

      // Close (120 for 20-100, <= 130)
      final close = service.calculateQuantityScore(
        productQuantity: 120,
        minQuantity: 20,
        maxQuantity: 100,
      );
      expect(close, equals(80));

      // Far poor (500 for 20-100)
      final poor = service.calculateQuantityScore(
        productQuantity: 500,
        minQuantity: 20,
        maxQuantity: 100,
      );
      expect(poor, equals(30));
    });

    test('7. Completeness score reflects product field presence', () {
      final full = service.calculateCompletenessScore(
        title: 'Terracotta Vase',
        category: 'Home Decor',
        material: 'Clay',
        technique: 'Wheel Pottery',
        origin: 'Rajasthan',
        description: 'Traditional pot',
        keywords: ['#pot'],
        hasImage: true,
      );
      expect(full, equals(100));

      final partial = service.calculateCompletenessScore(
        title: 'Terracotta Vase',
        category: 'Home Decor',
        material: 'Clay',
        technique: 'Wheel Pottery',
        origin: 'Rajasthan',
        description: 'Traditional pot',
        keywords: [],
        hasImage: false,
      );
      expect(partial, equals(80));
    });

    test('8. Weighted final score adheres to component weights and clamps', () {
      final score = service.calculateFinalScore(
        categoryScore: 100, // 25
        materialScore: 90,  // 13.5
        techniqueScore: 100,// 10
        priceScore: 100,    // 20
        quantityScore: 80,  // 8
        locationScore: 70,  // 3.5
        completenessScore: 100, // 15
      );
      // 25 + 13.5 + 10 + 20 + 8 + 3.5 + 15 = 95.0 -> 95
      expect(score, equals(95));
      expect(score, inInclusiveRange(0, 100));
    });

    test('9. Buyer sorting places highest matchScore first', () {
      final results = service.matchBuyers(
        buyers: DemoData.buyers,
        targetPrice: 850.0,
        quantity: 50,
        productTitle: 'Handcrafted Terracotta Vase',
        catalog: const GeneratedCatalog(
          title: 'Handcrafted Terracotta Vase',
          category: 'Home Decor',
          craftTechnique: 'Wheel Pottery',
          material: 'Natural River Clay',
          origin: 'Rajasthan, India',
          description: 'Finely crafted terracotta vase.',
          keywords: ['#terracotta', '#handmade'],
        ),
        imageBytes: [1, 2, 3],
      );

      expect(results.length, equals(DemoData.buyers.length));
      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].matchScore, greaterThanOrEqualTo(results[i + 1].matchScore));
      }
    });

    test('10. Changing price dynamically changes match score', () {
      final buyer = DemoData.buyers.firstWhere((b) => b.id == 'B-001'); // Budget 800-900

      final matchAt850 = service.matchBuyers(
        buyers: [buyer],
        targetPrice: 850.0, // Inside budget
        quantity: 50,
        catalog: const GeneratedCatalog(
          title: 'Handcrafted Terracotta Vase',
          category: 'Home Decor',
          craftTechnique: 'Wheel Pottery',
          material: 'Natural River Clay',
          origin: 'Rajasthan, India',
          description: 'Finely crafted terracotta vase.',
        ),
        imageBytes: [1, 2, 3],
      ).first;

      final matchAt1400 = service.matchBuyers(
        buyers: [buyer],
        targetPrice: 1400.0, // Far outside budget
        quantity: 50,
        catalog: const GeneratedCatalog(
          title: 'Handcrafted Terracotta Vase',
          category: 'Home Decor',
          craftTechnique: 'Wheel Pottery',
          material: 'Natural River Clay',
          origin: 'Rajasthan, India',
          description: 'Finely crafted terracotta vase.',
        ),
        imageBytes: [1, 2, 3],
      ).first;

      expect(matchAt850.priceScore, equals(100));
      expect(matchAt1400.priceScore, equals(30));
      expect(matchAt850.matchScore, greaterThan(matchAt1400.matchScore));
    });

    test('11. Match quality label maps correctly across all ranges', () {
      expect(BuyerMatchingService.matchQualityLabel(95), equals('Excellent Match'));
      expect(BuyerMatchingService.matchQualityLabel(90), equals('Excellent Match'));
      expect(BuyerMatchingService.matchQualityLabel(85), equals('Good Match'));
      expect(BuyerMatchingService.matchQualityLabel(75), equals('Good Match'));
      expect(BuyerMatchingService.matchQualityLabel(70), equals('Moderate Match'));
      expect(BuyerMatchingService.matchQualityLabel(60), equals('Moderate Match'));
      expect(BuyerMatchingService.matchQualityLabel(55), equals('Low Match'));
      expect(BuyerMatchingService.matchQualityLabel(30), equals('Low Match'));
    });

    test('12. Category mismatch produces appropriate explanation and limited fit reason', () {
      final buyer = DemoData.buyers.firstWhere((b) => b.id == 'B-001'); // FabIndia - Home Decor / Terracotta

      final nonCraftMatches = service.matchBuyers(
        buyers: [buyer],
        targetPrice: 850.0,
        quantity: 50,
        productTitle: 'Atomberg Smart Fan Remote',
        catalog: const GeneratedCatalog(
          title: 'Atomberg Smart Fan Remote',
          category: 'Electronics',
          craftTechnique: 'Injection Molding',
          material: 'Plastic & PCB',
          origin: 'Pune, Maharashtra',
          description: 'Smart remote control for ceiling fans.',
        ),
        imageBytes: [1, 2, 3],
      );

      final result = nonCraftMatches.first;
      // Category score should be low (< 70)
      expect(result.categoryScore, lessThan(70));
      // Should NOT say 'Home & Decor Portfolio Fit'
      expect(result.reasons, isNot(contains('Home & Decor Portfolio Fit')));
      // Should specify 'Limited Category Fit'
      expect(result.reasons, contains('Limited Category Fit'));
      // Recommendation should acknowledge limited category compatibility
      expect(result.recommendation, contains('category compatibility is limited'));
    });
  });

  group('ProductCreationProvider Buyer Matching Integration', () {
    test('Provider exposes buyerMatches and updates dynamically', () {
      final prov = ProductCreationProvider();

      expect(prov.buyerMatches.isNotEmpty, isTrue);
      final initialTopScore = prov.buyerMatches.first.matchScore;
      expect(initialTopScore, greaterThanOrEqualTo(85));

      // Change margin to 50% which increases targetPrice
      prov.setMargin(50);
      expect(prov.buyerMatches.isNotEmpty, isTrue);
    });
  });
}
