import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

// -----------------------------------------------------------------------------
// Vector SVG Icon Wrapper
// -----------------------------------------------------------------------------
class AppSvgIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;

  const AppSvgIcon({
    super.key,
    required this.assetPath,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

// -----------------------------------------------------------------------------
// iOS Haptic Bounce Interactive Wrapper
// -----------------------------------------------------------------------------
class IosBounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;

  const IosBounceButton({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.94,
    this.duration = const Duration(milliseconds: 110),
  });

  @override
  State<IosBounceButton> createState() => _IosBounceButtonState();
}

class _IosBounceButtonState extends State<IosBounceButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// iOS Glass Icon Button (AppBar, Action Rows)
// -----------------------------------------------------------------------------
class IosGlassIconButton extends StatelessWidget {
  final String svgPath;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final double borderRadius;
  final bool hasBorder;

  const IosGlassIconButton({
    super.key,
    required this.svgPath,
    this.onTap,
    this.size = 42.0,
    this.iconSize = 20.0,
    this.iconColor,
    this.backgroundColor,
    this.borderRadius = 14.0,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return IosBounceButton(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(borderRadius),
          border: hasBorder
              ? Border.all(
                  color: Colors.black.withValues(alpha: 0.08),
                  width: 1.0,
                )
              : null,
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
          assetPath: svgPath,
          size: iconSize,
          color: iconColor ?? AppColors.textBlackColor,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// iOS Premium Pill Action Button (Save, Export, Share)
// -----------------------------------------------------------------------------
class IosPillActionButton extends StatelessWidget {
  final String label;
  final String? svgPath;
  final IconData? iconData;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double fontSize;
  final bool isFullWidth;

  const IosPillActionButton({
    super.key,
    required this.label,
    this.svgPath,
    this.iconData,
    this.onTap,
    this.backgroundColor = AppColors.bratGreen,
    this.textColor = Colors.black,
    this.height = 46.0,
    this.fontSize = 15.0,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor == AppColors.bratGreen
                ? AppColors.bratGreen.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (svgPath != null) ...[
            AppSvgIcon(
              assetPath: svgPath!,
              size: fontSize + 2,
              color: textColor,
            ),
            const SizedBox(width: 6),
          ] else if (iconData != null) ...[
            Icon(
              iconData,
              size: fontSize + 2,
              color: textColor,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );

    return IosBounceButton(
      onTap: onTap,
      child: isFullWidth
          ? SizedBox(width: double.infinity, child: buttonContent)
          : buttonContent,
    );
  }
}
