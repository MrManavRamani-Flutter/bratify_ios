import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'text_layer_model.dart';

class MemeDesign {
  final int? id; // Primary key
  final Uint8List? backgroundImageBytes;
  final Color backgroundColor;
  final String text;
  final TextAlign textAlign;
  final String fontFamily;
  final double fontSize;
  final String fontWeight;
  final Color textColor;
  final Uint8List? imageBytes;
  final String createdAt; // ISO8601 string
  final String filterId;
  final double filterIntensity;

  // Exact design layout preservation
  final String? textLayersJson;
  final double? textOffsetX;
  final double? textOffsetY;
  final int? frameId;
  final double? aspectRatio;
  final int? bgMode;
  final bool? isTransparentBg;
  final double? blurSigma;
  final bool? hasFilmGrain;
  final double? grainOpacity;
  final bool? isInverted;
  final bool? hasVignette;
  final double? letterSpacing;
  final String? textCase;
  final double? frameBgOpacity;
  final String? frameBgFit;

  MemeDesign({
    this.id,
    this.backgroundImageBytes,
    required this.backgroundColor,
    required this.text,
    required this.textAlign,
    required this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.textColor,
    this.imageBytes,
    String? createdAt,
    this.filterId = 'none',
    this.filterIntensity = 1.0,
    this.textLayersJson,
    this.textOffsetX,
    this.textOffsetY,
    this.frameId,
    this.aspectRatio,
    this.bgMode,
    this.isTransparentBg,
    this.blurSigma,
    this.hasFilmGrain,
    this.grainOpacity,
    this.isInverted,
    this.hasVignette,
    this.letterSpacing,
    this.textCase,
    this.frameBgOpacity,
    this.frameBgFit,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  /// Deserialized text layers if present
  List<TextLayerModel>? get textLayers {
    if (textLayersJson == null || textLayersJson!.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(textLayersJson!);
      if (decoded is List) {
        return decoded
            .map((item) => TextLayerModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (_) {}
    return null;
  }

  static Uint8List? _parseBytes(dynamic raw) {
    if (raw == null) return null;
    if (raw is Uint8List) return raw;
    if (raw is List<int>) return Uint8List.fromList(raw);
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return null;
      try {
        return base64Decode(trimmed);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'backgroundImageBytes':
            backgroundImageBytes != null ? base64Encode(backgroundImageBytes!) : null,
        'backgroundColor': backgroundColor.toARGB32(),
        'text': text,
        'textAlign': textAlign.index,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'fontWeight': fontWeight,
        'textColor': textColor.toARGB32(),
        'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
        'createdAt': createdAt,
        'filterId': filterId,
        'filterIntensity': filterIntensity,
        'textLayersJson': textLayersJson,
        'textOffsetX': textOffsetX,
        'textOffsetY': textOffsetY,
        'frameId': frameId,
        'aspectRatio': aspectRatio,
        'bgMode': bgMode,
        'isTransparentBg': isTransparentBg,
        'blurSigma': blurSigma,
        'hasFilmGrain': hasFilmGrain,
        'grainOpacity': grainOpacity,
        'isInverted': isInverted,
        'hasVignette': hasVignette,
        'letterSpacing': letterSpacing,
        'textCase': textCase,
        'frameBgOpacity': frameBgOpacity,
        'frameBgFit': frameBgFit,
      };

  /// Raw map optimized for SQLite database insertion/updating
  Map<String, dynamic> toDbMap() => {
        if (id != null) 'id': id,
        'backgroundImageBytes': backgroundImageBytes,
        'backgroundColor': backgroundColor.toARGB32(),
        'text': text,
        'textAlign': textAlign.index,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'fontWeight': fontWeight,
        'textColor': textColor.toARGB32(),
        'imageBytes': imageBytes,
        'createdAt': createdAt,
        'filterId': filterId,
        'filterIntensity': filterIntensity,
        'textLayersJson': textLayersJson,
        'textOffsetX': textOffsetX,
        'textOffsetY': textOffsetY,
        'frameId': frameId,
        'aspectRatio': aspectRatio,
        'bgMode': bgMode,
        'isTransparentBg': isTransparentBg == null ? null : (isTransparentBg! ? 1 : 0),
        'blurSigma': blurSigma,
        'hasFilmGrain': hasFilmGrain == null ? null : (hasFilmGrain! ? 1 : 0),
        'grainOpacity': grainOpacity,
        'isInverted': isInverted == null ? null : (isInverted! ? 1 : 0),
        'hasVignette': hasVignette == null ? null : (hasVignette! ? 1 : 0),
        'letterSpacing': letterSpacing,
        'textCase': textCase,
        'frameBgOpacity': frameBgOpacity,
        'frameBgFit': frameBgFit,
      };

  factory MemeDesign.fromJson(Map<String, dynamic> json) {
    final rawTextAlign = json['textAlign'];
    TextAlign effectiveTextAlign = TextAlign.center;
    if (rawTextAlign is int && rawTextAlign >= 0 && rawTextAlign < TextAlign.values.length) {
      effectiveTextAlign = TextAlign.values[rawTextAlign];
    }

    final rawBgColor = json['backgroundColor'];
    final effectiveBgColor = rawBgColor is int ? Color(rawBgColor) : const Color(0xff8ACE00);

    final rawTextColor = json['textColor'];
    final effectiveTextColor = rawTextColor is int ? Color(rawTextColor) : Colors.black;

    bool? parseBool(dynamic val) {
      if (val == null) return null;
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val.toLowerCase() == 'true' || val == '1';
      return null;
    }

    return MemeDesign(
      id: json['id'] as int?,
      backgroundImageBytes: _parseBytes(json['backgroundImageBytes']),
      backgroundColor: effectiveBgColor,
      text: (json['text'] as String?) ?? 'brat',
      textAlign: effectiveTextAlign,
      fontFamily: (json['fontFamily'] as String?) ?? 'Arial',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 36.0,
      fontWeight: (json['fontWeight'] as String?) ?? 'Bold',
      textColor: effectiveTextColor,
      imageBytes: _parseBytes(json['imageBytes']),
      createdAt: (json['createdAt'] as String?) ?? DateTime.now().toIso8601String(),
      filterId: (json['filterId'] as String?) ?? 'none',
      filterIntensity: (json['filterIntensity'] as num?)?.toDouble() ?? 1.0,
      textLayersJson: json['textLayersJson'] as String?,
      textOffsetX: (json['textOffsetX'] as num?)?.toDouble(),
      textOffsetY: (json['textOffsetY'] as num?)?.toDouble(),
      frameId: json['frameId'] as int?,
      aspectRatio: (json['aspectRatio'] as num?)?.toDouble(),
      bgMode: json['bgMode'] as int?,
      isTransparentBg: parseBool(json['isTransparentBg']),
      blurSigma: (json['blurSigma'] as num?)?.toDouble(),
      hasFilmGrain: parseBool(json['hasFilmGrain']),
      grainOpacity: (json['grainOpacity'] as num?)?.toDouble(),
      isInverted: parseBool(json['isInverted']),
      hasVignette: parseBool(json['hasVignette']),
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble(),
      textCase: json['textCase'] as String?,
      frameBgOpacity: (json['frameBgOpacity'] as num?)?.toDouble(),
      frameBgFit: json['frameBgFit'] as String?,
    );
  }
}

extension MemeDesignCopyWith on MemeDesign {
  MemeDesign copyWith({
    int? id,
    Uint8List? backgroundImageBytes,
    Color? backgroundColor,
    String? text,
    TextAlign? textAlign,
    String? fontFamily,
    double? fontSize,
    String? fontWeight,
    Color? textColor,
    Uint8List? imageBytes,
    String? createdAt,
    String? filterId,
    double? filterIntensity,
    String? textLayersJson,
    double? textOffsetX,
    double? textOffsetY,
    int? frameId,
    double? aspectRatio,
    int? bgMode,
    bool? isTransparentBg,
    double? blurSigma,
    bool? hasFilmGrain,
    double? grainOpacity,
    bool? isInverted,
    bool? hasVignette,
    double? letterSpacing,
    String? textCase,
    double? frameBgOpacity,
    String? frameBgFit,
  }) {
    return MemeDesign(
      id: id ?? this.id,
      backgroundImageBytes: backgroundImageBytes ?? this.backgroundImageBytes,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      text: text ?? this.text,
      textAlign: textAlign ?? this.textAlign,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      textColor: textColor ?? this.textColor,
      imageBytes: imageBytes ?? this.imageBytes,
      createdAt: createdAt ?? this.createdAt,
      filterId: filterId ?? this.filterId,
      filterIntensity: filterIntensity ?? this.filterIntensity,
      textLayersJson: textLayersJson ?? this.textLayersJson,
      textOffsetX: textOffsetX ?? this.textOffsetX,
      textOffsetY: textOffsetY ?? this.textOffsetY,
      frameId: frameId ?? this.frameId,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      bgMode: bgMode ?? this.bgMode,
      isTransparentBg: isTransparentBg ?? this.isTransparentBg,
      blurSigma: blurSigma ?? this.blurSigma,
      hasFilmGrain: hasFilmGrain ?? this.hasFilmGrain,
      grainOpacity: grainOpacity ?? this.grainOpacity,
      isInverted: isInverted ?? this.isInverted,
      hasVignette: hasVignette ?? this.hasVignette,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      textCase: textCase ?? this.textCase,
      frameBgOpacity: frameBgOpacity ?? this.frameBgOpacity,
      frameBgFit: frameBgFit ?? this.frameBgFit,
    );
  }
}
