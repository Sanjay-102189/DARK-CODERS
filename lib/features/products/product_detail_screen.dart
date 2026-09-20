import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/demo_data.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final appProducts = context.watch<AppStateProvider>().products;
    final product = appProducts.firstWhere(
      (Product p) => p.id == productId,
      orElse: () => DemoData.products.firstWhere(
        (Product p) => p.id == productId,
        orElse: () => DemoData.products.first,
      ),
    );
    final isPublished = product.status == ProductStatus.published;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : context.go('/products'),
        ),
        title: Text('Product Details', style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildProductImage(product.imageUrl),
            ),
            const SizedBox(height: 16),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isPublished ? AppColors.secondaryContainer : AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(isPublished ? '✓ Published' : 'Draft', style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w700, color: isPublished ? AppColors.secondary : AppColors.onSurfaceVariant)),
            ),
            const SizedBox(height: 12),
            Text(product.name, style: GoogleFonts.epilogue(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            if (product.nameHindi.isNotEmpty)
              Text(product.nameHindi, style: GoogleFonts.notoSans(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('₹${product.price.toInt()}', style: GoogleFonts.epilogue(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 16),
            _infoRow('Category', product.category),
            _infoRow('Craft Technique', product.craftTechnique),
            _infoRow('Material', product.material),
            _infoRow('Origin', product.origin),
            const SizedBox(height: 16),
            Text('Description', style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(product.description, style: GoogleFonts.notoSans(fontSize: 15, color: AppColors.onSurface, height: 1.5)),
            const SizedBox(height: 16),
            if (product.keywords.isNotEmpty) ...[
              Text('Keywords', style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: product.keywords.map((k) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(k, style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
                )).toList(),
              ),
            ],
            if (product.voiceTranscript != null && product.voiceTranscript!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Artisan Voice Note (आवाज़ विवरण)', style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant, width: 0.5),
                ),
                child: Text('"${product.voiceTranscript}"', style: GoogleFonts.notoSans(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant)),
              ),
            ],
            if (product.baseCost != null && product.baseCost! > 0) ...[
              const SizedBox(height: 16),
              Text('Pricing Breakdown (लागत एवं लाभ)', style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _infoRow('Base Cost', '₹${product.baseCost?.toInt() ?? 0}'),
                    if (product.profit != null) _infoRow('Artisan Profit', '₹${product.profit?.toInt() ?? 0}'),
                    if (product.marginPercent != null) _infoRow('Margin', '${product.marginPercent?.toInt() ?? 0}%'),
                    _infoRow('Final Price', '₹${product.price.toInt()}'),
                  ],
                ),
              ),
            ],
            if (product.topBuyerMatches != null && product.topBuyerMatches!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Matched Buyers (${product.topBuyerMatches!.length})', style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              ...product.topBuyerMatches!.map((bm) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront_rounded, size: 18, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bm['buyerName'] ?? 'Buyer',
                            style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                          ),
                          if (bm['location'] != null)
                            Text(
                              bm['location'],
                              style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${bm['matchPercent'] ?? bm['matchScore'] ?? 90}% Match',
                        style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            if (isPublished) ...[
              const SizedBox(height: 20),
              Row(children: [
                _statCard('Views', '${product.views}', Icons.visibility_rounded),
                const SizedBox(width: 12),
                _statCard('Orders', '${product.orders}', Icons.shopping_bag_rounded),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateTestOrderDialog(context, product),
                  icon: const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white),
                  label: Text(
                    'Simulate Test Order (परीक्षण ऑर्डर बनाएं)',
                    style: GoogleFonts.epilogue(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: GoogleFonts.notoSans(fontSize: 13, color: AppColors.onSurfaceVariant))),
          Expanded(child: Text(value, style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface))),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 6),
            Text(value, style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            Text(label, style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.broken_image_rounded, size: 56, color: AppColors.onSurfaceVariant)),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.image_rounded, size: 56, color: AppColors.onSurfaceVariant)),
      );
    }
    return const Center(child: Icon(Icons.image_rounded, size: 64, color: AppColors.onSurfaceVariant));
  }

  void _showCreateTestOrderDialog(BuildContext context, Product product) {
    int selectedQty = 10;
    final hasMatches = product.topBuyerMatches != null && product.topBuyerMatches!.isNotEmpty;
    final firstMatch = hasMatches ? product.topBuyerMatches!.first : null;
    final selectedBuyer = firstMatch != null ? (firstMatch['buyerName'] as String? ?? 'FabIndia Sourcing') : 'FabIndia Sourcing';
    final selectedLocation = firstMatch != null ? (firstMatch['location'] as String? ?? 'New Delhi / NCR') : 'New Delhi / NCR';
    final selectedBuyerId = firstMatch != null ? (firstMatch['buyerId'] as String? ?? 'buyer-001') : 'buyer-001';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final unitPrice = product.price > 0 ? product.price : 850.0;
          final totalAmount = selectedQty * unitPrice;

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Simulate Test Order (परीक्षण ऑर्डर)',
                  style: GoogleFonts.epilogue(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Create a verified test purchase order for pipeline demonstration',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Buyer details
                Text('Buyer (खरीदार):', style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selectedBuyer, style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                            Text(selectedLocation, style: GoogleFonts.notoSans(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Quantity selector
                Text('Batch Quantity (मात्रा):', style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [5, 10, 25, 50].map((qty) {
                    final isSel = selectedQty == qty;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => selectedQty = qty),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.secondaryContainer : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel ? AppColors.secondary : AppColors.outlineVariant,
                              width: isSel ? 1.5 : 0.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$qty pcs',
                            style: GoogleFonts.epilogue(
                              fontSize: 13,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              color: isSel ? AppColors.secondary : AppColors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Total calculation summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Order Value: ($selectedQty × ₹${unitPrice.toInt()})',
                          style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      Text(
                        '₹${totalAmount.toInt()}',
                        style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: Selector<OrdersProvider, bool>(
                    selector: (_, p) => p.isCreatingOrder,
                    builder: (btnCtx, isCreating, _) {
                      return ElevatedButton(
                        onPressed: isCreating
                            ? null
                            : () async {
                                final prov = context.read<OrdersProvider>();
                                final ok = await prov.createTestOrder(
                                  product: product,
                                  buyerName: selectedBuyer,
                                  buyerLocation: selectedLocation,
                                  buyerId: selectedBuyerId,
                                  quantity: selectedQty,
                                );

                                if (ctx.mounted) {
                                  Navigator.of(ctx).pop();
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  if (ok) {
                                    final orderIdStr = prov.lastCreatedOrderId != null ? ' (${prov.lastCreatedOrderId})' : '';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Test order created successfully$orderIdStr',
                                                style: GoogleFonts.notoSans(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: AppColors.secondary,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        action: SnackBarAction(
                                          label: 'View Orders',
                                          textColor: Colors.white,
                                          onPressed: () => context.go('/orders'),
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed: ${prov.createOrderError ?? "Could not create order"}',
                                          style: GoogleFonts.notoSans(fontSize: 13),
                                        ),
                                        backgroundColor: AppColors.error,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isCreating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                'Confirm Test Order (ऑर्डर दर्ज करें)',
                                style: GoogleFonts.epilogue(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
