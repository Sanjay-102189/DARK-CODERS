import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/demo_data.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class PublishScreen extends StatefulWidget {
  const PublishScreen({super.key});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Mark product as published in AppStateProvider
      final prov = context.read<ProductCreationProvider>();
      prov.publish();

      // Add a newly published product to app state with dynamic catalog values & pricing
      final finalPrice = prov.pricingResult.buyerFriendlyPrice > 0
          ? prov.pricingResult.buyerFriendlyPrice.toDouble()
          : (prov.recommendedPrice > 0 ? prov.recommendedPrice : 850.0);

      final prodId = prov.savedFirestoreProductId ?? (prov.productId.isNotEmpty ? prov.productId : 'cm-pot-new');
      final prodImage = prov.cloudinaryImageUrl ?? DemoData.enhancedPotImageUrl;

      final auth = context.read<AuthProvider>();
      final pr = prov.pricingResult;
      final matches = prov.buyerMatches;
      final summary = matches.take(5).map((bm) => {
        'buyerId': bm.buyer.id,
        'buyerName': bm.buyer.name,
        'matchPercent': bm.matchScore,
        'matchScore': bm.matchScore,
        'location': bm.buyer.location,
        'businessType': bm.buyer.verificationLabel,
        'reasons': bm.reasons,
      }).toList();

      final newProd = Product(
        id: prodId,
        artisanId: auth.currentUid ?? '',
        name: prov.catalog?.title ?? 'Handcrafted Terracotta Flower Pot',
        nameHindi: prov.catalog?.titleHindi ?? 'हस्तनिर्मित टेराकोटा नक्काशीदार फूलदान',
        category: prov.catalog?.category ?? 'Terracotta & Clay',
        craftTechnique: prov.catalog?.craftTechnique ?? 'Handcrafted',
        material: prov.catalog?.material ?? 'Clay',
        origin: prov.catalog?.origin ?? 'India',
        description: prov.catalog?.description ?? '',
        voiceTranscript: prov.voiceTranscript,
        price: finalPrice,
        baseCost: pr.baseCost,
        profit: pr.profit,
        marginPercent: prov.marginPercent,
        topBuyerMatches: summary,
        buyerMatchCount: matches.length,
        imageUrl: prodImage,
        completionPercent: 1.0,
        status: ProductStatus.published,
        views: 1,
        orders: 0,
        createdAt: DateTime.now(),
        publishedAt: DateTime.now(),
      );
      context.read<AppStateProvider>().addProduct(newProd);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductCreationProvider>();
    final price = prov.pricingResult.buyerFriendlyPrice > 0
        ? prov.pricingResult.buyerFriendlyPrice
        : (prov.recommendedPrice > 0 ? prov.recommendedPrice.toInt() : 850);
    final displayTitle = prov.catalog?.title ?? 'Handcrafted Terracotta Flower Pot';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Celebration Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.onSecondaryContainer,
                  size: 52,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Catalog Ready & Broadcast Ready!',
                style: GoogleFonts.epilogue(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'उत्पाद सफलतापूर्वक तैयार हुआ',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your handcrafted piece is cataloged with AI. Ready to export to national buyer networks.',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Product Mini Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineVariant, width: 0.6),
                  boxShadow: AppTheme.elevation1,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: prov.enhancedImageBytes != null
                          ? Image.memory(
                              prov.enhancedImageBytes!,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            )
                          : (prov.imageBytes != null
                              ? Image.memory(
                                  prov.imageBytes!,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  DemoData.enhancedPotImageUrl,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 72,
                                    height: 72,
                                    color: AppColors.surfaceContainerLow,
                                    child: const Icon(Icons.image, color: AppColors.primary),
                                  ),
                                )),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Catalog Export Ready',
                              style: GoogleFonts.notoSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayTitle,
                            style: GoogleFonts.epilogue(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Target Price: ₹$price / piece',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Multi-Channel Distribution Status
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Multi-Channel Distribution',
                  style: GoogleFonts.epilogue(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildChannelRow(
                icon: Icons.hub_rounded,
                title: 'ONDC Open Commerce Network',
                subtitle: 'Direct B2B discoverability protocol across pan-India buyer apps',
                status: 'Ready for Integration',
                color: AppColors.secondary,
              ),
              const SizedBox(height: 8),
              _buildChannelRow(
                icon: Icons.shopping_bag_outlined,
                title: 'Amazon Karigar',
                subtitle: 'Automated catalog sync with GI tag verification',
                status: 'Catalog Export Ready',
                color: AppColors.secondary,
              ),
              const SizedBox(height: 8),
              _buildChannelRow(
                icon: Icons.account_balance_rounded,
                title: 'GeM (Government e-Marketplace)',
                subtitle: 'Public procurement portal catalog standard export',
                status: 'Catalog Export Ready',
                color: AppColors.secondary,
              ),
              const SizedBox(height: 8),
              _buildChannelRow(
                icon: Icons.chat_rounded,
                title: 'WhatsApp Mitra Broadcast',
                subtitle: 'Share PDF digital catalog with verified bulk buyers',
                status: 'Share Ready',
                color: AppColors.primary,
              ),
              const SizedBox(height: 32),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final auth = context.read<AuthProvider>();
                    if (auth.isAuthenticated && auth.currentUid != null) {
                      context.read<AppStateProvider>().fetchCloudProducts(auth.currentUid!);
                    }
                    context.go('/products');
                  },
                  icon: const Icon(Icons.inventory_2_rounded, color: Colors.white),
                  label: Text(
                    'View in My Products (उत्पाद देखें)',
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
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final auth = context.read<AuthProvider>();
                    if (auth.isAuthenticated && auth.currentUid != null) {
                      context.read<AppStateProvider>().fetchCloudProducts(auth.currentUid!);
                    }
                    context.go('/home');
                  },
                  icon: const Icon(Icons.home_rounded, color: AppColors.primary),
                  label: Text(
                    'Back to Dashboard (मुख्य पृष्ठ)',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color color,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.epilogue(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: GoogleFonts.notoSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
