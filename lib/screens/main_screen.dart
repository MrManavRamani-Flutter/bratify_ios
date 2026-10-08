import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/frame_model.dart';
import '../models/meme_design_model.dart';
import '../my_app.dart';
import '../services/app_update_service.dart';
import '../services/database_service.dart';
import '../widgets/app_svg_icon.dart';
import 'generate_screen.dart';
import 'home_screen.dart';
import 'save_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
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
    _selectedIndex = widget.initialIndex;
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

  void openEditor({FrameTemplate? frame, MemeDesign? design}) {
    HapticFeedback.lightImpact();
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
      loadSavedMemes();
      DatabaseHelper.savedMemesChangeNotifier.value++;
      if (result == 'library') {
        _onItemTapped(1);
      }
    });
  }

  void onMemeSelected(MemeDesign meme) {
    openEditor(design: meme);
  }

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      loadSavedMemes();
      DatabaseHelper.savedMemesChangeNotifier.value++;
    }
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
            HomeScreen(
              onOpenLibrary: () => _onItemTapped(1),
            ),
            SaveScreen(
              onEditSelected: (MemeDesign meme) {
                openEditor(design: meme);
              },
            ),
            const SettingScreen(),
          ],
        ),
        bottomNavigationBar: buildBottomNavigationBar(context),
      ),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context) {
    final isTab = context.isTablet;

    final tabs = [
      const _NavTabItem(
        title: 'Studio',
        icon: Icons.auto_awesome_rounded,
        assetSvg: 'assets/svg/generate.svg',
      ),
      const _NavTabItem(
        title: 'Library',
        icon: Icons.bookmark_rounded,
        assetSvg: 'assets/svg/save.svg',
      ),
      const _NavTabItem(
        title: 'Settings',
        icon: Icons.settings_rounded,
        assetSvg: 'assets/svg/settings.svg',
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
            constraints: BoxConstraints(maxWidth: isTab ? 660 : double.infinity),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTab ? 28 : 12,
                vertical: isTab ? 8 : 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(tabs.length, (index) {
                  final tab = tabs[index];
                  final isSelected = _selectedIndex == index;

                  return Expanded(
                    child: IosBounceButton(
                      onTap: () => _onItemTapped(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          vertical: isTab ? 11 : 7,
                          horizontal: isTab ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.bratGreen.withValues(alpha: 0.22)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(isTab ? 16 : 14),
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
                                size: isTab ? 26 : 20,
                                color: isSelected
                                    ? AppColors.textBlackColor
                                    : Colors.black45,
                              )
                            else
                              Icon(
                                tab.icon,
                                size: isTab ? 26 : 20,
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
                                fontSize: isTab ? 14 : 11,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.textBlackColor
                                    : Colors.black45,
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
