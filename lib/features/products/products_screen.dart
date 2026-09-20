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

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _selectedTab = 0; // 0 = Cloud Products, 1 = Demo Catalog
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
          context.read<AppStateProvider>().fetchCloudProducts(uid);
        }
      });
    } else if (!isAuth && _lastLoadedUid != null) {
      _lastLoadedUid = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<AppStateProvider>().clearCloudProducts();
        }
      });
    }
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      await context.read<AppStateProvider>().fetchCloudProducts(auth.currentUid!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final appState = context.watch<AppStateProvider>();
    final cloudProducts = appState.cloudProducts;
    final demoProducts = appState.products.isNotEmpty ? appState.products : DemoData.products;

    final displayedProducts = _selectedTab == 0 ? cloudProducts : demoProducts;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Products',
              style: GoogleFonts.epilogue(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              _selectedTab == 0
                  ? (auth.isAuthenticated
                      ? 'क्लाउड सिंक • ${cloudProducts.length} items'
                      : 'क्लाउड उत्पाद • लॉगिन आवश्यक')
                  : 'डेमो सूची • ${demoProducts.length} items',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: auth.isAuthenticated ? 'Account: ${auth.email}' : 'Sign In',
            onPressed: () => showAuthModal(context),
            icon: Icon(
              auth.isAuthenticated ? Icons.account_circle : Icons.account_circle_outlined,
              color: auth.isAuthenticated ? AppColors.secondary : AppColors.primary,
            ),
          ),
          IconButton(
            onPressed: () => context.push('/add-product'),
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Tab Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedTab = 0);
                      if (auth.isAuthenticated) {
                        appState.fetchCloudProducts(auth.currentUid!);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? AppColors.surfaceContainerLowest
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _selectedTab == 0 ? AppTheme.elevation1 : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_done_rounded,
                            size: 16,
                            color: _selectedTab == 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'My Cloud (${cloudProducts.length})',
                            style: GoogleFonts.epilogue(
                              fontSize: 13,
                              fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                              color: _selectedTab == 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? AppColors.surfaceContainerLowest
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _selectedTab == 1 ? AppTheme.elevation1 : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 16,
                            color: _selectedTab == 1 ? AppColors.primary : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Demo Catalog',
                            style: GoogleFonts.epilogue(
                              fontSize: 13,
                              fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                              color: _selectedTab == 1 ? AppColors.primary : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: _selectedTab == 0
                ? _buildCloudTab(context, auth, appState, cloudProducts)
                : _buildProductsList(context, displayedProducts, isCloud: false),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudTab(
    BuildContext context,
    AuthProvider auth,
    AppStateProvider appState,
    List<Product> cloudProducts,
  ) {
    if (!auth.isAuthenticated) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Artisan Sign In Required',
                style: GoogleFonts.epilogue(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in with your artisan account to view and manage products saved in your Cloud Firestore collection.',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => showAuthModal(context),
                icon: const Icon(Icons.login_rounded, color: Colors.white),
                label: Text(
                  'Sign In / Register',
                  style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _selectedTab = 1),
                child: Text(
                  'View Demo Catalog Instead',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (appState.isLoadingCloudProducts) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Loading your cloud products...'),
          ],
        ),
      );
    }

    if (appState.cloudProductsError != null && cloudProducts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_off_rounded, size: 32, color: AppColors.error),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Sync Cloud Products',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              appState.cloudProductsError!,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Retry Fetch'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (cloudProducts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_queue_rounded, size: 36, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Products in Cloud Yet',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'When you capture a product, generate an AI catalog, and tap "Save Product", your catalog is stored here in Cloud Firestore.',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/add-product'),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add New Product',
                  style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildProductsList(context, cloudProducts, isCloud: true);
  }

  Widget _buildProductsList(BuildContext context, List<Product> products, {required bool isCloud}) {
    return RefreshIndicator(
      onRefresh: isCloud ? _refresh : () async {},
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          final isPublished = p.status == ProductStatus.published;
          return GestureDetector(
            onTap: () => context.push('/product/${p.id}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.elevation1,
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildProductThumbnail(p.imageUrl),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(
                              '₹${p.price.toInt()}',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            if (isCloud) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Cloud',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (isPublished)
                          Row(
                            children: [
                              const Icon(Icons.visibility_rounded, size: 13, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 3),
                              Text('${p.views}', style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.onSurfaceVariant)),
                              const SizedBox(width: 10),
                              const Icon(Icons.shopping_bag_rounded, size: 13, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 3),
                              Text('${p.orders} orders', style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.onSurfaceVariant)),
                            ],
                          )
                        else
                          Text(
                            p.status == ProductStatus.catalogReady
                                ? 'Catalog Ready • Pricing Pending'
                                : 'Draft • Tap to view',
                            style: GoogleFonts.notoSans(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPublished
                          ? AppColors.secondaryContainer
                          : AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPublished ? 'Published' : (p.status == ProductStatus.catalogReady ? 'Ready' : 'Draft'),
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isPublished ? AppColors.secondary : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductThumbnail(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_rounded, color: AppColors.onSurfaceVariant, size: 32),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_rounded, color: AppColors.onSurfaceVariant, size: 32),
      );
    }
    return const Icon(Icons.image_rounded, color: AppColors.onSurfaceVariant, size: 32);
  }
}
