import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../models/frame_model.dart';
import '../../services/logger_service.dart';
import '../../widgets/app_svg_icon.dart';

class FramesCatalogSheet extends StatefulWidget {
  final FrameTemplate? currentFrame;
  final Function(FrameTemplate frame) onFrameSelected;

  const FramesCatalogSheet({
    super.key,
    this.currentFrame,
    required this.onFrameSelected,
  });

  static Future<void> show({
    required BuildContext context,
    FrameTemplate? currentFrame,
    required Function(FrameTemplate frame) onFrameSelected,
  }) {
    AppLogger.logAction('FramesCatalog', 'Opened 500 Frames Catalog modal');
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FramesCatalogSheet(
        currentFrame: currentFrame,
        onFrameSelected: onFrameSelected,
      ),
    );
  }

  @override
  State<FramesCatalogSheet> createState() => _FramesCatalogSheetState();
}

class _FramesCatalogSheetState extends State<FramesCatalogSheet> {
  String _selectedCategory = 'All (500)';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = [
    'All (500)',
    '🍏 Brat & Album',
    '📸 Polaroid & Vintage',
    '🎞️ Y2K & Digicam',
    '🎵 Music & Audio',
    '✨ Acid & Rave Neon',
    '🖤 Minimal & Editorial',
    '📐 Collage, Strips & Stamps',
    '💬 Quotes & Viral Memes',
    '🌈 Pastel & Moodboard',
    '⚡ Social Story & Reels',
  ];

  @override
  void initState() {
    super.initState();
    AppLogger.logInfo('FramesCatalog', 'Catalog initialized with ${predefined500Frames.length} templates');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTab = MediaQuery.sizeOf(context).shortestSide >= 600;

    final filteredFrames = predefined500Frames.where((f) {
      final matchesCategory = _selectedCategory == 'All (500)' || f.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.caption.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.82,
      decoration: const BoxDecoration(
        color: Color(0xff121217),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '🖼️ 500 Predefined Frames',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '10 curated aesthetics · Tap any frame to apply instantly',
                      style: TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Search Filter Field
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
                  hintText: 'Search template name or style...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                  AppLogger.logInfo('FramesCatalog', 'Search query: $val');
                },
              ),
            ),
          ),

          // Category Chips Bar
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSelected = _selectedCategory == cat;
                return IosBounceButton(
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    AppLogger.logAction('FramesCatalog', 'Category filtered', {'category': cat});
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
                      cat,
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

          // Frames Grid
          Expanded(
            child: filteredFrames.isEmpty
                ? const Center(
                    child: Text('No frames matched your search', style: TextStyle(color: Colors.white38)),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTab ? 4 : 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: filteredFrames.length,
                    itemBuilder: (context, index) {
                      final frame = filteredFrames[index];
                      final isSelected = widget.currentFrame?.id == frame.id;

                      return IosBounceButton(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          AppLogger.logAction('FramesCatalog', 'Applied Frame', {
                            'id': frame.id,
                            'name': frame.name,
                            'category': frame.category,
                          });
                          widget.onFrameSelected(frame);
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff1A1A22),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.bratGreen : Colors.white12,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Frame Canvas Miniature
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: frame.frameBgColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: frame.borderColor,
                                      width: frame.borderWidth.clamp(1.0, 3.0),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      frame.caption.isNotEmpty ? frame.caption : 'brat',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: frame.captionColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Frame Name & Category
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Text(
                                  frame.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.bratGreen : Colors.white70,
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
        ],
      ),
    );
  }
}
