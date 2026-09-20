import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/demo_data.dart';
import '../../providers/providers.dart';

class VoiceCatalogScreen extends StatefulWidget {
  const VoiceCatalogScreen({super.key});

  @override
  State<VoiceCatalogScreen> createState() => _VoiceCatalogScreenState();
}

class _VoiceCatalogScreenState extends State<VoiceCatalogScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Warm up voice recognition engine safely on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final prov = context.read<ProductCreationProvider>();
        if (!prov.isRecording && prov.voiceTranscript.isEmpty) {
          prov.retryVoiceInit();
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    final prov = context.read<ProductCreationProvider>();
    if (prov.isRecording) {
      await prov.stopVoiceRecording();
    } else {
      await prov.startVoiceRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductCreationProvider>();
    final selectedLang = prov.selectedVoiceLanguage;
    final isListening = prov.isRecording;
    final hasRealTranscript = prov.voiceTranscript.isNotEmpty;

    // Display transcript: real recognized words, or demo if selected, or empty prompt
    final String displayTranscript;
    final String transcriptBadge;
    if (hasRealTranscript) {
      displayTranscript = prov.voiceTranscript;
      transcriptBadge = 'Live Recognized Transcript';
    } else if (prov.useDemoVoice) {
      displayTranscript = DemoData.demoTranscript;
      transcriptBadge = 'Demo Voice Transcript';
    } else {
      displayTranscript = 'Tap microphone to describe your product (or tap Edit to type)...';
      transcriptBadge = 'Awaiting Voice Input';
    }

    final catalog = prov.catalog;
    final catLower = (catalog?.category ?? '').toLowerCase();
    final matLower = (catalog?.material ?? '').toLowerCase();
    final techLower = (catalog?.craftTechnique ?? '').toLowerCase();

    final String geminiInsight;
    if (prov.useDemoProduct ||
        catLower.contains('terracotta') ||
        catLower.contains('pottery') ||
        catLower.contains('clay') ||
        matLower.contains('clay') ||
        matLower.contains('terracotta')) {
      geminiInsight =
          'Gemini detects: Terracotta clay, wheel pottery technique and traditional handmade craft.';
    } else if (catalog != null &&
        (techLower.contains('confirmation') ||
            matLower.contains('confirmation') ||
            catalog.craftTechnique.contains('confirm') ||
            catalog.material.contains('confirm'))) {
      geminiInsight =
          'Gemini identified some attributes that need artisan confirmation.';
    } else if (catalog != null) {
      geminiInsight =
          'Gemini has analyzed the product image and voice description.';
    } else {
      geminiInsight =
          'Gemini AI will analyze your product photograph and spoken voice context.';
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
              'Voice Description',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'आवाज से विवरण • Step 3 of 4',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          // Demo Auto-fill button
          TextButton.icon(
            onPressed: () {
              prov.selectDemoVoice();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Demo speech loaded in $selectedLang',
                    style: GoogleFonts.notoSans(color: Colors.white),
                  ),
                  backgroundColor: AppColors.inverseSurface,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.auto_fix_normal, size: 16, color: AppColors.primary),
            label: Text(
              'Demo Voice',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title & Subtitle
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tell Us About Your Craft',
                    style: GoogleFonts.epilogue(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'अपने उत्पाद के बारे में खुलकर बोलें',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Speak naturally in your mother tongue — AI auto-translates, detects craft heritage, and writes your buyer catalog.',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Language Selector Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant, width: 0.5),
              ),
              child: Row(
                children: [
                  _buildLangTab('हिन्दी (Hindi)', selectedLang == 'Hindi', () {
                    prov.selectVoiceLanguage('Hindi');
                  }),
                  _buildLangTab('தமிழ் (Tamil)', selectedLang == 'Tamil', () {
                    prov.selectVoiceLanguage('Tamil');
                  }),
                  _buildLangTab('English', selectedLang == 'English', () {
                    prov.selectVoiceLanguage('English');
                  }),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Hero Mic Button with Concentric Animated Rings
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final scale = isListening ? 1.0 + (_animController.value * 0.12) : 1.0;
                  final outerScale = isListening ? 1.0 + (_animController.value * 0.25) : 1.0;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outermost ripple ring
                      if (isListening)
                        Transform.scale(
                          scale: outerScale,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.12),
                            ),
                          ),
                        ),
                      // Middle ring
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isListening
                              ? AppColors.primary.withOpacity(0.25)
                              : AppColors.primaryFixed,
                        ),
                      ),
                      // Core 80x80px gradient button
                      Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9F3C16), Color(0xFFBF542C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // State Label
            Text(
              isListening
                  ? 'Listening... (सुन रहे हैं... ${prov.recordingDuration}s)'
                  : (hasRealTranscript
                      ? 'Recording Complete (आवाज दर्ज हो गई ✓)'
                      : 'Tap microphone to describe your product (बोलने के लिए दबाएं)'),
              style: GoogleFonts.epilogue(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isListening ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),

            // Waveform Amplitude Visualizer
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(9, (index) {
                  final heights = [12.0, 24.0, 36.0, 18.0, 32.0, 28.0, 14.0, 26.0, 10.0];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200 + (index * 40)),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 4,
                    height: isListening
                        ? (heights[index] * (0.5 + (_animController.value * 0.7)))
                        : 8.0,
                    decoration: BoxDecoration(
                      color: isListening ? AppColors.primary : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // Graceful Fallback / Error Banner if Voice Recognition is unavailable
            if (prov.voiceError != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.error.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prov.voiceError!,
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onErrorContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tip: You can still type your description manually below or tap "Use Demo Voice" to proceed.',
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
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => prov.retryVoiceInit(),
                        icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                        label: Text(
                          'Retry Mic Setup',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Live Transcription Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
                      Row(
                        children: [
                          Icon(
                            hasRealTranscript
                                ? Icons.verified_rounded
                                : Icons.mic_none_rounded,
                            size: 16,
                            color: hasRealTranscript ? AppColors.secondary : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            transcriptBadge,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: hasRealTranscript ? AppColors.secondary : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryFixed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selectedLang,
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onTertiaryFixed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '"$displayTranscript"',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: hasRealTranscript || prov.useDemoVoice
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                      height: 1.5,
                      fontStyle: hasRealTranscript ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasRealTranscript)
                        TextButton.icon(
                          onPressed: () {
                            prov.clearVoiceTranscript();
                          },
                          icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.error),
                          label: Text(
                            'Clear',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      TextButton.icon(
                        onPressed: () {
                          _showEditTranscriptDialog(
                            context,
                            hasRealTranscript
                                ? prov.voiceTranscript
                                : (prov.useDemoVoice ? DemoData.demoTranscript : ''),
                          );
                        },
                        icon: const Icon(Icons.edit_note_rounded, size: 18),
                        label: Text(
                          hasRealTranscript ? 'Edit Transcript (संपादन)' : 'Type Description (लिखें)',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI Features Highlight
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.tertiaryFixed.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.tertiary.withOpacity(0.2), width: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.tertiary, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      geminiInsight,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
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
              onPressed: () {
                context.push('/ai-processing');
              },
              icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
              label: Text(
                'Generate AI Catalog with Gemini',
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

  Widget _buildLangTab(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  void _showEditTranscriptDialog(BuildContext context, String currentText) {
    final controller = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        title: Text(
          'Product Description',
          style: GoogleFonts.epilogue(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: GoogleFonts.notoSans(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Describe your craft in Hindi, Tamil, or English...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProductCreationProvider>().setTranscript(controller.text);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
