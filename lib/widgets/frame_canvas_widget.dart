import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../features/studio_effects/studio_effects_model.dart';
import '../models/frame_model.dart';

class FrameCanvasWidget extends StatelessWidget {
  final FrameTemplate frame;
  final XFile? imageFile;
  final VoidCallback onPickImage;
  final VoidCallback? onPhotoTap;
  final VoidCallback? onClearImage;
  final VoidCallback? onCropImage;
  final VoidCallback? onChangeImage;
  final VoidCallback? onDeleteImage;
  final double photoScale;
  final Offset photoOffset;
  final int photoRotation;
  final double customAngleDegrees;
  final bool flipHorizontal;
  final bool flipVertical;
  final BoxFit photoFit;
  final bool showFloatingControls;
  final bool showCaption;
  final StudioEffectsModel? studioEffects;
  final List<XFile?>? imageFiles;
  final Function(int slotIndex)? onPickSlotImage;
  final Function(int slotIndex)? onSlotPhotoTap;

  const FrameCanvasWidget({
    super.key,
    required this.frame,
    required this.imageFile,
    required this.onPickImage,
    this.onPhotoTap,
    this.onClearImage,
    this.onCropImage,
    this.onChangeImage,
    this.onDeleteImage,
    this.photoScale = 1.0,
    this.photoOffset = Offset.zero,
    this.photoRotation = 0,
    this.customAngleDegrees = 0.0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.photoFit = BoxFit.cover,
    this.showFloatingControls = true,
    this.showCaption = true,
    this.studioEffects,
    this.imageFiles,
    this.onPickSlotImage,
    this.onSlotPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRatio = (studioEffects?.aspectRatio ?? frame.aspectRatio).clamp(0.4, 2.5);

    Widget canvasContent = AspectRatio(
      aspectRatio: effectiveRatio,
      child: Container(
        decoration: BoxDecoration(
          color: frame.frameBgColor,
          borderRadius: BorderRadius.circular(frame.borderRadius.clamp(0.0, 48.0)),
          border: frame.borderWidth > 0
              ? Border.all(
                  color: frame.borderColor,
                  width: frame.borderWidth.clamp(0.0, 30.0),
                )
              : null,
          boxShadow: frame.hasShadow
              ? const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            (frame.borderRadius - frame.borderWidth).clamp(0.0, 48.0),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Retro Windows 98 Title Bar Overlay
              if (frame.overlayType == FrameOverlayType.retroWindow)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 24,
                  child: Container(
                    color: const Color(0xff000080),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.photo_outlined, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            frame.caption.isNotEmpty ? frame.caption : 'image_viewer.exe',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 14,
                          height: 14,
                          color: const Color(0xffC0C0C0),
                          alignment: Alignment.center,
                          child: const Text('✕', style: TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),

              // Inner Photo Content Area (with Frame Padding)
              Padding(
                padding: frame.padding,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    (frame.borderRadius * 0.5).clamp(0.0, 32.0),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildPhotoContent(context),
                      _buildOverlayDetails(),
                    ],
                  ),
                ),
              ),

              // Filmstrip Perforations (Top & Bottom)
              if (frame.overlayType == FrameOverlayType.filmstrip) ...[
                Positioned(
                  top: 4,
                  left: 8,
                  right: 8,
                  height: 12,
                  child: _buildFilmstripHoles(),
                ),
                Positioned(
                  bottom: 4,
                  left: 8,
                  right: 8,
                  height: 12,
                  child: _buildFilmstripHoles(),
                ),
              ],

              // Badges: Parental Advisory / 365 / Vinyl
              if (studioEffects?.showParentalAdvisory == true)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Text(
                      'PARENTAL\nADVISORY\nEXPLICIT CONTENT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 6,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        height: 0.9,
                      ),
                    ),
                  ),
                ),

