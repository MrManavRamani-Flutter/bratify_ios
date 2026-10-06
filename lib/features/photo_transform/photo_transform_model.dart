import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Data model encapsulating all photo transformations:
/// Quarter rotations (90° steps), free custom continuous angles (-180°..180°),
/// Horizontal & Vertical flip states, scale, and offset.
class PhotoTransformState {
  final int rotationQuarter; // 0: 0°, 1: 90°, 2: 180°, 3: 270°
  final double customAngleDegrees; // Continuous fine angle (-180° to 180°)
  final bool flipHorizontal; // Horizontal mirror
  final bool flipVertical; // Vertical mirror
  final double scale; // Zoom factor
  final Offset offset; // Pan translation

  const PhotoTransformState({
    this.rotationQuarter = 0,
    this.customAngleDegrees = 0.0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.scale = 1.0,
    this.offset = Offset.zero,
  });

  /// Total combined rotation in radians
  double get totalAngleInRadians {
    final totalDeg = (rotationQuarter * 90.0) + customAngleDegrees;
    return totalDeg * (math.pi / 180.0);
  }

  /// Total combined rotation in normalized degrees (-180..180)
  double get totalDegrees {
    double deg = (rotationQuarter * 90.0) + customAngleDegrees;
    deg = (deg % 360);
    if (deg > 180) deg -= 360;
    return deg;
  }

  PhotoTransformState copyWith({
    int? rotationQuarter,
    double? customAngleDegrees,
    bool? flipHorizontal,
    bool? flipVertical,
    double? scale,
    Offset? offset,
  }) {
    return PhotoTransformState(
      rotationQuarter: rotationQuarter ?? this.rotationQuarter,
      customAngleDegrees: customAngleDegrees ?? this.customAngleDegrees,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rotationQuarter': rotationQuarter,
      'customAngleDegrees': customAngleDegrees,
      'flipHorizontal': flipHorizontal,
      'flipVertical': flipVertical,
      'scale': scale,
      'offsetDx': offset.dx,
      'offsetDy': offset.dy,
    };
  }

  factory PhotoTransformState.fromJson(Map<String, dynamic> json) {
    return PhotoTransformState(
      rotationQuarter: json['rotationQuarter'] as int? ?? 0,
      customAngleDegrees: (json['customAngleDegrees'] as num?)?.toDouble() ?? 0.0,
      flipHorizontal: json['flipHorizontal'] as bool? ?? false,
      flipVertical: json['flipVertical'] as bool? ?? false,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      offset: Offset(
        (json['offsetDx'] as num?)?.toDouble() ?? 0.0,
        (json['offsetDy'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }
}
