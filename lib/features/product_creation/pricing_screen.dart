import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/demo_data.dart';
import '../../providers/providers.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  double _marginPercent = 30.0;
  bool _audioPlaying = false;

  @override
  void initState() {
    super.initState();
    final prov = context.read<ProductCreationProvider>();
    _marginPercent = prov.marginPercent.toDouble();
  }

  void _toggleAudioGuidance() {
    setState(() {
      _audioPlaying = !_audioPlaying;
    });
    if (_audioPlaying) {
      final prov = context.read<ProductCreationProvider>();
      final pricing = prov.pricingResult;
      final text = prov.selectedVoiceLanguage == 'English'
          ? pricing.voiceGuidanceEnglish
          : pricing.voiceGuidanceHindi;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text,
            style: GoogleFonts.notoSans(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: AppColors.inverseSurface,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  void _showEditCostDialog(
    BuildContext context, {
    required String title,
    required double currentValue,
    required Function(double) onSave,
  }) {
    double tempVal = currentValue;
    final textController = TextEditingController(text: currentValue.toInt().toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit $title (लागत बदलें)',
                        style: GoogleFonts.epilogue(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (tempVal >= 20) {
                            tempVal -= 20;
                            textController.text = tempVal.toInt().toString();
                            setModalState(() {});
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                      ),
                      Expanded(
                        child: TextField(
                          controller: textController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.epilogue(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            prefixStyle: GoogleFonts.epilogue(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onChanged: (val) {
                            final parsed = double.tryParse(val);
                            if (parsed != null && parsed >= 0) {
                              tempVal = parsed;
                            }
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          tempVal += 20;
                          textController.text = tempVal.toInt().toString();
                          setModalState(() {});
                        },
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final parsed = double.tryParse(textController.text);
                        if (parsed != null && parsed >= 0) {
                          onSave(parsed);
                        } else {
                          onSave(tempVal);
                        }
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Apply & Recalculate',
                        style: GoogleFonts.epilogue(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBatchQuantityDialog(
    BuildContext context,
    int currentQty,
    Function(int) onSave,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Batch / Order Quantity',
                style: GoogleFonts.epilogue(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bulk order discounts apply dynamically: 1–20 (0%), 21–100 (-3%), 101+ (-5%).',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuantityChoice(ctx, 15, 'Retail', '0% disc.', currentQty, onSave),
                  _buildQuantityChoice(ctx, 50, 'Standard', '-3% disc.', currentQty, onSave),
                  _buildQuantityChoice(ctx, 120, 'Bulk B2B', '-5% disc.', currentQty, onSave),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantityChoice(
    BuildContext ctx,
    int qty,
    String label,
    String badge,
    int currentQty,
    Function(int) onSave,
  ) {
    final isSelected = currentQty == qty;
    return InkWell(
      onTap: () {
        onSave(qty);
        Navigator.pop(ctx);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryContainer : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.outlineVariant,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$qty units',
              style: GoogleFonts.epilogue(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.onSecondaryContainer : AppColors.onSurface,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: GoogleFonts.notoSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductCreationProvider>();
    final pricing = prov.pricingResult;

    final rawMaterial = prov.rawMaterialCost;
    final craftLabor = prov.laborCost;
    final packaging = prov.packagingCost;
    final totalBaseCost = pricing.baseCost;
    final profit = pricing.profit;
    final targetPrice = pricing.buyerFriendlyPrice;

    // Sweetspot progress calculation
    final marketRange = pricing.marketCeiling - pricing.marketFloor;
    final sweetspotProgress = marketRange > 0
        ? ((targetPrice - pricing.marketFloor) / marketRange).clamp(0.05, 0.95)
        : 0.5;

    final productTitle = prov.catalog?.title ?? 'Handcrafted Terracotta Pot';
    final productBatchSize = prov.quantity;
    final productId = prov.productId.isNotEmpty ? prov.productId : 'CM-4091';

    final catalog = prov.catalog;
    final catLower = (catalog?.category ?? '').toLowerCase();
    final matLower = (catalog?.material ?? '').toLowerCase();
    final titleLower = (catalog?.title ?? '').toLowerCase();

    final isPotteryOrClay = prov.useDemoProduct ||
        catLower.contains('pottery') ||
        catLower.contains('terracotta') ||
        catLower.contains('clay') ||
        matLower.contains('clay') ||
        matLower.contains('terracotta') ||
        titleLower.contains('pot') ||
        titleLower.contains('vase') ||
        titleLower.contains('diya');

    final isCraft = isPotteryOrClay ||
        catLower.contains('handicraft') ||
        catLower.contains('craft') ||
        catLower.contains('brass') ||
        catLower.contains('wood') ||
        catLower.contains('textile') ||
        catLower.contains('metal') ||
        catLower.contains('decor') ||
        catLower.contains('sari') ||
        catLower.contains('shawl') ||
        catLower.contains('dhokra');

    final String rawCostTitle;
    final String rawCostDesc;
    final String laborCostTitle;
    final String laborCostDesc;
    final String packagingTitle;
    final String packagingDesc;

    if (isPotteryOrClay) {
      rawCostTitle = 'Raw Material';
      rawCostDesc = 'Clay & fuel';
      laborCostTitle = 'Craft Labor';
      laborCostDesc = '3.5 hrs effort';
      packagingTitle = 'Packaging';
      packagingDesc = 'Straw carton';
    } else if (isCraft) {
      rawCostTitle = 'Raw Material';
      rawCostDesc = 'Craft supplies';
      laborCostTitle = 'Craft Labor';
      laborCostDesc = 'Artisan labor';
      packagingTitle = 'Packaging';
      packagingDesc = 'Protective pack';
    } else {
      rawCostTitle = 'Raw/Product Cost';
      rawCostDesc = 'Unit cost';
      laborCostTitle = 'Processing/Labor';
      laborCostDesc = 'Labor/assembly';
      packagingTitle = 'Packaging';
      packagingDesc = 'Retail box';
    }

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
              'AI Smart Pricing',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'स्मार्ट मूल्य निर्धारण • Step 4 of 4',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          // Audio Guidance Button
          GestureDetector(
            onTap: _toggleAudioGuidance,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _audioPlaying ? AppColors.primary : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    _audioPlaying ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                    size: 16,
                    color: _audioPlaying ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'सुनें',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _audioPlaying ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                      onPressed: () => prov.savePricingToFirestore(),
                      child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error)),
                    ),
                  ],
                ),
              ),
            ],

            // Product Quick Glance Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant, width: 0.5),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: prov.enhancedImageBytes != null
                        ? Image.memory(
                            prov.enhancedImageBytes!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : (prov.imageBytes != null
                            ? Image.memory(
                                prov.imageBytes!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                DemoData.enhancedPotImageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: AppColors.surfaceContainerLow,
                                  child: const Icon(Icons.image, color: AppColors.primary),
                                ),
                              )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Verified Batch',
                                style: GoogleFonts.notoSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '#$productId',
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          productTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.epilogue(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _showBatchQuantityDialog(
                              context,
                              productBatchSize,
                              (qty) => prov.setQuantity(qty),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                'Batch size: $productBatchSize ready units in studio',
                                style: GoogleFonts.notoSans(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.edit_outlined, size: 12, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Cost Breakdown Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Cost Breakdown',
                      style: GoogleFonts.epilogue(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
                      ),
                      child: Text(
                        'Demo Cost Profile',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Base Cost: ₹${totalBaseCost.toInt()}',
                  style: GoogleFonts.epilogue(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3-Column Cost Breakdown Tiles (Tappable to edit)
            Row(
              children: [
                Expanded(
                  child: _buildCostTile(
                    title: rawCostTitle,
                    amount: '₹${rawMaterial.toInt()}',
                    desc: rawCostDesc,
                    icon: isCraft ? Icons.terrain_rounded : Icons.inventory_rounded,
                    onTap: () {
                      _showEditCostDialog(
                        context,
                        title: rawCostTitle,
                        currentValue: rawMaterial,
                        onSave: (val) => prov.updateCosts(rawMaterial: val),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCostTile(
                    title: laborCostTitle,
                    amount: '₹${craftLabor.toInt()}',
                    desc: laborCostDesc,
                    icon: isCraft ? Icons.pan_tool_alt_rounded : Icons.build_rounded,
                    onTap: () {
                      _showEditCostDialog(
                        context,
                        title: laborCostTitle,
                        currentValue: craftLabor,
                        onSave: (val) => prov.updateCosts(labor: val),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCostTile(
                    title: packagingTitle,
                    amount: '₹${packaging.toInt()}',
                    desc: packagingDesc,
                    icon: Icons.inventory_2_rounded,
                    onTap: () {
                      _showEditCostDialog(
                        context,
                        title: packagingTitle,
                        currentValue: packaging,
                        onSave: (val) => prov.updateCosts(packaging: val),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Margin Slider Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant, width: 0.6),
                boxShadow: AppTheme.elevation1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Desired Profit Margin',
                        style: GoogleFonts.epilogue(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${pricing.marginPercent}% (+₹${profit.toInt()} profit)',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.surfaceContainerHighest,
                      thumbColor: AppColors.primary,
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _marginPercent.clamp(15.0, 50.0),
                      min: 15,
                      max: 50,
                      divisions: 7,
                      onChanged: (val) {
                        setState(() {
                          _marginPercent = val;
                        });
                        prov.setMargin(val.toInt());
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Min (15% / ₹${(totalBaseCost * 0.15).round()})',
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Market (~${pricing.suggestedMargin.round()}% / ₹${(totalBaseCost * (pricing.suggestedMargin / 100)).round()})',
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Premium (50% / ₹${(totalBaseCost * 0.50).round()})',
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // AI Recommendation Target Banner (#9F3C16 Terracotta)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9F3C16), Color(0xFFBF542C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.auto_awesome, size: 14, color: AppColors.tertiaryFixed),
                                const SizedBox(width: 4),
                                Text(
                                  'AI-Assisted Target',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${pricing.confidenceScore}% Confidence',
                              style: GoogleFonts.notoSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Price Accepted ✓',
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹$targetPrice',
                        style: GoogleFonts.epilogue(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ piece (प्रति पीस)',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Market Sweetspot Visual Bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${pricing.marketFloor.toInt()} Floor',
                              style: GoogleFonts.notoSans(fontSize: 11, color: Colors.white70),
                            ),
                            Text(
                              '● ₹${pricing.sweetSpot.toInt()} Sweetspot',
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '₹${pricing.marketCeiling.toInt()} Ceiling',
                              style: GoogleFonts.notoSans(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: sweetspotProgress,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryContainer),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pricing.marketContext,
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Transparent AI Explainability Box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: AppColors.tertiaryFixed),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            pricing.reasoning,
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.92),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Fair Trade Escrow Guarantee
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondaryContainer, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded, color: AppColors.secondary, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CraftMitra Escrow Protection',
                          style: GoogleFonts.epilogue(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          '50% advance via escrow is locked into digital escrow before dispatch.',
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
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
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: prov.isSavingToFirestore
                  ? null
                  : () async {
                      final prov = context.read<ProductCreationProvider>();
                      prov.acceptPrice();

                      final auth = context.read<AuthProvider>();
                      if (auth.isAuthenticated) {
                        final ok = await prov.savePricingToFirestore();
                        if (!ok) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Pricing save failed: ${prov.firestoreSaveError ?? "Unknown error"}',
                                  style: GoogleFonts.notoSans(fontSize: 12),
                                ),
                                action: SnackBarAction(
                                  label: 'Retry',
                                  textColor: Colors.white,
                                  onPressed: () => prov.savePricingToFirestore(),
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
                        context.push('/buyer-match');
                      }
                    },
              icon: prov.isSavingToFirestore
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.people_alt_rounded, color: Colors.white),
              label: Text(
                prov.isSavingToFirestore
                    ? 'Saving Pricing...'
                    : 'Match Verified Buyers (खरीदार खोजें)',
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
        ),
      ),
    );
  }

  Widget _buildCostTile({
    required String title,
    required String amount,
    required String desc,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                if (onTap != null)
                  const Icon(Icons.edit_outlined, size: 12, color: AppColors.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: GoogleFonts.epilogue(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              desc,
              style: GoogleFonts.notoSans(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
