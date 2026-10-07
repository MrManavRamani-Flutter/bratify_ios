import 'package:flutter/material.dart';

/// Representation of a creative color-grading filter for Bratify Studio.
class StudioFilter {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<Color> previewColors;
  final List<double> matrix;

  const StudioFilter({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.previewColors,
    required this.matrix,
  });
}

/// Catalog of curated aesthetic visual filters for Bratify Studio.
/// Supports smooth intensity interpolation (0.0 to 1.0) with Identity matrix.
class StudioFilterCatalog {
  /// Standard 4x5 identity matrix (no color modification)
  static const List<double> identityMatrix = [
    1.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ];

  static const List<StudioFilter> filters = [
    StudioFilter(
      id: 'none',
      name: 'Normal',
      category: 'Original',
      description: 'Original crisp look without color grade',
      previewColors: [Color(0xffE2E8F0), Color(0xff94A3B8)],
      matrix: identityMatrix,
    ),
    StudioFilter(
      id: 'brat',
      name: '🍏 Brat Lime',
      category: 'Signature',
      description: 'Iconic Charli XCX high-key neon lime matrix aura',
      previewColors: [Color(0xff8ACE00), Color(0xffB5FF00)],
      matrix: [
        0.65, 0.35, 0.00, 0.0, 12.0,
        0.15, 1.25, 0.10, 0.0, 24.0,
        0.00, 0.20, 0.55, 0.0, -8.0,
        0.00, 0.00, 0.00, 1.0, 0.0,
      ],
    ),
    StudioFilter(
      id: 'noir',
      name: '🎬 Noir B&W',
      category: 'Film & B&W',
      description: 'Deep high-contrast monochrome silver gelatin film',
      previewColors: [Color(0xff18181B), Color(0xff71717A)],
      matrix: [
        0.30, 0.59, 0.11, 0.0, -6.0,
        0.30, 0.59, 0.11, 0.0, -6.0,
        0.30, 0.59, 0.11, 0.0, -6.0,
        0.00, 0.00, 0.00, 1.0, 0.0,
      ],
    ),
    StudioFilter(
      id: 'vintage',
      name: '📷 Vintage 90s',
      category: 'Film & B&W',
      description: 'Warm nostalgic 90s disposable camera & Polaroid',
      previewColors: [Color(0xffE0A96D), Color(0xffDDC3A5)],
      matrix: [
        0.92, 0.14, 0.06, 0.0, 22.0,
        0.06, 0.86, 0.10, 0.0, 14.0,
        0.06, 0.10, 0.68, 0.0, 32.0,
        0.00, 0.00, 0.00, 1.0, 0.0,
      ],
    ),
    StudioFilter(
      id: 'cyberpunk',
      name: '⚡ Cyber Neon',
      category: 'Hyperpop',
      description: 'Electric cyan and vivid magenta neon duotone',
      previewColors: [Color(0xff00F0FF), Color(0xffFF007F)],
      matrix: [
        1.20, 0.00, 0.35, 0.0, 20.0,
        0.00, 0.85, 0.35, 0.0, 0.0,
        0.35, 0.20, 1.35, 0.0, 30.0,
        0.00, 0.00, 0.00, 1.0, 0.0,
      ],
    ),
    StudioFilter(
      id: 'golden',
      name: '🌅 Golden Hour',
      category: 'Warm & Sun',
      description: 'Sun-drenched amber glow with warm skin tones',
      previewColors: [Color(0xffFFAA00), Color(0xffFF5500)],
      matrix: [
        1.25, 0.10, 0.00, 0.0, 26.0,
        0.10, 1.05, 0.00, 0.0, 14.0,
        0.00, 0.00, 0.70, 0.0, -22.0,
        0.00, 0.00, 0.00, 1.0, 0.0,
      ],
    ),
    StudioFilter(
      id: 'cold',
      name: '❄️ Cold Indie',
      category: 'Moody',
      description: 'Atmospheric twilight chill with moody blue shadows',
      previewColors: [Color(0xff38BDF8), Color(0xff6366F1)],
      matrix: [
        0.78, 0.12, 0.10, 0.0, -12.0,
        0.10, 0.90, 0.20, 0.0, 2.0,
        0.20, 0.20, 1.28, 0.0, 32.0,
        0.00, 0.00, 0.00, 1.0, 0.0,
      ],
    ),
    StudioFilter(
      id: 'vivid',
      name: '💥 Vivid Pop',
      category: 'Hyperpop',
      description: 'Ultra-saturated punchy pop festival colors',
      previewColors: [Color(0xffFF0055), Color(0xffFFAA00)],
      matrix: [
        1.30, -0.15, -0.15, 0.0, 6.0,
        -0.15, 1.30, -0.15, 0.0, 6.0,
        -0.15, -0.15, 1.30, 0.0, 6.0,
        0.00,  0.00,  0.00, 1.0, 0.0,
      ],
    ),
    StudioFilter(
      id: 'sepia',
      name: '☕ Warm Sepia',
      category: 'Film & B&W',
      description: 'Antique brown parchment authentic sepia tone',
      previewColors: [Color(0xff78350F), Color(0xffD97706)],
      matrix: [
        0.393, 0.769, 0.189, 0.0, 0.0,
        0.349, 0.686, 0.168, 0.0, 0.0,
        0.272, 0.534, 0.131, 0.0, 0.0,
        0.000, 0.000, 0.000, 1.0, 0.0,
      ],
    ),
    StudioFilter(
      id: 'acid',
      name: '🧪 Acid Rave',
      category: 'Signature',
      description: 'High-energy fluorescent ultraviolet acid trip',
      previewColors: [Color(0xffD946EF), Color(0xff8ACE00)],
      matrix: [
        0.55, 0.75, 0.00, 0.0, 18.0,
        0.10, 1.35, 0.20, 0.0, 28.0,
        0.00, 0.45, 1.10, 0.0, 12.0,
        0.00, 0.00, 0.00, 1.0, 0.0,
      ],
    ),
    StudioFilter(
      id: 'pastel',
      name: '🌸 Pastel Dream',
      category: 'Moody',
      description: 'Soft dreamy bubblegum pink & lavender fairy vibe',
      previewColors: [Color(0xffF472B6), Color(0xffC084FC)],
      matrix: [
        1.15, 0.10, 0.15, 0.0, 32.0,
        0.10, 0.95, 0.10, 0.0, 18.0,
        0.15, 0.10, 1.10, 0.0, 28.0,
        0.00, 0.00, 0.00, 1.0, 0.0,
      ],
    ),
    StudioFilter(
      id: 'cinematic',
      name: '🎞️ Teal & Orange',
      category: 'Film & B&W',
      description: 'Hollywood blockbuster rich teal and orange contrast',
      previewColors: [Color(0xff0D9488), Color(0xffF97316)],
      matrix: [
        1.20, 0.00, 0.00, 0.0, 18.0,
        0.00, 1.05, 0.05, 0.0, 6.0,
        0.05, 0.10, 1.25, 0.0, 22.0,
        0.00, 0.00, 0.00, 1.0, 0.0,
      ],
    ),
    StudioFilter(
      id: 'invert',
      name: '🩻 Invert X-Ray',
      category: 'Experimental',
      description: 'Striking negative spectrum inverted exposure',
      previewColors: [Color(0xff0F172A), Color(0xff38BDF8)],
      matrix: [
        -1.0,  0.0,  0.0, 0.0, 255.0,
         0.0, -1.0,  0.0, 0.0, 255.0,
         0.0,  0.0, -1.0, 0.0, 255.0,
         0.0,  0.0,  0.0, 1.0,   0.0,
      ],
    ),
  ];

  static StudioFilter getFilter(String id) {
    return filters.firstWhere(
      (f) => f.id == id,
      orElse: () => filters.first,
    );
  }

  /// Calculates the blended 4x5 ColorFilter matrix based on [intensity] (0.0 to 1.0).
  static List<double> getMatrix(String filterId, {double intensity = 1.0}) {
    final filter = getFilter(filterId);
    if (filter.id == 'none') return identityMatrix;

    final t = intensity.clamp(0.0, 1.0);
    if (t >= 0.999) return filter.matrix;
    if (t <= 0.001) return identityMatrix;

    final target = filter.matrix;
    final interpolated = List<double>.filled(20, 0.0);
    for (int i = 0; i < 20; i++) {
      interpolated[i] = identityMatrix[i] + (target[i] - identityMatrix[i]) * t;
    }
    return interpolated;
  }
}