              if (studioEffects?.show365Badge == true)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xff8ACE00), width: 1),
                    ),
                    child: const Text(
                      '365',
                      style: TextStyle(
                        color: Color(0xff8ACE00),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),

              if (studioEffects?.showVinylStamp == true)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.radio_button_checked, size: 10, color: Colors.white70),
                        SizedBox(width: 4),
                        Text('33 RPM', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

              // Bottom/Top Frame Caption & Deluxe Subtext
              if (showCaption && frame.caption.isNotEmpty && frame.overlayType != FrameOverlayType.retroWindow)
                Align(
                  alignment: frame.captionAlignment,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: _getCaptionCrossAxisAlignment(),
                      children: [
                        _buildBlurredText(
                          text: frame.caption,
                          style: _getCaptionStyle(),
                          blurSigma: studioEffects?.blurSigma ?? 0.0,
                        ),
                        if (studioEffects?.showSubtext == true && studioEffects!.subtext.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            studioEffects!.subtext,
                            textAlign: _getCaptionTextAlign(),
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: (studioEffects!.subtextSize).clamp(9.0, 18.0),
                              fontWeight: FontWeight.w500,
                              color: studioEffects!.subtextColor ?? frame.captionColor.withValues(alpha: 0.8),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              // Analog Film Grain Overlay
              if ((studioEffects?.hasFilmGrain == true && studioEffects!.grainOpacity > 0) || frame.hasFilmGrain)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: studioEffects?.grainOpacity ?? 0.08,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.08),
                              Colors.white.withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            tileMode: TileMode.repeated,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Dark Vignette Overlay
              if (studioEffects?.hasVignette == true)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                          radius: 0.85,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (studioEffects?.isInverted == true) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          -1, 0, 0, 0, 255,
          0, -1, 0, 0, 255,
          0, 0, -1, 0, 255,
          0, 0, 0, 1, 0,
        ]),
        child: canvasContent,
      );
    }

    return canvasContent;
  }

  Widget _buildBlurredText({
    required String text,
    required TextStyle style,
    required double blurSigma,
  }) {
    final textWidget = Text(
      text,
      textAlign: _getCaptionTextAlign(),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: style,
    );

    if (blurSigma <= 0.05) return textWidget;

    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: textWidget,
    );
  }

  CrossAxisAlignment _getCaptionCrossAxisAlignment() {
    if (frame.captionAlignment == Alignment.topLeft ||
        frame.captionAlignment == Alignment.bottomLeft ||
        frame.captionAlignment == Alignment.centerLeft) {
      return CrossAxisAlignment.start;
    } else if (frame.captionAlignment == Alignment.topRight ||
        frame.captionAlignment == Alignment.bottomRight ||
        frame.captionAlignment == Alignment.centerRight) {
      return CrossAxisAlignment.end;
    }
    return CrossAxisAlignment.center;
  }

  TextAlign _getCaptionTextAlign() {
    if (frame.captionAlignment == Alignment.topLeft ||
        frame.captionAlignment == Alignment.bottomLeft ||
        frame.captionAlignment == Alignment.centerLeft) {
      return TextAlign.left;
    } else if (frame.captionAlignment == Alignment.topRight ||
        frame.captionAlignment == Alignment.bottomRight ||
        frame.captionAlignment == Alignment.centerRight) {
      return TextAlign.right;
    }
    return TextAlign.center;
  }

  Widget _buildPhotoContent(BuildContext context) {
    final List<XFile?> files = imageFiles ?? [imageFile];
    XFile? getFile(int i) => i < files.length ? files[i] : null;

    switch (frame.photoLayout) {
      case FramePhotoLayout.split2H:
        return Row(
          children: [
            Expanded(child: _buildSinglePhotoSlot(context, 0, getFile(0))),
            Container(width: 3, color: frame.borderColor.withValues(alpha: 0.6)),
            Expanded(child: _buildSinglePhotoSlot(context, 1, getFile(1))),
          ],
        );

      case FramePhotoLayout.split2V:
        return Column(
          children: [
            Expanded(child: _buildSinglePhotoSlot(context, 0, getFile(0))),
            Container(height: 3, color: frame.borderColor.withValues(alpha: 0.6)),
            Expanded(child: _buildSinglePhotoSlot(context, 1, getFile(1))),
          ],
        );

      case FramePhotoLayout.polaroidDuo:
        return Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(3),
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: _buildSinglePhotoSlot(context, 0, getFile(0)),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(3),
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: _buildSinglePhotoSlot(context, 1, getFile(1)),
              ),
            ),
          ],
        );

      case FramePhotoLayout.triptych3:
        return Row(
          children: [
            Expanded(child: _buildSinglePhotoSlot(context, 0, getFile(0))),
            const SizedBox(width: 3),
            Expanded(child: _buildSinglePhotoSlot(context, 1, getFile(1))),
            const SizedBox(width: 3),
            Expanded(child: _buildSinglePhotoSlot(context, 2, getFile(2))),
          ],
        );

      case FramePhotoLayout.filmstrip3:
        return Column(
          children: [
            Expanded(child: _buildSinglePhotoSlot(context, 0, getFile(0))),
            const SizedBox(height: 4),
            Expanded(child: _buildSinglePhotoSlot(context, 1, getFile(1))),
            const SizedBox(height: 4),
            Expanded(child: _buildSinglePhotoSlot(context, 2, getFile(2))),
          ],
        );

      case FramePhotoLayout.grid4:
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildSinglePhotoSlot(context, 0, getFile(0))),
                  const SizedBox(width: 3),
                  Expanded(child: _buildSinglePhotoSlot(context, 1, getFile(1))),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildSinglePhotoSlot(context, 2, getFile(2))),
                  const SizedBox(width: 3),
                  Expanded(child: _buildSinglePhotoSlot(context, 3, getFile(3))),
                ],
              ),
            ),
          ],
        );

      case FramePhotoLayout.single:
        return _buildSinglePhotoSlot(context, 0, getFile(0));
    }
  }

  Widget _buildSinglePhotoSlot(BuildContext context, int slotIndex, XFile? slotFile) {
    final hasImage = slotFile != null;
    return GestureDetector(
      onTap: () {
        if (hasImage) {
          if (onSlotPhotoTap != null) {
            onSlotPhotoTap!(slotIndex);
          } else if (onPhotoTap != null) {
            onPhotoTap!();
          } else {
            onPickImage();
          }
        } else {
          if (onPickSlotImage != null) {
            onPickSlotImage!(slotIndex);
          } else {
            onPickImage();
          }
        }
      },
      child: Container(
        color: Colors.black12,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              ClipRect(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..translateByDouble(photoOffset.dx, photoOffset.dy, 0.0, 1.0)
                    ..rotateZ(((photoRotation * 90.0) + customAngleDegrees) * (3.141592653589793 / 180.0))
                    ..scaleByDouble(
                      (flipHorizontal ? -1.0 : 1.0) * photoScale,
                      (flipVertical ? -1.0 : 1.0) * photoScale,
                      1.0,
                      1.0,
                    ),
                  child: Image.file(
                    File(slotFile.path),
                    fit: photoFit,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(slotIndex: slotIndex),
                  ),
                ),
              )
            else
              _buildPlaceholder(slotIndex: slotIndex),

            // Top-right edit pill on photo slot when image is present
            if (hasImage && showFloatingControls)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.crop_rotate_rounded, size: 11, color: Colors.white),
                      SizedBox(width: 3),
                      Text('Crop', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder({int slotIndex = 0}) {
    final isMulti = frame.maxPhotos > 1;
    return Container(
      color: const Color(0xff2A2A2E),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMulti ? Icons.add_photo_alternate_rounded : Icons.add_a_photo_outlined,
              size: isMulti ? 26 : 38,
              color: Colors.white70,
            ),
            const SizedBox(height: 4),
            Text(
              isMulti ? 'Add Photo ${slotIndex + 1}' : 'Tap to Set Photo',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isMulti ? 11 : 14,
              ),
            ),
            if (!isMulti) ...[
              const SizedBox(height: 2),
              const Text(
                'Choose from Gallery or Camera',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayDetails() {
    switch (frame.overlayType) {
      case FrameOverlayType.vhs:
        return Stack(
          children: [
            Positioned(
              top: 8,
              left: 10,
              child: Row(
                children: const [
                  Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'REC',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SP 0:00:00',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );

      case FrameOverlayType.digicam:
        return Stack(
          children: [
            Positioned(
              top: 8,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.black54,
                child: const Text('ISO 400', style: TextStyle(color: Colors.yellow, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              top: 8,
              right: 10,
              child: const Icon(Icons.battery_3_bar_outlined, color: Colors.greenAccent, size: 18),
            ),
            Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white38, width: 1),
                ),
              ),
            ),
          ],
        );

      case FrameOverlayType.musicPlayer:
        return Positioned(
          bottom: 8,
          left: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.play_circle_filled, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: LinearProgressIndicator(
                    value: 0.45,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation(Color(0xff8ACE00)),
                    minHeight: 3,
                  ),
                ),
                SizedBox(width: 6),
                Text('3:24', style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
        );

      case FrameOverlayType.cdCase:
        return Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          width: 14,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black54, Colors.white12, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFilmstripHoles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(8, (_) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      }),
    );
  }

  TextStyle _getCaptionStyle() {
    final font = frame.captionFont;
    final size = frame.captionSize.clamp(9.0, 36.0);
    final color = frame.captionColor;

    List<Shadow>? shadows;
    if (studioEffects != null && studioEffects!.glowRadius > 0) {
      shadows = [
        Shadow(
          color: studioEffects!.glowColor,
          blurRadius: studioEffects!.glowRadius,
        ),
      ];
    }

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return TextStyle(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color,
        shadows: shadows,
      );
    }

    if (font == 'Arial' || font == 'Brat Sans') {
      return TextStyle(
        fontFamily: 'Arial',
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color,
        shadows: shadows,
      );
    }

    try {
      return GoogleFonts.getFont(
        font,
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color,
        shadows: shadows,
      );
    } catch (_) {
      return TextStyle(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color,
        shadows: shadows,
      );
    }
  }
}
