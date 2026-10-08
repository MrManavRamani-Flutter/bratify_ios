import 'dart:io';

import 'package:brat_generator/models/meme_design_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_colors.dart';
import '../my_app.dart';
import '../services/database_service.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_svg_icon.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SaveScreen extends StatefulWidget {
  final Function(MemeDesign) onEditSelected;
  const SaveScreen({super.key, required this.onEditSelected});

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  List<MemeDesign> savedMemes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    DatabaseHelper.savedMemesChangeNotifier.addListener(_onDbChanged);
    loadSavedMemes();
  }

  void _onDbChanged() {
    if (mounted) {
      loadSavedMemes();
    }
  }

  @override
  void dispose() {
    DatabaseHelper.savedMemesChangeNotifier.removeListener(_onDbChanged);
    super.dispose();
  }

  Future<void> loadSavedMemes() async {
    final memes = await DatabaseHelper().getAllMemeDesigns();
    if (!mounted) return;
    setState(() {
      savedMemes = memes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTab = context.isTablet;
    final crossAxisCount = isTab ? 3 : 2;
    final crossAxisSpacing = isTab ? 20.0 : 10.0;
    final mainAxisSpacing = isTab ? 20.0 : 10.0;

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
          child: Stack(
            children: [
              // Custom App Bar
              const CustomRowWidget(
                centerText: "Library",
                isLeft: false,
                isRightSetting: false,
                isRightMore: false,
              ),
              // Main Content
              Padding(
                padding: EdgeInsets.only(top: isTab ? 85 : 55),
                child: _isLoading && savedMemes.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.bratGreen),
                        ),
                      )
                    : (savedMemes.isEmpty)
                        ? RefreshIndicator(
                            onRefresh: loadSavedMemes,
                            color: Colors.black,
                            backgroundColor: AppColors.bratGreen,
                            child: LayoutBuilder(
                              builder: (context, constraints) => SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: isTab ? 90 : 72,
                                            height: isTab ? 90 : 72,
                                            decoration: BoxDecoration(
                                              color: AppColors.bratGreen.withValues(alpha: 0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.bookmark_border_rounded,
                                              size: isTab ? 48 : 38,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: isTab ? 22 : 16),
                                          Text(
                                            "Your Library is Empty",
                                            style: TextStyle(
                                              fontSize: isTab ? 22 : 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black87,
                                              letterSpacing: -0.4,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Create iconic brat memes and presets in Studio, then tap Save to build your collection.",
                                            style: TextStyle(
                                              fontSize: isTab ? 15 : 13,
                                              height: 1.4,
                                              color: Colors.grey.shade600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: loadSavedMemes,
                            color: Colors.black,
                            backgroundColor: AppColors.bratGreen,
                            child: AlignedGridView.count(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isTab ? 24 : 10,
                                vertical: isTab ? 18 : 5,
                              ),
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: mainAxisSpacing,
                              crossAxisSpacing: crossAxisSpacing,
                              itemCount: savedMemes.length,
                              itemBuilder: (context, index) {
                                final memeItem = savedMemes[index];
                                return _buildGridItem(context, memeItem, isTab);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, MemeDesign memeDesign, bool isTab) {
    return Padding(
      padding: EdgeInsets.all(isTab ? 10 : 8),
      child: Container(
        padding: EdgeInsets.all(isTab ? 12 : 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTab ? 20 : 15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image Banner with fixed height (tap to open & edit)
            GestureDetector(
              onTap: () => widget.onEditSelected(memeDesign),
              child: SizedBox(
                height: isTab ? 230 : 120,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isTab ? 14 : 10),
                  child: (memeDesign.imageBytes != null && memeDesign.imageBytes!.isNotEmpty)
                      ? Image.memory(
                          memeDesign.imageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackPreview(memeDesign, isTab),
                        )
                      : _buildFallbackPreview(memeDesign, isTab),
                ),
              ),
            ),
            SizedBox(height: isTab ? 14 : 10),
            // iOS Glass Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IosGlassIconButton(
                  svgPath: 'assets/svg/edit.svg',
                  size: isTab ? 50 : 38,
                  iconSize: isTab ? 24 : 18,
                  onTap: () {
                    widget.onEditSelected(memeDesign);
                  },
                ),
                IosGlassIconButton(
                  svgPath: 'assets/svg/delete.svg',
                  size: isTab ? 50 : 38,
                  iconSize: isTab ? 24 : 18,
                  iconColor: Colors.redAccent,
                  onTap: () {
                    _showDeleteDialog(context, memeDesign);
                  },
                ),
                Builder(
                  builder: (btnContext) => IosGlassIconButton(
                    svgPath: 'assets/svg/share.svg',
                    size: isTab ? 50 : 38,
                    iconSize: isTab ? 24 : 18,
                    onTap: () {
                      _shareMemeImage(btnContext, memeDesign);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: isTab ? 8 : 6),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackPreview(MemeDesign meme, [bool isTab = false]) {
    return Container(
      width: double.infinity,
      color: meme.backgroundColor,
      alignment: Alignment.center,
      padding: EdgeInsets.all(isTab ? 12.0 : 8.0),
      child: Text(
        meme.text,
        textAlign: meme.textAlign,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: meme.textColor,
          fontSize: isTab ? 20 : 16,
          fontWeight: FontWeight.bold,
          fontFamily: meme.fontFamily,
        ),
      ),
    );
  }

  void _shareMemeImage(BuildContext context, MemeDesign meme) async {
    final box = context.findRenderObject() as RenderBox?;
    final size = MediaQuery.sizeOf(context);
    final origin = box != null
        ? (box.localToGlobal(Offset.zero) & box.size)
        : Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: 20,
            height: 20,
          );
    try {
      final Uint8List? imageBytes = meme.imageBytes;
      if (imageBytes == null) {
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/shared_meme_${DateTime.now().millisecondsSinceEpoch}.png';

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Check out this meme!',
        sharePositionOrigin: origin,
      );
    } catch (_) {}
  }

  void _showDeleteDialog(BuildContext context, MemeDesign meme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirm Delete',
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this meme from your library?',
          style: GoogleFonts.outfit(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteMeme(meme);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMeme(MemeDesign meme) async {
    if (meme.id != null) {
      await DatabaseHelper().deleteMemeDesign(meme.id!);
      await loadSavedMemes(); // refresh list
    }
  }
}
