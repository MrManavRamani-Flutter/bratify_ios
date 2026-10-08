import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/frame_model.dart';
import '../models/meme_design_model.dart';
import '../my_app.dart';
import '../services/database_service.dart';
import 'generate_screen.dart';

/// Clean, modern Studio Hub (Home Screen)
/// Allows user to start a new design, pick a frame layout preset, or resume saved drafts.
class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenLibrary;
  const HomeScreen({super.key, required this.onOpenLibrary});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MemeDesign> _recentDesigns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    DatabaseHelper.savedMemesChangeNotifier.addListener(_loadRecentDesigns);
    _loadRecentDesigns();
  }

  @override
  void dispose() {
    DatabaseHelper.savedMemesChangeNotifier.removeListener(_loadRecentDesigns);
    super.dispose();
  }

  Future<void> _loadRecentDesigns() async {
    final designs = await DatabaseHelper().getAllMemeDesigns();
    if (!mounted) return;
    setState(() {
      _recentDesigns = designs;
      _isLoading = false;
    });
  }

  void _openEditor({FrameTemplate? frame, MemeDesign? design}) {
    HapticFeedback.mediumImpact();
    FrameTemplate? effectiveFrame = frame;
    if (design != null) {
      if (design.frameTemplate != null) {
        effectiveFrame = design.frameTemplate;
      } else if (design.frameId != null) {
        final matches = predefined100Frames.where((f) => f.id == design.frameId);
        if (matches.isNotEmpty) {
          effectiveFrame = matches.first;
        }
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => GenerateScreen(
          initialFrame: effectiveFrame ?? defaultCustomFrame,
          initialDesign: design,
          isDedicatedEditScreen: true,
        ),
      ),
    ).then((result) {
      _loadRecentDesigns();
      DatabaseHelper.savedMemesChangeNotifier.value++;
      if (result == 'library') {
        widget.onOpenLibrary();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTab = context.isTablet;
    final hPad = isTab ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. App Bar Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, isTab ? 22 : 16, hPad, 10),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Brat Studio',
                          style: GoogleFonts.outfit(
                            fontSize: isTab ? 38 : 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Custom Frame & Collage Maker',
                          style: GoogleFonts.outfit(
                            fontSize: isTab ? 16 : 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. Primary Hero Create Action Card
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isTab ? 14 : 10),
                child: GestureDetector(
                  onTap: () => _openEditor(),
                  child: Container(
                    padding: EdgeInsets.all(isTab ? 28 : 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff18181B), Color(0xff27272A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(isTab ? 26 : 22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTab ? 12 : 8,
                                  vertical: isTab ? 5 : 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bratGreen,
                                  borderRadius: BorderRadius.circular(isTab ? 8 : 6),
                                ),
                                child: Text(
                                  'CUSTOM BUILDER',
                                  style: TextStyle(
                                    fontSize: isTab ? 12 : 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: isTab ? 14 : 10),
                              Text(
                                'Design Custom Frame',
                                style: GoogleFonts.outfit(
                                  fontSize: isTab ? 26 : 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Set multi-photo slots, custom borders, corners & draggable text.',
                                style: GoogleFonts.outfit(
                                  fontSize: isTab ? 15 : 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isTab ? 20 : 14),
                        Container(
                          width: isTab ? 64 : 52,
                          height: isTab ? 64 : 52,
                          decoration: const BoxDecoration(
                            color: AppColors.bratGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_rounded, size: isTab ? 36 : 30, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Frame Layout Presets Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, isTab ? 22 : 16, hPad, 8),
                child: Row(
                  children: [
                    Text(
                      'START WITH A LAYOUT',
                      style: GoogleFonts.outfit(
                        fontSize: isTab ? 15 : 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Horizontal Scrollable Layout Presets Grid
            SliverToBoxAdapter(
              child: SizedBox(
                height: isTab ? 165 : 126,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  itemCount: customFrameLayoutPresets.length,
                  separatorBuilder: (_, __) => SizedBox(width: isTab ? 16 : 12),
                  itemBuilder: (context, index) {
                    final preset = customFrameLayoutPresets[index];
                    return _buildLayoutCard(preset, isTab);
                  },
                ),
              ),
            ),

            // 5. Recent Creations / Drafts Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, isTab ? 28 : 24, hPad, 8),
                child: Row(
                  children: [
                    Text(
                      'MY RECENT CREATIONS',
                      style: GoogleFonts.outfit(
                        fontSize: isTab ? 15 : 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.black45,
                      ),
                    ),
                    const Spacer(),
                    if (_recentDesigns.isNotEmpty)
                      GestureDetector(
                        onTap: widget.onOpenLibrary,
                        child: Text(
                          'View All (${_recentDesigns.length})',
                          style: GoogleFonts.outfit(
                            fontSize: isTab ? 15 : 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 6. Recent Designs Grid or Empty State
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: Colors.black)),
                ),
              )
            else if (_recentDesigns.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
                  child: Container(
                    padding: EdgeInsets.all(isTab ? 36 : 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTab ? 22 : 18),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.photo_library_outlined, size: isTab ? 52 : 40, color: Colors.black26),
                        SizedBox(height: isTab ? 16 : 12),
                        Text(
                          'No Creations Yet',
                          style: GoogleFonts.outfit(
                            fontSize: isTab ? 20 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap "+ Create Custom Frame" to design your first frame and post!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: isTab ? 15 : 13,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 30),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTab ? 3 : 2,
                    mainAxisSpacing: isTab ? 18 : 12,
                    crossAxisSpacing: isTab ? 18 : 12,
                    childAspectRatio: isTab ? 0.96 : 0.88,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final design = _recentDesigns[index];
                      return _buildRecentCard(design, isTab);
                    },
                    childCount: _recentDesigns.length.clamp(0, 6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutCard(FrameTemplate preset, bool isTab) {
    IconData layoutIcon;
    switch (preset.photoLayout) {
      case FramePhotoLayout.split2H:
        layoutIcon = Icons.view_column_rounded;
        break;
      case FramePhotoLayout.split2V:
        layoutIcon = Icons.view_agenda_rounded;
        break;
      case FramePhotoLayout.grid4:
        layoutIcon = Icons.grid_view_rounded;
        break;
      case FramePhotoLayout.triptych3:
      case FramePhotoLayout.filmstrip3:
        layoutIcon = Icons.view_week_rounded;
        break;
      case FramePhotoLayout.polaroidDuo:
        layoutIcon = Icons.photo_rounded;
        break;
      case FramePhotoLayout.single:
        layoutIcon = Icons.crop_square_rounded;
        break;
    }

    return GestureDetector(
      onTap: () => _openEditor(frame: preset),
      child: Container(
        width: isTab ? 140 : 110,
        padding: EdgeInsets.all(isTab ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTab ? 20 : 16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTab ? 58 : 44,
              height: isTab ? 58 : 44,
              decoration: BoxDecoration(
                color: const Color(0xffF1F5F9),
                borderRadius: BorderRadius.circular(isTab ? 16 : 12),
              ),
              child: Icon(layoutIcon, size: isTab ? 30 : 24, color: Colors.black87),
            ),
            SizedBox(height: isTab ? 12 : 8),
            Text(
              preset.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: isTab ? 15 : 12,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              '${preset.maxPhotos} Photo${preset.maxPhotos > 1 ? "s" : ""}',
              style: GoogleFonts.outfit(
                fontSize: isTab ? 12 : 10,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCard(MemeDesign design, bool isTab) {
    return GestureDetector(
      onTap: () => _openEditor(design: design),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTab ? 22 : 16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTab ? 22 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: design.imageBytes != null
                    ? Image.memory(
                        design.imageBytes!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: design.backgroundColor,
                        alignment: Alignment.center,
                        child: Text(
                          design.text,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: design.textColor,
                            fontSize: isTab ? 18 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTab ? 14 : 10,
                  vertical: isTab ? 12 : 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        design.text.isNotEmpty ? design.text : 'Custom Design',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: isTab ? 15 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.edit_rounded, size: isTab ? 18 : 14, color: Colors.black45),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
