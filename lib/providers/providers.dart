import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import '../services/firestore_product_service.dart';
import '../services/firestore_order_service.dart';
import '../services/auth_service.dart';
import '../../models/models.dart';
import '../../core/constants/demo_data.dart';
import '../services/ai_catalog_service.dart';
import '../services/ai_image_enhancement_service.dart';
import '../services/smart_pricing_service.dart';
import '../services/buyer_matching_service.dart';
import '../services/voice_recording_service.dart';
import '../services/image_picker_service.dart';

export 'auth_provider.dart';

/// Global app state — language, artisan, products list
class AppStateProvider extends ChangeNotifier {
  String _selectedLanguage = 'English';
  Artisan _artisan = DemoData.artisan;
  List<Product> _products = List.from(DemoData.products);
  int _currentNavIndex = 0;

  final FirestoreProductService _firestoreService;
  List<Product> _cloudProducts = [];
  bool _isLoadingCloudProducts = false;
  String? _cloudProductsError;

  AppStateProvider({FirestoreProductService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreProductService();

  String get selectedLanguage => _selectedLanguage;
  Artisan get artisan => _artisan;

  /// Returns persistent cloud products for authenticated artisans, with demo fallback.
  List<Product> get products {
    if (_cloudProducts.isNotEmpty) {
      final cloudIds = _cloudProducts.map((p) => p.id).toSet();
      return [..._cloudProducts, ..._products.where((p) => !cloudIds.contains(p.id))];
    }
    return _products;
  }

  int get currentNavIndex => _currentNavIndex;

  List<Product> get cloudProducts => _cloudProducts;
  bool get isLoadingCloudProducts => _isLoadingCloudProducts;
  String? get cloudProductsError => _cloudProductsError;

  /// Safely notifies listeners outside of Flutter's build/layout phase.
  void _safeNotifyListeners() {
    try {
      final binding = WidgetsBinding.instance;
      if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks ||
          binding.schedulerPhase == SchedulerPhase.midFrameMicrotasks) {
        binding.addPostFrameCallback((_) {
          notifyListeners();
        });
        return;
      }
    } catch (_) {
      // In non-widget test environments or if binding is uninitialized
    }
    notifyListeners();
  }

  Future<void> fetchCloudProducts(String artisanId) async {
    _isLoadingCloudProducts = true;
    _cloudProductsError = null;
    _safeNotifyListeners();

    try {
      debugPrint('[AppStateProvider] [START] Fetching cloud products for artisan UID: $artisanId');
      final rawList = await _firestoreService.getProductsForArtisan(artisanId);
      _cloudProducts = rawList.map((m) => Product.fromFirestore(m, m['id'] as String?)).toList();
      _isLoadingCloudProducts = false;
      debugPrint('[AppStateProvider] [SUCCESS] Loaded ${_cloudProducts.length} cloud products for artisan UID: $artisanId');
      _safeNotifyListeners();
    } on FirebaseException catch (fe) {
      debugPrint('[AppStateProvider] [FAIL] FirebaseException fetching cloud products: code=${fe.code}, message=${fe.message}');
      _isLoadingCloudProducts = false;
      _cloudProductsError = '[${fe.code}] ${fe.message}';
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('[AppStateProvider] [FAIL] Error fetching cloud products: $e');
      _isLoadingCloudProducts = false;
      _cloudProductsError = e.toString();
      _safeNotifyListeners();
    }
  }

  void clearCloudProducts() {
    _cloudProducts = [];
    _cloudProductsError = null;
    _safeNotifyListeners();
  }

  List<Product> get publishedProducts =>
      products.where((p) => p.status == ProductStatus.published).toList();
  List<Product> get draftProducts =>
      products.where((p) => p.status == ProductStatus.draft).toList();

  void setLanguage(String lang) {
    _selectedLanguage = lang;
    notifyListeners();
  }

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  void addProduct(Product product) {
    final existingIndex = _products.indexWhere((p) => p.id == product.id);
    if (existingIndex >= 0) {
      _products[existingIndex] = product;
    } else {
      _products.insert(0, product);
    }

    final cloudIndex = _cloudProducts.indexWhere((p) => p.id == product.id);
    if (cloudIndex >= 0) {
      _cloudProducts[cloudIndex] = product;
    } else {
      _cloudProducts.insert(0, product);
    }
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void publishProduct(String productId) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        status: ProductStatus.published,
        completionPercent: 1.0,
      );
      notifyListeners();
    }
  }
}

/// Internal status tracking for AI catalog generation
enum AiGenerationStatus {
  idle,
  analyzingImage,
  generatingCatalog,
  success,
  failed,
  demo,
}

/// State for the product creation flow
class ProductCreationProvider extends ChangeNotifier {
  final AiCatalogService _aiService = AiCatalogService();
  final AiImageEnhancementService _imageService = AiImageEnhancementService();
  final SmartPricingService _pricingService = SmartPricingService();
  final BuyerMatchingService _buyerMatchingService = BuyerMatchingService();
  final VoiceRecordingService _voiceService = VoiceRecordingService();
  final ImagePickerService _pickerService = ImagePickerService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirestoreProductService _firestoreService;
  final AuthService _authService;

  ProductCreationProvider({
    ImagePickerService? pickerService,
    FirestoreProductService? firestoreService,
    AuthService? authService,
  })  : _firestoreService = firestoreService ?? FirestoreProductService(),
        _authService = authService ?? AuthService() {
    checkAndRecoverLostImage(pickerService);
  }

  /// Safely checks for lost camera data after Android Activity recreation
  Future<ImagePickerResult?> checkAndRecoverLostImage([ImagePickerService? pickerService]) async {
    final service = pickerService ?? _pickerService;
    try {
      final recovered = await service.retrieveLostResult();
      if (recovered != null && recovered.file != null && recovered.bytes != null) {
        setImage(recovered.file!, recovered.bytes!);
        debugPrint('[ProductCreationProvider] Recovered lost camera photo: ${recovered.file!.name}');
        return recovered;
      }
    } catch (e) {
      debugPrint('[ProductCreationProvider] Notice: Lost image check: $e');
    }
    return null;
  }

