import 'package:brat_generator/constants/app_colors.dart';
import 'package:brat_generator/my_app.dart';
import 'package:brat_generator/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_svg_icon.dart';

class CustomRowWidget extends StatelessWidget {
  final String centerText;
  final bool isLeft;
  final bool isRightKing;
  final bool isRightSetting;
  final bool isRightMore;
  final VoidCallback? onReset;
  final VoidCallback? onNew;

  const CustomRowWidget({
    super.key,
    required this.centerText,
    required this.isLeft,
    this.isRightKing = false,
    required this.isRightSetting,
    required this.isRightMore,
    this.onReset,
    this.onNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ipad ? 80 : 60,
      color: AppColors.offWhiteColor,
      padding: EdgeInsets.symmetric(horizontal: ipad ? 25 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (isLeft)
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.fillColor,
                size: iphoneX
                    ? 24
                    : ipad
                        ? 36
                        : 26,
              ),
            ),
          if (isRightSetting)
            IosGlassIconButton(
              svgPath: 'assets/svg/settings.svg',
              size: ipad ? 56 : 42,
              iconSize: ipad ? 28 : 20,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingScreen(),
                  ),
                );
              },
            ),
          if (isRightSetting) const SizedBox(width: 8),
          Expanded(
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    centerText,
                    textAlign: (isRightSetting) ? TextAlign.start : TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: iphoneX
                          ? 24
                          : ipad
                              ? 34
                              : (!isLeft && !isRightSetting)
                                  ? 28
                                  : 30,
                      color: AppColors.textFillColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRightMore)
                PopupMenuButton<int>(
                  icon: Container(
                    width: ipad ? 56 : 42,
                    height: ipad ? 56 : 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: AppSvgIcon(
                      assetPath: 'assets/svg/more.svg',
                      size: ipad ? 24 : 18,
                      color: AppColors.textBlackColor,
                    ),
                  ),
                  position: PopupMenuPosition.under,
                  color: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (value) {
                    if (value == 0) {
                      // Handle "New Meme" action
                      if (onNew != null) {
                        onNew!(); // Call the New function
                      }
                    } else if (value == 1) {
                      // Handle "Reset Meme" action
                      if (onReset != null) {
                        onReset!(); // Call the reset function
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                    PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: iphoneX
                                ? 24
                                : ipad
                                    ? 40
                                    : 26,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'New Meme',
                            style: GoogleFonts.outfit(
                              fontSize: iphoneX
                                  ? 14
                                  : ipad
                                      ? 22
                                      : 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.refresh,
                              size: iphoneX
                                  ? 24
                                  : ipad
                                      ? 40
                                      : 26),
                          SizedBox(width: 10),
                          Text(
                            'Reset Meme',
                            style: GoogleFonts.outfit(
                              fontSize: iphoneX
                                  ? 14
                                  : ipad
                                      ? 22
                                      : 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          )
        ],
      ),
    );
  }
}
