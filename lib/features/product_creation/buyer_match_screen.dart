import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/demo_data.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/buyer_matching_service.dart';

class BuyerMatchScreen extends StatefulWidget {
  const BuyerMatchScreen({super.key});

  @override
  State<BuyerMatchScreen> createState() => _BuyerMatchScreenState();
}

class _BuyerMatchScreenState extends State<BuyerMatchScreen> {
  String _selectedFilter = 'All Matches (7)';
  final Set<String> _sentCatalogs = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final auth = context.read<AuthProvider>();
        if (auth.isAuthenticated) {
          context.read<ProductCreationProvider>().saveBuyerMatchesToFirestore();
        }
      }
    });
  }

  final List<String> _filters = [
    'All Matches (7)',
    'Verified B2B',
    'Chennai / Bengaluru',
    'High Volume (100+)',
  ];

  void _sendCatalog(String buyerName) {
    setState(() {
      _sentCatalogs.add(buyerName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.task_alt_rounded, color: AppColors.secondaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Catalog successfully sent to $buyerName!',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductCreationProvider>();
    final matches = prov.buyerMatches;
    final targetPrice = prov.pricingResult.buyerFriendlyPrice;

    // Apply filter selection
    final filteredMatches = matches.where((res) {
      if (_selectedFilter == 'Verified B2B') {
        return res.buyer.verificationLabel.contains('B2B') ||
            res.buyer.verificationLabel.contains('Enterprise') ||
            res.buyer.verificationLabel.contains('Exporter');
      } else if (_selectedFilter == 'Chennai / Bengaluru') {
        return res.buyer.location.contains('Chennai') ||
            res.buyer.location.contains('Bengaluru');
      } else if (_selectedFilter == 'High Volume (100+)') {
        return res.buyer.maxQuantity >= 100 ||
            res.buyer.requirement.contains('100') ||
            res.buyer.requirement.contains('200') ||
            res.buyer.requirement.contains('150');
      }
      return true;
    }).toList();

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
              'AI Buyer Matching Network',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              '${matches.length} सत्यापित खरीदार उपलब्ध • Step 4 of 4',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (prov.firestoreSaveError != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        prov.firestoreSaveError!,
                        style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () => prov.saveBuyerMatchesToFirestore(),
                      child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error)),
                    ),
                  ],
                ),
              ),
            ],
            // Header summary
            Text(
              '${matches.length} Verified Buyers Matched',
              style: GoogleFonts.epilogue(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'AI Match Score • Based on product fit & buyer requirements. Direct payment through 50% advance via escrow.',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Horizontal Filter Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Matched Buyer Cards
            ...filteredMatches.map((BuyerMatchResult res) {
              final Buyer b = res.buyer;
              final isSent = _sentCatalogs.contains(b.name);
              final isHighMatch = res.matchScore >= 90;
              final fitsBudget = res.priceScore == 100;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isHighMatch
                        ? AppColors.secondary.withOpacity(0.4)
                        : AppColors.outlineVariant,
                    width: isHighMatch ? 1.5 : 0.6,
                  ),
                  boxShadow: AppTheme.elevation1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: res.matchScore >= 90
                                ? AppColors.secondaryContainer
                                : (res.matchScore >= 75
                                    ? AppColors.primaryFixed
                                    : AppColors.surfaceContainerHigh),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${res.matchScore}% ${BuyerMatchingService.matchQualityLabel(res.matchScore)}',
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: res.matchScore >= 90
                                  ? AppColors.onSecondaryContainer
                                  : (res.matchScore >= 75
                                      ? AppColors.onPrimaryFixed
                                      : AppColors.onSurfaceVariant),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded,
                                size: 16, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              b.verificationLabel,
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Storefront + Name + Location
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: prov.enhancedImageBytes != null
                              ? Image.memory(
                                  prov.enhancedImageBytes!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                )
                              : (prov.imageBytes != null
                                  ? Image.memory(
                                      prov.imageBytes!,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      DemoData.enhancedPotImageUrl,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 64,
                                        height: 64,
                                        color: AppColors.surfaceContainerLow,
                                        child: const Icon(Icons.storefront_rounded,
                                            color: AppColors.primary),
                                      ),
                                    )),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.name,
                                style: GoogleFonts.epilogue(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${b.location}, ${b.state} • ${b.distanceKm.toInt()} km away',
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 16, color: Color(0xFFEAB308)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${b.rating} (${b.completedOrders} orders paid on-time)',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Requirement & Budget
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Requirement:',
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                b.requirement,
                                style: GoogleFonts.epilogue(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Target Budget:',
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                fitsBudget
                                    ? '${b.budgetRange} (Fits ₹$targetPrice ✨)'
                                    : '${b.budgetRange} (Target ₹$targetPrice)',
                                style: GoogleFonts.epilogue(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: fitsBudget ? AppColors.primary : AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dynamic Match Reasons
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: res.reasons.map((p) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_rounded,
                                size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              p,
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    // Explainable AI Match Insight
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              res.recommendation,
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _sendCatalog(b.name),
                            icon: Icon(
                              isSent ? Icons.check_circle_rounded : Icons.send_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(
                              isSent ? 'Catalog Sent ✓' : 'Send 1-Click Catalog',
                              style: GoogleFonts.epilogue(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isSent ? AppColors.secondary : AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Connecting to ${b.name}...'),
                                backgroundColor: AppColors.inverseSurface,
                              ),
                            );
                          },
                          icon: const Icon(Icons.call_rounded, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
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
                child: ElevatedButton.icon(
                  onPressed: prov.isSavingToFirestore
                      ? null
                      : () async {
                          final auth = context.read<AuthProvider>();
                          if (auth.isAuthenticated) {
                            final ok = await prov.publishProductToFirestore();
                            if (!ok) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Publish failed: ${prov.firestoreSaveError ?? "Unknown error"}',
                                      style: GoogleFonts.notoSans(fontSize: 12),
                                    ),
                                    action: SnackBarAction(
                                      label: 'Retry',
                                      textColor: Colors.white,
                                      onPressed: () => prov.publishProductToFirestore(),
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
                          } else {
                            prov.publish();
                          }
                          if (context.mounted) {
                            context.push('/publish');
                          }
                        },
                  icon: prov.isSavingToFirestore
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.rocket_launch_rounded, color: Colors.white),
                  label: Text(
                    prov.isSavingToFirestore
                        ? 'Publishing & Broadcasting...'
                        : 'Publish & Broadcast (प्रकाशित करें)',
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
              Text(
                'Notifies ${matches.length} matched verified buyers instantly via WhatsApp & SMS',
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
