import 'dart:convert';
import 'package:flutter/material.dart';

/// Represents an individual draggable, styleable text label on the canvas.
class TextLayerModel {
  final String id;
  String text;
  Offset offset; // Normalized coordinates: 0.0 to 1.0 (relative to canvas width & height)
  String fontFamily;
  double fontSize;
  String fontWeight; // 'Regular', 'Medium', 'Bold', 'Black'
  Color textColor;
  TextAlign textAlign;
  double letterSpacing;
  double lineHeight;
  String textCase; // 'lowercase', 'UPPERCASE', 'Normal'
  double blurSigma; // Signature Brat low-res blur (0.0 to 6.0)
  bool hasShadow;
  Color shadowColor;
  double shadowBlur;
  Offset shadowOffset;
  Color? backgroundColor; // Optional highlight background pill
  double rotation; // Degrees
  double scale;
  bool isVisible;
  bool isLocked;

  TextLayerModel({
    required this.id,
    this.text = 'brat',
    this.offset = const Offset(0.5, 0.5), // Center by default
    this.fontFamily = 'Arial',
    this.fontSize = 36.0,
    this.fontWeight = 'Bold',
    this.textColor = Colors.black,
    this.textAlign = TextAlign.center,
    this.letterSpacing = -1.0,
    this.lineHeight = 1.05,
    this.textCase = 'lowercase',
    this.blurSigma = 0.5,
    this.hasShadow = false,
    this.shadowColor = Colors.black45,
    this.shadowBlur = 4.0,
    this.shadowOffset = const Offset(0, 2),
    this.backgroundColor,
    this.rotation = 0.0,
    this.scale = 1.0,
    this.isVisible = true,
    this.isLocked = false,
  });

  /// Formatted display string based on textCase
  String get formattedText {
    final raw = text.isEmpty ? 'brat' : text;
    switch (textCase) {
      case 'lowercase':
        return raw.toLowerCase();
      case 'UPPERCASE':
        return raw.toUpperCase();
      default:
        return raw;
    }
  }

  /// FontWeight helper
  FontWeight get effectiveFontWeight {
    switch (fontWeight) {
      case 'Regular':
        return FontWeight.w400;
      case 'Medium':
        return FontWeight.w500;
      case 'Black':
        return FontWeight.w900;
      case 'Bold':
      default:
        return FontWeight.w700;
    }
  }

  TextLayerModel copyWith({
    String? id,
    String? text,
    Offset? offset,
    String? fontFamily,
    double? fontSize,
    String? fontWeight,
    Color? textColor,
    TextAlign? textAlign,
    double? letterSpacing,
    double lineHeight = -999, // Sentinel for null-like check
    String? textCase,
    double? blurSigma,
    bool? hasShadow,
    Color? shadowColor,
    double? shadowBlur,
    Offset? shadowOffset,
    Color? backgroundColor,
    double? rotation,
    double? scale,
    bool? isVisible,
    bool? isLocked,
    bool clearBackground = false,
  }) {
    return TextLayerModel(
      id: id ?? this.id,
      text: text ?? this.text,
      offset: offset ?? this.offset,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      textColor: textColor ?? this.textColor,
      textAlign: textAlign ?? this.textAlign,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight != -999 ? lineHeight : this.lineHeight,
      textCase: textCase ?? this.textCase,
      blurSigma: blurSigma ?? this.blurSigma,
      hasShadow: hasShadow ?? this.hasShadow,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      backgroundColor: clearBackground ? null : (backgroundColor ?? this.backgroundColor),
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'offset_dx': offset.dx,
        'offset_dy': offset.dy,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'fontWeight': fontWeight,
        'textColor': textColor.toARGB32(),
        'textAlign': textAlign.index,
        'letterSpacing': letterSpacing,
        'lineHeight': lineHeight,
        'textCase': textCase,
        'blurSigma': blurSigma,
        'hasShadow': hasShadow,
        'shadowColor': shadowColor.toARGB32(),
        'shadowBlur': shadowBlur,
        'shadowOffset_dx': shadowOffset.dx,
        'shadowOffset_dy': shadowOffset.dy,
        'backgroundColor': backgroundColor?.toARGB32(),
        'rotation': rotation,
        'scale': scale,
        'isVisible': isVisible,
        'isLocked': isLocked,
      };

  factory TextLayerModel.fromJson(Map<String, dynamic> json) => TextLayerModel(
        id: json['id'] as String? ?? UniqueKey().toString(),
        text: json['text'] as String? ?? 'brat',
        offset: Offset(
          (json['offset_dx'] as num?)?.toDouble() ?? 0.5,
          (json['offset_dy'] as num?)?.toDouble() ?? 0.5,
        ),
        fontFamily: json['fontFamily'] as String? ?? 'Arial',
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 36.0,
        fontWeight: json['fontWeight'] as String? ?? 'Bold',
        textColor: json['textColor'] != null ? Color(json['textColor'] as int) : Colors.black,
        textAlign: json['textAlign'] != null
            ? TextAlign.values[(json['textAlign'] as int).clamp(0, TextAlign.values.length - 1)]
            : TextAlign.center,
        letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? -1.0,
        lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.05,
        textCase: json['textCase'] as String? ?? 'lowercase',
        blurSigma: (json['blurSigma'] as num?)?.toDouble() ?? 0.5,
        hasShadow: json['hasShadow'] as bool? ?? false,
        shadowColor: json['shadowColor'] != null ? Color(json['shadowColor'] as int) : Colors.black45,
        shadowBlur: (json['shadowBlur'] as num?)?.toDouble() ?? 4.0,
        shadowOffset: Offset(
          (json['shadowOffset_dx'] as num?)?.toDouble() ?? 0.0,
          (json['shadowOffset_dy'] as num?)?.toDouble() ?? 2.0,
        ),
        backgroundColor: json['backgroundColor'] != null ? Color(json['backgroundColor'] as int) : null,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        isVisible: json['isVisible'] as bool? ?? true,
        isLocked: json['isLocked'] as bool? ?? false,
      );

  static String encodeList(List<TextLayerModel> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }

  static List<TextLayerModel> decodeList(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((e) => TextLayerModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
