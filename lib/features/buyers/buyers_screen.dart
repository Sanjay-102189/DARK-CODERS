import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/buyer_matching_service.dart';

class BuyersScreen extends StatelessWidget {
  const BuyersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductCreationProvider>();
    final matches = prov.buyerMatches;
    final targetPrice = prov.pricingResult.buyerFriendlyPrice > 0
        ? prov.pricingResult.buyerFriendlyPrice
        : (prov.recommendedPrice > 0 ? prov.recommendedPrice.toInt() : 850);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buyer Network', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            Text('खरीदार नेटवर्क • ${matches.length} verified matches', style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final m = matches[index];
          final b = m.buyer;
          final score = m.matchScore;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.elevation1,
              border: Border.all(color: AppColors.outlineVariant, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: score >= 90
                            ? AppColors.secondaryContainer
                            : (score >= 75
                                ? AppColors.primaryFixed
                                : AppColors.surfaceContainer),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            score >= 90 ? Icons.stars_rounded : Icons.auto_graph_rounded,
                            size: 14,
                            color: score >= 90
                                ? AppColors.onSecondaryContainer
                                : (score >= 75 ? AppColors.onPrimaryFixed : AppColors.tertiary),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$score% ${BuyerMatchingService.matchQualityLabel(score)}',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: score >= 90
                                  ? AppColors.onSecondaryContainer
                                  : (score >= 75 ? AppColors.onPrimaryFixed : AppColors.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 3),
                        Text(b.verificationLabel, style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Business identity
                Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: AppColors.onSurfaceVariant, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.name, style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface), overflow: TextOverflow.ellipsis),
                          Row(children: [
                            const Icon(Icons.location_on_rounded, size: 13, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 3),
                            Text('${b.location}, ${b.state}', style: GoogleFonts.notoSans(fontSize: 13, color: AppColors.onSurfaceVariant)),
                          ]),
                          if (b.rating > 0) Row(children: [
                            const Icon(Icons.star_rounded, size: 14, color: AppColors.haldiGold),
                            const SizedBox(width: 3),
                            Text('${b.rating}', style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.w700)),
                            Text(' (${b.completedOrders} orders paid on-time)', style: GoogleFonts.notoSans(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Match insights
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Order Requirement:', style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.onSurfaceVariant)),
                        Text(b.requirement, style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                      ]),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Buyer Target Budget:', style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.onSurfaceVariant)),
                        Text(b.budgetRange, style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                      ]),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: m.reasons.map((r) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('✓ $r', style: GoogleFonts.notoSans(fontSize: 10, color: AppColors.onSurfaceVariant)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✨ Proposal sent to ${b.name} with ₹$targetPrice unit rate!'),
                                backgroundColor: AppColors.inverseSurface,
                              ),
                            );
                          },
                          icon: const Icon(Icons.bolt_rounded, size: 18),
                          label: Text('Send Catalog', style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 44, height: 44,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, side: BorderSide.none, backgroundColor: AppColors.surfaceContainerHigh),
                        child: const Icon(Icons.call_rounded, size: 20, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
