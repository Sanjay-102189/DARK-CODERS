import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:craftmitra/services/image_picker_service.dart';
import 'package:craftmitra/providers/providers.dart';

class FakeImagePicker extends ImagePicker {
  XFile? nextImage;
  PlatformException? throwException;
  LostDataResponse? nextLostData;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    if (throwException != null) {
      throw throwException!;
    }
    return nextImage;
  }

  @override
  Future<LostDataResponse> retrieveLostData() async {
    if (throwException != null) {
      throw throwException!;
    }
    return nextLostData ?? LostDataResponse.empty();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImagePickerService and Camera Stability Tests', () {
    late FakeImagePicker fakePicker;
    late ImagePickerService service;

    setUp(() {
      fakePicker = FakeImagePicker();
      service = ImagePickerService(picker: fakePicker);
    });

    test('1. Gallery selection returns valid file and bytes', () async {
      final testBytes = Uint8List.fromList([10, 20, 30, 40]);
      fakePicker.nextImage = XFile.fromData(testBytes);

      final result = await service.pickFromGallery();
      expect(result.file, isNotNull);
      expect(result.bytes, equals(testBytes));
      expect(result.errorMessage, isNull);
      expect(result.isPermissionDenied, isFalse);
    });

    test('2. Camera selection returns valid file and bytes', () async {
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      fakePicker.nextImage = XFile.fromData(testBytes);

      final result = await service.pickFromCamera();
      expect(result.file, isNotNull);
      expect(result.bytes, equals(testBytes));
      expect(result.errorMessage, isNull);
    });

    test('3. Null camera result handled gracefully when user cancels', () async {
      fakePicker.nextImage = null;

      final result = await service.pickFromCamera();
      expect(result.file, isNull);
      expect(result.bytes, isNull);
      expect(result.errorMessage, isNull);
      expect(result.isPermissionDenied, isFalse);
    });

    test('4. Camera permission exception handled gracefully without crash', () async {
      fakePicker.throwException = PlatformException(
        code: 'camera_access_denied',
        message: 'The user did not allow camera access.',
      );

      final result = await service.pickFromCamera();
      expect(result.file, isNull);
      expect(result.bytes, isNull);
      expect(result.isPermissionDenied, isTrue);
      expect(result.errorMessage, contains('Camera permission denied'));
    });

    test('5. Lost image recovery retrieves photo if Android activity was recreated', () async {
      final testBytes = Uint8List.fromList([100, 200]);
      fakePicker.nextLostData = LostDataResponse(
        file: XFile.fromData(testBytes),
        type: RetrieveType.image,
      );

      final recovered = await service.retrieveLostImage();
      expect(recovered, isNotNull);

      final result = await service.retrieveLostResult();
      expect(result, isNotNull);
      expect(result!.file, isNotNull);
      expect(result.bytes, equals(testBytes));
    });

    test('6. Empty lost-data response returns null without errors', () async {
      fakePicker.nextLostData = LostDataResponse.empty();

      final recovered = await service.retrieveLostImage();
      expect(recovered, isNull);

      final result = await service.retrieveLostResult();
      expect(result, isNull);
    });

    test('7. Provider receives recovered image upon checking lost data', () async {
      final testBytes = Uint8List.fromList([50, 60, 70]);
      fakePicker.nextLostData = LostDataResponse(
        file: XFile.fromData(testBytes),
        type: RetrieveType.image,
      );

      final provider = ProductCreationProvider(pickerService: service);
      expect(provider.isRealImage, isFalse); // initially before async check resolves

      final res = await provider.checkAndRecoverLostImage(service);
      expect(res, isNotNull);
      expect(provider.isRealImage, isTrue);
      expect(provider.selectedImage, isNotNull);
      expect(provider.imageBytes, equals(testBytes));
    });
  });
}
