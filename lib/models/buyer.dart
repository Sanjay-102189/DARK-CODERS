class Buyer {
  final String id;
  final String name;
  final String location;
  final String state;
  final double distanceKm;
  final int matchPercent;
  final double rating;
  final int completedOrders;
  final String requirement;
  final String budgetRange;
  final String imageUrl;
  final bool isVerified;
  final String verificationLabel;
  final List<String> matchReasons;

  // Dynamic matching attributes
  final List<String> preferredCategories;
  final List<String> preferredMaterials;
  final List<String> preferredTechniques;
  final double minBudget;
  final double maxBudget;
  final int minQuantity;
  final int maxQuantity;
  final String region;

  const Buyer({
    required this.id,
    required this.name,
    required this.location,
    required this.state,
    this.distanceKm = 0,
    required this.matchPercent,
    this.rating = 0,
    this.completedOrders = 0,
    this.requirement = '',
    this.budgetRange = '',
    this.imageUrl = '',
    this.isVerified = true,
    this.verificationLabel = 'Verified Enterprise',
    this.matchReasons = const [],
    this.preferredCategories = const [],
    this.preferredMaterials = const [],
    this.preferredTechniques = const [],
    this.minBudget = 0,
    this.maxBudget = 0,
    this.minQuantity = 0,
    this.maxQuantity = 0,
    this.region = '',
  });

  Buyer copyWith({
    String? id,
    String? name,
    String? location,
    String? state,
    double? distanceKm,
    int? matchPercent,
    double? rating,
    int? completedOrders,
    String? requirement,
    String? budgetRange,
    String? imageUrl,
    bool? isVerified,
    String? verificationLabel,
    List<String>? matchReasons,
    List<String>? preferredCategories,
    List<String>? preferredMaterials,
    List<String>? preferredTechniques,
    double? minBudget,
    double? maxBudget,
    int? minQuantity,
    int? maxQuantity,
    String? region,
  }) {
    return Buyer(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      state: state ?? this.state,
      distanceKm: distanceKm ?? this.distanceKm,
      matchPercent: matchPercent ?? this.matchPercent,
      rating: rating ?? this.rating,
      completedOrders: completedOrders ?? this.completedOrders,
      requirement: requirement ?? this.requirement,
      budgetRange: budgetRange ?? this.budgetRange,
      imageUrl: imageUrl ?? this.imageUrl,
      isVerified: isVerified ?? this.isVerified,
      verificationLabel: verificationLabel ?? this.verificationLabel,
      matchReasons: matchReasons ?? this.matchReasons,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      preferredMaterials: preferredMaterials ?? this.preferredMaterials,
      preferredTechniques: preferredTechniques ?? this.preferredTechniques,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      region: region ?? this.region,
    );
  }
}
