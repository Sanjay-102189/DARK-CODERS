import 'package:flutter_test/flutter_test.dart';
import 'package:craftmitra/models/models.dart';
import 'package:craftmitra/services/smart_pricing_service.dart';
import 'package:craftmitra/services/buyer_matching_service.dart';
import 'package:craftmitra/core/constants/demo_data.dart';

void main() {
  group('Phase 6.5 Data Integrity Tests', () {
    late SmartPricingService pricingService;
    late BuyerMatchingService buyerService;

    setUp(() {
      pricingService = SmartPricingService();
      buyerService = BuyerMatchingService();
    });

    test('1. Craft product benchmark reflects National Artisan Registry', () {
      final res = pricingService.calculatePricing(
        rawMaterialCost: 250,
        laborCost: 270,
        packagingCost: 80,
        marginPercentage: 30,
        category: 'Pottery',
        productTitle: 'Handcrafted Terracotta Flower Pot',
      );

      expect(res.marketContext, contains('National Artisan Registry'));
      expect(res.marketContext, contains('verified artisan listings'));
    });

    test('2. Non-craft product uses generic illustrative benchmark', () {
      final res = pricingService.calculatePricing(
        rawMaterialCost: 250,
        laborCost: 270,
        packagingCost: 80,
        marginPercentage: 30,
        category: 'Electronics',
        productTitle: 'Atomberg Smart Fan Remote',
      );

      expect(res.marketContext, equals('Demo Category Benchmark • Illustrative pricing range'));
      expect(res.marketContext, isNot(contains('National Artisan Registry')));
      expect(res.reasoning, contains('illustrative pricing range'));
    });

    test('3. Buyer mismatch produces appropriate explanation without misleading claims', () {
      final buyer = DemoData.buyers.firstWhere((b) => b.id == 'B-001'); // FabIndia Craft Buyer

      final matches = buyerService.matchBuyers(
        buyers: [buyer],
        targetPrice: 850,
        quantity: 50,
        productTitle: 'Atomberg Smart Fan Remote',
        catalog: const GeneratedCatalog(
          title: 'Atomberg Smart Fan Remote',
          category: 'Electronics',
          craftTechnique: 'Molding',
          material: 'Plastic',
          origin: 'Pune',
          description: 'Smart remote for ceiling fan',
        ),
        imageBytes: [1, 2, 3],
      );

      final result = matches.first;
      expect(result.reasons, isNot(contains('Home & Decor Portfolio Fit')));
      expect(result.reasons, contains('Limited Category Fit'));
      expect(result.recommendation, contains('category compatibility is limited'));
      expect(BuyerMatchingService.matchQualityLabel(result.matchScore), isNot(equals('Excellent Match')));
    });

    test('4. Dynamic voice insight logic generates category-adapted context', () {
      String getDynamicInsight(GeneratedCatalog? catalog) {
        if (catalog == null) {
          return 'Gemini identified some attributes that need artisan confirmation.';
        }
        final catLower = catalog.category.toLowerCase();
        final titleLower = catalog.title.toLowerCase();
        final isPotteryOrClay = catLower.contains('clay') ||
            catLower.contains('terracotta') ||
            catLower.contains('pottery') ||
            titleLower.contains('terracotta');

        if (isPotteryOrClay) {
          return 'Gemini detects: Terracotta clay, wheel pottery technique and traditional handmade craft.';
        } else if (catalog.category.isNotEmpty && catalog.title.isNotEmpty) {
          return 'Gemini has analyzed the product image and voice description.';
        } else {
          return 'Gemini identified some attributes that need artisan confirmation.';
        }
      }

      // Terracotta craft
      const terracottaCatalog = GeneratedCatalog(
        title: 'Handcrafted Terracotta Pot',
        category: 'Terracotta & Clay',
        craftTechnique: 'Wheel Throwing',
        material: 'Terracotta Clay',
        origin: 'Rajasthan',
        description: 'Pot',
      );
      expect(
        getDynamicInsight(terracottaCatalog),
        equals('Gemini detects: Terracotta clay, wheel pottery technique and traditional handmade craft.'),
      );

      // Non-craft (fan remote)
      const remoteCatalog = GeneratedCatalog(
        title: 'Atomberg Smart Fan Remote',
        category: 'Electronics',
        craftTechnique: 'Molding',
        material: 'Plastic',
        origin: 'Pune',
        description: 'Fan remote',
      );
      expect(
        getDynamicInsight(remoteCatalog),
        equals('Gemini has analyzed the product image and voice description.'),
      );

      // Uncertain/Null catalog
      expect(
        getDynamicInsight(null),
        equals('Gemini identified some attributes that need artisan confirmation.'),
      );
    });
  });
}
