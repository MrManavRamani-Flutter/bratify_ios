import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../features/frames/frame_preflight_sheet.dart';
import '../models/frame_model.dart';
import '../my_app.dart';
import '../widgets/app_svg_icon.dart';
import 'generate_screen.dart';
import 'settings/settings_screen.dart';

class TemplatesScreen extends StatefulWidget {
  final Function(FrameTemplate frame)? onSelectTemplate;
  final Function(FrameTemplate frame, XFile? photo)? onSelectTemplateWithPhoto;
  final VoidCallback? onOpenBlankStudio;

  const TemplatesScreen({
    super.key,
    this.onSelectTemplate,
    this.onSelectTemplateWithPhoto,
    this.onOpenBlankStudio,
  });

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  String _selectedCategory = 'All (500)';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = [
    'All (500)',
    '📸 Multi-Photo Collages',
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTab = context.isTablet;

    final filteredFrames = predefined500Frames.where((f) {
      final matchesCategory = _selectedCategory == 'All (500)'
          ? true
          : (_selectedCategory == '📸 Multi-Photo Collages'
              ? f.maxPhotos > 1
              : f.category == _selectedCategory);
      final matchesQuery = _searchQuery.isEmpty ||
          f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.caption.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Home Screen Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTab ? 24 : 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    // Settings Icon
                    IosGlassIconButton(
                      svgPath: 'assets/svg/settings.svg',
                      size: 38,
                      iconSize: 18,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.bratGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '500 AESTHETIC FRAMES',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: isTab ? 19 : 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Blank Canvas Button
                    IosBounceButton(
                      onTap: () {
                        if (widget.onOpenBlankStudio != null) {
                          widget.onOpenBlankStudio!();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const GenerateScreen(
                                isDedicatedEditScreen: true,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('✨', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              'Blank Studio',
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
                      hintText: 'Search 500 templates (Brat, Polaroid, Y2K...)',
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
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IosBounceButton(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = cat);
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
                            cat,
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

              // Grid of Templates
              Expanded(
                child: filteredFrames.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded, size: 48, color: Colors.black26),
                            const SizedBox(height: 12),
                            Text(
                              'No templates found',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTab ? 24 : 16,
                          vertical: 8,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTab ? 4 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: filteredFrames.length,
                        itemBuilder: (context, index) {
                          final frame = filteredFrames[index];
                          return _buildTemplateCard(frame);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(FrameTemplate frame) {
    return IosBounceButton(
      onTap: () {
        HapticFeedback.lightImpact();
        FramePreflightSheet.show(
          context: context,
          frame: frame,
          onProceed: (selectedFrame, photo) {
            if (widget.onSelectTemplateWithPhoto != null) {
              widget.onSelectTemplateWithPhoto!(selectedFrame, photo);
            } else if (widget.onSelectTemplate != null) {
              widget.onSelectTemplate!(selectedFrame);
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => GenerateScreen(
                  initialFrame: selectedFrame,
                  initialImage: photo,
                  isDedicatedEditScreen: true,
                ),
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Box with optional multi-photo badge
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Container(
                        color: frame.frameBgColor,
                        padding: frame.padding * 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(frame.borderRadius * 0.4),
                      border: frame.borderWidth > 0
                          ? Border.all(
                              color: frame.borderColor,
                              width: (frame.borderWidth * 0.5).clamp(1.0, 4.0),
                            )
                          : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _getOverlayIcon(frame.overlayType),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              frame.caption.isNotEmpty ? frame.caption : 'brat',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: frame.captionFont == 'Brat Sans' ? 'Arial' : frame.captionFont,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: frame.captionColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                      ),
                    ),
                  ),
                  if (frame.maxPhotos > 1)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.bratGreen.withValues(alpha: 0.6), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.collections_rounded, size: 10, color: AppColors.bratGreen),
                            const SizedBox(width: 3),
                            Text(
                              '${frame.maxPhotos} Photos',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Card Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          frame.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _getRatioLabel(frame.aspectRatio),
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bratGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Use',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getOverlayIcon(FrameOverlayType type) {
    switch (type) {
      case FrameOverlayType.polaroid:
        return const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.black54);
      case FrameOverlayType.vhs:
        return const Icon(Icons.videocam_outlined, size: 20, color: Colors.redAccent);
      case FrameOverlayType.digicam:
        return const Icon(Icons.camera_rounded, size: 20, color: Colors.amber);
      case FrameOverlayType.musicPlayer:
        return const Icon(Icons.music_note_rounded, size: 20, color: AppColors.bratGreen);
      case FrameOverlayType.filmstrip:
        return const Icon(Icons.movie_creation_outlined, size: 20, color: Colors.black54);
      case FrameOverlayType.stamp:
        return const Icon(Icons.verified_outlined, size: 20, color: Colors.black54);
      case FrameOverlayType.retroWindow:
        return const Icon(Icons.desktop_windows_outlined, size: 20, color: Colors.blueAccent);
      default:
        return Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.bratGreen,
            shape: BoxShape.circle,
          ),
        );
    }
  }

  String _getRatioLabel(double ratio) {
    if ((ratio - 1.0).abs() < 0.05) return '1:1 Square';
    if ((ratio - 9 / 16).abs() < 0.05) return '9:16 Story';
    if ((ratio - 4 / 5).abs() < 0.05) return '4:5 Portrait';
    if ((ratio - 16 / 9).abs() < 0.05) return '16:9 Wide';
    return '${ratio.toStringAsFixed(2)} Ratio';
  }
}
