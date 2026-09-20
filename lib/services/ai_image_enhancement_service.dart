import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';

class ImageEnhancementResult {
  final Uint8List? enhancedBytes;
  final bool isSuccess;
  final String? errorMessage;

  const ImageEnhancementResult({
    this.enhancedBytes,
    required this.isSuccess,
    this.errorMessage,
  });

  factory ImageEnhancementResult.success(Uint8List bytes) {
    return ImageEnhancementResult(
      enhancedBytes: bytes,
      isSuccess: true,
    );
  }

  factory ImageEnhancementResult.failure(String error) {
    return ImageEnhancementResult(
      enhancedBytes: null,
      isSuccess: false,
      errorMessage: error,
    );
  }
}

class AiImageEnhancementService {
  static const String imageModel = 'gemini-3.1-flash-image';

  static const String enhancementPrompt = '''
Edit this product photograph for an artisan e-commerce catalog.

Preserve the exact identity, shape, structure, craftsmanship, colors, texture and important details of the original product.

Do not invent or add product features.

Remove distracting background clutter where possible.
Create a clean, simple, professional product-photo presentation.
Improve lighting and exposure naturally.
Improve clarity and sharpness.
Correct minor perspective/framing issues.
Keep the product realistic and authentic.
Do not add text, logos, decorations, people, hands, or unrelated objects.
Do not change the actual product.
Place the product against a clean neutral warm-light background suitable for an Indian artisan marketplace.

The result must look like a genuine professional product photograph, not an artificial illustration.
''';

  Future<ImageEnhancementResult> enhanceImage({
    required Uint8List imageBytes,
  }) async {
    debugPrint('[AiImageEnhancementService] Starting Gemini image enhancement');

    bool isFirebaseAvailable = false;
    try {
      if (Firebase.apps.isNotEmpty) {
        isFirebaseAvailable = true;
      }
    } catch (_) {
      isFirebaseAvailable = false;
    }

    if (!isFirebaseAvailable) {
      const msg = 'Firebase not initialized. Original photo preserved.';
      debugPrint('[AiImageEnhancementService] Image enhancement error: $msg');
      return ImageEnhancementResult.failure(msg);
    }

    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: imageModel,
        generationConfig: GenerationConfig(
          responseModalities: [ResponseModalities.image],
        ),
      );

      final imagePart = InlineDataPart('image/jpeg', imageBytes);
      final promptPart = TextPart(enhancementPrompt);

      final response = await model.generateContent([
        Content.multi([promptPart, imagePart])
      ]);

      Uint8List? resultBytes;
      if (response.inlineDataParts.isNotEmpty) {
        resultBytes = response.inlineDataParts.first.bytes;
      } else {
        final candidate = response.candidates.firstOrNull;
        if (candidate != null) {
          for (final part in candidate.content.parts) {
            if (part is InlineDataPart) {
              resultBytes = part.bytes;
              break;
            }
          }
        }
      }

      if (resultBytes != null && resultBytes.isNotEmpty) {
        debugPrint(
            '[AiImageEnhancementService] Successfully generated enhanced product image using $imageModel');
        return ImageEnhancementResult.success(resultBytes);
      } else {
        const err = 'Empty or missing image data in Gemini response.';
        debugPrint('[AiImageEnhancementService] Image enhancement error: $err');
        return ImageEnhancementResult.failure(err);
      }
    } catch (e) {
      debugPrint('[AiImageEnhancementService] Image enhancement error: $e');
      return ImageEnhancementResult.failure(e.toString());
    }
  }
}
