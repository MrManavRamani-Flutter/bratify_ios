import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// -----------------------------------------------------------------------------
// Reusable Studio Choice Chip
// -----------------------------------------------------------------------------
class StudioChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;
  final double fontSize;

  const StudioChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? (activeColor ?? Colors.black) : AppColors.offWhiteColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? (activeColor ?? Colors.black) : Colors.black12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Reusable Studio Position Pill
// -----------------------------------------------------------------------------
class StudioPositionPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const StudioPositionPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.black12,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Reusable Studio Color Circle Indicator / Picker Button
// -----------------------------------------------------------------------------
class StudioColorCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;
  final String? tooltip;

  const StudioColorCircle({
    super.key,
    required this.color,
    this.isSelected = false,
    this.onTap,
    this.size = 28.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.bratGreen : Colors.black26,
          width: isSelected ? 2.5 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.bratGreen.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: isSelected
          ? Icon(
              Icons.check,
              size: size * 0.5,
              color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            )
          : null,
    );

    if (onTap != null) {
      circle = GestureDetector(onTap: onTap, child: circle);
    }
    if (tooltip != null) {
      circle = Tooltip(message: tooltip!, child: circle);
    }
    return circle;
  }
}

// -----------------------------------------------------------------------------
// Reusable Studio Slider Row
// -----------------------------------------------------------------------------
class StudioSliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String valueDisplay;
  final Widget? trailing;

  const StudioSliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.valueDisplay,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            activeColor: Colors.black,
            inactiveColor: Colors.black12,
            onChanged: onChanged,
          ),
        ),
        Text(
          valueDisplay,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          trailing!,
        ],
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// iOS Premium Pill Action Button
// Used in Maintenance / Onboarding / CTA screens
// -----------------------------------------------------------------------------
class IosPillActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double fontSize;
  final bool isFullWidth;
  final IconData? leadingIcon;

  const IosPillActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.height = 54.0,
    this.fontSize = 16.0,
    this.isFullWidth = true,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, color: textColor, size: fontSize + 2),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: height,
        width: isFullWidth ? double.infinity : null,
        padding: isFullWidth
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
