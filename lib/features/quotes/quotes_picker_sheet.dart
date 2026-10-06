import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../services/logger_service.dart';
import '../../widgets/app_svg_icon.dart';
import 'quotes_model.dart';

class QuotesPickerSheet extends StatefulWidget {
  final Function(String selectedQuote) onQuoteSelected;
  final String? currentQuote;

  const QuotesPickerSheet({
    super.key,
    required this.onQuoteSelected,
    this.currentQuote,
  });

  static Future<void> show({
    required BuildContext context,
    required Function(String selectedQuote) onQuoteSelected,
    String? currentQuote,
  }) {
    AppLogger.logAction('QuotesPicker', 'Opened Quotes Sheet modal');
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuotesPickerSheet(
        onQuoteSelected: onQuoteSelected,
        currentQuote: currentQuote,
      ),
    );
  }

  @override
  State<QuotesPickerSheet> createState() => _QuotesPickerSheetState();
}

class _QuotesPickerSheetState extends State<QuotesPickerSheet> {
  int _selectedCatIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppLogger.logInfo('QuotesPicker', 'Loaded ${QuotesCatalog.categories.length} quote categories');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTab = MediaQuery.sizeOf(context).shortestSide >= 600;
    final currentCat = QuotesCatalog.categories[_selectedCatIndex];

    final filteredQuotes = _searchQuery.isEmpty
        ? currentCat.quotes
        : QuotesCatalog.categories
            .expand((c) => c.quotes)
            .where((q) => q.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toSet()
            .toList();

    return Material(
      color: const Color(0xff121217),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  '💬 Quotes & Captions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                  hintText: 'Search viral quotes or phrases...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                  AppLogger.logInfo('QuotesPicker', 'Search query: $val');
                },
              ),
            ),
          ),

          // Category Pills
          if (_searchQuery.isEmpty)
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: QuotesCatalog.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final cat = QuotesCatalog.categories[idx];
                  final isSelected = _selectedCatIndex == idx;
                  return IosBounceButton(
                    onTap: () {
                      setState(() => _selectedCatIndex = idx);
                      AppLogger.logAction('QuotesPicker', 'Switched Category', {'category': cat.title});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.bratGreen : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.bratGreen : Colors.white12,
                        ),
                      ),
                      child: Text(
                        '${cat.icon} ${cat.title}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.black : Colors.white70,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 12),

          // Quotes Grid / List
          Expanded(
            child: filteredQuotes.isEmpty
                ? Center(
                    child: Text(
                      'No quotes found for "$_searchQuery"',
                      style: const TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    itemCount: filteredQuotes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final quote = filteredQuotes[index];
                      final isCurrent = widget.currentQuote == quote;

                      return IosBounceButton(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          AppLogger.logAction('QuotesPicker', 'Quote applied', {'quote': quote});
                          widget.onQuoteSelected(quote);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.bratGreen.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isCurrent ? AppColors.bratGreen : Colors.white10,
                              width: isCurrent ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  quote,
                                  style: TextStyle(
                                    fontSize: isTab ? 16 : 14,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                    color: isCurrent ? AppColors.bratGreen : Colors.white.withValues(alpha: 0.9),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              Icon(
                                isCurrent ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                size: 20,
                                color: isCurrent ? AppColors.bratGreen : Colors.white38,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}
}
