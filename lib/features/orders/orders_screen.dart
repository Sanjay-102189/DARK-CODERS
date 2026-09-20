import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String? _lastLoadedUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    final uid = auth.currentUid;
    final isAuth = auth.isAuthenticated;

    if (isAuth && uid != null && uid != _lastLoadedUid) {
      _lastLoadedUid = uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<OrdersProvider>().fetchCloudOrders(uid);
        }
      });
    } else if (!isAuth && _lastLoadedUid != null) {
      _lastLoadedUid = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<OrdersProvider>().clearCloudOrders();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersProv = context.watch<OrdersProvider>();
    final auth = context.watch<AuthProvider>();
    final orders = ordersProv.orders;
    final isAuth = auth.isAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Orders', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            Text('ऑर्डर • ${orders.length} ${orders.length == 1 ? "order" : "orders"}${isAuth ? " (Cloud Synced)" : " (Demo)"}',
                style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.onSurfaceVariant)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/sales'),
            icon: const Icon(Icons.bar_chart_rounded, size: 18),
            label: Text('Sales', style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: _buildBody(context, ordersProv, auth, orders),
    );
  }

  Widget _buildBody(BuildContext context, OrdersProvider ordersProv, AuthProvider auth, List<CraftOrder> orders) {
    if (ordersProv.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
            SizedBox(height: 12),
            Text('Loading artisan orders...', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
          ],
        ),
      );
    }

    if (ordersProv.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                'Failed to load orders',
                style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                ordersProv.error!,
                style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (auth.currentUid != null) {
                    ordersProv.fetchCloudOrders(auth.currentUid!);
                  }
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Text(
                'No Orders Yet',
                style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Orders from verified buyers will appear here. Publish products to receive orders from retail and enterprise buyers.',
                style: GoogleFonts.notoSans(fontSize: 13, color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.go('/products'),
                icon: const Icon(Icons.storefront_rounded, size: 18),
                label: const Text('View Products & Simulate Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final o = orders[index];
        final isActive = o.currentStatus == OrderStatus.inProduction || o.currentStatus == OrderStatus.accepted;
        final isCompleted = o.isCompleted;

        return GestureDetector(
          onTap: () => context.push('/order/${Uri.encodeComponent(o.id)}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.elevation1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(o.id,
                            style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.tertiary,
                                letterSpacing: 0.5)),
                        if (o.isTestOrder) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Test Order',
                              style: GoogleFonts.notoSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.secondary),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.secondaryContainer
                            : isActive
                                ? AppColors.secondaryContainer
                                : AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isActive)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                            ),
                          Text(o.statusLabel,
                              style: GoogleFonts.notoSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isCompleted || isActive
                                      ? AppColors.onSecondaryContainer
                                      : AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(o.buyerName, style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                if (o.buyerLocation.isNotEmpty)
                  Text(o.buyerLocation, style: GoogleFonts.notoSans(fontSize: 13, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${o.productName} × ${o.quantity}',
                          style: GoogleFonts.notoSans(fontSize: 13, color: AppColors.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text('₹${_formatAmount(o.totalValue)}',
                        style: GoogleFonts.epilogue(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}k';
    return amount.toStringAsFixed(0);
  }
}
