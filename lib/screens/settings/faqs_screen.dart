import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_colors.dart';
import '../../my_app.dart';
import '../../widgets/app_bar_widget.dart';

class FAQsScreen extends StatefulWidget {
  const FAQsScreen({super.key});

  @override
  State<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> faqs = const [
    {
      'category': 'General',
      'icon': '🍏',
      'question': 'What is Bratify?',
      'answer':
          'Bratify is the ultimate aesthetic post and meme studio inspired by Charli XCX\'s iconic Brat album aesthetic and Y2K pop culture. It lets you create viral low-res text memes, authentic grainy album covers, Polaroid & Digicam photos, and social posts in seconds.',
    },
    {
      'category': 'Studio & FX',
      'icon': '✨',
      'question': 'How do I get the authentic blurry "Brat" look?',
      'answer':
          '1. In Studio, select the classic text canvas or any Brat frame.\n'
          '2. Switch to the FX (Effects) tab.\n'
          '3. Set Blur Sigma between 1.0 and 2.5 (the sweet spot for low-res blur).\n'
          '4. Keep Film Grain enabled (~15%) and use Arial font in lowercase with negative letter-spacing for the exact signature look.',
    },
    {
      'category': 'Templates',
      'icon': '🖼️',
      'question': 'How do the 500 Aesthetic Frames work?',
      'answer':
          'Tap the "500 Frames" tab in the bottom bar to browse 10 curated categories:\n'
          '• 🍏 Brat & Album Covers\n'
          '• 📸 Polaroid & Vintage\n'
          '• 🎞️ Y2K & Digicam Overlays\n'
          '• 🎵 Music & Spotify-style Audio Players\n'
          '• ✨ Acid & Rave Neon\n'
          '• 🖤 Minimal & Editorial Magazine\n'
          '• 📐 Collage, Strips & Stamps\n'
          '• 💬 Quotes & Chat Bubbles\n'
          '• 🌈 Pastel Moodboards\n'
          '• ⚡ 9:16 Social Stories & Reels\n\n'
          'Tap any template to immediately open and customize it in the Studio.',
    },
    {
      'category': 'Photos',
      'icon': '📸',
      'question': 'Can I use my own photos with frames?',
      'answer':
          'Yes! Tap on any frame canvas or the photo button to choose an image from your Gallery or Camera. You can pinch to zoom, drag to pan, rotate 90°, flip horizontally/vertically, and choose different fit modes (Cover or Contain).',
    },
    {
      'category': 'Formats',
      'icon': '📐',
      'question': 'Which aspect ratios are supported for social media?',
      'answer':
          'Bratify supports all standard social formats:\n'
          '• 1:1 Square: Perfect for Instagram Feed, Threads, and Profile pictures.\n'
          '• 9:16 Story / Reel: Ideal for Instagram Stories, TikTok, Snapchat, and WhatsApp Status.\n'
          '• 4:5 Portrait: Maximum vertical screen coverage on mobile Instagram feed.\n'
          '• 16:9 Landscape: Great for X (Twitter) posts and YouTube thumbnails.\n\n'
          'Switch aspect ratios anytime in the "Ratio" tool tab.',
    },
    {
      'category': 'Quotes',
      'icon': '🎲',
      'question': 'What is the "Inspire Me" quote generator?',
      'answer':
          'If you need creative inspiration or lyrics, tap the "Viral Quotes" tab or the 🎲 Inspire Me button in the Studio. It randomly selects from hundreds of curated bratty lyrics, unhinged pop-culture lines, and trending quotes. Tap "Use" to instantly populate your canvas.',
    },
    {
      'category': 'Export',
      'icon': '💾',
      'question': 'How do I save and export my creations?',
      'answer':
          '• Save to Library: Saves your design inside the app so you can re-edit it anytime.\n'
          '• Save to Photos: Exports a crystal-clear Ultra-HD PNG directly to your iPhone Camera Roll.\n'
          '• Share: Opens the native iOS Share Sheet to send directly to Instagram, WhatsApp, TikTok, Messages, or AirDrop.',
    },
    {
      'category': 'Pricing',
      'icon': '💎',
      'question': 'Is Bratify completely free? Are there any ads or subscriptions?',
      'answer':
          'Bratify is 100% Free! There are zero in-app purchases, no subscriptions, no paywalls, and no pop-up ads. All 500 frames, 30+ Google fonts, studio effects, and HD exports are completely unlocked for everyone.',
    },
    {
      'category': 'Privacy',
      'icon': '🔒',
      'question': 'Does Bratify collect my personal photos or data?',
      'answer':
          'No. Your privacy is paramount. All image rendering, text formatting, and photo exports happen 100% locally on your device. We never upload your personal photos or designs to any external servers.',
    },
    {
      'category': 'Editing',
      'icon': '✏️',
      'question': 'Can I re-edit a saved meme later?',
      'answer':
          'Yes! Open the "Library" tab, tap on any previously saved meme, and it will reload into the Studio with all text, font, and frame settings intact ready for further editing.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTab = context.isTablet;

    final filteredFaqs = _searchQuery.isEmpty
        ? faqs
        : faqs.where((faq) {
            final q = faq['question']!.toLowerCase();
            final a = faq['answer']!.toLowerCase();
            final cat = faq['category']!.toLowerCase();
            final query = _searchQuery.toLowerCase();
            return q.contains(query) || a.contains(query) || cat.contains(query);
          }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.offWhiteColor,
        body: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              const CustomRowWidget(
                centerText: "FAQs & Guide",
                isLeft: true,
                isRightSetting: false,
                isRightMore: false,
              ),

              // Search Box
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTab ? 30 : 16,
                  vertical: 8,
                ),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Search FAQs, blur effect, 500 frames...',
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.black38,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Colors.black45,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.black45,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // FAQ list
              Expanded(
                child: filteredFaqs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.help_outline_rounded,
                              size: 48,
                              color: Colors.black26,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No matching questions found',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTab ? 30 : 16,
                          vertical: 8,
                        ),
                        itemCount: filteredFaqs.length,
                        itemBuilder: (context, index) {
                          final faq = filteredFaqs[index];
                          return _buildFAQCard(
                            context: context,
                            icon: faq['icon']!,
                            category: faq['category']!,
                            question: faq['question']!,
                            answer: faq['answer']!,
                            isTab: isTab,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCard({
    required BuildContext context,
    required String icon,
    required String category,
    required String question,
    required String answer,
    required bool isTab,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: isTab ? 20 : 16,
            vertical: 4,
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.bratGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          title: Text(
            question,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: isTab ? 17 : 14.5,
              color: Colors.black87,
              letterSpacing: -0.2,
            ),
          ),
          trailing: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.black54,
            size: 22,
          ),
          childrenPadding: EdgeInsets.only(
            left: isTab ? 68 : 56,
            right: isTab ? 24 : 16,
            bottom: 16,
          ),
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                answer,
                style: GoogleFonts.outfit(
                  fontSize: isTab ? 15 : 13.5,
                  color: Colors.black54,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
