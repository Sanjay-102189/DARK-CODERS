import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/image_picker_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ImagePickerService _pickerService = ImagePickerService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = context.read<ProductCreationProvider>();
      final recovered = await prov.checkAndRecoverLostImage(_pickerService);
      if (mounted && recovered != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Camera photo recovered successfully',
              style: GoogleFonts.notoSans(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: AppColors.secondary,
            action: SnackBarAction(
              label: 'Open Studio',
              textColor: Colors.white,
              onPressed: () {
                if (mounted) context.push('/image-studio');
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductCreationProvider>();
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
              'Add New Product',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'नया उत्पाद जोड़ें • Step 1 of 4',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_camera_rounded,
                      size: 16, color: AppColors.onPrimaryFixed),
                  const SizedBox(width: 8),
                  Text(
                    'Step 1: Product Photography / उत्पाद फ़ोटो',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimaryFixed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Show your craft to the world',
              style: GoogleFonts.epilogue(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Take a simple photo in normal room or sunlight. Our AI will clean the background and add studio lighting.',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (prov.isRealImage && prov.imageBytes != null) ...[
              GestureDetector(
                onTap: () => context.push('/image-studio'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.secondary, width: 1.5),
                    boxShadow: AppTheme.elevation1,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          prov.imageBytes!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Photo Captured / Ready',
                              style: GoogleFonts.epilogue(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              'Tap to proceed to studio with current photo',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.secondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Demo Quick-Start Card (Recommended for judging)
            GestureDetector(
              onTap: () {
                context.read<ProductCreationProvider>().reset();
                context.read<ProductCreationProvider>().selectDemoProduct();
                context.push('/image-studio');
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF1EA), Color(0xFFFFEADF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                  boxShadow: AppTheme.elevation1,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Recommended for Demo',
                                style: GoogleFonts.notoSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Ready',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Use Demo Terracotta Pot',
                            style: GoogleFonts.epilogue(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Pre-loaded high quality workshop photo',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Camera / Gallery Options
            Row(
              children: [
                Expanded(
                  child: _buildCaptureOption(
                    context: context,
                    icon: Icons.camera_alt_rounded,
                    title: 'Take Photo',
                    subtitle: 'कैमरा चालू करें',
                    color: AppColors.primary,
                    bgColor: AppColors.surfaceContainerLowest,
                    onTap: () async {
                      final provider = context.read<ProductCreationProvider>();
                      final result = await _pickerService.pickFromCamera();
                      if (!context.mounted) return;

                      if (result.file != null && result.bytes != null) {
                        provider.reset();
                        provider.setImage(result.file!, result.bytes!);
                        context.push('/image-studio');
                      } else if (result.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.errorMessage!,
                              style: GoogleFonts.notoSans(color: Colors.white, fontSize: 13),
                            ),
                            backgroundColor: AppColors.inverseSurface,
                            action: SnackBarAction(
                              label: 'Use Demo',
                              textColor: AppColors.secondaryContainer,
                              onPressed: () {
                                provider.reset();
                                provider.selectDemoProduct();
                                context.push('/image-studio');
                              },
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildCaptureOption(
                    context: context,
                    icon: Icons.photo_library_rounded,
                    title: 'Upload Gallery',
                    subtitle: 'गैलरी से चुनें',
                    color: AppColors.secondary,
                    bgColor: AppColors.surfaceContainerLowest,
                    onTap: () async {
                      final provider = context.read<ProductCreationProvider>();
                      final result = await _pickerService.pickFromGallery();
                      if (!context.mounted) return;

                      if (result.file != null && result.bytes != null) {
                        provider.reset();
                        provider.setImage(result.file!, result.bytes!);
                        context.push('/image-studio');
                      } else if (result.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.errorMessage!,
                              style: GoogleFonts.notoSans(color: Colors.white, fontSize: 13),
                            ),
                            backgroundColor: AppColors.inverseSurface,
                            action: SnackBarAction(
                              label: 'Use Demo',
                              textColor: AppColors.secondaryContainer,
                              onPressed: () {
                                provider.reset();
                                provider.selectDemoProduct();
                                context.push('/image-studio');
                              },
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // AI Photography Tips Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          size: 20, color: AppColors.tertiary),
                      const SizedBox(width: 8),
                      Text(
                        'AI Photo Tips for Best Catalog Results',
                        style: GoogleFonts.epilogue(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Natural Lighting',
                    desc: 'Photograph near an open doorway or courtyard.',
                  ),
                  const SizedBox(height: 8),
                  _buildTipItem(
                    icon: Icons.center_focus_strong_outlined,
                    title: 'Keep in Center',
                    desc: 'Capture the whole piece from eye-level.',
                  ),
                  const SizedBox(height: 8),
                  _buildTipItem(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Don’t Worry About Background',
                    desc: 'CraftMitra AI will automatically remove clutter.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant, width: 0.8),
          boxShadow: AppTheme.elevation1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.epilogue(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.notoSans(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.onSurface),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: desc,
                  style: const TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
