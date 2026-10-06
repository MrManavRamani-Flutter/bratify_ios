import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

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
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

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
      };

  factory MemeDesign.fromJson(Map<String, dynamic> json) => MemeDesign(
        id: json['id'],
        backgroundImageBytes: json['backgroundImageBytes'] != null
            ? base64Decode(json['backgroundImageBytes'])
            : null,
        backgroundColor: Color(json['backgroundColor']),
        text: json['text'],
        textAlign: TextAlign.values[json['textAlign']],
        fontFamily: json['fontFamily'],
        fontSize: (json['fontSize'] as num).toDouble(),
        fontWeight: json['fontWeight'],
        textColor: Color(json['textColor']),
        imageBytes: json['imageBytes'] != null ? base64Decode(json['imageBytes']) : null,
        createdAt: json['createdAt'],
      );
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
    );
  }
}
