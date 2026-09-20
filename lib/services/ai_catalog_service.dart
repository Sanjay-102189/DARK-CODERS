import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../models/models.dart';
import '../core/constants/demo_data.dart';

class CatalogGenerationResult {
  final GeneratedCatalog catalog;
  final bool isRealAi;
  final String statusMessage;
  final String? technicalDetails;

  const CatalogGenerationResult({
    required this.catalog,
    required this.isRealAi,
    required this.statusMessage,
    this.technicalDetails,
  });
}

typedef GeminiContentGenerator = Future<String?> Function(List<Part> parts);

class AiCatalogService {
  // Supported Firebase AI Logic Gemini 3.x Flash multimodal model for catalog understanding
  static const String geminiModel = 'gemini-3.7-flash';

  /// Classifies whether an error encountered during Gemini catalog generation is transient.
  /// Transient failures (server 5xx, high-demand spikes, network timeouts) are retried.
  /// Obvious permanent/user errors (invalid keys, unsupported location/content) are never retried.
  static bool isTransientError(Object error) {
    if (error is InvalidApiKey ||
        error is UnsupportedUserLocation ||
        error is ServiceApiNotEnabled ||
        error is FormatException ||
        error is ArgumentError) {
      return false;
    }

    final errStr = error.toString().toLowerCase();

    // Permanent / non-retryable error markers
    if (errStr.contains('api_key_invalid') ||
        errStr.contains('invalid api key') ||
        errStr.contains('unsupported location') ||
        errStr.contains('permission_denied') ||
        errStr.contains('permission denied') ||
        errStr.contains('not enabled') ||
        errStr.contains('invalid argument') ||
        errStr.contains('unsupported content') ||
        errStr.contains('bad request') ||
        errStr.contains('400') ||
        errStr.contains('401') ||
        errStr.contains('403') ||
        errStr.contains('404')) {
      return false;
    }

    // Explicit FirebaseAI ServerException
    if (error is ServerException) {
      return true;
    }

    // High demand, transient server 5xx, service unavailable, rate limits, network timeouts
    if (error is QuotaExceeded ||
        errStr.contains('500') ||
        errStr.contains('502') ||
        errStr.contains('503') ||
        errStr.contains('504') ||
        errStr.contains('server error') ||
        errStr.contains('high demand') ||
        errStr.contains('spikes in demand') ||
        errStr.contains('service unavailable') ||
        errStr.contains('temporarily unavailable') ||
        errStr.contains('deadline exceeded') ||
        errStr.contains('try again later') ||
        errStr.contains('resource_exhausted') ||
        errStr.contains('socketexception') ||
        errStr.contains('clientexception') ||
        errStr.contains('timeoutexception') ||
        errStr.contains('timed out') ||
        errStr.contains('connection closed') ||
        errStr.contains('connection reset') ||
        errStr.contains('network failure')) {
      return true;
    }

    if (error is FirebaseAIException) {
      return errStr.contains('server') || errStr.contains('unavailable') || errStr.contains('demand');
    }

    return false;
  }