  int _currentStep = 0;
  bool _useDemoProduct = false;
  bool _useDemoVoice = false;
  bool _imageEnhanced = false;
  String _voiceTranscript = '';
  String _selectedVoiceLanguage = 'Hindi';
  bool _isRecording = false;
  bool _isTranscribing = false;
  String? _voiceError;
  int _recordingDuration = 0;

  GeneratedCatalog? _catalog;
  int _marginPercent = 30;
  double _rawMaterialCost = 250.0;
  double _laborCost = 270.0;
  double _packagingCost = 80.0;
  int _quantity = 120;
  String _complexity = 'Medium';
  SmartPricingResult? _pricingResult;
  List<BuyerMatchResult>? _buyerMatches;

  bool _isProcessing = false;
  int _processingStep = 0;
  bool _priceAccepted = false;
  bool _published = false;
  String _productId = '';

  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool _isRealImage = false;
  AiGenerationStatus _aiStatus = AiGenerationStatus.idle;
  String? _aiStatusMessage;
  String? _aiTechnicalNote;
  String? _cloudinaryImageUrl;
bool _isUploadingImage = false;
String? _imageUploadError;

  Uint8List? _enhancedImageBytes;
  bool _isImageEnhanced = false;
  bool _isEnhancingImage = false;
  String? _imageEnhancementError;

  bool _isSavingToFirestore = false;
  bool _isSavedToFirestore = false;
  bool _isPricingSaved = false;
  bool _isBuyerMatchesSaved = false;
  bool _isPublishedInFirestore = false;
  String? _firestoreSaveError;
  String? _savedFirestoreProductId;

  int get currentStep => _currentStep;
  bool get useDemoProduct => _useDemoProduct;
  bool get useDemoVoice => _useDemoVoice;
  bool get imageEnhanced => _imageEnhanced;
  String get voiceTranscript => _voiceTranscript;
  String get selectedVoiceLanguage => _selectedVoiceLanguage;
  bool get isRecording => _isRecording;
  bool get isTranscribing => _isTranscribing;
  String? get voiceError => _voiceError;
  int get recordingDuration => _recordingDuration;
  VoiceRecordingService get voiceService => _voiceService;

  GeneratedCatalog? get catalog => _catalog;
  int get marginPercent => _marginPercent;
  double get rawMaterialCost => _rawMaterialCost;
  double get laborCost => _laborCost;
  double get packagingCost => _packagingCost;
  int get quantity => _quantity;
  String get complexity => _complexity;

  bool get isProcessing => _isProcessing;
  int get processingStep => _processingStep;
  bool get priceAccepted => _priceAccepted;
  bool get published => _published;
  String get productId => _productId;

  XFile? get selectedImage => _selectedImage;
  Uint8List? get imageBytes => _imageBytes;
  bool get isRealImage => _isRealImage;
  AiGenerationStatus get aiStatus => _aiStatus;
  bool get isRealAi => _aiStatus == AiGenerationStatus.success;
  String? get aiStatusMessage => _aiStatusMessage;
  String? get aiTechnicalNote => _aiTechnicalNote;
  String? get cloudinaryImageUrl => _cloudinaryImageUrl;
  bool get isUploadingImage => _isUploadingImage;
  String? get imageUploadError => _imageUploadError;

  Uint8List? get enhancedImageBytes => _enhancedImageBytes;
  bool get isImageEnhanced => _isImageEnhanced;
  bool get isEnhancingImage => _isEnhancingImage;
  String? get imageEnhancementError => _imageEnhancementError;

  bool get isSavingToFirestore => _isSavingToFirestore;
  bool get isSavedToFirestore => _isSavedToFirestore;
  bool get isPricingSaved => _isPricingSaved;
  bool get isBuyerMatchesSaved => _isBuyerMatchesSaved;
  bool get isPublishedInFirestore => _isPublishedInFirestore;
  String? get firestoreSaveError => _firestoreSaveError;
  String? get savedFirestoreProductId => _savedFirestoreProductId;

  SmartPricingResult _computePricing() {
    return _pricingService.calculatePricing(
      rawMaterialCost: _rawMaterialCost,
      laborCost: _laborCost,
      packagingCost: _packagingCost,
      marginPercentage: _marginPercent,
      category: _catalog?.category ?? 'Pottery',
      craftTechnique: _catalog?.craftTechnique ?? 'Wheel-thrown terracotta',
      material: _catalog?.material ?? 'Terracotta Clay',
      complexity: _complexity,
      orderQuantity: _quantity,
      productTitle: _catalog?.title ?? 'Handcrafted Terracotta Pot',
    );
  }

  SmartPricingResult get pricingResult {
    _pricingResult ??= _computePricing();
    return _pricingResult!;
  }

  List<BuyerMatchResult> _computeBuyerMatches() {
    final pricing = pricingResult;
    return _buyerMatchingService.matchBuyers(
      buyers: DemoData.buyers,
      catalog: _catalog,
      targetPrice: pricing.buyerFriendlyPrice.toDouble(),
      quantity: _quantity,
      imageBytes: _enhancedImageBytes ?? _imageBytes,
      productTitle: _catalog?.title ?? 'Handcrafted Terracotta Pot',
      artisanState: 'Rajasthan',
    );
  }

  List<BuyerMatchResult> get buyerMatches {
    _buyerMatches ??= _computeBuyerMatches();
    return _buyerMatches!;
  }

  double get baseCost => pricingResult.baseCost;
  double get profit => pricingResult.profit;
  double get recommendedPrice => pricingResult.buyerFriendlyPrice.toDouble();

