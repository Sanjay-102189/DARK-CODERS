import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/demo_data.dart';
import '../../providers/providers.dart';

class ImageStudioScreen extends StatefulWidget {
  const ImageStudioScreen({super.key});

  @override
  State<ImageStudioScreen> createState() => _ImageStudioScreenState();
}

class _ImageStudioScreenState extends State<ImageStudioScreen> {
  double _splitPosition = 0.5; // 0.0 to 1.0
  bool _isProcessingEnhancement = false;
  String _activeFilter = 'Original';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<ProductCreationProvider>();
      if (!prov.isRealImage) {
        prov.enhanceImage();
      }
    });
  }

  void _triggerFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _isProcessingEnhancement = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isProcessingEnhancement = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductCreationProvider>();
    final isRealImage = prov.isRealImage && prov.imageBytes != null;
    final rawPhotoUrl = DemoData.rawPotImageUrl;
    final studioPhotoUrl = DemoData.enhancedPotImageUrl;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Image Studio',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'फोटो सुधार एवं ई-कॉमर्स बैकग्राउंड',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: AppColors.onSecondaryContainer),
                const SizedBox(width: 4),
                Text(
                  'AI Ready',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step 2 of 4 • Photo Enhancement',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '50% Done',
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimaryFixed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Before / After Comparison Canvas
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final height = 300.0;

                      return Stack(
                        children: [
                          // Base container / Enhanced studio layer (Right side)
                          Container(
                            width: width,
                            height: height,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppTheme.elevation2,
                              border: Border.all(color: AppColors.outlineVariant, width: 0.5),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: prov.isImageEnhanced && prov.enhancedImageBytes != null
                                      ? Image.memory(
                                          prov.enhancedImageBytes!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _buildFallbackStudioImage(),
                                        )
                                      : isRealImage
                                          ? Image.memory(
                                              prov.imageBytes!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _buildFallbackStudioImage(),
                                            )
                                          : Image.network(
                                              studioPhotoUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _buildFallbackStudioImage(),
                                            ),
                                ),
                                // Enhanced Badge
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.65),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.auto_awesome, size: 12, color: AppColors.tertiary),
                                        const SizedBox(width: 4),
                                        Text(
                                          prov.isImageEnhanced && prov.enhancedImageBytes != null
                                              ? 'Enhanced with Gemini AI'
                                              : isRealImage
                                                  ? (prov.isEnhancingImage ? 'Enhancing...' : 'Original (Preserved)')
                                                  : 'Studio AI',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Clipped Before layer (Left side)
                          ClipRect(
                            clipper: _SplitClipper(split: _splitPosition, width: width),
                            child: Container(
                              width: width,
                              height: height,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: isRealImage
                                        ? Image.memory(
                                            prov.imageBytes!,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            rawPhotoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _buildFallbackRawImage(),
                                          ),
                                  ),
                                  // Raw Badge
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.65),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isRealImage ? 'Original (Real Photo)' : 'Original Photo',
                                        style: GoogleFonts.notoSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Draggable Split Divider Handle
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: (width * _splitPosition) - 18,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onHorizontalDragUpdate: (details) {
                                setState(() {
                                  _splitPosition = (_splitPosition + (details.primaryDelta! / width)).clamp(0.05, 0.95);
                                });
                              },
                              child: Container(
                                width: 36,
                                alignment: Alignment.center,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Vertical Line
                                    Container(
                                      width: 2,
                                      color: Colors.white,
                                    ),
                                    // Circular Grip
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.compare_arrows_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // In-progress enhancement overlay
                          if (_isProcessingEnhancement || prov.isEnhancingImage)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircularProgressIndicator(color: Colors.white),
                                      const SizedBox(height: 12),
                                      Text(
                                        prov.isEnhancingImage
                                            ? 'Enhancing with Gemini AI (gemini-3.1-flash-image)...'
                                            : 'Applying $_activeFilter...',
                                        style: GoogleFonts.notoSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      '⟵ Drag slider to compare Before & After ⟶',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (isRealImage) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: prov.isImageEnhanced
                              ? AppColors.secondaryContainer.withOpacity(0.5)
                              : prov.isEnhancingImage
                                  ? AppColors.tertiaryFixed.withOpacity(0.4)
                                  : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: prov.isImageEnhanced
                                ? AppColors.secondary.withOpacity(0.4)
                                : AppColors.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  prov.isImageEnhanced
                                      ? Icons.auto_awesome
                                      : prov.isEnhancingImage
                                          ? Icons.hourglass_top_rounded
                                          : Icons.info_outline,
                                  size: 14,
                                  color: prov.isImageEnhanced
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    prov.isImageEnhanced
                                        ? 'Enhanced with Gemini AI • Studio Quality'
                                        : prov.isEnhancingImage
                                            ? 'Generating real product enhancement with Gemini 3.1 Flash Image...'
                                            : (prov.imageEnhancementError != null
                                                ? 'AI enhancement unavailable — original photo preserved'
                                                : 'Original photo ready • Tap Retouch for AI enhancement'),
                                    style: GoogleFonts.notoSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: prov.isImageEnhanced
                                          ? AppColors.onSecondaryContainer
                                          : AppColors.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            if (!prov.isImageEnhanced && !prov.isEnhancingImage) ...[
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () => prov.enhanceProductImage(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    prov.imageEnhancementError != null
                                        ? 'Tap to retry AI image enhancement'
                                        : 'Tap to enhance with Gemini AI',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // AI Fixes Badges Row
                  Text(
                    'AI Enhancements Applied',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildEnhancementChip(Icons.check_circle_rounded, 'Background Cleaned', AppColors.secondary),
                      _buildEnhancementChip(Icons.check_circle_rounded, 'Studio Light Fixed', AppColors.secondary),
                      _buildEnhancementChip(Icons.check_circle_rounded, 'Catalog Centered', AppColors.secondary),
                      _buildEnhancementChip(Icons.high_quality_rounded, '4K Sharpened', AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Quick Action Tools
                  Text(
                    'Quick Adjustments / त्वरित संपादन',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildToolButton(
                        icon: Icons.auto_fix_high_rounded,
                        label: 'Retouch',
                        isActive: _activeFilter == 'Retouch' || prov.isEnhancingImage,
                        onTap: () {
                          _triggerFilter('Retouch');
                          if (isRealImage && !prov.isEnhancingImage) {
                            prov.enhanceProductImage();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildToolButton(
                        icon: Icons.wallpaper_rounded,
                        label: 'Ivory BG',
                        isActive: _activeFilter == 'Ivory BG',
                        onTap: () => _triggerFilter('Ivory BG'),
                      ),
                      const SizedBox(width: 8),
                      _buildToolButton(
                        icon: Icons.crop_rounded,
                        label: 'Square Crop',
                        isActive: _activeFilter == 'Square Crop',
                        onTap: () => _triggerFilter('Square Crop'),
                      ),
                      const SizedBox(width: 8),
                      _buildToolButton(
                        icon: Icons.brightness_6_rounded,
                        label: 'Shadows',
                        isActive: _activeFilter == 'Shadows',
                        onTap: () => _triggerFilter('Shadows'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quality score banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondaryContainer, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: AppColors.secondary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'E-commerce Catalog Ready',
                                style: GoogleFonts.epilogue(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                'Prepared for marketplace-style product listings.',
                                style: GoogleFonts.notoSans(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Bottom Dock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: prov.isUploadingImage
    ? null
    : () async {
        final provider = context.read<ProductCreationProvider>();

        // Demo product already uses a pre-loaded image.
        if (!provider.isRealImage) {
          provider.enhanceImage();
          context.push('/voice-catalog');
          return;
        }

        // Real product image → upload to Cloudinary.
        await provider.uploadImageToCloudinary();

        if (!context.mounted) return;

        if (provider.cloudinaryImageUrl != null) {
          provider.enhanceImage();
          context.push('/voice-catalog');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.imageUploadError ??
                    'Could not upload product image. Please try again.',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              backgroundColor: AppColors.inverseSurface,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
                  icon: prov.isUploadingImage
    ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
    : const Icon(
        Icons.mic_rounded,
        color: Colors.white,
      ),
label: Text(
  prov.isUploadingImage
      ? 'Uploading Product Image...'
      : 'Next: Add Voice Description (आवाज जोड़ें)',
                    style: GoogleFonts.epilogue(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancementChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.outlineVariant,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Colors.white : AppColors.onSurface,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackRawImage() {
    return Container(
      color: const Color(0xFF8D7B68),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: Colors.white70),
      ),
    );
  }

  Widget _buildFallbackStudioImage() {
    return Container(
      color: const Color(0xFFF9F6F0),
      child: const Center(
        child: Icon(Icons.auto_awesome, size: 48, color: AppColors.primary),
      ),
    );
  }
}

class _SplitClipper extends CustomClipper<Rect> {
  final double split;
  final double width;

  _SplitClipper({required this.split, required this.width});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, width * split, size.height);
  }

  @override
  bool shouldReclip(_SplitClipper oldClipper) {
    return oldClipper.split != split || oldClipper.width != width;
  }
}