  /// Detects MIME type from byte signatures (magic numbers).
  static String detectMimeType(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return 'image/jpeg';
    // JPEG: 0xFF 0xD8 0xFF
    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    // PNG: 0x89 0x50 0x4E 0x47 0x0D 0x0A 0x1A 0x0A
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    }
    // WebP: RIFF ... WEBP
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  /// Generates a structured bilingual catalog from image bytes and artisan context.
  /// Uses Firebase AI Logic with Gemini when Firebase is configured.
  /// Includes bounded automatic retry (up to 3 attempts) for transient failures (5xx, high demand, timeouts).
  /// For real images, never silently returns hardcoded demo data on failure.
  Future<CatalogGenerationResult> generateCatalog({
    required Uint8List? imageBytes,
    required String selectedLanguage,
    String? voiceTranscript,
    bool isRealImage = true,
    void Function(String statusMessage)? onStatusUpdate,
    GeminiContentGenerator? contentGenerator,
    List<Duration>? customRetryDelays,
  }) async {
    debugPrint('[AI_CATALOG] START');
    final hasRealImage = (imageBytes != null && imageBytes.isNotEmpty) || isRealImage;
    final mimeType = detectMimeType(imageBytes);
    debugPrint('[AI_CATALOG] Real image bytes: ${imageBytes?.length ?? 0}');
    debugPrint('[AI_CATALOG] MIME: $mimeType');
    debugPrint('[AI_CATALOG] Voice transcript: ${voiceTranscript ?? "(none)"}');

    // Check if Firebase is initialized
    bool isFirebaseAvailable = false;
    try {
      if (Firebase.apps.isNotEmpty) {
        isFirebaseAvailable = true;
      }
    } catch (_) {
      isFirebaseAvailable = false;
    }

    if (!isFirebaseAvailable && contentGenerator == null) {
      debugPrint('[AI_CATALOG] Firebase is not initialized.');
      if (hasRealImage) {
        debugPrint('[AI_CATALOG] GEMINI FAILED: Firebase not initialized.');
        debugPrint('[AI_CATALOG] DEMO FALLBACK BLOCKED FOR REAL IMAGE');
        throw FirebaseAIException("AI couldn't analyze the product right now. Please try again.");
      }
      return buildFallbackResult(
        selectedLanguage: selectedLanguage,
        voiceTranscript: voiceTranscript,
        reason: 'Firebase AI Logic is ready in code, but requires project configuration. Continuing with verified craft fallback.',
      );
    }

    // Build prompt with domain-specific rules
    final prompt = _buildMultimodalPrompt(
      selectedLanguage: selectedLanguage,
      voiceTranscript: voiceTranscript,
    );

    // Multimodal input: Visual evidence leading, followed by structured instructions
    final List<Part> parts = [];
    if (imageBytes != null && imageBytes.isNotEmpty) {
      parts.add(InlineDataPart(mimeType, imageBytes));
    }
    parts.add(TextPart(prompt));

    const maxAttempts = 3;
    final delays = customRetryDelays ?? const [Duration(seconds: 1), Duration(seconds: 2)];
    Object? lastError;
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;
      debugPrint('[AI_CATALOG] Attempt $attempt/$maxAttempts');
      debugPrint('[AI_CATALOG] Gemini request started with model: $geminiModel');

      if (attempt == 1) {
        onStatusUpdate?.call('Analyzing with Gemini AI…');
      }

      try {
        String? rawText;
        if (contentGenerator != null) {
          rawText = await contentGenerator(parts);
        } else {
          final model = FirebaseAI.googleAI().generativeModel(
            model: geminiModel,
            generationConfig: GenerationConfig(
              responseMimeType: 'application/json',
              temperature: 0.2,
            ),
          );
          final response = await model.generateContent([Content.multi(parts)]);
          rawText = response.text;
        }

        debugPrint('[AI_CATALOG] Gemini response received');

        if (rawText != null && rawText.trim().isNotEmpty) {
          final parsedCatalog = parseStructuredJson(rawText, selectedLanguage);
          debugPrint('[AI_CATALOG] JSON parsed');
          debugPrint('[AI_CATALOG] Product detected: ${parsedCatalog.title}');

          // Consistency check for obvious contradictions (e.g. pottery for handkerchief)
          final inconsistency = validateConsistency(
            parsedCatalog,
            imageBytes: imageBytes,
            voiceTranscript: voiceTranscript,
          );
          if (inconsistency != null) {
            debugPrint('[AI_CATALOG] Semantic consistency check failed: $inconsistency');
            throw FormatException(inconsistency);
          }

          if (attempt > 1) {
            debugPrint('[AI_CATALOG] AI SUCCESS on attempt $attempt');
          } else {
            debugPrint('[AI_CATALOG] AI SUCCESS');
          }

          return CatalogGenerationResult(
            catalog: parsedCatalog,
            isRealAi: true,
            statusMessage: 'Generated via $geminiModel',
            technicalDetails: null,
          );
        } else {
          throw FirebaseAIException('Empty response received from Gemini.');
        }
      } catch (e) {
        lastError = e;

        if (e is FormatException && e.message.contains('inconsistent')) {
          rethrow;
        }

        final transient = isTransientError(e);
        if (transient && attempt < maxAttempts) {
          final delay = (attempt - 1 < delays.length) ? delays[attempt - 1] : const Duration(seconds: 2);
          debugPrint('[AI_CATALOG] Attempt $attempt/$maxAttempts failed: transient server error');
          debugPrint('[AI_CATALOG] Retrying in ${delay.inSeconds}s');
          onStatusUpdate?.call('Gemini is busy. Retrying…');
          if (delay > Duration.zero) {
            await Future.delayed(delay);
          }
          continue;
        } else {
          if (transient) {
            debugPrint('[AI_CATALOG] Attempt $attempt/$maxAttempts failed: transient server error');
            debugPrint('[AI_CATALOG] Gemini failed after $maxAttempts attempts');
          } else {
            debugPrint('[AI_CATALOG] Attempt $attempt/$maxAttempts failed: $e');
          }
          break;
        }
      }
    }