  void reset() {
    _currentStep = 0;
    _useDemoProduct = false;
    _useDemoVoice = false;
    _imageEnhanced = false;
    _voiceTranscript = '';
    _selectedVoiceLanguage = 'Hindi';
    _isRecording = false;
    _isTranscribing = false;
    _voiceError = null;
    _recordingDuration = 0;
    _catalog = null;
    _marginPercent = 30;
    _rawMaterialCost = 250.0;
    _laborCost = 270.0;
    _packagingCost = 80.0;
    _quantity = 120;
    _complexity = 'Medium';
    _pricingResult = null;
    _buyerMatches = null;
    _isProcessing = false;
    _processingStep = 0;
    _priceAccepted = false;
    _published = false;
    _productId = 'CM-${DateTime.now().millisecondsSinceEpoch % 10000}';
    _selectedImage = null;
    _imageBytes = null;
    _isRealImage = false;
    _aiStatus = AiGenerationStatus.idle;
    _aiStatusMessage = null;
    _aiTechnicalNote = null;
    _cloudinaryImageUrl = null;
    _isUploadingImage = false;
    _imageUploadError = null;
    _enhancedImageBytes = null;
    _isImageEnhanced = false;
    _isEnhancingImage = false;
    _imageEnhancementError = null;
    _isSavingToFirestore = false;
    _isSavedToFirestore = false;
    _isPricingSaved = false;
    _isBuyerMatchesSaved = false;
    _isPublishedInFirestore = false;
    _firestoreSaveError = null;
    _savedFirestoreProductId = null;
    notifyListeners();
  }

  void setImage(XFile file, Uint8List bytes) {
    _selectedImage = file;
    _imageBytes = bytes;
    _isRealImage = true;
    _useDemoProduct = false;
    _aiStatus = AiGenerationStatus.idle;
    _aiStatusMessage = null;
    _aiTechnicalNote = null;
    _cloudinaryImageUrl = null;
    _isUploadingImage = false;
    _imageUploadError = null;
    _enhancedImageBytes = null;
    _isImageEnhanced = false;
    _isEnhancingImage = false;
    _imageEnhancementError = null;
    notifyListeners();
  }

