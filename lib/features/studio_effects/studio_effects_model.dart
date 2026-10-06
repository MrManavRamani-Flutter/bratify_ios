import 'package:flutter/material.dart';

/// Comprehensive aesthetic effects state for Bratify Studio.
/// Supports authentic album typography blur, neon glows, deluxe subtexts,
/// vintage film grain, and quick ratio/color presets.
class StudioEffectsModel {
  // Typography FX
  final double blurSigma; // 0.0 to 12.0 (Iconic low-res Brat cover blur)
  final double glowRadius; // 0.0 to 24.0 (Neon rave glow)
  final Color glowColor;
  final double letterSpacing; // -2.0 to 6.0
  final double lineHeight; // 0.8 to 2.0
  final bool isUppercase;

  // Deluxe Subtext System (Iconic "and it's the same but there's three more songs so it's not")
  final bool showSubtext;
  final String subtext;
  final double subtextSize;
  final Color? subtextColor;

  // Aesthetic Badges & Stamps
  final bool showParentalAdvisory;
  final bool show365Badge;
  final bool showVinylStamp;

  // Surface Textures & Overlays
  final bool hasFilmGrain;
  final double grainOpacity;
  final bool hasVignette;
  final bool isInverted;

  // Canvas Framing
  final double aspectRatio;
  final String ratioName;

  const StudioEffectsModel({
    this.blurSigma = 0.0,
    this.glowRadius = 0.0,
    this.glowColor = const Color(0xff8ACE00),
    this.letterSpacing = -0.5,
    this.lineHeight = 1.0,
    this.isUppercase = false,
    this.showSubtext = false,
    this.subtext = "and it's the same but there's three more songs so it's not",
    this.subtextSize = 14.0,
    this.subtextColor,
    this.showParentalAdvisory = false,
    this.show365Badge = false,
    this.showVinylStamp = false,
    this.hasFilmGrain = false,
    this.grainOpacity = 0.12,
    this.hasVignette = false,
    this.isInverted = false,
    this.aspectRatio = 1.0,
    this.ratioName = '1:1 Square',
  });

  StudioEffectsModel copyWith({
    double? blurSigma,
    double? glowRadius,
    Color? glowColor,
    double? letterSpacing,
    double? lineHeight,
    bool? isUppercase,
    bool? showSubtext,
    String? subtext,
    double? subtextSize,
    Color? subtextColor,
    bool? showParentalAdvisory,
    bool? show365Badge,
    bool? showVinylStamp,
    bool? hasFilmGrain,
    double? grainOpacity,
    bool? hasVignette,
    bool? isInverted,
    double? aspectRatio,
    String? ratioName,
  }) {
    return StudioEffectsModel(
      blurSigma: blurSigma ?? this.blurSigma,
      glowRadius: glowRadius ?? this.glowRadius,
      glowColor: glowColor ?? this.glowColor,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      isUppercase: isUppercase ?? this.isUppercase,
      showSubtext: showSubtext ?? this.showSubtext,
      subtext: subtext ?? this.subtext,
      subtextSize: subtextSize ?? this.subtextSize,
      subtextColor: subtextColor ?? this.subtextColor,
      showParentalAdvisory: showParentalAdvisory ?? this.showParentalAdvisory,
      show365Badge: show365Badge ?? this.show365Badge,
      showVinylStamp: showVinylStamp ?? this.showVinylStamp,
      hasFilmGrain: hasFilmGrain ?? this.hasFilmGrain,
      grainOpacity: grainOpacity ?? this.grainOpacity,
      hasVignette: hasVignette ?? this.hasVignette,
      isInverted: isInverted ?? this.isInverted,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      ratioName: ratioName ?? this.ratioName,
    );
  }
}

/// Curated viral aesthetic presets for 1-tap style transformation
class StudioPalettePreset {
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;
  final String description;

  const StudioPalettePreset({
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
    required this.description,
  });
}

class StudioPresetsData {
  static const List<StudioPalettePreset> palettes = [
    StudioPalettePreset(
      name: '🍏 Brat Classic',
      backgroundColor: Color(0xff8ACE00),
      textColor: Colors.black,
      accentColor: Colors.black,
      description: 'Signature Charli XCX lime green album vibe',
    ),
    StudioPalettePreset(
      name: '🤍 Brat Deluxe',
      backgroundColor: Colors.white,
      textColor: Colors.black,
      accentColor: Color(0xff8ACE00),
      description: 'Clean stark white remastered edition aesthetic',
    ),
    StudioPalettePreset(
      name: '🖤 Club 365',
      backgroundColor: Color(0xff0A0A0C),
      textColor: Color(0xff8ACE00),
      accentColor: Color(0xff39FF14),
      description: 'Boiler Room midnight neon rave energy',
    ),
    StudioPalettePreset(
      name: '🌸 Spring Breakers',
      backgroundColor: Color(0xffFF5DA2),
      textColor: Colors.black,
      accentColor: Colors.white,
      description: 'Y2K cyber bubblegum hyperpop aesthetic',
    ),
    StudioPalettePreset(
      name: '💛 Von Dutch Acid',
      backgroundColor: Color(0xffE2F800),
      textColor: Colors.black,
      accentColor: Color(0xff8B00FF),
      description: 'High-contrast fluorescent speed racer',
    ),
    StudioPalettePreset(
      name: '💜 Sympathy Knife',
      backgroundColor: Color(0xff800080),
      textColor: Color(0xff00F0FF),
      accentColor: Colors.white,
      description: 'Moody ultraviolet electric fantasy',
    ),
    StudioPalettePreset(
      name: '🩵 So Transparent',
      backgroundColor: Color(0xff00F0FF),
      textColor: Colors.black,
      accentColor: Color(0xff0A0A0C),
      description: 'Cyber glacier crystal clean aesthetic',
    ),
    StudioPalettePreset(
      name: '🩸 B2B Rave',
      backgroundColor: Color(0xffFF003F),
      textColor: Colors.white,
      accentColor: Colors.black,
      description: 'Deep high-energy crimson club statement',
    ),
    StudioPalettePreset(
      name: '🪩 Silver Chrome',
      backgroundColor: Color(0xffD1D5DB),
      textColor: Color(0xff18181B),
      accentColor: Colors.white,
      description: 'Futuristic CD jewel case metallic tone',
    ),
    StudioPalettePreset(
      name: '🍵 Matcha Soft',
      backgroundColor: Color(0xffD1FAE5),
      textColor: Color(0xff064E3B),
      accentColor: Color(0xff059669),
      description: 'Calm Pinterest aesthetic lifestyle post',
    ),
  ];

  static const List<String> viralSubtextPresets = [
    "and it's the same but there's three more songs so it's not",
    "365 party girl deluxe edition",
    "remix album with a. g. cook",
    "live from boiler room ibiza",
    "certified club classic track",
    "dialing that number all night long",
    "main character energy 24/7",
    "it's okay to overthink everything",
    "delusional in the best way possible",
    "doing it strictly for the plot",
  ];

  static const List<Map<String, dynamic>> canvasRatios = [
    {'name': '1:1 Square', 'ratio': 1.0, 'sub': 'Album & Instagram'},
    {'name': '9:16 Story', 'ratio': 9 / 16, 'sub': 'Reels & TikTok'},
    {'name': '4:5 Portrait', 'ratio': 4 / 5, 'sub': 'Instagram Feed'},
    {'name': '16:9 Banner', 'ratio': 16 / 9, 'sub': 'Landscape Display'},
    {'name': '3:4 Digicam', 'ratio': 3 / 4, 'sub': 'Retro Film Print'},
  ];
}