    // Request failed or returned empty
    debugPrint('[AI_CATALOG] GEMINI FAILED');
    debugPrint('[AI_CATALOG] error=$lastError');

    if (hasRealImage) {
      debugPrint('[AI_CATALOG] DEMO FALLBACK BLOCKED FOR REAL IMAGE');
      throw FirebaseAIException("AI couldn't analyze the product right now. Please try again.");
    }

    debugPrint('[AI_CATALOG] Using demo fallback for non-real image mode.');
    return buildFallbackResult(
      selectedLanguage: selectedLanguage,
      voiceTranscript: voiceTranscript,
      reason: 'Gemini request could not complete: $lastError',
    );
  }

  /// System prompt strictly enforcing domain rules and required JSON schema.
  String _buildMultimodalPrompt({
    required String selectedLanguage,
    required String? voiceTranscript,
  }) {
    return '''
You are CraftMitra AI — an expert Indian artisan product cataloging assistant.
Analyze the ACTUAL ATTACHED PRODUCT PHOTOGRAPH first, supplemented by the artisan's voice transcript if provided.

CRITICAL INSTRUCTIONS & DOMAIN RULES:
1. Identify what is VISIBLY PRESENT in the image.
2. NEVER assume the product is pottery.
3. NEVER assume the product is textile.
4. NEVER assume material unless visual evidence or artisan voice supports it.
5. NEVER invent:
   - location
   - material
   - craft technique
   - artisan name
   - certification
   - heritage claim
   - dimensions
   - price
6. If something cannot be determined from the image or voice:
   Return "Not specified" or an appropriate uncertain value.
7. The uploaded image has higher priority than any default assumptions.
8. Artisan voice input supplements visual analysis:
   - If image and voice disagree: prefer observable visual evidence for product type; use artisan voice for material, location, traditional name, and details that cannot be visually determined.
   - Do not blindly combine contradictory information.
9. Support Indian languages (e.g. Tamil, Hindi, English, Tanglish, Hinglish):
   - Understand the artisan's spoken meaning.
   - For customer-facing "description" and "title", provide clean, fluent English suitable for e-commerce.
   - If target interface language is Hindi or Tamil, also provide the localized title in "hindiTitle".
10. Description must be factual and concise (2-4 sentences) written from an objective marketplace perspective.
11. NEVER mention AI, Gemini, prompt, transcript, model, or internal processing in the description.
12. NEVER output labels or conversational prefixes such as:
    - "Voice input from artisan:"
    - "Transcript:"
    - "Based on image:"
    - "According to the artisan"
13. Generate 3-5 useful e-commerce keywords/hashtags.
14. Output ONLY valid JSON matching this schema:

{
  "title": "Clean, concise English product title (e.g. Handwoven Checkered Cotton Handkerchief)",
  "hindiTitle": "हिन्दी या स्थानीय भाषा में शीर्षक (e.g. हथकरघा सूती रुमाल)",
  "description": "2-4 factual, polished e-commerce sentences describing the handcrafted item.",
  "category": "e.g. Apparel & Textiles, Kitchenware, Home Decor, Jewelry, Art & Collectibles",
  "craftTechnique": "e.g. Handloom Weaving, Block Printing, Wood Carving, or Not specified",
  "material": "e.g. Pure Cotton, Silk, Teak Wood, Brass, or Not specified",
  "origin": "e.g. Salem, Tamil Nadu, India, or Not specified",
  "keywords": ["#tag1", "#tag2", "#tag3", "#tag4"],
  "confidence": {
    "product": 0.95,
    "material": 0.85,
    "technique": 0.80,
    "origin": 0.50
  },
  "evidence": {
    "product": "Visual evidence of checkered fabric in photograph",
    "material": "Artisan voice specified pure cotton",
    "technique": "Observed handloom border finish",
    "origin": "Unavailable"
  }
}

Context Details:
- Target Interface Language: $selectedLanguage
- Artisan Spoken Description: ${voiceTranscript != null && voiceTranscript.trim().isNotEmpty ? voiceTranscript.trim() : "None provided; analyze image visual evidence directly."}
''';
  }

  /// Semantic consistency check between input context and generated catalog.
  /// Prevents presenting hallucinated catalog data (such as pottery on textile input).
  static String? validateConsistency(
    GeneratedCatalog catalog, {
    Uint8List? imageBytes,
    String? voiceTranscript,
  }) {
    if (voiceTranscript != null && voiceTranscript.isNotEmpty) {
      final vt = voiceTranscript.toLowerCase();
      final catTitle = catalog.title.toLowerCase();
      final catMat = catalog.material.toLowerCase();
      final catTech = catalog.craftTechnique.toLowerCase();
      final catCategory = catalog.category.toLowerCase();

      final isTextileVoice = vt.contains('handkerchief') ||
          vt.contains('cotton') ||
          vt.contains('cloth') ||
          vt.contains('textile') ||
          vt.contains('saree') ||
          vt.contains('dupatta') ||
          vt.contains('shawl') ||
          vt.contains('fabric') ||
          vt.contains('silk') ||
          vt.contains('பருத்தி') || // cotton in Tamil
          vt.contains('கைக்குட்டை') || // handkerchief in Tamil
          vt.contains('துணி') || // cloth in Tamil
          vt.contains('साड़ी') ||
          vt.contains('कपड़ा');

      final isPotteryResult = catTitle.contains('pottery') ||
          catTitle.contains('terracotta') ||
          catMat.contains('clay') ||
          catMat.contains('terracotta') ||
          catTech.contains('wheel pottery') ||
          catCategory.contains('pottery');

      if (isTextileVoice && isPotteryResult) {
        return 'AI result looks inconsistent with the product image. Please retry.';
      }

      final isPotteryVoice = vt.contains('pottery') ||
          vt.contains('clay') ||
          vt.contains('terracotta') ||
          vt.contains('kulhar') ||
          vt.contains('diya') ||
          vt.contains('मिट्टी') ||
          vt.contains('மண்பாண்டம்');

      final isTextileResult = catCategory.contains('apparel') ||
          catCategory.contains('textile') ||
          catMat.contains('cotton') ||
          catMat.contains('silk') ||
          catTech.contains('handloom') ||
          catTech.contains('weaving');

      if (isPotteryVoice && isTextileResult) {
        return 'AI result looks inconsistent with the product image. Please retry.';
      }
    }
    return null;
  }

  /// Defensively sanitizes AI-generated or fallback descriptions to eliminate conversational labels.
  static String sanitizeDescription(String rawDescription) {
    if (rawDescription.isEmpty) return '';

    String cleaned = rawDescription.trim();

    // Regex pattern matching unwanted label prefixes at start of text
    final prefixPatterns = [
      RegExp(
        r'^(?:(?:Voice\s*input(?:\s*from\s*(?:the\s*)?artisan)?)|Artisan\s*(?:spoken\s*description|input|said|voice)|User\s*input|Transcript|Based\s*on\s*(?:voice\s*input|artisan\s*(?:spoken\s*)?description|the\s*transcript)|According\s*to\s*(?:the\s*artisan|artisan|voice))\s*[:=–-]\s*',
        caseSensitive: false,
      ),
      RegExp(
        r'^(?:Voice\s*input\s*(?:from\s*(?:the\s*)?artisan)?)\s*[:=–-]?\s*',
        caseSensitive: false,
      ),
    ];

    bool matched = true;
    while (matched) {
      matched = false;
      for (final pattern in prefixPatterns) {
        if (pattern.hasMatch(cleaned)) {
          cleaned = cleaned.replaceFirst(pattern, '').trim();
          matched = true;
        }
      }
    }

    // Strip wrapping quotation marks
    if ((cleaned.startsWith('"') && cleaned.endsWith('"')) ||
        (cleaned.startsWith('“') && cleaned.endsWith('”')) ||
        (cleaned.startsWith("'") && cleaned.endsWith("'"))) {
      if (cleaned.length >= 2) {
        cleaned = cleaned.substring(1, cleaned.length - 1).trim();
      }
    }

    // Replace first-person opening phrases if any slipped through
    final firstPersonPattern = RegExp(
      r'^(?:I\s+(?:have\s+)?made|We\s+(?:have\s+)?made)\s+(?:this\s+)?',
      caseSensitive: false,
    );
    if (firstPersonPattern.hasMatch(cleaned)) {
      cleaned = cleaned.replaceFirst(firstPersonPattern, 'Handcrafted ').trim();
    }

    return cleaned;
  }

  /// Defensively sanitizes title fields
  static String sanitizeTitle(String rawTitle) {
    if (rawTitle.isEmpty) return 'Handcrafted Artisan Product';
    String cleaned = rawTitle.trim();
    final prefixPatterns = [
      RegExp(r'^(?:Product\s*Title|Title)\s*[:=–-]\s*', caseSensitive: false),
    ];
    for (final pattern in prefixPatterns) {
      cleaned = cleaned.replaceFirst(pattern, '').trim();
    }
    if ((cleaned.startsWith('"') && cleaned.endsWith('"')) ||
        (cleaned.startsWith('“') && cleaned.endsWith('”')) ||
        (cleaned.startsWith("'") && cleaned.endsWith("'"))) {
      if (cleaned.length >= 2) {
        cleaned = cleaned.substring(1, cleaned.length - 1).trim();
      }
    }
    return cleaned.isNotEmpty ? cleaned : 'Handcrafted Artisan Product';
  }

  /// Robust JSON parsing supporting code fences, extra text, and new schema fields.
  GeneratedCatalog parseStructuredJson(String jsonString, [String selectedLanguage = 'en']) {
    try {
      String clean = jsonString.trim();
      // Handle markdown code fences with optional preamble/postscript
      final fenceMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(clean);
      if (fenceMatch != null && fenceMatch.group(1) != null) {
        clean = fenceMatch.group(1)!.trim();
      } else {
        // If not in a code fence, extract substring from first '{' to last '}'
        final startIdx = clean.indexOf('{');
        final endIdx = clean.lastIndexOf('}');
        if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
          clean = clean.substring(startIdx, endIdx + 1);
        }
      }

      final Map<String, dynamic> data = jsonDecode(clean);

      final keywordsRaw = data['keywords'] ?? data['tags'];
      final List<String> keywords = [];
      if (keywordsRaw is List) {
        for (var k in keywordsRaw) {
          final kwStr = k.toString().trim();
          if (kwStr.isNotEmpty) {
            keywords.add(kwStr.startsWith('#') ? kwStr : '#$kwStr');
          }
        }
      }

      final rawTitle = data['title']?.toString() ??
          data['productTitle']?.toString() ??
          'Handcrafted Artisan Product';
      final cleanTitle = sanitizeTitle(rawTitle);

      final rawHindi = data['hindiTitle']?.toString() ??
          data['titleHindi']?.toString() ??
          '';
      final cleanHindi = sanitizeTitle(rawHindi);

      final rawDesc = data['description']?.toString() ??
          data['desc']?.toString() ??
          'Authentic Indian handcrafted creation preserving regional artistic traditions.';
      final cleanDesc = sanitizeDescription(rawDesc);

      final rawTechnique = data['craftTechnique']?.toString() ??
          data['technique']?.toString() ??
          'Not specified';
      final cleanTechnique = sanitizeTitle(rawTechnique);

      final rawMaterial = data['material']?.toString() ?? 'Not specified';
      final cleanMaterial = sanitizeTitle(rawMaterial);

      final rawCategory = data['category']?.toString() ?? 'Handicrafts';
      final cleanCategory = sanitizeTitle(rawCategory);

      final rawOrigin = data['origin']?.toString() ?? 'Not specified';
      final cleanOrigin = sanitizeTitle(rawOrigin);

      // Parse confidence map
      Map<String, double>? parsedConfidence;
      final rawConfidence = data['confidence'];
      if (rawConfidence is Map) {
        parsedConfidence = {};
        for (final entry in rawConfidence.entries) {
          final key = entry.key.toString();
          final val = (entry.value as num?)?.toDouble() ?? 0.0;
          parsedConfidence[key] = val.clamp(0.0, 1.0);
        }
      }

      // Parse evidence map
      Map<String, String>? parsedEvidence;
      final rawEvidence = data['evidence'];
      if (rawEvidence is Map) {
        parsedEvidence = {};
        for (final entry in rawEvidence.entries) {
          parsedEvidence[entry.key.toString()] = entry.value.toString();
        }
      }

      return GeneratedCatalog(
        title: cleanTitle,
        titleHindi: cleanHindi,
        category: cleanCategory,
        craftTechnique: cleanTechnique,
        material: cleanMaterial,
        origin: cleanOrigin,
        description: cleanDesc.isNotEmpty
            ? cleanDesc
            : 'Authentic Indian handcrafted creation preserving regional artistic traditions.',
        keywords: keywords.isNotEmpty
            ? keywords
            : ['#handcrafted', '#indianartisan', '#craftmitra'],
        confidence: parsedConfidence,
        evidence: parsedEvidence,
      );
    } catch (e) {
      debugPrint('[AI_CATALOG] JSON parse error: $e.');
      rethrow;
    }
  }

  /// Generates a verified fallback catalog for explicit demo mode only.
  CatalogGenerationResult buildFallbackResult({
    required String selectedLanguage,
    required String? voiceTranscript,
    required String reason,
    String artisanCraft = 'Traditional Indian Craft',
    String artisanLocation = 'India',
  }) {
    debugPrint('[AI_CATALOG] Generating clean fallback catalog. Reason: $reason');

    GeneratedCatalog base = DemoData.demoCatalog;

    if (voiceTranscript != null && voiceTranscript.trim().isNotEmpty) {
      final t = voiceTranscript.toLowerCase();

      String detectedCategory = 'Home Decor';
      String detectedMaterial = 'Natural River Clay';
      String detectedTechnique = 'Wheel Pottery';
      String detectedItem = 'Terracotta Pottery';
      String detectedItemHindi = 'टेराकोटा मिट्टी उत्पाद';

      if (t.contains('kulhar') || t.contains('cup') || t.contains('कुल्हड़')) {
        detectedCategory = 'Kitchenware';
        detectedMaterial = 'Natural River Clay';
        detectedTechnique = 'Wheel Pottery';
        detectedItem = 'Terracotta Kulhar Set';
        detectedItemHindi = 'टेराकोटा कुल्हड़ सेट';
      } else if (t.contains('diya') || t.contains('lamp') || t.contains('दीया') || t.contains('दीपक')) {
        detectedCategory = 'Festive Decor';
        detectedMaterial = 'Natural Clay';
        detectedTechnique = 'Hand Molding';
        detectedItem = 'Clay Festive Diya';
        detectedItemHindi = 'पारंपरिक मिट्टी का दीया';
      } else if (t.contains('brass') || t.contains('dhokra') || t.contains('bell metal') || t.contains('पीतल') || t.contains('कांसा')) {
        detectedCategory = 'Art & Collectibles';
        detectedMaterial = 'Brass / Bell Metal';
        detectedTechnique = 'Lost-wax Casting';
        detectedItem = 'Brass Dhokra Artifact';
        detectedItemHindi = 'पीतल ढोकरा कलाकृति';
      } else if (t.contains('wood') || t.contains('wooden') || t.contains('लकड़ी')) {
        detectedCategory = 'Home Decor';
        detectedMaterial = 'Carved Teak Wood';
        detectedTechnique = 'Hand Carving';
        detectedItem = 'Hand-carved Woodcraft';
        detectedItemHindi = 'नक्काशीदार काष्ठशिल्प';
      } else if (t.contains('textile') ||
          t.contains('saree') ||
          t.contains('shawl') ||
          t.contains('dupatta') ||
          t.contains('cotton') ||
          t.contains('silk') ||
          t.contains('handkerchief') ||
          t.contains('பருத்தி') ||
          t.contains('கைக்குட்டை') ||
          t.contains('साड़ी') ||
          t.contains('खादी')) {
        detectedCategory = 'Apparel & Textiles';
        detectedMaterial = 'Pure Handspun Cotton';
        detectedTechnique = 'Handloom Weaving';
        detectedItem = 'Handwoven Cotton Creation';
        detectedItemHindi = 'हथकरघा सूती वस्त्र';
      } else if (t.contains('pot') || t.contains('vase') || t.contains('clay') || t.contains('terracotta') || t.contains('घड़ा') || t.contains('फूलदान') || t.contains('मिट्टी')) {
        detectedCategory = 'Home Decor';
        detectedMaterial = 'Natural River Clay';
        detectedTechnique = 'Wheel Pottery';
        detectedItem = 'Terracotta Pottery';
        detectedItemHindi = 'टेराकोटा मिट्टी उत्पाद';
      }

      final cleanDescription =
          'Authentic handcrafted $detectedItem made using traditional artisanal techniques. '
          'Carefully formed with $detectedMaterial for lasting durability, fine texture, and a distinctive heritage aesthetic suitable for home decor and everyday utility.';

      base = GeneratedCatalog(
        title: 'Handcrafted $detectedItem',
        titleHindi: 'हस्तनिर्मित $detectedItemHindi',
        category: detectedCategory,
        craftTechnique: detectedTechnique,
        material: detectedMaterial,
        origin: artisanLocation,
        description: sanitizeDescription(cleanDescription),
        keywords: [
          '#handcrafted',
          '#indianartisan',
          '#${detectedCategory.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase()}',
          '#traditionalcraft',
        ],
        confidence: {
          'product': 0.75,
          'material': 0.70,
          'technique': 0.65,
          'origin': 0.50,
        },
        evidence: {
          'product': 'Derived from artisan voice keywords',
          'material': 'Identified from spoken description',
          'technique': 'Traditional craft association',
          'origin': 'Default craft region',
        },
      );
    }

    return CatalogGenerationResult(
      catalog: base,
      isRealAi: false,
      statusMessage: 'Verified Craft Catalog (Fallback)',
      technicalDetails: reason,
    );
  }
}
