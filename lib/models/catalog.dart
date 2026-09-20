class GeneratedCatalog {
  final String title;
  final String titleHindi;
  final String category;
  final String craftTechnique;
  final String material;
  final String origin;
  final String description;
  final List<String> keywords;
  final Map<String, double>? confidence;
  final Map<String, String>? evidence;

  const GeneratedCatalog({
    required this.title,
    this.titleHindi = '',
    required this.category,
    required this.craftTechnique,
    required this.material,
    required this.origin,
    required this.description,
    this.keywords = const [],
    this.confidence,
    this.evidence,
  });

  GeneratedCatalog copyWith({
    String? title,
    String? titleHindi,
    String? category,
    String? craftTechnique,
    String? material,
    String? origin,
    String? description,
    List<String>? keywords,
    Map<String, double>? confidence,
    Map<String, String>? evidence,
  }) {
    return GeneratedCatalog(
      title: title ?? this.title,
      titleHindi: titleHindi ?? this.titleHindi,
      category: category ?? this.category,
      craftTechnique: craftTechnique ?? this.craftTechnique,
      material: material ?? this.material,
      origin: origin ?? this.origin,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
      confidence: confidence ?? this.confidence,
      evidence: evidence ?? this.evidence,
    );
  }
}