  Future<void> uploadImageToCloudinary() async {
    // Avoid redundant uploads if image was already uploaded
    if (_cloudinaryImageUrl != null && _cloudinaryImageUrl!.isNotEmpty) {
      debugPrint(
        '[ProductCreationProvider] Reusing existing Cloudinary URL: $_cloudinaryImageUrl',
      );
      return;
    }

    final bytesToUpload = _enhancedImageBytes ?? _imageBytes;
    if (bytesToUpload == null) {
      _imageUploadError = 'No product image selected.';
      notifyListeners();
      return;
    }

    _isUploadingImage = true;
    _imageUploadError = null;
    notifyListeners();

    try {
      final fileName = _selectedImage?.name ?? 'craftmitra_product';
      final isUsingEnhanced = _enhancedImageBytes != null;
      debugPrint(
        '[ProductCreationProvider] Uploading to Cloudinary (usingEnhanced: $isUsingEnhanced, fileName: $fileName)',
      );

      final imageUrl = await _cloudinaryService.uploadProductImage(
        imageBytes: bytesToUpload,
        fileName: fileName,
      );

      _cloudinaryImageUrl = imageUrl;
      _imageUploadError = null;

      debugPrint(
        '[ProductCreationProvider] Cloudinary upload successful: $imageUrl',
      );
    } catch (e) {
      _cloudinaryImageUrl = null;
      _imageUploadError = e.toString();

      debugPrint(
        '[ProductCreationProvider] Cloudinary upload failed: $e',
      );
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void selectDemoProduct() {
    _useDemoProduct = true;
    _isRealImage = false;
    _selectedImage = null;
    _imageBytes = null;
    _aiStatus = AiGenerationStatus.demo;
    _aiStatusMessage = 'Demo Product';
    _aiTechnicalNote = null;
    _cloudinaryImageUrl = null;
    _isUploadingImage = false;
    _imageUploadError = null;
    _enhancedImageBytes = null;
    _isImageEnhanced = false;
    _isEnhancingImage = false;
    _imageEnhancementError = null;
    notifyListeners();
  }

  void enhanceImage() {
    _imageEnhanced = true;
    notifyListeners();
  }

  Future<void> enhanceProductImage() async {
    if (_imageBytes == null) {
      debugPrint('[ProductCreationProvider] No image bytes available to enhance.');
      return;
    }

    _isEnhancingImage = true;
    _imageEnhancementError = null;
    notifyListeners();

    try {
      final result = await _imageService.enhanceImage(imageBytes: _imageBytes!);
      if (result.isSuccess && result.enhancedBytes != null) {
        _enhancedImageBytes = result.enhancedBytes;
        _isImageEnhanced = true;
        _imageEnhanced = true;
        _imageEnhancementError = null;
        _cloudinaryImageUrl = null;
      } else {
        _isImageEnhanced = false;
        _imageEnhancementError = result.errorMessage;
      }
    } catch (e) {
      _isImageEnhanced = false;
      _imageEnhancementError = e.toString();
    } finally {
      _isEnhancingImage = false;
      notifyListeners();
    }
  }

  void selectDemoVoice() {
    _useDemoVoice = true;
    _voiceTranscript = DemoData.demoTranscript;
    _voiceError = null;
    notifyListeners();
  }

  void setVoiceLanguage(String lang) {
    _selectedVoiceLanguage = lang;
    notifyListeners();
  }

  void selectVoiceLanguage(String lang) {
    _selectedVoiceLanguage = lang;
    notifyListeners();
  }

  void setTranscript(String text) {
    _voiceTranscript = text;
    _voiceError = null;
    notifyListeners();
  }

  void clearVoiceTranscript() {
    _voiceTranscript = '';
    _voiceError = null;
    notifyListeners();
  }

  Future<void> startVoiceRecording() async {
    _voiceError = null;
    _useDemoVoice = false;
    final success = await _voiceService.startRecording(
      language: _selectedVoiceLanguage,
      onResult: (text, isFinal) {
        _voiceTranscript = text;
        if (isFinal) {
          _isRecording = false;
          _isTranscribing = false;
        }
        notifyListeners();
      },
      onStateChanged: (state) {
        _isRecording = (state == VoiceRecordingState.recording);
        _isTranscribing = (state == VoiceRecordingState.processing);
        _recordingDuration = _voiceService.recordingDuration;
        if (state == VoiceRecordingState.error) {
          _voiceError = _voiceService.lastError ??
              'Voice recognition unavailable. You can type your description instead.';
          _isRecording = false;
          _isTranscribing = false;
        }
        notifyListeners();
      },
    );

    if (!success) {
      _isRecording = false;
      _voiceError = _voiceService.lastError ??
          'Voice recognition unavailable. You can type your description instead.';
      notifyListeners();
    }
  }

  Future<void> stopVoiceRecording() async {
    await _voiceService.stopRecording(
      onStateChanged: (state) {
        _isRecording = (state == VoiceRecordingState.recording);
        _isTranscribing = (state == VoiceRecordingState.processing);
        _recordingDuration = _voiceService.recordingDuration;
        notifyListeners();
      },
    );
  }

  void setProcessing(bool val) {
    _isProcessing = val;
    notifyListeners();
  }

  void setProcessingStep(int step) {
    _processingStep = step;
    notifyListeners();
  }

  void generateCatalog() {
    _catalog = DemoData.demoCatalog;
    _aiStatus = AiGenerationStatus.demo;
    _aiStatusMessage = 'Demo Catalog';
    _pricingResult = _computePricing();
    _buyerMatches = _computeBuyerMatches();
    notifyListeners();
  }

  /// Explicitly selects demo mode when real AI fails or when artisan wants demo catalog.
  void useDemoProductCatalog() {
    _useDemoProduct = true;
    _isRealImage = false;
    final fallback = _aiService.buildFallbackResult(
      selectedLanguage: _selectedVoiceLanguage,
      voiceTranscript: _voiceTranscript.isNotEmpty ? _voiceTranscript : null,
      reason: 'Artisan selected demo catalog mode',
    );
    _catalog = fallback.catalog;
    _aiStatus = AiGenerationStatus.demo;
    _aiStatusMessage = 'Demo Catalog (Selected)';
    _aiTechnicalNote = null;
    _pricingResult = _computePricing();
    _buyerMatches = _computeBuyerMatches();
    notifyListeners();
  }

  Future<void> runAiCatalogGeneration() async {
    _isProcessing = true;
    _aiStatus = AiGenerationStatus.analyzingImage;
    _aiStatusMessage = null;
    _aiTechnicalNote = null;
    notifyListeners();

    try {
      _aiStatus = AiGenerationStatus.generatingCatalog;
      _aiStatusMessage = 'Analyzing with Gemini AI…';
      notifyListeners();

      final result = await _aiService.generateCatalog(
        imageBytes: _enhancedImageBytes ?? _imageBytes,
        selectedLanguage: _selectedVoiceLanguage,
        voiceTranscript: _voiceTranscript.isNotEmpty ? _voiceTranscript : null,
        isRealImage: _isRealImage,
        onStatusUpdate: (msg) {
          _aiStatusMessage = msg;
          notifyListeners();
        },
      );
      _catalog = result.catalog.copyWith(
        description: AiCatalogService.sanitizeDescription(result.catalog.description),
        title: AiCatalogService.sanitizeTitle(result.catalog.title),
      );
      _aiStatus = result.isRealAi ? AiGenerationStatus.success : AiGenerationStatus.demo;
      _aiStatusMessage = result.statusMessage;
      _aiTechnicalNote = result.technicalDetails;
      _pricingResult = _computePricing();
      _buyerMatches = _computeBuyerMatches();
    } catch (e) {
      debugPrint('[ProductCreationProvider] AI Catalog generation error: $e');
      if (_isRealImage) {
        _catalog = null;
        _aiStatus = AiGenerationStatus.failed;
        _aiStatusMessage = "AI couldn't analyze the product right now. Please try again.";
        _aiTechnicalNote = e.toString();
        debugPrint('[AI_CATALOG] DEMO FALLBACK BLOCKED FOR REAL IMAGE: $e');
      } else {
        final fallback = _aiService.buildFallbackResult(
          selectedLanguage: _selectedVoiceLanguage,
          voiceTranscript: _voiceTranscript.isNotEmpty ? _voiceTranscript : null,
          reason: e.toString(),
        );
        _catalog = fallback.catalog;
        _aiStatus = AiGenerationStatus.demo;
        _aiStatusMessage = fallback.statusMessage;
        _aiTechnicalNote = e.toString();
        _pricingResult = _computePricing();
        _buyerMatches = _computeBuyerMatches();
      }
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void updateCatalog(GeneratedCatalog catalog) {
    _catalog = catalog.copyWith(
      description: AiCatalogService.sanitizeDescription(catalog.description),
      title: AiCatalogService.sanitizeTitle(catalog.title),
    );
    _pricingResult = _computePricing();
    _buyerMatches = _computeBuyerMatches();
    notifyListeners();
  }

  void setMargin(int percent) {
    _marginPercent = percent;
    _pricingResult = _computePricing();
    _buyerMatches = _computeBuyerMatches();
    notifyListeners();
  }

  void updateCosts({double? rawMaterial, double? labor, double? packaging}) {
    if (rawMaterial != null) _rawMaterialCost = rawMaterial;
    if (labor != null) _laborCost = labor;
    if (packaging != null) _packagingCost = packaging;
    _pricingResult = _computePricing();
    _buyerMatches = _computeBuyerMatches();
    notifyListeners();
  }

  void setQuantity(int qty) {
    _quantity = qty;
    _pricingResult = _computePricing();
    _buyerMatches = _computeBuyerMatches();
    notifyListeners();
  }

  void setComplexity(String comp) {
    _complexity = comp;
    _pricingResult = _computePricing();
    _buyerMatches = _computeBuyerMatches();
    notifyListeners();
  }

  void recalculatePricing() {
    _pricingResult = _computePricing();
    _buyerMatches = _computeBuyerMatches();
    notifyListeners();
  }

  void recalculateBuyerMatches() {
    _buyerMatches = _computeBuyerMatches();
    notifyListeners();
  }

  Future<void> retryVoiceInit() async {
    _voiceError = null;
    notifyListeners();
    debugPrint('[ProductCreationProvider] Retrying voice recognition initialization...');
    final ok = await _voiceService.retryInitialization();
    if (!ok) {
      _voiceError = _voiceService.lastError ?? 'Voice recognition unavailable. You can type your description manually or use Demo Voice.';
      debugPrint('[ProductCreationProvider] Voice retry result: false, error: $_voiceError');
    } else {
      debugPrint('[ProductCreationProvider] Voice recognition initialized successfully.');
    }
    notifyListeners();
  }

  void acceptPrice() {
    _priceAccepted = true;
    notifyListeners();
  }

  void publish() {
    _published = true;
    notifyListeners();
  }

  /// Saves current product information to Cloud Firestore under `products/{productId}`.
  /// Status starts at 'catalogReady' and can be updated as artisan moves through workflow.
  Future<bool> saveProductToFirestore({String status = 'catalogReady'}) async {
    _isSavingToFirestore = true;
    _firestoreSaveError = null;
    notifyListeners();

    try {
      final isReal = !_useDemoProduct;
      final currentUser = _authService.currentUser;

      debugPrint('[ProductCreationProvider] [START] saveProductToFirestore:');
      debugPrint('  - currentUser is null: ${currentUser == null}');
      debugPrint('  - current Firebase UID: ${currentUser?.uid ?? 'NONE'}');
      debugPrint('  - isReal: $isReal, useDemoProduct: $_useDemoProduct');

      if (isReal && currentUser == null) {
        _isSavingToFirestore = false;
        _firestoreSaveError = 'Authentication required. Please sign in to save real products.';
        notifyListeners();
        debugPrint('[ProductCreationProvider] [ABORT] Unauthenticated real product save.');
        return false;
      }

      // Security rule requirement: request.resource.data.artisanId == request.auth.uid
      // When an artisan is authenticated, artisanId MUST match their Firebase UID.
      final artisanId = currentUser != null ? currentUser.uid : 'artisan-demo';
      final artisanEmail = currentUser?.email;

      if (_productId.isEmpty) {
        _productId = 'CM-${DateTime.now().millisecondsSinceEpoch % 10000}';
      }

      final cat = _catalog;
      final pr = pricingResult;
      final effectivePrice = pr.buyerFriendlyPrice > 0
          ? pr.buyerFriendlyPrice.toDouble()
          : (recommendedPrice > 0 ? recommendedPrice : 850.0);

      final imageUrl = _cloudinaryImageUrl ??
          (_isRealImage ? 'local_captured_image' : 'assets/images/terracotta_vase.jpg');

      debugPrint('  - product ID: $_productId');
      debugPrint('  - artisanId being written: $artisanId');
      debugPrint('  - imageUrl: $imageUrl');
      debugPrint('  - Firestore collection/doc path: products/$_productId');
      debugPrint('  - Target status: $status');

      final matches = _buyerMatches ?? [];
      final summaryMatches = matches.take(5).map((bm) => {
        'buyerId': bm.buyer.id,
        'buyerName': bm.buyer.name,
        'matchPercent': bm.matchScore,
        'location': bm.buyer.location,
      }).toList();

      final data = <String, dynamic>{
        'id': _productId,
        'artisanId': artisanId,
        if (artisanEmail != null && artisanEmail.isNotEmpty) 'artisanEmail': artisanEmail,
        'name': cat?.title ?? 'Handcrafted Item',
        'productTitle': cat?.title ?? 'Handcrafted Item',
        'nameHindi': cat?.titleHindi ?? 'हस्तशिल्प उत्पाद',
        'hindiTitle': cat?.titleHindi ?? 'हस्तशिल्प उत्पाद',
        'description': AiCatalogService.sanitizeDescription(cat?.description ?? ''),
        'category': cat?.category ?? 'Handicrafts',
        'material': cat?.material ?? 'Terracotta / Clay',
        'craftType': cat?.category ?? 'Pottery',
        'craftTechnique': cat?.craftTechnique ?? 'Handcrafted',
        'origin': cat?.origin ?? 'India',
        'imageUrl': imageUrl,
        'voiceTranscript': _voiceTranscript,
        'voiceDescription': _voiceTranscript,
        'price': effectivePrice,
        'status': status,
        'keywords': cat?.keywords ?? <String>[],
        'isDemo': _useDemoProduct,
        'quantity': _quantity,
        'complexity': _complexity,
        'rawMaterialCost': _rawMaterialCost,
        'laborCost': _laborCost,
        'packagingCost': _packagingCost,
        'marginPercent': _marginPercent,
        'baseCost': pr.baseCost,
        'profit': pr.profit,
        'recommendedPrice': effectivePrice,
        'pricing': {
          'materialCost': _rawMaterialCost,
          'laborCost': _laborCost,
          'packagingCost': _packagingCost,
          'baseCost': pr.baseCost,
          'desiredMargin': _marginPercent,
          'suggestedMargin': pr.suggestedMargin,
          'marketBenchmark': pr.benchmarkName,
          'marketFloor': pr.marketFloor,
          'sweetSpot': pr.sweetSpot,
          'marketCeiling': pr.marketCeiling,
          'recommendedPrice': effectivePrice,
          'reasoning': pr.reasoning,
          'confidenceScore': pr.confidenceScore,
        },
        'completionPercent': status == 'published'
            ? 1.0
            : (status == 'buyerMatched'
                ? 0.9
                : (status == 'priceReady' ? 0.8 : 0.6)),
        if (summaryMatches.isNotEmpty) 'topBuyerMatches': summaryMatches,
        if (summaryMatches.isNotEmpty) 'buyerMatches': summaryMatches,
        if (matches.isNotEmpty) 'buyerMatchCount': matches.length,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == 'published') 'publishedAt': FieldValue.serverTimestamp(),
      };

      await _firestoreService.saveProduct(productId: _productId, data: data);

      _isSavingToFirestore = false;
      _isSavedToFirestore = true;
      if (status == 'priceReady' || status == 'buyerMatched' || status == 'published') {
        _isPricingSaved = true;
      }
      if (status == 'buyerMatched' || status == 'published') {
        _isBuyerMatchesSaved = true;
      }
      if (status == 'published') {
        _published = true;
        _isPublishedInFirestore = true;
      }
      _savedFirestoreProductId = _productId;
      debugPrint('[ProductCreationProvider] [SUCCESS] Firestore document products/$_productId successfully persisted (status=$status).');
      notifyListeners();
      return true;
    } on FirebaseException catch (fe) {
      debugPrint('[ProductCreationProvider] [FAIL] FirebaseException saving to Firestore: code=${fe.code}, message=${fe.message}');
      _isSavingToFirestore = false;
      _firestoreSaveError = '[${fe.code}] ${fe.message ?? 'Permission or Firestore error'}';
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('[ProductCreationProvider] [FAIL] Firestore save failed: $e');
      _isSavingToFirestore = false;
      _firestoreSaveError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Updates pricing details in the existing Firestore product document.
  Future<bool> savePricingToFirestore() async {
    if (_productId.isEmpty) return false;
    _isSavingToFirestore = true;
    _firestoreSaveError = null;
    notifyListeners();

    try {
      final currentUser = _authService.currentUser;
      final artisanId = currentUser != null ? currentUser.uid : 'artisan-demo';
      final pr = pricingResult;
      final effectivePrice = pr.buyerFriendlyPrice > 0
          ? pr.buyerFriendlyPrice.toDouble()
          : (recommendedPrice > 0 ? recommendedPrice : 850.0);

      if (!_isSavedToFirestore) {
        debugPrint('[ProductCreationProvider] Product not yet saved in Firestore; saving full document with status=priceReady');
        return await saveProductToFirestore(status: 'priceReady');
      }

      debugPrint('[ProductCreationProvider] [START] Updating pricing on products/$_productId');
      final pricingData = <String, dynamic>{
        'artisanId': artisanId,
        'price': effectivePrice,
        'recommendedPrice': effectivePrice,
        'baseCost': pr.baseCost,
        'profit': pr.profit,
        'marginPercent': _marginPercent,
        'rawMaterialCost': _rawMaterialCost,
        'laborCost': _laborCost,
        'packagingCost': _packagingCost,
        'quantity': _quantity,
        'complexity': _complexity,
        'confidenceScore': pr.confidenceScore,
        'marketFloor': pr.marketFloor,
        'marketCeiling': pr.marketCeiling,
        'sweetSpot': pr.sweetSpot,
        'marketBenchmark': pr.benchmarkName,
        'pricingReasoning': pr.reasoning,
        'status': 'priceReady',
        'completionPercent': 0.8,
        'pricing': {
          'materialCost': _rawMaterialCost,
          'laborCost': _laborCost,
          'packagingCost': _packagingCost,
          'baseCost': pr.baseCost,
          'desiredMargin': _marginPercent,
          'suggestedMargin': pr.suggestedMargin,
          'marketBenchmark': pr.benchmarkName,
          'marketFloor': pr.marketFloor,
          'sweetSpot': pr.sweetSpot,
          'marketCeiling': pr.marketCeiling,
          'recommendedPrice': effectivePrice,
          'reasoning': pr.reasoning,
          'confidenceScore': pr.confidenceScore,
        },
      };

      await _firestoreService.updateProductFields(
        productId: _productId,
        data: pricingData,
      );
      _isPricingSaved = true;
      debugPrint('[ProductCreationProvider] [SUCCESS] Saved pricing to products/$_productId');
      return true;
    } on FirebaseException catch (fe) {
      debugPrint('[ProductCreationProvider] [FAIL] FirebaseException saving pricing: code=${fe.code}, message=${fe.message}');
      _firestoreSaveError = '[${fe.code}] ${fe.message ?? 'Firestore error'}';
      return false;
    } catch (e) {
      debugPrint('[ProductCreationProvider] [FAIL] Error saving pricing: $e');
      _firestoreSaveError = e.toString();
      return false;
    } finally {
      _isSavingToFirestore = false;
      notifyListeners();
    }
  }

  /// Saves lightweight buyer matches summary to the existing Firestore product document.
  Future<bool> saveBuyerMatchesToFirestore() async {
    if (_productId.isEmpty) return false;
    _isSavingToFirestore = true;
    _firestoreSaveError = null;
    notifyListeners();

    try {
      final currentUser = _authService.currentUser;
      final artisanId = currentUser != null ? currentUser.uid : 'artisan-demo';
      final matches = buyerMatches;
      final summary = matches.take(5).map((bm) => {
        'buyerId': bm.buyer.id,
        'buyerName': bm.buyer.name,
        'matchPercent': bm.matchScore,
        'matchScore': bm.matchScore,
        'location': bm.buyer.location,
        'businessType': bm.buyer.verificationLabel,
        'reasons': bm.reasons,
      }).toList();

      if (!_isSavedToFirestore) {
        debugPrint('[ProductCreationProvider] Product not yet saved; saving full document before buyer matches');
        final saved = await saveProductToFirestore(status: 'buyerMatched');
        if (saved) {
          _isBuyerMatchesSaved = true;
        }
        return saved;
      }

      debugPrint('[ProductCreationProvider] [START] Saving buyer matches summary to products/$_productId');
      final data = <String, dynamic>{
        'artisanId': artisanId,
        'topBuyerMatches': summary,
        'buyerMatches': summary,
        'buyerMatchCount': matches.length,
        'status': 'buyerMatched',
        'completionPercent': 0.9,
      };

      await _firestoreService.updateProductFields(
        productId: _productId,
        data: data,
      );
      _isBuyerMatchesSaved = true;
      debugPrint('[ProductCreationProvider] [SUCCESS] Saved buyer matches to products/$_productId');
      return true;
    } on FirebaseException catch (fe) {
      debugPrint('[ProductCreationProvider] [FAIL] FirebaseException saving buyer matches: code=${fe.code}, message=${fe.message}');
      _firestoreSaveError = '[${fe.code}] ${fe.message ?? 'Firestore error'}';
      return false;
    } catch (e) {
      debugPrint('[ProductCreationProvider] [FAIL] Error saving buyer matches: $e');
      _firestoreSaveError = e.toString();
      return false;
    } finally {
      _isSavingToFirestore = false;
      notifyListeners();
    }
  }

  /// Explicitly updates Firestore status to 'published' when artisan taps Publish/Broadcast.
  Future<bool> publishProductToFirestore() async {
    if (_productId.isEmpty) return false;
    _isSavingToFirestore = true;
    _firestoreSaveError = null;
    notifyListeners();

    try {
      final currentUser = _authService.currentUser;
      final artisanId = currentUser != null ? currentUser.uid : 'artisan-demo';
      final pr = pricingResult;
      final effectivePrice = pr.buyerFriendlyPrice > 0
          ? pr.buyerFriendlyPrice.toDouble()
          : (recommendedPrice > 0 ? recommendedPrice : 850.0);

      final matches = buyerMatches;
      final summary = matches.take(5).map((bm) => {
        'buyerId': bm.buyer.id,
        'buyerName': bm.buyer.name,
        'matchPercent': bm.matchScore,
        'matchScore': bm.matchScore,
        'location': bm.buyer.location,
        'businessType': bm.buyer.verificationLabel,
        'reasons': bm.reasons,
      }).toList();

      if (!_isSavedToFirestore) {
        debugPrint('[ProductCreationProvider] [NOTICE] Product not yet in Firestore; creating document with status=published');
        final saved = await saveProductToFirestore(status: 'published');
        if (saved) {
          _published = true;
          _isPublishedInFirestore = true;
          return true;
        }
        return false;
      }

      final publishData = <String, dynamic>{
        'artisanId': artisanId,
        'status': 'published',
        'price': effectivePrice,
        'completionPercent': 1.0,
        if (summary.isNotEmpty) 'topBuyerMatches': summary,
        if (summary.isNotEmpty) 'buyerMatches': summary,
        if (matches.isNotEmpty) 'buyerMatchCount': matches.length,
        'publishedAt': FieldValue.serverTimestamp(),
      };

      await _firestoreService.updateProductFields(
        productId: _productId,
        data: publishData,
      );

      _published = true;
      _isPublishedInFirestore = true;
      debugPrint('[ProductCreationProvider] [SUCCESS] Product $_productId updated to status=published (100% completion)');
      return true;
    } on FirebaseException catch (fe) {
      debugPrint('[ProductCreationProvider] [FAIL] FirebaseException publishing to Firestore: code=${fe.code}, message=${fe.message}');
      _firestoreSaveError = '[${fe.code}] ${fe.message ?? 'Firestore error'}';
      return false;
    } catch (e) {
      debugPrint('[ProductCreationProvider] [FAIL] Firestore publish update failed: $e');
      _firestoreSaveError = e.toString();
      return false;
    } finally {
      _isSavingToFirestore = false;
      notifyListeners();
    }
  }
}

/// Orders state provider with real Cloud Firestore persistence and derived sales
class OrdersProvider extends ChangeNotifier {
  final FirestoreOrderService _firestoreService;
  final AuthService _authService;

  List<CraftOrder> _cloudOrders = [];
  final List<CraftOrder> _demoOrders = List.from(DemoData.orders);
  bool _isLoading = false;
  String? _error;
  bool _isCreatingOrder = false;
  String? _createOrderError;
  String? _lastCreatedOrderId;

  OrdersProvider({
    FirestoreOrderService? firestoreService,
    AuthService? authService,
  })  : _firestoreService = firestoreService ?? FirestoreOrderService(),
        _authService = authService ?? AuthService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCreatingOrder => _isCreatingOrder;
  String? get createOrderError => _createOrderError;
  String? get lastCreatedOrderId => _lastCreatedOrderId;
  List<CraftOrder> get cloudOrders => _cloudOrders;

  /// Returns real authenticated orders if user is authenticated; demo orders for unauthenticated/demo mode.
  List<CraftOrder> get orders {
    if (_authService.isAuthenticated) {
      return _cloudOrders;
    }
    return _demoOrders;
  }

  /// Derives real business analytics strictly from completed orders.
  SalesData get salesData {
    if (_authService.isAuthenticated) {
      return SalesData.fromOrders(_cloudOrders);
    }
    return DemoData.salesData;
  }

  void _safeNotifyListeners() {
    try {
      final binding = WidgetsBinding.instance;
      if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks ||
          binding.schedulerPhase == SchedulerPhase.midFrameMicrotasks) {
        binding.addPostFrameCallback((_) {
          notifyListeners();
        });
        return;
      }
    } catch (_) {}
    notifyListeners();
  }

  /// Fetches orders belonging to the authenticated artisan from Cloud Firestore.
  Future<void> fetchCloudOrders(String artisanId) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      debugPrint('[OrdersProvider] [START] Fetching orders for artisan UID: $artisanId');
      final rawList = await _firestoreService.getOrdersForArtisan(artisanId);
      _cloudOrders = rawList.map((m) => CraftOrder.fromFirestore(m, m['id'] as String?)).toList();
      _isLoading = false;
      debugPrint('[OrdersProvider] [SUCCESS] Loaded ${_cloudOrders.length} cloud orders for artisan UID: $artisanId');
    } on FirebaseException catch (fe) {
      debugPrint('[OrdersProvider] [FAIL] FirebaseException loading orders: code=${fe.code}, message=${fe.message}');
      _isLoading = false;
      _error = '[${fe.code}] ${fe.message ?? 'Firestore error'}';
    } catch (e) {
      debugPrint('[OrdersProvider] [FAIL] Error loading orders: $e');
      _isLoading = false;
      _error = e.toString();
    } finally {
      _safeNotifyListeners();
    }
  }

  void clearCloudOrders() {
    _cloudOrders = [];
    _error = null;
    _safeNotifyListeners();
  }

  CraftOrder? getOrder(String id) {
    try {
      if (_authService.isAuthenticated) {
        return _cloudOrders.firstWhere((o) => o.id == id);
      }
      return _demoOrders.firstWhere((o) => o.id == id);
    } catch (_) {
      try {
        return _demoOrders.firstWhere((o) => o.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  /// Creates a simulated test order from a matched/demo buyer.
  /// Strictly requires authenticated artisan and prevents duplicate clicks.
  Future<bool> createTestOrder({
    required Product product,
    required String buyerName,
    required String buyerLocation,
    String buyerId = '',
    required int quantity,
  }) async {
    if (_isCreatingOrder) {
      debugPrint('[OrdersProvider] [ABORT] Duplicate order creation blocked');
      return false;
    }

    _isCreatingOrder = true;
    _createOrderError = null;
    _safeNotifyListeners();

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _isCreatingOrder = false;
        _createOrderError = 'Authentication required. Please sign in to create orders.';
        _safeNotifyListeners();
        return false;
      }

      final artisanId = currentUser.uid;
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch % 100000}';
      final effectivePrice = product.price > 0 ? product.price : 850.0;
      final totalAmount = quantity * effectivePrice;

      debugPrint('[OrdersProvider] [START] Creating test order:');
      debugPrint('  - orderId: $orderId');
      debugPrint('  - artisanId: $artisanId');
      debugPrint('  - productId: ${product.id}');
      debugPrint('  - buyerName: $buyerName');
      debugPrint('  - quantity: $quantity, unitPrice: $effectivePrice, total: $totalAmount');

      final orderData = <String, dynamic>{
        'id': orderId,
        'orderId': orderId,
        'productId': product.id,
        'artisanId': artisanId,
        'buyerId': buyerId.isNotEmpty ? buyerId : 'demo-buyer',
        'buyerName': buyerName,
        'buyerLocation': buyerLocation,
        'productName': product.name,
        'quantity': quantity,
        'unitPrice': effectivePrice,
        'pricePerUnit': effectivePrice,
        'totalAmount': totalAmount,
        'totalValue': totalAmount,
        'status': 'placed',
        'currentStatus': 'placed',
        'statusLabel': orderStatusToLabel(OrderStatus.placed),
        'productImageUrl': product.imageUrl,
        'imageUrl': product.imageUrl,
        'readyCount': 0,
        'totalCount': quantity,
        'isTestOrder': true,
      };

      await _firestoreService.createOrder(orderId: orderId, data: orderData);

      final newOrder = CraftOrder.fromFirestore(orderData, orderId);
      _cloudOrders.insert(0, newOrder);
      _lastCreatedOrderId = orderId;
      _isCreatingOrder = false;
      debugPrint('[OrdersProvider] [SUCCESS] Order $orderId successfully created and saved in Firestore.');
      _safeNotifyListeners();
      return true;
    } on FirebaseException catch (fe) {
      debugPrint('[OrdersProvider] [FAIL] FirebaseException creating order: code=${fe.code}, message=${fe.message}');
      _isCreatingOrder = false;
      _createOrderError = '[${fe.code}] ${fe.message ?? 'Firestore error'}';
      _safeNotifyListeners();
      return false;
    } catch (e) {
      debugPrint('[OrdersProvider] [FAIL] Error creating order: $e');
      _isCreatingOrder = false;
      _createOrderError = e.toString();
      _safeNotifyListeners();
      return false;
    }
  }

  /// Updates order status in Firestore and updates local state.
  /// Preserves artisan ownership on every update.
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final currentUser = _authService.currentUser;
      final artisanId = currentUser != null ? currentUser.uid : '';

      if (artisanId.isNotEmpty) {
        await _firestoreService.updateOrderStatus(
          orderId: orderId,
          artisanId: artisanId,
          status: orderStatusToString(newStatus),
        );
      }

      final index = _cloudOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final current = _cloudOrders[index];
        final isNowCompleted = (newStatus == OrderStatus.completed || newStatus == OrderStatus.delivered);
        _cloudOrders[index] = current.copyWith(
          currentStatus: newStatus,
          statusLabel: orderStatusToLabel(newStatus),
          updatedAt: DateTime.now(),
          completedAt: isNowCompleted ? (current.completedAt ?? DateTime.now()) : current.completedAt,
          readyCount: isNowCompleted ? current.quantity : current.readyCount,
        );
      }

      // Also update demo orders if present
      final demoIndex = _demoOrders.indexWhere((o) => o.id == orderId);
      if (demoIndex != -1) {
        final current = _demoOrders[demoIndex];
        final isNowCompleted = (newStatus == OrderStatus.completed || newStatus == OrderStatus.delivered);
        _demoOrders[demoIndex] = current.copyWith(
          currentStatus: newStatus,
          statusLabel: orderStatusToLabel(newStatus),
          updatedAt: DateTime.now(),
          completedAt: isNowCompleted ? (current.completedAt ?? DateTime.now()) : current.completedAt,
          readyCount: isNowCompleted ? current.quantity : current.readyCount,
        );
      }

      _safeNotifyListeners();
      return true;
    } on FirebaseException catch (fe) {
      debugPrint('[OrdersProvider] [FAIL] FirebaseException updating order status: code=${fe.code}, message=${fe.message}');
      _error = '[${fe.code}] ${fe.message ?? 'Firestore error'}';
      _safeNotifyListeners();
      return false;
    } catch (e) {
      debugPrint('[OrdersProvider] [FAIL] Error updating order status: $e');
      _error = e.toString();
      _safeNotifyListeners();
      return false;
    }
  }
}

/// Sales data provider — dynamically derived from orders
class SalesProvider extends ChangeNotifier {
  SalesData _salesData = DemoData.salesData;

  SalesData get salesData => _salesData;

  void updateFromOrders(List<CraftOrder> orders, {bool isAuthenticated = false}) {
    if (isAuthenticated) {
      _salesData = SalesData.fromOrders(orders);
    } else {
      _salesData = DemoData.salesData;
    }
    notifyListeners();
  }
}
