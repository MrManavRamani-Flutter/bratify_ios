import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../my_app.dart';

class CustomOnboardButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isFilled;
  final Widget? icon;
  final bool isDisable;
  final bool? isSmallSize;
  final bool? isOnBoard;

  const CustomOnboardButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isFilled = false,
    this.icon,
    this.isDisable = false,
    this.isSmallSize = false,
    this.isOnBoard = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isDisable) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isFilled
              ? (isDisable ? AppColors.fillHalfColor : AppColors.fillColor)
              : Colors.transparent,
          border: isFilled
              ? null
              : Border.all(
                  color: isDisable ? AppColors.fillHalfColor : AppColors.fillColor,
                  width: 0.8,
                ),
          borderRadius: BorderRadius.circular(isOnBoard == true ? 16 : 10),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: iphoneX
                    ? 18
                    : ipad
                        ? (isSmallSize == true ? 20 : 32)
                        : 20,
                fontWeight: FontWeight.w600,
                color: isFilled
                    ? AppColors.whiteColor
                    : (isDisable ? AppColors.fillHalfColor : AppColors.textFillColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
