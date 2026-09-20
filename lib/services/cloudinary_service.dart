import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'ywqclnmk';
  static const String _uploadPreset = 'craftmitra_products';

  Future<String> uploadProductImage({
    required Uint8List imageBytes,
    String fileName = 'product_image',
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    // Sanitize filename to avoid duplicate extensions or path components
    String cleanFileName = fileName.trim();
    if (cleanFileName.contains('/') || cleanFileName.contains(r'\')) {
      cleanFileName = cleanFileName.split(RegExp(r'[/\\]')).last;
    }
    // Remove repeated duplicate extensions (e.g. image.jpg.jpg -> image.jpg)
    while (cleanFileName.toLowerCase().endsWith('.jpg.jpg') ||
        cleanFileName.toLowerCase().endsWith('.jpeg.jpeg') ||
        cleanFileName.toLowerCase().endsWith('.png.png') ||
        cleanFileName.toLowerCase().endsWith('.webp.webp')) {
      cleanFileName = cleanFileName.substring(0, cleanFileName.lastIndexOf('.'));
    }

    final lower = cleanFileName.toLowerCase();
    if (!lower.endsWith('.jpg') &&
        !lower.endsWith('.jpeg') &&
        !lower.endsWith('.png') &&
        !lower.endsWith('.webp')) {
      cleanFileName = '$cleanFileName.jpg';
    }

    debugPrint('[CloudinaryService] [START] Uploading image ($cleanFileName, ${imageBytes.length} bytes) to Cloudinary');

    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: cleanFileName,
      ),
    );

    request.fields['upload_preset'] = _uploadPreset;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage = 'Cloudinary upload failed';

      try {
        final body = jsonDecode(response.body);
        errorMessage = body['error']?['message'] ?? errorMessage;
      } catch (_) {
        // Keep default error message.
      }

      debugPrint('[CloudinaryService] [FAIL] HTTP ${response.statusCode}: $errorMessage');
      throw Exception(
        '$errorMessage (HTTP ${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body);

    final secureUrl = data['secure_url'];

    if (secureUrl == null || secureUrl.toString().isEmpty) {
      debugPrint('[CloudinaryService] [FAIL] No secure_url returned in response');
      throw Exception('Cloudinary did not return an image URL.');
    }

    final resultUrl = secureUrl.toString();
    debugPrint('[CloudinaryService] [SUCCESS] Uploaded successfully: $resultUrl');
    return resultUrl;
  }
}