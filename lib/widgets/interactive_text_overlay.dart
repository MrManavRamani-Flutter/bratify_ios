import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/text_layer_model.dart';

/// Renders all draggable, selectable text layers on top of the studio canvas.
class InteractiveTextOverlay extends StatelessWidget {
  final List<TextLayerModel> layers;
  final String? activeLayerId;
  final bool isExporting;
  final ValueChanged<String> onSelectLayer;
  final void Function(String id, Offset newNormalizedOffset) onUpdateOffset;
  final ValueChanged<String> onDeleteLayer;
  final ValueChanged<String> onEditLayer;

  const InteractiveTextOverlay({
    super.key,
    required this.layers,
    required this.activeLayerId,
    this.isExporting = false,
    required this.onSelectLayer,
    required this.onUpdateOffset,
    required this.onDeleteLayer,
    required this.onEditLayer,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasW = constraints.maxWidth;
        final canvasH = constraints.maxHeight;

        if (canvasW <= 0 || canvasH <= 0) return const SizedBox.shrink();

        return Stack(
          clipBehavior: Clip.none,
          children: layers.where((l) => l.isVisible).map((layer) {
            final isSelected = !isExporting && (layer.id == activeLayerId);
            final posX = layer.offset.dx * canvasW;
            final posY = layer.offset.dy * canvasH;

            return Positioned(
              left: posX,
              top: posY,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: _buildLayerItem(
                  context,
                  layer,
                  isSelected,
                  canvasW,
                  canvasH,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLayerItem(
    BuildContext context,
    TextLayerModel layer,
    bool isSelected,
    double canvasW,
    double canvasH,
  ) {
    Widget textWidget = _buildStyledText(layer);

    // Apply rotation
    if (layer.rotation != 0.0) {
      textWidget = Transform.rotate(
        angle: layer.rotation * (math.pi / 180.0),
        child: textWidget,
      );
    }

    if (isExporting) {
      return textWidget;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onSelectLayer(layer.id);
      },
      onDoubleTap: () {
        HapticFeedback.lightImpact();
        onEditLayer(layer.id);
      },
      onPanStart: (_) {
        onSelectLayer(layer.id);
      },
      onPanUpdate: (details) {
        if (layer.isLocked) return;
        final newDx = (layer.offset.dx + (details.delta.dx / canvasW)).clamp(0.02, 0.98);
        final newDy = (layer.offset.dy + (details.delta.dy / canvasH)).clamp(0.02, 0.98);
        onUpdateOffset(layer.id, Offset(newDx, newDy));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: isSelected
            ? BoxDecoration(
                border: Border.all(
                  color: AppColors.bratGreen,
                  width: 1.6,
                ),
                borderRadius: BorderRadius.circular(6),
                color: AppColors.bratGreen.withValues(alpha: 0.08),
              )
            : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            textWidget,

            // Quick Selection Badges for active layer
            if (isSelected) ...[
              // Delete Button (Top-Right)
              Positioned(
                top: -12,
                right: -12,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onDeleteLayer(layer.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Edit Text Button (Top-Left)
              Positioned(
                top: -12,
                left: -12,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onEditLayer(layer.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.bratGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 11,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStyledText(TextLayerModel layer) {
    TextStyle style = _resolveTextStyle(layer);

    Widget content = Text(
      layer.formattedText,
      textAlign: layer.textAlign,
      style: style,
    );

    // Background pill highlight if present
    if (layer.backgroundColor != null) {
      content = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: layer.backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: content,
      );
    }

    // Brat Signature Blur
    if (layer.blurSigma > 0.01) {
      content = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: layer.blurSigma.clamp(0.0, 6.0),
          sigmaY: layer.blurSigma.clamp(0.0, 6.0),
        ),
        child: content,
      );
    }

    return content;
  }

  TextStyle _resolveTextStyle(TextLayerModel layer) {
    List<Shadow>? shadows;
    if (layer.hasShadow) {
      shadows = [
        Shadow(
          color: layer.shadowColor,
          blurRadius: layer.shadowBlur,
          offset: layer.shadowOffset,
        ),
      ];
    }

    // In unit test environment, fallback to system font to avoid font loader delays
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return TextStyle(
        fontSize: layer.fontSize,
        fontWeight: layer.effectiveFontWeight,
        color: layer.textColor,
        letterSpacing: layer.letterSpacing,
        height: layer.lineHeight,
        shadows: shadows,
      );
    }

    if (layer.fontFamily == 'Arial' || layer.fontFamily == 'Brat Sans') {
      return TextStyle(
        fontFamily: 'Arial',
        fontSize: layer.fontSize,
        fontWeight: layer.effectiveFontWeight,
        color: layer.textColor,
        letterSpacing: layer.letterSpacing,
        height: layer.lineHeight,
        shadows: shadows,
      );
    }

    try {
      return GoogleFonts.getFont(
        layer.fontFamily,
        fontSize: layer.fontSize,
        fontWeight: layer.effectiveFontWeight,
        color: layer.textColor,
        letterSpacing: layer.letterSpacing,
        height: layer.lineHeight,
        shadows: shadows,
      );
    } catch (_) {
      return TextStyle(
        fontSize: layer.fontSize,
        fontWeight: layer.effectiveFontWeight,
        color: layer.textColor,
        letterSpacing: layer.letterSpacing,
        height: layer.lineHeight,
        shadows: shadows,
      );
    }
  }
}
