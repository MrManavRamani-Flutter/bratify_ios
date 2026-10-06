import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../models/frame_model.dart';
import '../models/meme_design_model.dart';
import '../my_app.dart';
import '../services/app_update_service.dart';
import '../services/database_service.dart';
import '../widgets/app_svg_icon.dart';
import 'generate_screen.dart';
import 'quotes_screen.dart';
import 'save_screen.dart';
import 'templates_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  MemeDesign? initialDesign;
  FrameTemplate? selectedFrame;
  XFile? selectedPhoto;
  String? selectedQuote;
  List<MemeDesign> savedMemes = [];

  static const _overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(_overlayStyle);
    loadSavedMemes();
    appProcess();
  }

  Future<void> appProcess() async {
    if (mounted) {
      await AppUpdateService.checkForUpdate(context);
    }
  }

  Future<void> loadSavedMemes() async {
    final memes = await DatabaseHelper().getAllMemeDesigns();
    if (mounted) {
      setState(() {
        savedMemes = memes;
      });
    }
  }

  void onMemeSelected(MemeDesign meme) {
    setState(() {
      initialDesign = meme;
      _selectedIndex = 1;
    });
  }

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle,
      child: Scaffold(
        backgroundColor: AppColors.offWhiteColor,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            TemplatesScreen(
              onSelectTemplate: (frame) {
                setState(() {
                  selectedFrame = frame;
                  selectedPhoto = null;
                  _selectedIndex = 1;
                });
              },
              onSelectTemplateWithPhoto: (frame, photo) {
                setState(() {
                  selectedFrame = frame;
                  selectedPhoto = photo;
                  _selectedIndex = 1;
                });
              },
              onOpenBlankStudio: () {
                setState(() {
                  selectedFrame = null;
                  selectedPhoto = null;
                  initialDesign = null;
                  _selectedIndex = 1;
                });
              },
            ),
            GenerateScreen(
              initialDesign: initialDesign,
              initialFrame: selectedFrame,
              initialText: selectedQuote,
              initialImage: selectedPhoto,
              onReset: (meme) {
                setState(() {
                  initialDesign = null;
                  selectedFrame = null;
                  selectedPhoto = null;
                  selectedQuote = null;
                });
              },
              onBackToHome: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            QuotesScreen(
              onSelectQuote: (quote) {
                setState(() {
                  selectedQuote = quote;
                  _selectedIndex = 1;
                });
              },
            ),
            SaveScreen(
              onEditSelected: (MemeDesign meme) {
                setState(() {
                  initialDesign = meme;
                  _selectedIndex = 1;
                });
              },
            ),
          ],
        ),
        bottomNavigationBar: buildBottomNavigationBar(context),
      ),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context) {
    final isTab = context.isTablet;

    final tabs = [
      _NavTabItem(
        title: '500 Frames',
        icon: Icons.dashboard_customize_rounded,
      ),
      _NavTabItem(
        title: 'Studio',
        icon: Icons.auto_awesome_rounded,
        assetSvg: 'assets/svg/generate.svg',
      ),
      _NavTabItem(
        title: 'Viral Quotes',
        icon: Icons.format_quote_rounded,
      ),
      _NavTabItem(
        title: 'Library',
        icon: Icons.bookmark_rounded,
        assetSvg: 'assets/svg/save.svg',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
            width: 0.8,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTab ? 600 : double.infinity),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTab ? 20 : 8,
                vertical: 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(tabs.length, (index) {
                  final tab = tabs[index];
                  final isSelected = _selectedIndex == index;

                  return Expanded(
                    child: IosBounceButton(
                      onTap: () {
                        if (index == 3) {
                          initialDesign = null;
                        }
                        _onItemTapped(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          vertical: isTab ? 10 : 7,
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.bratGreen.withValues(alpha: 0.22)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.bratGreen,
                                  width: 1.4,
                                )
                              : Border.all(color: Colors.transparent),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (tab.assetSvg != null)
                              AppSvgIcon(
                                assetPath: tab.assetSvg!,
                                size: isTab ? 24 : 20,
                                color: isSelected
                                    ? AppColors.textBlackColor
                                    : Colors.black45,
                              )
                            else
                              Icon(
                                tab.icon,
                                size: isTab ? 24 : 20,
                                color: isSelected
                                    ? AppColors.textBlackColor
                                    : Colors.black45,
                              ),
                            const SizedBox(height: 3),
                            Text(
                              tab.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: isTab ? 13 : 11,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.textBlackColor
                                    : Colors.black54,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTabItem {
  final String title;
  final IconData icon;
  final String? assetSvg;

  const _NavTabItem({
    required this.title,
    required this.icon,
    this.assetSvg,
  });
}
