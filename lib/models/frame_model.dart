import 'package:flutter/material.dart';

enum FrameOverlayType {
  none,
  polaroid,
  filmstrip,
  retroWindow,
  vhs,
  digicam,
  musicPlayer,
  cdCase,
  stamp,
}

enum FramePhotoLayout {
  single,      // 1 photo (standard)
  split2H,     // 2 photos side by side
  split2V,     // 2 photos stacked vertically
  polaroidDuo, // 2 polaroid cards side-by-side
  triptych3,   // 3 photos side by side
  filmstrip3,  // 3 photos in vertical filmstrip
  grid4,       // 4 photos 2x2 collage
}

/// Dynamic, user-customizable frame model.
/// Allows full control over borders, corner radii, layouts, and colors.
class FrameTemplate {
  final int id;
  final String name;
  final String category;
  final Color frameBgColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets padding;
  final double aspectRatio;
  final String caption;
  final String captionFont;
  final Color captionColor;
  final double captionSize;
  final Alignment captionAlignment;
  final FrameOverlayType overlayType;
  final bool hasFilmGrain;
  final bool hasShadow;
  final FramePhotoLayout photoLayout;
  final int maxPhotos;
  final double slotSpacing;

  const FrameTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.frameBgColor,
    required this.borderColor,
    this.borderWidth = 0.0,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(12.0),
    this.aspectRatio = 1.0,
    this.caption = '',
    this.captionFont = 'Arial',
    this.captionColor = Colors.black,
    this.captionSize = 14.0,
    this.captionAlignment = Alignment.bottomCenter,
    this.overlayType = FrameOverlayType.none,
    this.hasFilmGrain = false,
    this.hasShadow = true,
    this.photoLayout = FramePhotoLayout.single,
    this.maxPhotos = 1,
    this.slotSpacing = 4.0,
  });

  FrameTemplate copyWith({
    int? id,
    String? name,
    String? category,
    Color? frameBgColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    EdgeInsets? padding,
    double? aspectRatio,
    String? caption,
    String? captionFont,
    Color? captionColor,
    double? captionSize,
    Alignment? captionAlignment,
    FrameOverlayType? overlayType,
    bool? hasFilmGrain,
    bool? hasShadow,
    FramePhotoLayout? photoLayout,
    int? maxPhotos,
    double? slotSpacing,
  }) {
    return FrameTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      frameBgColor: frameBgColor ?? this.frameBgColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      caption: caption ?? this.caption,
      captionFont: captionFont ?? this.captionFont,
      captionColor: captionColor ?? this.captionColor,
      captionSize: captionSize ?? this.captionSize,
      captionAlignment: captionAlignment ?? this.captionAlignment,
      overlayType: overlayType ?? this.overlayType,
      hasFilmGrain: hasFilmGrain ?? this.hasFilmGrain,
      hasShadow: hasShadow ?? this.hasShadow,
      photoLayout: photoLayout ?? this.photoLayout,
      maxPhotos: maxPhotos ?? this.maxPhotos,
      slotSpacing: slotSpacing ?? this.slotSpacing,
    );
  }
}

/// Versatile starter layouts that the user can pick from and fully customize.
final List<FrameTemplate> customFrameLayoutPresets = [
  const FrameTemplate(
    id: 1,
    name: 'Classic Single',
    category: 'Single',
    frameBgColor: Colors.white,
    borderColor: Colors.black,
    borderWidth: 8.0,
    borderRadius: 16.0,
    padding: EdgeInsets.all(12.0),
    aspectRatio: 1.0,
    photoLayout: FramePhotoLayout.single,
    maxPhotos: 1,
    slotSpacing: 4.0,
  ),
  const FrameTemplate(
    id: 2,
    name: 'Split Duo (H)',
    category: 'Duo',
    frameBgColor: Colors.white,
    borderColor: Colors.black,
    borderWidth: 8.0,
    borderRadius: 16.0,
    padding: EdgeInsets.all(10.0),
    aspectRatio: 1.0,
    photoLayout: FramePhotoLayout.split2H,
    maxPhotos: 2,
    slotSpacing: 4.0,
  ),
  const FrameTemplate(
    id: 3,
    name: 'Split Duo (V)',
    category: 'Duo',
    frameBgColor: Colors.white,
    borderColor: Colors.black,
    borderWidth: 8.0,
    borderRadius: 16.0,
    padding: EdgeInsets.all(10.0),
    aspectRatio: 1.0,
    photoLayout: FramePhotoLayout.split2V,
    maxPhotos: 2,
    slotSpacing: 4.0,
  ),
  const FrameTemplate(
    id: 4,
    name: 'Polaroid Card',
    category: 'Retro',
    frameBgColor: Colors.white,
    borderColor: Color(0xffEEEEEE),
    borderWidth: 2.0,
    borderRadius: 8.0,
    padding: EdgeInsets.fromLTRB(12, 12, 12, 38),
    aspectRatio: 0.85,
    overlayType: FrameOverlayType.polaroid,
    photoLayout: FramePhotoLayout.single,
    maxPhotos: 1,
    slotSpacing: 0.0,
  ),
  const FrameTemplate(
    id: 5,
    name: 'Grid 4 Collage',
    category: 'Collage',
    frameBgColor: Colors.white,
    borderColor: Colors.black,
    borderWidth: 8.0,
    borderRadius: 16.0,
    padding: EdgeInsets.all(10.0),
    aspectRatio: 1.0,
    photoLayout: FramePhotoLayout.grid4,
    maxPhotos: 4,
    slotSpacing: 4.0,
  ),
  const FrameTemplate(
    id: 6,
    name: 'Triptych (3)',
    category: 'Multi',
    frameBgColor: Colors.white,
    borderColor: Colors.black,
    borderWidth: 6.0,
    borderRadius: 14.0,
    padding: EdgeInsets.all(8.0),
    aspectRatio: 1.0,
    photoLayout: FramePhotoLayout.triptych3,
    maxPhotos: 3,
    slotSpacing: 4.0,
  ),
  const FrameTemplate(
    id: 7,
    name: 'Filmstrip (3)',
    category: 'Retro',
    frameBgColor: Color(0xff18181B),
    borderColor: Colors.white24,
    borderWidth: 4.0,
    borderRadius: 12.0,
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    aspectRatio: 0.56,
    overlayType: FrameOverlayType.filmstrip,
    photoLayout: FramePhotoLayout.filmstrip3,
    maxPhotos: 3,
    slotSpacing: 6.0,
  ),
  const FrameTemplate(
    id: 8,
    name: 'Border Free',
    category: 'Minimal',
    frameBgColor: Colors.transparent,
    borderColor: Colors.transparent,
    borderWidth: 0.0,
    borderRadius: 0.0,
    padding: EdgeInsets.zero,
    aspectRatio: 1.0,
    hasShadow: false,
    photoLayout: FramePhotoLayout.single,
    maxPhotos: 1,
    slotSpacing: 0.0,
  ),
];

const defaultCustomFrame = FrameTemplate(
  id: 1,
  name: 'Custom Frame',
  category: 'Custom',
  frameBgColor: Colors.white,
  borderColor: Colors.black,
  borderWidth: 8.0,
  borderRadius: 16.0,
  padding: EdgeInsets.all(12.0),
  aspectRatio: 1.0,
  photoLayout: FramePhotoLayout.single,
  maxPhotos: 1,
  slotSpacing: 4.0,
);

// Backward-compatibility aliases
final List<FrameTemplate> predefined500Frames = customFrameLayoutPresets;
final List<FrameTemplate> predefined100Frames = customFrameLayoutPresets;
