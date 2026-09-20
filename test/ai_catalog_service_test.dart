import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:craftmitra/services/ai_catalog_service.dart';
import 'package:craftmitra/models/models.dart';
import 'package:craftmitra/core/constants/demo_data.dart';

void main() {
  group('AiCatalogService - Real AI Catalog Generation & Quality Tests', () {
    final service = AiCatalogService();

    test('1. Parses clean JSON response with standard keys and clean description', () {
      const jsonStr = '''
      {
        "productTitle": "Handmade Blue Pottery Vase",
        "hindiTitle": "हस्तनिर्मित ब्लू पॉटरी फूलदान",
        "category": "Home Decor",
        "technique": "Quartz Stone Powder Wheel Glaze",
        "material": "Blue Pottery / Quartz",
        "origin": "Jaipur, Rajasthan, India",
        "description": "Authentic Jaipur blue pottery vase with vibrant cobalt floral motifs. Crafted by skilled artisans to enhance living spaces with traditional elegance.",
        "keywords": ["#bluepottery", "#jaipur", "#handcrafted"]
      }
      ''';

      final catalog = service.parseStructuredJson(jsonStr);

      expect(catalog.title, equals('Handmade Blue Pottery Vase'));
      expect(catalog.titleHindi, equals('हस्तनिर्मित ब्लू पॉटरी फूलदान'));
      expect(catalog.category, equals('Home Decor'));
      expect(catalog.craftTechnique, equals('Quartz Stone Powder Wheel Glaze'));
      expect(catalog.material, equals('Blue Pottery / Quartz'));
      expect(catalog.origin, equals('Jaipur, Rajasthan, India'));
      expect(catalog.description, contains('Authentic Jaipur blue pottery vase'));
      expect(catalog.description, isNot(contains('Voice input')));
      expect(catalog.description, isNot(contains('Transcript:')));
      expect(catalog.keywords, equals(['#bluepottery', '#jaipur', '#handcrafted']));
    });

    test('2. Parses markdown-fenced JSON with preamble and postscript', () {
      const fencedResponse = '''
      Here is your structured catalog JSON:
      ```json
      {
        "productTitle": "Terracotta Chai Kulhar Set",
        "hindiTitle": "टेराकोटा कुल्हड़ सेट",
        "category": "Kitchenware",
        "technique": "Hand-turned on potter wheel",
        "material": "Natural Clay",
        "origin": "Alwar, Rajasthan, India",
        "description": "Eco-friendly clay tea cups bringing traditional earthy aroma to every sip. Handcrafted for everyday durability and authentic taste.",
        "keywords": ["kulhar", "terracotta", "artisan"]
      }
      ```
      Hope this helps!
      ''';

      final catalog = service.parseStructuredJson(fencedResponse);

      expect(catalog.title, equals('Terracotta Chai Kulhar Set'));
      expect(catalog.titleHindi, equals('टेराकोटा कुल्हड़ सेट'));
      expect(catalog.category, equals('Kitchenware'));
      expect(catalog.keywords, equals(['#kulhar', '#terracotta', '#artisan']));
    });

    test('3. Supports existing aliases (title, titleHindi, craftTechnique, tags)', () {
      const altJson = '''
      {
        "title": "Brass Dhokra Figurine",
        "titleHindi": "पीतल ढोकरा मूर्ति",
        "category": "Art & Collectibles",
        "craftTechnique": "Lost-wax casting",
        "material": "Bell Metal / Brass",
        "origin": "Bastar, Chhattisgarh, India",
        "description": "Tribal lost-wax cast artifact depicting regional folk deities.",
        "tags": ["dhokra", "tribalart", "brass"]
      }
      ''';

      final catalog = service.parseStructuredJson(altJson);

      expect(catalog.title, equals('Brass Dhokra Figurine'));
      expect(catalog.titleHindi, equals('पीतल ढोकरा मूर्ति'));
      expect(catalog.craftTechnique, equals('Lost-wax casting'));
      expect(catalog.keywords, equals(['#dhokra', '#tribalart', '#brass']));
    });

    test('4. Sanitizes description containing "Voice input from the artisan = "', () {
      const dirtyJson = '''
      {
        "productTitle": "Handmade Clay Pot",
        "hindiTitle": "मिट्टी का घड़ा",
        "category": "Kitchenware",
        "technique": "Wheel Pottery",
        "material": "Natural Clay",
        "origin": "Alwar, Rajasthan",
        "description": "Voice input from the artisan = Handcrafted clay pot made using traditional pottery techniques. Natural brown finish suited for home decor.",
        "keywords": ["#clay", "#pot"]
      }
      ''';

      final catalog = service.parseStructuredJson(dirtyJson);

      expect(catalog.description, isNot(contains('Voice input from the artisan')));
      expect(catalog.description, isNot(contains('=')));
      expect(catalog.description, startsWith('Handcrafted clay pot made using traditional pottery techniques'));
    });

    test('5. Sanitizes description containing "Transcript:" or "Based on voice input:"', () {
      final sanitized1 = AiCatalogService.sanitizeDescription(
        'Transcript: Beautiful terracotta vase hand-molded by local artisans.',
      );
      expect(sanitized1, equals('Beautiful terracotta vase hand-molded by local artisans.'));

      final sanitized2 = AiCatalogService.sanitizeDescription(
        'Based on voice input: Traditional brass lamp with intricate floral etchings.',
      );
      expect(sanitized2, equals('Traditional brass lamp with intricate floral etchings.'));

      final sanitized3 = AiCatalogService.sanitizeDescription(
        'According to the artisan: Hand-carved wooden elephant artifact.',
      );
      expect(sanitized3, equals('Hand-carved wooden elephant artifact.'));
    });

    test('6. Sanitizes quotes and first-person colloquial openings', () {
      final sanitized = AiCatalogService.sanitizeDescription(
        '"I made this terracotta kulhar set using clean river clay and wood kiln firing."',
      );
      expect(sanitized, isNot(contains('I made')));
      expect(sanitized, startsWith('Handcrafted terracotta kulhar set'));
      expect(sanitized, isNot(startsWith('"')));
      expect(sanitized, isNot(endsWith('"')));
    });

    test('7. Fallback catalog produces a clean, professional description and NEVER embeds raw transcript verbatim', () {
      const rawTranscript = 'This is handmade clay pot. I made it using traditional pottery techniques. Naan traditional pottery method la panniruken.';
      final result = service.buildFallbackResult(
        selectedLanguage: 'en',
        voiceTranscript: rawTranscript,
        reason: 'Network timeout',
      );

      expect(result.isRealAi, isFalse);
      expect(result.statusMessage, contains('Verified Craft Catalog'));
      expect(result.catalog.title, contains('Terracotta'));
      // Must NOT contain verbatim transcript
      expect(result.catalog.description, isNot(contains(rawTranscript)));
      expect(result.catalog.description, isNot(contains('panniruken')));
      expect(result.catalog.description, isNot(contains('Voice input')));
      expect(result.catalog.description, isNot(contains('Artisan spoken description')));
      expect(result.catalog.description, isNot(contains('Based on')));
      // Must be professional e-commerce description
      expect(result.catalog.description, contains('Authentic handcrafted'));
      expect(result.catalog.description, contains('traditional artisanal techniques'));
    });

    test('8. Multilingual / mixed-language input does not become the raw transcript in description', () {
      const tanglishSpeech = 'Idhu handmade clay pot. Naan traditional pottery method la panniruken.';
      final result = service.buildFallbackResult(
        selectedLanguage: 'en',
        voiceTranscript: tanglishSpeech,
        reason: 'Gemini offline',
      );

      expect(result.catalog.description, isNot(contains('Idhu')));
      expect(result.catalog.description, isNot(contains('panniruken')));
      expect(result.catalog.description, contains('Authentic handcrafted'));
    });

    test('9. Fallback uses default DemoData catalog when no voice transcript is provided', () {
      final result = service.buildFallbackResult(
        selectedLanguage: 'en',
        voiceTranscript: null,
        reason: 'Firebase offline',
      );

      expect(result.isRealAi, isFalse);
      expect(result.catalog.title, equals(DemoData.demoCatalog.title));
      expect(result.catalog.description, equals(DemoData.demoCatalog.description));
    });

    test('10. Malformed JSON throws for caller to handle and retry', () {
      const brokenJson = '{ "productTitle": "Incomplete json...';
      expect(() => service.parseStructuredJson(brokenJson), throwsA(isA<Object>()));
    });

    test('11. Detects MIME types accurately from byte signatures (JPEG, PNG, WebP)', () {
      final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00]);
      final pngBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
      final webpBytes = Uint8List.fromList([
        0x52, 0x49, 0x46, 0x46, 0x00, 0x00, 0x00, 0x00, 0x57, 0x45, 0x42, 0x50
      ]);
      final randomBytes = Uint8List.fromList([0x01, 0x02, 0x03]);

      expect(AiCatalogService.detectMimeType(jpegBytes), equals('image/jpeg'));
      expect(AiCatalogService.detectMimeType(pngBytes), equals('image/png'));
      expect(AiCatalogService.detectMimeType(webpBytes), equals('image/webp'));
      expect(AiCatalogService.detectMimeType(randomBytes), equals('image/jpeg'));
      expect(AiCatalogService.detectMimeType(null), equals('image/jpeg'));
    });

    test('12. Parses required Gemini schema with confidence scores and evidence fields', () {
      const schemaJson = '''
      {
        "title": "Handwoven Checkered Cotton Handkerchief",
        "hindiTitle": "हथकरघा सूती रुमाल",
        "description": "Premium soft cotton handkerchief with checkered artisan patterns.",
        "category": "Apparel & Textiles",
        "craftTechnique": "Handloom Weaving",
        "material": "Pure Cotton",
        "origin": "Salem, Tamil Nadu, India",
        "keywords": ["#cotton", "#handkerchief", "#handloom"],
        "confidence": {
          "product": 0.95,
          "material": 0.90,
          "technique": 0.85,
          "origin": 0.60
        },
        "evidence": {
          "product": "Visual fabric weave pattern in photograph",
          "material": "Spoken description specified cotton",
          "technique": "Visual handloom edge texture",
          "origin": "Artisan workshop location"
        }
      }
      ''';

      final catalog = service.parseStructuredJson(schemaJson);

      expect(catalog.title, equals('Handwoven Checkered Cotton Handkerchief'));
      expect(catalog.category, equals('Apparel & Textiles'));
      expect(catalog.material, equals('Pure Cotton'));
      expect(catalog.craftTechnique, equals('Handloom Weaving'));
      expect(catalog.confidence?['product'], equals(0.95));
      expect(catalog.confidence?['material'], equals(0.90));
      expect(catalog.evidence?['product'], contains('Visual fabric weave'));
      expect(catalog.evidence?['material'], contains('Spoken description'));
    });

    test('13. Semantic consistency validator catches pottery claims on textile/handkerchief inputs', () {
      const potteryCatalog = GeneratedCatalog(
        title: 'Terracotta Handcrafted Pot',
        category: 'Home Decor',
        craftTechnique: 'Wheel Pottery',
        material: 'Natural River Clay',
        origin: 'Alwar, Rajasthan',
        description: 'Earthen pot for cooling water.',
      );

      final inconsistency = AiCatalogService.validateConsistency(
        potteryCatalog,
        voiceTranscript: 'மென்மையான உயர்தர பருத்தி கைக்குட்டை cotton handkerchief',
      );

      expect(inconsistency, isNotNull);
      expect(inconsistency, contains('inconsistent with the product image'));
    });

    test('14. Real-image generation throws when Firebase is unavailable and blocks silent demo fallback', () async {
      final fakeImage = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);

      expect(
        () => service.generateCatalog(
          imageBytes: fakeImage,
          selectedLanguage: 'en',
          voiceTranscript: 'Cotton handkerchief',
          isRealImage: true,
        ),
        throwsA(isA<Object>()),
      );
    });

    test('15. Explicit demo mode generates fallback without throwing', () async {
      final result = await service.generateCatalog(
        imageBytes: null,
        selectedLanguage: 'en',
        voiceTranscript: 'cotton handkerchief',
        isRealImage: false,
      );

      expect(result.isRealAi, isFalse);
      expect(result.statusMessage, contains('Fallback'));
    });

    test('16. Model configuration uses supported Gemini 3.x Flash and no retired models', () {
      expect(AiCatalogService.geminiModel, equals('gemini-3.7-flash'));
      expect(AiCatalogService.geminiModel, isNot(contains('gemini-2.0')));
      expect(AiCatalogService.geminiModel, isNot(contains('gemini-1.5')));
      expect(AiCatalogService.geminiModel, isNot(contains('flash-lite')));
      expect(AiCatalogService.geminiModel, isNot(contains('flash-image')));
    });

    const validSampleJson = '''
    {
      "productTitle": "Handcrafted Silk Scarf",
      "hindiTitle": "हस्तनिर्मित रेशमी दुपट्टा",
      "category": "Apparel & Textiles",
      "technique": "Handloom Weaving",
      "material": "Pure Mulberry Silk",
      "origin": "Varanasi, Uttar Pradesh, India",
      "description": "Exquisite handwoven silk scarf with traditional zari border detailing.",
      "keywords": ["#silk", "#handloom", "#scarf"]
    }
    ''';

    test('17. Gemini succeeds on first attempt without retrying', () async {
      int callCount = 0;
      final statusLogs = <String>[];

      final result = await service.generateCatalog(
        imageBytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]),
        selectedLanguage: 'en',
        voiceTranscript: 'Pure silk scarf with zari border',
        isRealImage: true,
        customRetryDelays: [Duration.zero, Duration.zero],
        onStatusUpdate: (msg) => statusLogs.add(msg),
        contentGenerator: (parts) async {
          callCount++;
          return validSampleJson;
        },
      );

      expect(callCount, equals(1));
      expect(result.isRealAi, isTrue);
      expect(result.catalog.title, equals('Handcrafted Silk Scarf'));
      expect(statusLogs, contains('Analyzing with Gemini AI…'));
      expect(statusLogs, isNot(contains('Gemini is busy. Retrying…')));
    });

    test('18. First attempt transiently fails with 500 server error, second attempt succeeds', () async {
      int callCount = 0;
      final statusLogs = <String>[];

      final result = await service.generateCatalog(
        imageBytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]),
        selectedLanguage: 'en',
        voiceTranscript: 'Pure silk scarf with zari border',
        isRealImage: true,
        customRetryDelays: [Duration.zero, Duration.zero],
        onStatusUpdate: (msg) => statusLogs.add(msg),
        contentGenerator: (parts) async {
          callCount++;
          if (callCount == 1) {
            throw ServerException('Server Error [500] This model is currently experiencing high demand. Spikes in demand are usually temporary. Please try again later.');
          }
          return validSampleJson;
        },
      );

      expect(callCount, equals(2));
      expect(result.isRealAi, isTrue);
      expect(result.catalog.title, equals('Handcrafted Silk Scarf'));
      expect(statusLogs, contains('Analyzing with Gemini AI…'));
      expect(statusLogs, contains('Gemini is busy. Retrying…'));
    });

    test('19. First two attempts transiently fail and third attempt succeeds', () async {
      int callCount = 0;
      final statusLogs = <String>[];

      final result = await service.generateCatalog(
        imageBytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]),
        selectedLanguage: 'en',
        voiceTranscript: 'Pure silk scarf with zari border',
        isRealImage: true,
        customRetryDelays: [Duration.zero, Duration.zero],
        onStatusUpdate: (msg) => statusLogs.add(msg),
        contentGenerator: (parts) async {
          callCount++;
          if (callCount < 3) {
            throw ServerException('Server Error [503] Model overloaded. High demand spike.');
          }
          return validSampleJson;
        },
      );

      expect(callCount, equals(3));
      expect(result.isRealAi, isTrue);
      expect(result.catalog.title, equals('Handcrafted Silk Scarf'));
      expect(statusLogs.where((s) => s.contains('Retrying')).length, equals(2));
    });

    test('20. All three attempts fail: retry stops at 3, throws user-friendly error, blocks demo fallback', () async {
      int callCount = 0;

      await expectLater(
        () => service.generateCatalog(
          imageBytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]),
          selectedLanguage: 'en',
          voiceTranscript: 'Pure silk scarf with zari border',
          isRealImage: true,
          customRetryDelays: [Duration.zero, Duration.zero],
          contentGenerator: (parts) async {
            callCount++;
            throw ServerException('Server Error [500] Service Unavailable');
          },
        ),
        throwsA(
          isA<FirebaseAIException>().having(
            (e) => e.message,
            'message',
            contains("AI couldn't analyze the product right now. Please try again."),
          ),
        ),
      );

      // Verify retry count never exceeds 3
      expect(callCount, equals(3));
    });

    test('21. Permanent / non-transient errors (e.g. InvalidApiKey) do not retry and fail immediately', () async {
      int callCount = 0;

      await expectLater(
        () => service.generateCatalog(
          imageBytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]),
          selectedLanguage: 'en',
          voiceTranscript: 'Pure silk scarf with zari border',
          isRealImage: true,
          customRetryDelays: [Duration.zero, Duration.zero],
          contentGenerator: (parts) async {
            callCount++;
            throw InvalidApiKey('API key not valid. Please pass a valid API key.');
          },
        ),
        throwsA(isA<FirebaseAIException>()),
      );

      // Fails immediately after attempt 1 without retry
      expect(callCount, equals(1));
    });

    test('22. Transient error classifier correctly categorizes transient vs permanent errors', () {
      // Transient
      expect(AiCatalogService.isTransientError(ServerException('Server Error [500] high demand')), isTrue);
      expect(AiCatalogService.isTransientError(QuotaExceeded('quota temporarily exceeded')), isTrue);
      expect(AiCatalogService.isTransientError(FirebaseAIException('Spikes in demand are usually temporary. Please try again later.')), isTrue);
      expect(AiCatalogService.isTransientError(FirebaseAIException('503 Service Unavailable')), isTrue);
      expect(AiCatalogService.isTransientError(Exception('SocketException: Connection reset by peer')), isTrue);
      expect(AiCatalogService.isTransientError(Exception('TimeoutException after 0:00:30.000000: Future not completed')), isTrue);

      // Permanent / Non-retryable
      expect(AiCatalogService.isTransientError(InvalidApiKey('Invalid API key')), isFalse);
      expect(AiCatalogService.isTransientError(UnsupportedUserLocation()), isFalse);
      expect(AiCatalogService.isTransientError(ServiceApiNotEnabled('projects/123')), isFalse);
      expect(AiCatalogService.isTransientError(FormatException('Invalid JSON syntax')), isFalse);
      expect(AiCatalogService.isTransientError(ArgumentError('Invalid prompt argument')), isFalse);
      expect(AiCatalogService.isTransientError(FirebaseAIException('400 Bad Request: Unsupported content')), isFalse);
    });

    test('23. Existing Tamil and regional voice transcript flow remains intact', () async {
      const tamilVoiceTranscript = 'மென்மையான உயர்தர பட்டு சேலை பாரம்பரிய ஜரிகை வேலைப்பாடு';
      int callCount = 0;

      final result = await service.generateCatalog(
        imageBytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]),
        selectedLanguage: 'ta',
        voiceTranscript: tamilVoiceTranscript,
        isRealImage: true,
        customRetryDelays: [Duration.zero, Duration.zero],
        contentGenerator: (parts) async {
          callCount++;
          return validSampleJson;
        },
      );

      expect(callCount, equals(1));
      expect(result.isRealAi, isTrue);
      expect(result.catalog.title, equals('Handcrafted Silk Scarf'));
      expect(result.catalog.description, isNot(contains('Voice input from the artisan')));
    });
  });
}
