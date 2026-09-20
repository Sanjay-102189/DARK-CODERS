import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/demo_data.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  void _showStatusUpdateDialog(CraftOrder order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 18),
            Text(
              'Update Order Status',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'ऑर्डर की वर्तमान स्थिति बदलें',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _statusOptionTile(
              ctx,
              order,
              OrderStatus.accepted,
              'Accepted & Escrow Confirmed',
              'ऑर्डर स्वीकार किया गया',
              Icons.check_circle_outline_rounded,
            ),
            _statusOptionTile(
              ctx,
              order,
              OrderStatus.inProduction,
              'In Production & Crafting',
              'हस्तशिल्प निर्माण जारी है',
              Icons.local_fire_department_rounded,
            ),
            _statusOptionTile(
              ctx,
              order,
              OrderStatus.pickup,
              'Ready for Logistics Pickup',
              'पैकेजिंग पूर्ण, पिकअप हेतु तैयार',
              Icons.inventory_2_rounded,
            ),
            _statusOptionTile(
              ctx,
              order,
              OrderStatus.delivered,
              'Delivered & Completed (फाइनल बिक्री)',
              'खरीदार को प्राप्त हुआ — भुगतान जारी',
              Icons.task_alt_rounded,
              isFinal: true,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _statusOptionTile(
    BuildContext ctx,
    CraftOrder order,
    OrderStatus targetStatus,
    String title,
    String subtitle,
    IconData icon, {
    bool isFinal = false,
  }) {
    final isCurrent = order.currentStatus == targetStatus;

    return InkWell(
      onTap: () async {
        Navigator.pop(ctx);
        final prov = context.read<OrdersProvider>();
        final ok = await prov.updateOrderStatus(order.id, targetStatus);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ok
                          ? 'Order updated: $title'
                          : 'Failed to update order: ${prov.error ?? "Unknown error"}',
                      style: GoogleFonts.notoSans(fontSize: 13, color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: ok
                  ? (isFinal ? AppColors.secondary : AppColors.primary)
                  : AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.secondaryContainer.withValues(alpha: 0.5)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent ? AppColors.secondary : AppColors.outlineVariant,
            width: isCurrent ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isCurrent ? AppColors.secondary : AppColors.primary, size: 22),
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
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Current', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersProv = context.watch<OrdersProvider>();
    final decodedId = Uri.decodeComponent(widget.orderId);
    final order = ordersProv.getOrder(decodedId) ??
        DemoData.orders.firstWhere(
          (CraftOrder o) => o.id == decodedId,
          orElse: () => DemoData.orders.first,
        );

    final status = order.currentStatus;
    final isCompleted = order.isCompleted;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : context.go('/orders'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ${order.id}',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'ऑर्डर विवरण एवं ट्रैकिंग',
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
                const Icon(Icons.verified_user_rounded,
                    size: 14, color: AppColors.onSecondaryContainer),
                const SizedBox(width: 4),
                Text(
                  'Escrow Secured',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client & Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant, width: 0.6),
                boxShadow: AppTheme.elevation1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.secondaryContainer
                              : AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted ? AppColors.secondary : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              order.statusLabel,
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isCompleted ? AppColors.onSecondaryContainer : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Total: ₹${order.totalValue.toInt()}',
                        style: GoogleFonts.epilogue(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order.buyerName,
                    style: GoogleFonts.epilogue(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (order.buyerLocation.isNotEmpty)
                    Text(
                      order.buyerLocation,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  const Divider(height: 24, color: AppColors.outlineVariant),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: order.productImageUrl.startsWith('http')
                            ? Image.network(
                                order.productImageUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 48,
                                  height: 48,
                                  color: AppColors.surfaceContainerLow,
                                  child: const Icon(Icons.image, color: AppColors.primary),
                                ),
                              )
                            : Image.asset(
                                'assets/images/terracotta_vase.jpg',
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 48,
                                  height: 48,
                                  color: AppColors.surfaceContainerLow,
                                  child: const Icon(Icons.image, color: AppColors.primary),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.productName,
                              style: GoogleFonts.epilogue(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              '${order.quantity} units @ ₹${order.pricePerUnit.toInt()}',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5-Stage Delivery Stepper Timeline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Production & Delivery Timeline',
                  style: GoogleFonts.epilogue(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => _showStatusUpdateDialog(order),
                  icon: const Icon(Icons.edit_note_rounded, size: 20),
                  tooltip: 'Update status milestone',
                ),
              ],
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant, width: 0.6),
                boxShadow: AppTheme.elevation1,
              ),
              child: Column(
                children: [
                  _buildTimelineStage(
                    stageNum: '1',
                    title: '1. Order Placed & Escrow Locked',
                    desc: '${order.buyerName} PO confirmed for ${order.quantity} units',
                    isDone: status.index > OrderStatus.placed.index || isCompleted,
                    isActive: status == OrderStatus.placed && !isCompleted,
                    isLast: false,
                  ),
                  _buildTimelineStage(
                    stageNum: '2',
                    title: '2. Accepted by Artisan',
                    desc: '₹${(order.totalValue * 0.5).toInt()} (50% advance) locked in CraftMitra Escrow',
                    isDone: status.index > OrderStatus.accepted.index || isCompleted,
                    isActive: status == OrderStatus.accepted,
                    isLast: false,
                  ),
                  _buildTimelineStage(
                    stageNum: '3',
                    title: '3. Craft Production & Packaging',
                    desc: status == OrderStatus.inProduction
                        ? 'Handcrafting & kiln firing in progress (${order.readyCount}/${order.quantity} pieces)'
                        : 'Batch crafting & protective straw carton packing',
                    isDone: status.index > OrderStatus.inProduction.index || isCompleted,
                    isActive: status == OrderStatus.inProduction,
                    isLast: false,
                  ),
                  _buildTimelineStage(
                    stageNum: '4',
                    title: '4. Ready for Logistics Pickup',
                    desc: 'Doorstep collection scheduled via Logistics Mitra',
                    isDone: status.index > OrderStatus.pickup.index || isCompleted,
                    isActive: status == OrderStatus.pickup,
                    isLast: false,
                  ),
                  _buildTimelineStage(
                    stageNum: '5',
                    title: '5. Delivered & Payment Release (बिक्री पूर्ण)',
                    desc: isCompleted
                        ? 'Delivered successfully. ₹${order.totalValue.toInt()} credited to artisan account.'
                        : 'Direct transfer into SBI account upon doorstep delivery scan',
                    isDone: isCompleted,
                    isActive: isCompleted,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Escrow details card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondaryContainer, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_rounded, color: AppColors.secondary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Escrow Payment Security',
                        style: GoogleFonts.epilogue(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buyer deposited 50% advance (₹${(order.totalValue * 0.5).toInt()}) into digital escrow. Payment is guaranteed upon logistics milestone completion.',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
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
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tax Invoice #${order.id} downloaded')),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Invoice PDF'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showStatusUpdateDialog(order),
                  icon: const Icon(Icons.update_rounded, color: Colors.white, size: 18),
                  label: const Text('Update Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStage({
    required String stageNum,
    required String title,
    required String desc,
    required bool isDone,
    required bool isActive,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.secondary
                    : isActive
                        ? AppColors.primary
                        : AppColors.surfaceContainerHighest,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : isActive
                        ? const Icon(Icons.local_fire_department_rounded, size: 16, color: Colors.white)
                        : Text(
                            stageNum,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isDone ? AppColors.secondary : AppColors.outlineVariant,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.epilogue(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? AppColors.primary
                        : isDone
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
