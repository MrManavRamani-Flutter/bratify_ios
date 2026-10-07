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
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = const [
    'All',
    'General',
    'Multi-Photo & Frames',
    'Canvas & Background',
    'Text & Typography',
    'Filters & FX',
    'Crop & Transform',
    'Save, Library & Edit',
    'Formats & Quotes',
    'Privacy & Pricing',
  ];

  final List<Map<String, String>> faqs = const [
    {
      'category': 'General',
      'icon': '🍏',
      'question': 'What is Bratify?',
      'answer':
          'Bratify is the ultimate aesthetic post and meme studio inspired by Charli XCX\'s iconic Brat album aesthetic, Y2K digital cameras, Polaroid frames, and modern pop culture. You can craft low-res blurry text memes, multi-photo collage frames, grainy album covers, and high-impact social media posts in seconds.',
    },
    {
      'category': 'General',
      'icon': '↩️',
      'question': 'How does the Undo and Redo system work?',
      'answer':
          'At the top of the Studio canvas, you will find Undo (↺) and Redo (↻) buttons. Bratify remembers up to 25 history steps, including layout switches, photo uploads, text movements, color changes, and filter adjustments so you can experiment freely without losing your progress.',
    },
    {
      'category': 'Multi-Photo & Frames',
      'icon': '🖼️',
      'question': 'How do multi-photo collage frames work?',
      'answer':
          'In Studio Tab 0 (Layout & Slots):\n'
          '• Choose any layout: Single, Split 2H (side-by-side), Split 2V (top-and-bottom), Polaroid Duo, or 4-Photo Grid.\n'
          '• Each photo slot is independent: select Slot 1, Slot 2, etc., to assign different photos.\n'
          '• Tap directly on any photo in the canvas preview to crop, rotate, flip, replace, or remove it individually.',
    },
    {
      'category': 'Multi-Photo & Frames',
      'icon': '📸',
      'question': 'How do I add or change photos in specific slots?',
      'answer':
          'Under Tab 0 (Layout & Slots):\n'
          '1. In the "Active Photo Slot" row, tap Slot 1, Slot 2, Slot 3, or Slot 4 to select which slot you want to edit.\n'
          '2. Tap "Choose Photo" or tap the empty slot directly on the canvas to pick an image from your Photo Library or Camera.\n'
          '3. To replace a photo, tap on that slot anytime and pick a new image or tap the trash icon to clear it.',
    },
    {
      'category': 'Multi-Photo & Frames',
      'icon': '🎨',
      'question': 'Can I customize frame borders, rounded corners, and spacing?',
      'answer':
          'Yes! Under Tab 0 (Layout & Slots):\n'
          '• Border Width: Adjust frame border thickness from 0px (borderless) up to 30px with quick presets (None, Thin, Bold, Ultra).\n'
          '• Corner Radius: Smooth or sharpen photo corners from 0px to 48px.\n'
          '• Slot Spacing: Control the gap between multiple photo slots.\n'
          '• Border & Frame Color: Select any preset color or tap the color palette picker for a custom HEX hue.',
    },
    {
      'category': 'Canvas & Background',
      'icon': '🌄',
      'question': 'How do I set a custom background image instead of a solid color?',
      'answer':
          'In Tab 1 (Background & Colors):\n'
          '1. Toggle the background mode switch from "Solid Color" to "Image Background".\n'
          '2. Tap "Choose Background Photo" to upload any photo, texture, or wallpaper from your device.\n'
          '3. Customize your background with Opacity (0% - 100%), Blur Sigma (soft focus effect), and Fit modes (Cover, Contain, Fill).',
    },
    {
      'category': 'Canvas & Background',
      'icon': '🧪',
      'question': 'How do I adjust background opacity, fit modes, and blur?',
      'answer':
          'When "Image Background" mode is active in Tab 1:\n'
          '• Background Fit: Choose "Cover" (fills entire canvas), "Contain" (fits full picture inside), or "Fill" (stretches to edge).\n'
          '• Background Opacity: Slide from 10% to 100% to create subtle texture or full vibrant imagery behind your frame.\n'
          '• Background Blur: Soften distracting backgrounds with a Gaussian blur slider.',
    },
    {
      'category': 'Text & Typography',
      'icon': '✍️',
      'question': 'Can I add multiple text labels and drag them anywhere?',
      'answer':
          'Yes! Under Tab 2 (Text Layers):\n'
          '• Tap "+ Add Text Layer" to add multiple labels across your canvas.\n'
          '• Drag any text layer freely with your finger to position it anywhere on the canvas.\n'
          '• Double-tap or select any layer in the list to customize its font, text size, font weight, color, alignment, letter spacing, line height, and text blur.\n'
          '• All custom positions (X and Y coordinates) are saved permanently with your post.',
    },
    {
      'category': 'Text & Typography',
      'icon': '🔤',
      'question': 'Which fonts and typographic controls are available?',
      'answer':
          'Bratify includes 30+ curated typography styles including iconic lowercase Arial, retro typewriter, bold condensed sans-serifs, and editorial serifs.\n'
          'You can adjust:\n'
          '• Size: 14pt to 72pt with a smooth slider.\n'
          '• Alignment: Left, Center, or Right.\n'
          '• Letter Spacing: Tight negative spacing (-2.0) for classic Brat style or wide editorial spacing (+4.0).\n'
          '• Text Case: Uppercase, Lowercase, or Title Case.\n'
          '• Text Blur: Blur individual labels for a dreamlike, hazy aesthetic.',
    },
    {
      'category': 'Filters & FX',
      'icon': '✨',
      'question': 'How do the Studio Aesthetic Filters work?',
      'answer':
          'In Tab 4 (Photo & Filters):\n'
          '• Explore 10+ curated color filters including Lime Boost, Cyber Brat, Neon Noir, Vintage Fade, Mono Chrome, Warm Summer, Cool Breeze, Pastel Dreams, Golden Hour, Sepia Grain, and Cyan Glow.\n'
          '• Use the Filter Intensity Slider (0% - 100%) to smoothly adjust the strength of the filter on your photos and canvas.',
    },
    {
      'category': 'Filters & FX',
      'icon': '🌫️',
      'question': 'How do I get the authentic blurry "Brat" signature aesthetic?',
      'answer':
          '1. In Studio Tab 4 (FX & Studio Effects), set Blur Sigma to between 1.0 and 2.5 (the sweet spot for authentic low-res blur).\n'
          '2. Keep Film Grain enabled (~12% - 15% opacity) to add realistic analog film texture.\n'
          '3. In Tab 2, use Arial or narrow sans-serif font in lowercase with negative letter-spacing (-0.5 to -1.0) on the iconic Brat lime green background.',
    },
    {
      'category': 'Filters & FX',
      'icon': '🎞️',
      'question': 'What do Invert, Vignette, and Film Grain FX do?',
      'answer':
          'Under the FX menu in Tab 4:\n'
          '• Authentic Film Grain: Generates genuine procedural film grain noise to give digital photos an analog 35mm film feel.\n'
          '• Vignette: Softens and darkens the outer perimeter for vintage camera lens emphasis.\n'
          '• Invert Colors: Negates canvas colors for rave flyer and acid club poster aesthetics.',
    },
    {
      'category': 'Crop & Transform',
      'icon': '✂️',
      'question': 'How do I crop and transform photos for different slots?',
      'answer':
          '• Tap any photo on your canvas and select "Crop & Adjust".\n'
          '• Interactive Cropping: Pinch and zoom to select the exact crop region with presets like 1:1, 4:5, 9:16, and 16:9.\n'
          '• Photo Transforms: Rotate in 90° increments, adjust custom angles (-45° to +45°), flip horizontally/vertically, and change BoxFit (Cover, Contain, Fill).',
    },
    {
      'category': 'Save, Library & Edit',
      'icon': '💾',
      'question': 'What is the difference between "Save to Library" and "Save to Photos"?',
      'answer':
          '• Save to Library: Stores your complete project internally in the app database. All multi-photo slots, background images, text layers, drag positions, filters, and borders remain fully editable anytime.\n'
          '• Save to Photos: Renders an Ultra-HD 3x Retina resolution PNG directly to your iPhone Camera Roll (Photos app) for sharing on social media.',
    },
    {
      'category': 'Save, Library & Edit',
      'icon': '🔄',
      'question': 'Can I re-edit a saved post later without losing multi-photo layouts or text positions?',
      'answer':
          'Absolutely! Open the "Library" tab from the bottom navigation bar and tap on any saved post. It will reload into the Studio with all photo slots, custom layouts (split 2H, polaroid duo, etc.), background images, text positions, custom fonts, and filters completely preserved and ready to continue editing.',
    },
    {
      'category': 'Formats & Quotes',
      'icon': '📐',
      'question': 'Which aspect ratios are supported for social platforms?',
      'answer':
          'Bratify provides instant aspect ratio presets in Tab 0 and Tab 4:\n'
          '• 1:1 Square: Perfect for Instagram Feed, Threads, and profile avatars.\n'
          '• 9:16 Story / Reel: Fullscreen vertical for Instagram Stories, TikTok, Snapchat, and WhatsApp Status.\n'
          '• 4:5 Portrait: Highest screen coverage on mobile Instagram feed.\n'
          '• 16:9 Landscape: Ideal for X (Twitter) headers and video thumbnails.',
    },
    {
      'category': 'Formats & Quotes',
      'icon': '🎲',
      'question': 'What is the "Inspire Me" quote generator?',
      'answer':
          'Need catchy lyrics, witty pop-culture references, or viral meme captions? Tap the "Viral Quotes" tab or the 🎲 Inspire Me button to browse hundreds of curated quotes. Tap "Use" to instantly populate the active text layer on your canvas.',
    },
    {
      'category': 'Privacy & Pricing',
      'icon': '🔒',
      'question': 'Does Bratify upload my photos or personal data to servers?',
      'answer':
          'Never! Bratify operates 100% locally and offline on your device. All image processing, filters, photo storage, and rendering happen on-device. No accounts, logins, or tracking servers are ever used.',
    },
    {
      'category': 'Privacy & Pricing',
      'icon': '💎',
      'question': 'Is Bratify completely free? Are there any ads or subscriptions?',
      'answer':
          'Bratify is 100% Free! There are zero subscriptions, no hidden paywalls, and no pop-up ads. All multi-photo frames, Google fonts, filters, custom background modes, and Ultra-HD exports are completely unlocked.',
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

    final filteredFaqs = faqs.where((faq) {
      final matchesCategory = _selectedCategory == 'All' || faq['category'] == _selectedCategory;
      if (!matchesCategory) return false;
      if (_searchQuery.isEmpty) return true;
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
                  vertical: 6,
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
                      hintText: 'Search FAQs, multi-photo, filters, blur, library...',
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

              // Horizontal Category Chips
              Container(
                height: 38,
                margin: const EdgeInsets.only(top: 4, bottom: 8),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: isTab ? 30 : 16),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final cat = categories[idx];
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCategory = cat);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.black12,
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.bratGreen : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black12, width: 0.8),
        ),
        clipBehavior: Clip.antiAlias,
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
    ),
  );
  }
}
