import 'package:flutter_test/flutter_test.dart';
import 'package:craftmitra/services/smart_pricing_service.dart';
import 'package:craftmitra/providers/providers.dart';

void main() {
  group('SmartPricingService Tests', () {
    late SmartPricingService service;

    setUp(() {
      service = SmartPricingService();
    });

    test('Standard Terracotta Vase calculates expected baseline values', () {
      final result = service.calculatePricing(
        rawMaterialCost: 250.0,
        laborCost: 270.0,
        packagingCost: 80.0,
        marginPercentage: 30,
        category: 'Pottery',
        craftTechnique: 'Wheel-thrown terracotta',
        material: 'Terracotta Clay',
        complexity: 'Medium',
        orderQuantity: 120,
        productTitle: 'Handcrafted Terracotta Pot',
      );

      // Base cost should be 250 + 270 + 80 = 600
      expect(result.baseCost, equals(600.0));
      // Benchmark should be Terracotta Vase / Pot
      expect(result.marketFloor, equals(750.0));
      expect(result.sweetSpot, equals(850.0));
      expect(result.marketCeiling, equals(950.0));
      // Cost plus price at 30%: 600 + 180 = 780
      expect(result.costPlusPrice, equals(780.0));
      // Recommended buyer-friendly price should be rounded to ~850
      expect(result.buyerFriendlyPrice, equals(850));
      // Confidence score should be in 90-95% range for complete product + benchmark
      expect(result.confidenceScore, inInclusiveRange(90, 95));
      // Reasoning should be populated and explainable
      expect(result.reasoning, contains('Recommended at ₹850'));
      expect(result.reasoning, contains('base cost is ₹600'));
      expect(result.reasoning, contains('selected margin is 30%'));
      // Voice guidance text
      expect(result.voiceGuidanceEnglish, contains('₹850'));
      expect(result.voiceGuidanceHindi, contains('₹850'));
    });

    test('Margin slider recalculates price dynamically', () {
      final at30 = service.calculatePricing(
        rawMaterialCost: 250.0,
        laborCost: 270.0,
        packagingCost: 80.0,
        marginPercentage: 30,
        category: 'Pottery',
        craftTechnique: 'Wheel-thrown terracotta',
        material: 'Terracotta Clay',
        complexity: 'Medium',
        orderQuantity: 120,
      );

      final at45 = service.calculatePricing(
        rawMaterialCost: 250.0,
        laborCost: 270.0,
        packagingCost: 80.0,
        marginPercentage: 45,
        category: 'Pottery',
        craftTechnique: 'Wheel-thrown terracotta',
        material: 'Terracotta Clay',
        complexity: 'Medium',
        orderQuantity: 120,
      );

      expect(at45.buyerFriendlyPrice, greaterThan(at30.buyerFriendlyPrice));
      expect(at45.targetPrice, greaterThan(at30.targetPrice));
    });

    test('Cost changes recalculate base cost and recommendation', () {
      final res1 = service.calculatePricing(
        rawMaterialCost: 200.0,
        laborCost: 200.0,
        packagingCost: 50.0,
        marginPercentage: 30,
        category: 'Pottery',
      );

      final res2 = service.calculatePricing(
        rawMaterialCost: 350.0,
        laborCost: 300.0,
        packagingCost: 100.0,
        marginPercentage: 30,
        category: 'Pottery',
      );

      expect(res1.baseCost, equals(450.0));
      expect(res2.baseCost, equals(750.0));
      expect(res2.buyerFriendlyPrice, greaterThan(res1.buyerFriendlyPrice));
    });

    test('Benchmark categorization works for all demo categories', () {
      final diya = service.getBenchmark(productTitle: 'Festive Clay Diya Set');
      expect(diya.floor, equals(350.0));
      expect(diya.center, equals(420.0));
      expect(diya.ceiling, equals(500.0));

      final pitcher = service.getBenchmark(productTitle: 'Handmade Clay Pitcher Jug');
      expect(pitcher.floor, equals(550.0));
      expect(pitcher.center, equals(650.0));
      expect(pitcher.ceiling, equals(750.0));

      final flowerPot = service.getBenchmark(productTitle: 'Garden Flower Pot Planter');
      expect(flowerPot.floor, equals(700.0));
      expect(flowerPot.center, equals(850.0));
      expect(flowerPot.ceiling, equals(950.0));
    });

    test('Bulk quantity discount scales appropriately', () {
      final single = service.calculatePricing(
        rawMaterialCost: 250.0,
        laborCost: 270.0,
        packagingCost: 80.0,
        marginPercentage: 30,
        category: 'Pottery',
        orderQuantity: 10, // 0% discount
      );

      final bulk = service.calculatePricing(
        rawMaterialCost: 250.0,
        laborCost: 270.0,
        packagingCost: 80.0,
        marginPercentage: 30,
        category: 'Pottery',
        orderQuantity: 120, // -5% discount
      );

      expect(bulk.targetPrice, lessThan(single.targetPrice));
      expect(bulk.bulkDiscountPercent, equals(-5.0));
      expect(single.bulkDiscountPercent, equals(0.0));
      expect(bulk.reasoning, contains('Bulk quantity discount applied'));
    });

    test('Complexity adjustments apply correctly', () {
      final low = service.calculatePricing(
        rawMaterialCost: 250.0,
        laborCost: 270.0,
        packagingCost: 80.0,
        marginPercentage: 30,
        category: 'Pottery',
        complexity: 'Low',
      );

      final high = service.calculatePricing(
        rawMaterialCost: 250.0,
        laborCost: 270.0,
        packagingCost: 80.0,
        marginPercentage: 30,
        category: 'Pottery',
        complexity: 'High',
      );

      expect(high.targetPrice, greaterThan(low.targetPrice));
      expect(high.complexityAdjustmentPercent, equals(10.0));
      expect(low.complexityAdjustmentPercent, equals(0.0));
      expect(high.reasoning, contains('higher craftsmanship effort'));
    });

    test('Demo safety handles invalid, negative, or zero inputs gracefully', () {
      final result = service.calculatePricing(
        rawMaterialCost: -50.0,
        laborCost: 0.0,
        packagingCost: double.nan,
        marginPercentage: -10,
        orderQuantity: -5,
      );

      expect(result.buyerFriendlyPrice, greaterThan(0));
      expect(result.targetPrice.isNaN, isFalse);
      expect(result.targetPrice.isInfinite, isFalse);
      expect(result.baseCost, greaterThan(0));
    });

    test('Craft benchmark text appears only for supported craft categories', () {
      final craftResult = service.calculatePricing(
        rawMaterialCost: 250.0,
        laborCost: 270.0,
        packagingCost: 80.0,
        marginPercentage: 30,
        category: 'Pottery',
        productTitle: 'Handcrafted Terracotta Pot',
      );

      expect(craftResult.marketContext, contains('National Artisan Registry'));
      expect(craftResult.marketContext, contains('verified artisan listings'));
    });

    test('Non-craft benchmark uses illustrative wording', () {
      final nonCraftResult = service.calculatePricing(
        rawMaterialCost: 250.0,
        laborCost: 270.0,
        packagingCost: 80.0,
        marginPercentage: 30,
        category: 'Electronics',
        productTitle: 'Atomberg Smart Fan Remote',
      );

      expect(nonCraftResult.marketContext, equals('Demo Category Benchmark • Illustrative pricing range'));
      expect(nonCraftResult.marketContext, isNot(contains('National Artisan Registry')));
      expect(nonCraftResult.reasoning, contains('illustrative pricing range'));
    });
  });

  group('ProductCreationProvider Smart Pricing Integration', () {
    test('Provider exposes pricingResult and updates upon margin change', () {
      final prov = ProductCreationProvider();

      expect(prov.baseCost, equals(600.0));
      expect(prov.marginPercent, equals(30));
      expect(prov.pricingResult.buyerFriendlyPrice, equals(850));

      prov.setMargin(40);
      expect(prov.marginPercent, equals(40));
      expect(prov.pricingResult.buyerFriendlyPrice, greaterThanOrEqualTo(850));

      prov.updateCosts(rawMaterial: 300.0);
      expect(prov.rawMaterialCost, equals(300.0));
      expect(prov.baseCost, equals(650.0));
    });
  });
}
