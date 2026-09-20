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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          context.read<OrdersProvider>().fetchCloudOrders(uid);
        }
      });
    } else if (!isAuth && _lastLoadedUid != null) {
      _lastLoadedUid = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<AppStateProvider>().clearCloudProducts();
          context.read<OrdersProvider>().clearCloudOrders();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                _buildGreeting(context),
                const SizedBox(height: 16),
                _buildVoiceAssistantCard(context),
                const SizedBox(height: 20),
                _buildKpiSection(context),
                const SizedBox(height: 20),
                _buildAddProductBanner(context),
                const SizedBox(height: 20),
                _buildDraftCard(context),
                const SizedBox(height: 20),
                _buildAiRecommendation(context),
                const SizedBox(height: 20),
                _buildRecentProducts(context),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.surface.withValues(alpha: 0.9),
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 64,
      title: Row(
        children: [
          // CraftMitra emblem placeholder (terracotta circle)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.recessedSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('CraftMitra',
                      style: GoogleFonts.epilogue(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      )),
                ],
              ),
              Text('क्राफ़्टमित्र',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  )),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.translate_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text('EN | अ | த',
                  style: GoogleFonts.notoSans(
                      fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => showAuthModal(context),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: const Icon(Icons.person_rounded,
                    size: 20, color: AppColors.onSurfaceVariant),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: context.watch<AuthProvider>().isAuthenticated
                        ? AppColors.secondary
                        : AppColors.outlineVariant,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning, Ramprasad ji 👋',
                style: GoogleFonts.epilogue(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text('शुभ प्रभात',
                      style: GoogleFonts.notoSans(
                          fontSize: 13, color: AppColors.onSurfaceVariant)),
                  const SizedBox(width: 6),
                  Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.outline)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text("Let's grow your craft business today",
                        style: GoogleFonts.notoSans(
                            fontSize: 13, color: AppColors.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.surfaceContainerHigh,
          child:
              const Icon(Icons.person, size: 28, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildVoiceAssistantCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.elevation1,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.mic_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('बोलकर पूछें (Voice Assistant)',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        )),
                    Text('"Ask CraftMitra in Hindi or Tamil"',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/ai-assistant'),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.elevation2,
                  ),
                  child: const Icon(Icons.graphic_eq_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Audio waveform visualization
          Row(
            children: [
              ...List.generate(6, (i) {
                final heights = [8.0, 16.0, 24.0, 12.0, 20.0, 8.0];
                final opacities = [1.0, 0.7, 1.0, 0.5, 1.0, 0.8];
                return Container(
                  width: 5,
                  height: heights[i],
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: opacities[i]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '"आज कितने ऑर्डर डिस्पैच करने हैं?"',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiSection(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final ordersProv = context.watch<OrdersProvider>();
    final auth = context.watch<AuthProvider>();
    final isAuth = auth.isAuthenticated;

    final productsCount = isAuth ? appState.cloudProducts.length : 24;
    final cloudOrders = ordersProv.cloudOrders;
    final activeOrdersCount = isAuth
        ? cloudOrders.where((o) => !o.isCompleted && o.currentStatus != OrderStatus.cancelled).length
        : 8;
    final pendingValue = isAuth
        ? cloudOrders
            .where((o) => !o.isCompleted && o.currentStatus != OrderStatus.cancelled)
            .fold<double>(0.0, (sum, o) => sum + o.totalValue)
        : 42500.0;
    final pendingSubtitle = isAuth
        ? '₹${pendingValue.toInt()} in progress'
        : '₹42,500 pending';

    final totalSalesValue = isAuth ? ordersProv.salesData.totalEarnings : 18450.0;
    final salesSubtitle = isAuth
        ? '${ordersProv.salesData.totalOrders} completed'
        : '+18% MoM';

    final totalMatchedBuyers = isAuth
        ? appState.cloudProducts.fold<int>(0, (sum, p) => sum + (p.buyerMatchCount ?? p.topBuyerMatches?.length ?? 0))
        : 12;
    final buyerSubtitle = isAuth ? 'Targeted buyers' : 'Verified matches';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('व्यापार सारांश (Overview)',
                style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface)),
            Row(
              children: [
                const Icon(Icons.sync_rounded,
                    size: 14, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text(isAuth ? 'Cloud Synced' : 'Demo Mode',
                    style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.go('/products'),
                child: _kpiCard(
                  'उत्पाद (Products)',
                  '$productsCount',
                  isAuth ? '${appState.publishedProducts.length} published' : '+3 this week',
                  Icons.inventory_2_rounded,
                  AppColors.surfaceContainerLow,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => context.go('/orders'),
                child: _kpiCard(
                  'सक्रिय ऑर्डर (Orders)',
                  '$activeOrdersCount',
                  pendingSubtitle,
                  Icons.local_shipping_rounded,
                  AppColors.secondaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/sales'),
                child: _kpiCard(
                  'बिक्री (Sales)',
                  '₹${totalSalesValue.toInt()}',
                  salesSubtitle,
                  Icons.payments_rounded,
                  AppColors.surfaceContainerLow,
                  iconColor: AppColors.tertiary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => context.go('/buyers'),
                child: _kpiCard(
                  'खरीदार (Buyers)',
                  '$totalMatchedBuyers',
                  buyerSubtitle,
                  Icons.storefront_rounded,
                  AppColors.surfaceContainerHigh,
                  trendIcon: Icons.verified_rounded,
                  trendColor: AppColors.tertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard(String label, String value, String trend, IconData icon,
      Color bg,
      {Color iconColor = AppColors.primary,
      IconData trendIcon = Icons.arrow_upward_rounded,
      Color trendColor = AppColors.secondary}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label,
                    style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.epilogue(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(trendIcon, size: 13, color: trendColor),
              const SizedBox(width: 3),
              Expanded(
                child: Text(trend,
                    style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: trendColor),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/add-product'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryContainer,
              AppColors.primary,
              AppColors.tertiary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.elevation2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('AI Magic Studio • तुरंत बनाएं',
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            )),
                      ),
                      const SizedBox(height: 6),
                      Text('+ Add New Product',
                          style: GoogleFonts.epilogue(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
                      Text('नया उत्पाद जोड़ें और पूरे भारत में बेचें',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                          )),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // 3 step mini cards
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stepMini(Icons.photo_camera_rounded, '1. Snap Photo'),
                  _stepMini(Icons.mic_rounded, '2. Speak Info'),
                  _stepMini(Icons.bolt_rounded, '3. Live Catalog'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppTheme.elevation1,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text('Start Product Cataloging (शुरू करें)',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepMini(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.notoSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildDraftCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.elevation1,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_edu_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 6),
                  Text('Continue Your Work',
                      style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('75% Done',
                    style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image_rounded,
                    color: AppColors.onSurfaceVariant, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Terracotta Decorative Flower Pot',
                        style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface)),
                    Text('मिट्टी का सजावटी गमला • Almost ready for B2B buyers',
                        style: GoogleFonts.notoSans(
                            fontSize: 13, color: AppColors.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.75,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Step checklist
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _checkItem('Photo', true),
              _checkItem('Details', true),
              _checkItem('Smart Price', true),
              _checkItem('Publish', false),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.push('/add-product'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue to Publish (आगे बढ़ें)',
                      style: GoogleFonts.notoSans(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkItem(String label, bool done) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 16,
          color: done ? AppColors.secondary : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 3),
        Text(label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: done ? AppColors.secondary : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            )),
      ],
    );
  }

  Widget _buildAiRecommendation(BuildContext context) {
    final prov = context.watch<ProductCreationProvider>();
    final topScore = prov.buyerMatches.isNotEmpty
        ? prov.buyerMatches.first.matchScore
        : 94;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryFixed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 13, color: AppColors.onTertiaryFixedVariant),
                    const SizedBox(width: 4),
                    Text('✨ AI Recommendation',
                        style: GoogleFonts.notoSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onTertiaryFixedVariant)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$topScore% Match',
                    style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
              '3 High-Value B2B Buyers are looking for Terracotta Decor!',
              style: GoogleFonts.epilogue(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface)),
          const SizedBox(height: 4),
          Text(
              'चेन्नई और बेंगलुरु के बुटीक होटल और एक्सपोर्ट खरीदार थोक ऑर्डर ढूंढ रहे हैं।',
              style: GoogleFonts.notoSans(
                  fontSize: 13, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                      child: Text('₹',
                          style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary))),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Avg. Order: ₹35,000 - ₹80,000',
                        style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface)),
                    Text('Estimated shipment: 15-20 days',
                        style: GoogleFonts.notoSans(
                            fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.go('/buyers'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('View 3 Buyer Inquiries (खरीदार देखें)',
                      style: GoogleFonts.notoSans(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  const Icon(Icons.east_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProducts(BuildContext context) {
    final appProducts = context.watch<AppStateProvider>().products;
    final products = appProducts.isNotEmpty ? appProducts : DemoData.products;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Products (हाल के उत्पाद)',
                    style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface)),
                Text('Manage listings & live inventory',
                    style: GoogleFonts.notoSans(
                        fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
            GestureDetector(
              onTap: () => context.go('/products'),
              child: Row(
                children: [
                  Text('View All (सभी)',
                      style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...products.map((Product p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _productListItem(context, p),
            )),
      ],
    );
  }

  Widget _productListItem(BuildContext context, Product product) {
    final isPublished = product.status == ProductStatus.published;
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.elevation1,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildProductThumbnail(product.imageUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface),
                      overflow: TextOverflow.ellipsis),
                  Text('₹${product.price.toInt()}',
                      style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  if (isPublished)
                    Row(
                      children: [
                        const Icon(Icons.visibility_rounded,
                            size: 12, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text('${product.views}',
                            style: GoogleFonts.notoSans(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant)),
                        const SizedBox(width: 8),
                        const Icon(Icons.shopping_bag_rounded,
                            size: 12, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text('${product.orders} orders',
                            style: GoogleFonts.notoSans(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant)),
                      ],
                    )
                  else
                    Text('Saved yesterday • Draft',
                        style: GoogleFonts.notoSans(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPublished
                        ? AppColors.secondaryContainer
                        : AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPublished ? 'Published' : 'Draft',
                    style: GoogleFonts.notoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isPublished
                          ? AppColors.secondary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  isPublished
                      ? Icons.more_vert_rounded
                      : Icons.edit_rounded,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductThumbnail(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_rounded, color: AppColors.onSurfaceVariant, size: 28),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_rounded, color: AppColors.onSurfaceVariant, size: 28),
      );
    }
    return const Icon(Icons.image_rounded, color: AppColors.onSurfaceVariant, size: 28);
  }
}
