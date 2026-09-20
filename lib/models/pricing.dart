class PricingBreakdown {
  final double rawMaterial;
  final String rawMaterialLabel;
  final double craftLabor;
  final String craftLaborLabel;
  final double packaging;
  final String packagingLabel;

  double get baseCost => rawMaterial + craftLabor + packaging;

  const PricingBreakdown({
    required this.rawMaterial,
    this.rawMaterialLabel = 'Clay, kiln fuel',
    required this.craftLabor,
    this.craftLaborLabel = '3.5h artisan effort',
    required this.packaging,
    this.packagingLabel = 'Straw & carton',
  });
}

class PricingResult {
  final PricingBreakdown breakdown;
  final int marginPercent;
  final double profit;
  final double recommendedPrice;
  final double marketFloor;
  final double marketCeiling;
  final String marketContext;

  const PricingResult({
    required this.breakdown,
    required this.marginPercent,
    required this.profit,
    required this.recommendedPrice,
    required this.marketFloor,
    required this.marketCeiling,
    this.marketContext =
        'Based on 42 verified artisan listings in Tamil Nadu & Karnataka cluster.',
  });
}
