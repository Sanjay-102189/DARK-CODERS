import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerResult {
  final XFile? file;
  final Uint8List? bytes;
  final String? errorMessage;
  final bool isPermissionDenied;

  const ImagePickerResult({
    this.file,
    this.bytes,
    this.errorMessage,
    this.isPermissionDenied = false,
  });
}

class ImagePickerService {
  final ImagePicker _picker;

  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  Future<ImagePickerResult> pickFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
        requestFullMetadata: false,
      );

      if (photo == null) {
        return const ImagePickerResult(); // Cancelled by user
      }

      final bytes = await photo.readAsBytes();
      return ImagePickerResult(file: photo, bytes: bytes);
    } on PlatformException catch (e) {
      final isPermission = e.code == 'camera_access_denied' ||
          e.code == 'permission_denied' ||
          e.message?.toLowerCase().contains('permission') == true;
      return ImagePickerResult(
        errorMessage: isPermission
            ? 'Camera permission denied. You can use the Demo Product or enable camera in settings.'
            : 'Could not access camera: ${e.message}',
        isPermissionDenied: isPermission,
      );
    } catch (e) {
      return ImagePickerResult(
        errorMessage: 'An unexpected error occurred: $e',
      );
    }
  }

  Future<ImagePickerResult> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
        requestFullMetadata: false,
      );

      if (image == null) {
        return const ImagePickerResult(); // Cancelled by user
      }

      final bytes = await image.readAsBytes();
      return ImagePickerResult(file: image, bytes: bytes);
    } on PlatformException catch (e) {
      final isPermission = e.code == 'photo_access_denied' ||
          e.code == 'permission_denied' ||
          e.message?.toLowerCase().contains('permission') == true;
      return ImagePickerResult(
        errorMessage: isPermission
            ? 'Gallery permission denied. You can use the Demo Product or enable gallery access in settings.'
            : 'Could not access gallery: ${e.message}',
        isPermissionDenied: isPermission,
      );
    } catch (e) {
      return ImagePickerResult(
        errorMessage: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Recovers image data if Android MainActivity was destroyed while the camera was open.
  Future<XFile?> retrieveLostImage() async {
    try {
      final response = await _picker.retrieveLostData();

      if (response.isEmpty) {
        return null;
      }

      if (response.files != null && response.files!.isNotEmpty) {
        return response.files!.first;
      }

      if (response.file != null) {
        return response.file;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Safe recovery of image bytes and file for ProductCreationProvider.
  Future<ImagePickerResult?> retrieveLostResult() async {
    try {
      final photo = await retrieveLostImage();
      if (photo == null) return null;
      final bytes = await photo.readAsBytes();
      return ImagePickerResult(file: photo, bytes: bytes);
    } catch (_) {
      return null;
    }
  }
}
