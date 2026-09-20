import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/demo_data.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../auth/auth_modal.dart';

class CatalogPreviewScreen extends StatefulWidget {
  const CatalogPreviewScreen({super.key});

  @override
  State<CatalogPreviewScreen> createState() => _CatalogPreviewScreenState();
}

class _CatalogPreviewScreenState extends State<CatalogPreviewScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _isEditing = false;
  GeneratedCatalog? _lastCatalog;

  @override
  void initState() {
    super.initState();
    final catalog = DemoData.demoCatalog;
    _titleController = TextEditingController(text: catalog.title);
    _descController = TextEditingController(text: catalog.description);
  }

  void _syncControllers(GeneratedCatalog catalog) {
    if (!_isEditing && _lastCatalog != catalog) {
      _lastCatalog = catalog;
      _titleController.text = catalog.title;
      _descController.text = catalog.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductCreationProvider>();
    final catalog = prov.catalog ?? DemoData.demoCatalog;
    _syncControllers(catalog);

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
              'AI Generated Catalog',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'तैयार डिजिटल कैटलॉग • Step 4 of 4',
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
              color: AppColors.tertiaryFixed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.translate_rounded,
                    size: 14, color: AppColors.onTertiaryFixed),
                const SizedBox(width: 4),
                Text(
                  'AI Bilingual',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onTertiaryFixed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (prov.aiStatusMessage != null || prov.isRealAi) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: prov.isRealAi
                      ? const Color(0xFFE8F5E9)
                      : AppColors.tertiaryFixed.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: prov.isRealAi
                        ? Colors.green.shade400
                        : AppColors.outlineVariant,
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          prov.isRealAi
                              ? Icons.verified_rounded
                              : Icons.auto_awesome_rounded,
                          size: 18,
                          color: prov.isRealAi ? Colors.green.shade700 : AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            prov.isRealAi
                                ? 'Real Multimodal AI Catalog (Gemini)'
                                : (prov.aiStatusMessage ?? 'Demo Catalog'),
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: prov.isRealAi
                                  ? Colors.green.shade900
                                  : AppColors.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: prov.isRealAi
                                ? Colors.green.shade100
                                : AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            prov.isRealAi ? 'REAL AI' : 'DEMO',
                            style: GoogleFonts.notoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: prov.isRealAi
                                  ? Colors.green.shade800
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (catalog.confidence != null && catalog.confidence!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: catalog.confidence!.entries.map((e) {
                          final pct = (e.value * 100).toInt();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200, width: 0.5),
                            ),
                            child: Text(
                              '${e.key}: $pct%',
                              style: GoogleFonts.notoSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade900,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    if (catalog.evidence != null && catalog.evidence!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Visual Evidence: ${catalog.evidence!['product'] ?? 'Analyzed from image'}',
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Preview Image Thumbnail Banner
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.surfaceContainerLowest,
                boxShadow: AppTheme.elevation1,
                border: Border.all(color: AppColors.outlineVariant, width: 0.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (prov.enhancedImageBytes != null)
                    Image.memory(
                      prov.enhancedImageBytes!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 48, color: AppColors.primary),
                        ),
                      ),
                    )
                  else if (prov.isRealImage && prov.imageBytes != null)
                    Image.memory(
                      prov.imageBytes!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 48, color: AppColors.primary),
                        ),
                      ),
                    )
                  else
                    Image.network(
                      DemoData.enhancedPotImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Center(
                          child: Icon(Icons.image, size: 48, color: AppColors.primary),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 13, color: AppColors.secondaryContainer),
                          const SizedBox(width: 4),
                          Text(
                            prov.isImageEnhanced && prov.enhancedImageBytes != null
                                ? 'AI Enhanced Product Photo'
                                : prov.isRealImage
                                    ? 'Artisan Real Capture'
                                    : 'Studio Quality Verified',
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Field 1: Title (English & Hindi)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant, width: 0.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Product Title / उत्पाद का नाम',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isEditing ? Icons.check_circle : Icons.edit_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_isEditing) {
                              prov.updateCatalog(
                                catalog.copyWith(
                                  title: _titleController.text.trim(),
                                  description: _descController.text.trim(),
                                ),
                              );
                            }
                            _isEditing = !_isEditing;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isEditing)
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.epilogue(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 6),
                      ),
                    )
                  else
                    Text(
                      _titleController.text,
                      style: GoogleFonts.epilogue(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Hindi: ${catalog.titleHindi}',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Field 2: Key Attributes 2x2 Grid
            Text(
              'Craft Attributes / शिल्प विशेषताएं',
              style: GoogleFonts.epilogue(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildAttributeTile(
                    icon: Icons.local_florist_rounded,
                    label: 'Category',
                    value: catalog.category,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAttributeTile(
                    icon: Icons.hardware_rounded,
                    label: 'Technique',
                    value: catalog.craftTechnique,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildAttributeTile(
                    icon: Icons.terrain_rounded,
                    label: 'Material',
                    value: catalog.material,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAttributeTile(
                    icon: Icons.location_on_rounded,
                    label: 'Origin',
                    value: catalog.origin,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // AI Recommended Benchmark Price hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary.withOpacity(0.25), width: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sell_rounded, size: 18, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'AI Recommended Price: ',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '₹${prov.pricingResult.buyerFriendlyPrice > 0 ? prov.pricingResult.buyerFriendlyPrice : 850}',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Fair Trade Sweetspot',
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Field 3: Buyer Story & Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant, width: 0.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Buyer Story & Description',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '✨ SEO Optimized',
                          style: GoogleFonts.notoSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_isEditing)
                    TextField(
                      controller: _descController,
                      maxLines: 4,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: AppColors.onSurface,
                        height: 1.4,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 6),
                      ),
                    )
                  else
                    Text(
                      _descController.text,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: AppColors.onSurface,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Field 4: Auto-Generated Keywords
            Text(
              'Search Keywords / खोज शब्द',
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
              children: catalog.keywords.map((kw) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant, width: 0.5),
                  ),
                  child: Text(
                    kw,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: prov.isSavingToFirestore
                      ? null
                      : () async {
                          final auth = context.read<AuthProvider>();
                          if (!auth.isAuthenticated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please sign in to save your product securely to Cloud Firestore.',
                                  style: GoogleFonts.notoSans(fontSize: 13),
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                action: SnackBarAction(
                                  label: 'Sign In',
                                  textColor: Colors.white,
                                  onPressed: () => showAuthModal(context),
                                ),
                              ),
                            );
                            showAuthModal(context);
                            return;
                          }
                          if (_isEditing) {
                            prov.updateCatalog(
                              catalog.copyWith(
                                title: _titleController.text.trim(),
                                description: _descController.text.trim(),
                              ),
                            );
                            setState(() => _isEditing = false);
                          }
                          final success = await prov.saveProductToFirestore();
                          if (!context.mounted) return;
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Product catalog saved to Firestore (ID: ${prov.savedFirestoreProductId})',
                                        style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.secondary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          } else {
                            final err = prov.firestoreSaveError ?? "Unknown error";
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Save failed: $err',
                                  style: GoogleFonts.notoSans(fontSize: 12),
                                ),
                                action: SnackBarAction(
                                  label: 'Retry',
                                  textColor: Colors.white,
                                  onPressed: () => prov.saveProductToFirestore(),
                                ),
                                backgroundColor: AppColors.error,
                                duration: const Duration(seconds: 5),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        },
                  icon: prov.isSavingToFirestore
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : Icon(
                          prov.isSavedToFirestore ? Icons.cloud_done_rounded : Icons.cloud_upload_outlined,
                          size: 18,
                          color: prov.isSavedToFirestore ? AppColors.secondary : AppColors.primary,
                        ),
                  label: Text(
                    prov.isSavingToFirestore
                        ? 'Saving to Firestore...'
                        : prov.isSavedToFirestore
                            ? 'Saved to Cloud (ID: ${prov.savedFirestoreProductId})'
                            : 'Save Product (कैटलॉग सुरक्षित करें)',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: prov.isSavedToFirestore ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: prov.isSavedToFirestore ? AppColors.secondary : AppColors.primary,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: prov.isSavingToFirestore
                      ? null
                      : () async {
                          final auth = context.read<AuthProvider>();
                          if (auth.isAuthenticated && !prov.isSavedToFirestore) {
                            final ok = await prov.saveProductToFirestore();
                            if (!ok) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Save failed: ${prov.firestoreSaveError ?? "Unknown error"}',
                                      style: GoogleFonts.notoSans(fontSize: 12),
                                    ),
                                    action: SnackBarAction(
                                      label: 'Retry',
                                      textColor: Colors.white,
                                      onPressed: () => prov.saveProductToFirestore(),
                                    ),
                                    backgroundColor: AppColors.error,
                                    duration: const Duration(seconds: 5),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }
                              return;
                            }
                          }
                          if (context.mounted) {
                            context.push('/pricing');
                          }
                        },
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: Text(
                    'Proceed to Smart Pricing (~₹${prov.pricingResult.buyerFriendlyPrice > 0 ? prov.pricingResult.buyerFriendlyPrice : 850})',
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
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.replay_rounded, size: 16, color: AppColors.onSurfaceVariant),
                label: Text(
                  'Re-record Voice / Edit Details',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttributeTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
