import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          'नमस्ते रामप्रसाद जी! 🙏 मैं आपका CraftMitra व्यापार साथी हूँ। आप मुझसे अपने व्यापार, ऑर्डर्स, खरीदारों या सरकारी योजनाओं के बारे में कुछ भी पूछ सकते हैं।',
      'english':
          'Hello Ramprasad ji! I am your CraftMitra Business Mitra. You can ask me anything about your orders, buyers, pricing, or government craft schemes.',
      'time': 'Just now',
    },
  ];

  final List<String> _suggestedPrompts = [
    'Which buyer pays fastest?',
    'PM विश्वकर्मा योजना पात्रता',
    'How many pots left in stock?',
    'How can I increase profit margin?',
    'Download GST invoice',
  ];

  void _sendMessage(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'isUser': true,
        'text': query,
        'time': 'Now',
      });
      _textController.clear();
    });

    _scrollToBottom();

    // Generate intelligent contextual response
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      String replyText = '';
      String replyEnglish = '';

      final lower = query.toLowerCase();
      if (lower.contains('buyer') || lower.contains('fastest') || lower.contains('खरीदार')) {
        replyText =
            '📊 दक्षिण लिविंग (Dakshin Living) सबसे तेज भुगतान करता है। उनका रिकॉर्ड 100% ऑन-टाइम है और वे ऑर्डर स्वीकार होते ही 50% एडवांस डिजिटल एस्क्रो में जमा कर देते हैं।';
        replyEnglish =
            'Dakshin Living pays fastest with 100% on-time record and 50% upfront escrow deposit upon PO acceptance.';
      } else if (lower.contains('vishwakarma') || lower.contains('योजना') || lower.contains('pm')) {
        replyText =
            '🏛️ आप पीएम विश्वकर्मा योजना के लिए 100% पात्र हैं! आपको ₹15,000 टूलकिट ग्रांट और 5% रियायती ब्याज दर पर ₹1,00,000 तक का कोलेटरल-फ्री ऋण मिल सकता है। क्या आप आवेदन फॉर्म का प्रारूप देखना चाहते हैं?';
        replyEnglish =
            'You are 100% eligible for PM Vishwakarma Yojana with ₹15,000 toolkit grant and up to ₹1,00,000 collateral-free loan at 5% interest.';
      } else if (lower.contains('stock') || lower.contains('pots') || lower.contains('बर्तन')) {
        replyText =
            '🏺 आपके पास अभी 120 तैयार मिट्टी के गुलदस्ते हैं। इसमें से 50 पीस दक्षिण लिविंग के ऑर्डर #CM-8821 के लिए आरक्षित हैं। 70 पीस नए खरीदारों के लिए तुरंत उपलब्ध हैं।';
        replyEnglish =
            'You currently have 120 ready terracotta vases. 50 are allocated to order #CM-8821, leaving 70 ready for immediate dispatch.';
      } else if (lower.contains('profit') || lower.contains('margin') || lower.contains('मुनाफा')) {
        replyText =
            '💡 AI सुझाव: अपनी कच्ची मिट्टी सीधे स्थानीय नदी किनारे से थोक में लेने और उत्सव के गिफ्ट बॉक्स पैकेजिंग जोड़ने से आपका शुद्ध लाभ मार्जिन 30% से बढ़कर 42% (₹980 प्रति पीस) हो सकता है!';
        replyEnglish =
            'AI tip: Sourcing bulk river clay and adding festive gift packaging can raise your net margin from 30% to 42% (₹980/piece).';
      } else {
        replyText =
            '✅ मैंने आपकी बात नोट कर ली है। आपके क्राफ्ट रिकॉर्ड के अनुसार यह जानकारी आपके प्रोफाइल और ऑर्डर शीट में अपडेट कर दी गई है।';
        replyEnglish =
            'Understood! Based on your craft records, this information has been referenced against your cluster data.';
      }

      setState(() {
        _messages.add({
          'isUser': false,
          'text': replyText,
          'english': replyEnglish,
          'time': 'Just now',
        });
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleVoiceMic() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && _isListening) {
          setState(() {
            _isListening = false;
          });
          _sendMessage('कौन सा खरीदार सबसे तेज भुगतान करता है? (Which buyer pays fastest?)');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Business Mitra',
                  style: GoogleFonts.epilogue(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'व्यापार साथी • Online',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Suggested prompt chips
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _suggestedPrompts[index];
                return ActionChip(
                  label: Text(
                    prompt,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  backgroundColor: AppColors.surfaceContainerHigh,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () => _sendMessage(prompt),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),

          // Chat messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppColors.primary
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 18),
                      ),
                      border: isUser
                          ? null
                          : Border.all(color: AppColors.outlineVariant, width: 0.6),
                      boxShadow: AppTheme.elevation1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'] as String,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: isUser ? Colors.white : AppColors.onSurface,
                            height: 1.4,
                          ),
                        ),
                        if (msg['english'] != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            msg['english'] as String,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            msg['time'] as String,
                            style: GoogleFonts.notoSans(
                              fontSize: 10,
                              color: isUser ? Colors.white70 : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Listening visualizer banner if active
          if (_isListening)
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.primaryFixed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.graphic_eq_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Listening in Hindi / Marwari (सुन रहे हैं...)',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimaryFixed,
                    ),
                  ),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.notoSans(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ask in Hindi, Tamil, English...',
                        hintStyle: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Mic button
                  GestureDetector(
                    onTap: _toggleVoiceMic,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening ? AppColors.secondary : AppColors.primary,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Send button
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                    onPressed: () => _sendMessage(_textController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
