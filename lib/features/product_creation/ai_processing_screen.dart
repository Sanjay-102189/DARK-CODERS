import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class AiProcessingScreen extends StatefulWidget {
  const AiProcessingScreen({super.key});

  @override
  State<AiProcessingScreen> createState() => _AiProcessingScreenState();
}

class _AiProcessingScreenState extends State<AiProcessingScreen> {
  int _currentStep = 0;
  bool _processingStarted = false;
  Future<void>? _aiFuture;

  final List<Map<String, String>> _steps = [
    {
      'title': 'Reading Product Image',
      'hindi': 'उत्पाद फ़ोटो विश्लेषण',
      'desc': 'Analyzing visual craft details, material contours, and texture',
    },
    {
      'title': 'Understanding Craft Attributes',
      'hindi': 'शिल्प विशेषताएं समझना',
      'desc': 'Analyzing image visual evidence and artisan spoken description',
    },
    {
      'title': 'Generating Bilingual Catalog',
      'hindi': 'द्विभाषी विवरण निर्माण',
      'desc': 'Drafting professional e-commerce title, story, and discovery tags',
    },
    {
      'title': 'Preparing Product Listing',
      'hindi': 'उत्पाद सूचीकरण तैयारी',
      'desc': 'Structuring craft attributes for catalog preview & smart pricing',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _processingStarted) return;
      _processingStarted = true;
      _startProcessingFlow();
    });
  }

  void _startProcessingFlow() async {
    if (!mounted) return;
    setState(() {
      _currentStep = 0;
    });

    // Kick off real AI catalog generation in background
    _aiFuture = context.read<ProductCreationProvider>().runAiCatalogGeneration();

    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        _currentStep = i;
      });
    }

    // Await AI completion
    await _aiFuture;
    if (!mounted) return;

    final prov = context.read<ProductCreationProvider>();
    if (prov.aiStatus == AiGenerationStatus.failed) {
      // Keep on screen and show failure state with Retry and Demo actions
      setState(() {});
      return;
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    // Automatically navigate to catalog preview on success
    context.pushReplacement('/catalog-preview');
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductCreationProvider>();
    final isFailed = prov.aiStatus == AiGenerationStatus.failed;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Glowing AI Hexagon / Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFailed
                        ? [const Color(0xFFDC2626), const Color(0xFFF97316)]
                        : [const Color(0xFF9F3C16), const Color(0xFFD97706)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isFailed ? Colors.red : AppColors.primary).withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  isFailed ? Icons.error_outline_rounded : Icons.auto_awesome,
                  color: Colors.white,
                  size: 46,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                isFailed ? 'AI Generation Notice' : 'CraftMitra AI Studio',
                style: GoogleFonts.epilogue(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isFailed
                    ? 'कैटलॉग निर्माण में समस्या आई'
                    : (prov.aiStatusMessage ?? 'डिजिटल कैटलॉग तैयार किया जा रहा है...'),
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: isFailed ? Colors.red.shade700 : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 36),

              if (isFailed) ...[
                // Failure Error Card with explicit Retry and Demo options
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200, width: 1.2),
                    boxShadow: AppTheme.elevation1,
                  ),
                  child: Column(
                    children: [
                      Text(
                        prov.aiStatusMessage ?? "AI couldn't analyze the product right now. Please try again.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade900,
                        ),
                      ),
                      if (prov.aiTechnicalNote != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          prov.aiTechnicalNote!,
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action: Retry AI
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _startProcessingFlow();
                    },
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: Text(
                      'Retry AI with Gemini (पुनः प्रयास करें)',
                      style: GoogleFonts.epilogue(
                        fontSize: 14,
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
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Action: Use Demo Product
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      prov.useDemoProductCatalog();
                      context.pushReplacement('/catalog-preview');
                    },
                    icon: const Icon(Icons.science_outlined, color: AppColors.secondary),
                    label: Text(
                      'Use Demo Product / Demo Mode (डेमो उत्पाद)',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.secondary, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Sequential Progress Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant, width: 0.6),
                    boxShadow: AppTheme.elevation2,
                  ),
                  child: Column(
                    children: List.generate(_steps.length, (index) {
                      final isDone = index < _currentStep;
                      final isActive = index == _currentStep;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            '${index + 1}',
                                            style: GoogleFonts.notoSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _steps[index]['title']!,
                                    style: GoogleFonts.epilogue(
                                      fontSize: 13,
                                      fontWeight:
                                          isActive ? FontWeight.w700 : FontWeight.w600,
                                      color: isActive
                                          ? AppColors.onSurface
                                          : isDone
                                              ? AppColors.secondary
                                              : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    _steps[index]['desc']!,
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
                      );
                    }),
                  ),
                ),
              ],

              const Spacer(),

              // Quick skip button for fast demo/testing
              if (!isFailed) ...[
                TextButton(
                  onPressed: () async {
                    if (_aiFuture != null) {
                      await _aiFuture;
                    }
                    if (!context.mounted) return;
                    final p = context.read<ProductCreationProvider>();
                    if (p.aiStatus == AiGenerationStatus.success || p.aiStatus == AiGenerationStatus.demo) {
                      context.pushReplacement('/catalog-preview');
                    } else if (p.aiStatus == AiGenerationStatus.failed) {
                      setState(() {});
                    }
                  },
                  child: Text(
                    'Skip animation (त्वरित आगे बढ़ें)',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
