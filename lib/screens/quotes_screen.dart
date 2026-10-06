import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../features/quotes/quotes_model.dart';
import '../my_app.dart';
import '../widgets/app_svg_icon.dart';
import 'generate_screen.dart';

class QuotesScreen extends StatefulWidget {
  final Function(String quote) onSelectQuote;

  const QuotesScreen({
    super.key,
    required this.onSelectQuote,
  });

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Random _random = Random();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onQuoteTapped(String quote) {
    HapticFeedback.lightImpact();
    widget.onSelectQuote(quote);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => GenerateScreen(
          initialText: quote,
          isDedicatedEditScreen: true,
        ),
      ),
    );
  }

  void _inspireMe() {
    HapticFeedback.mediumImpact();
    final allQuotes = QuotesCatalog.categories.expand((c) => c.quotes).toList();
    final randomQuote = allQuotes[_random.nextInt(allQuotes.length)];
    _onQuoteTapped(randomQuote);
  }

  @override
  Widget build(BuildContext context) {
    final isTab = context.isTablet;
    final currentCat = QuotesCatalog.categories[_selectedCategoryIndex];

    final filteredQuotes = _searchQuery.isEmpty
        ? currentCat.quotes
        : QuotesCatalog.categories
            .expand((c) => c.quotes)
            .where((q) => q.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toSet()
            .toList();

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTab ? 24 : 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.bratGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'VIRAL QUOTES & LYRICS',
                      style: GoogleFonts.outfit(
                        fontSize: isTab ? 20 : 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    // 🎲 Inspire Me Button
                    IosBounceButton(
                      onTap: _inspireMe,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎲', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 5),
                            Text(
                              'Inspire Me',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.bratGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTab ? 24 : 16),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search viral quotes & lyrics...',
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.black38,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.black45),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: Colors.black45),
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

              const SizedBox(height: 10),

              // Category Pills
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: isTab ? 24 : 16),
                  itemCount: QuotesCatalog.categories.length,
                  itemBuilder: (context, index) {
                    final cat = QuotesCatalog.categories[index];
                    final isSelected = _selectedCategoryIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IosBounceButton(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedCategoryIndex = index;
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.black12,
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${cat.icon} ${cat.title}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
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

              const SizedBox(height: 10),

              // List of Quotes
              Expanded(
                child: filteredQuotes.isEmpty
                    ? Center(
                        child: Text(
                          'No quotes match "$_searchQuery"',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: Colors.black45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTab ? 24 : 16,
                          vertical: 8,
                        ),
                        itemCount: filteredQuotes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final quote = filteredQuotes[index];
                          return _buildQuoteCard(quote, currentCat.icon);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCard(String quote, String icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onQuoteTapped(quote),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.bratGreen.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(icon, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '“$quote”',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to edit on canvas',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Copy button
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.black38),
                  tooltip: 'Copy Quote',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: quote));
                    HapticFeedback.selectionClick();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.bratGreen, size: 18),
                            const SizedBox(width: 8),
                            Text('Copied: "$quote"'),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xff18181B),
                        duration: const Duration(seconds: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
                // Use button
                IosBounceButton(
                  onTap: () => _onQuoteTapped(quote),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Use',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.bratGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: AppColors.bratGreen,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
