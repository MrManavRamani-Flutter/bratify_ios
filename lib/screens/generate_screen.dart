import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_colors.dart';
import '../features/photo_transform/photo_transform_model.dart';
import '../features/studio_effects/studio_effects_model.dart';
import '../features/studio_effects/studio_effects_sheet.dart';
import '../models/frame_model.dart';
import '../models/meme_design_model.dart';
import '../models/text_layer_model.dart';
import '../my_app.dart';
import '../services/database_service.dart';
import '../services/logger_service.dart';
import '../widgets/app_svg_icon.dart';
import '../widgets/frame_canvas_widget.dart';
import '../widgets/interactive_text_overlay.dart';
import '../widgets/text_layers_manager_widget.dart';
import 'image_crop_screen.dart';
import 'process_screen.dart';

class GenerateScreen extends StatefulWidget {
  final MemeDesign? initialDesign;
  final Function(MemeDesign)? onReset;
  final FrameTemplate? initialFrame;
  final String? initialText;
  final XFile? initialImage;
  final bool isDedicatedEditScreen;
  final VoidCallback? onBackToHome;

  const GenerateScreen({
    super.key,
    this.initialDesign,
    this.onReset,
    this.initialFrame,
    this.initialText,
    this.initialImage,
    this.isDedicatedEditScreen = false,
    this.onBackToHome,
  });

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _frameCaptionController = TextEditingController();
  final GlobalKey _repaintKey = GlobalKey();
  final GlobalKey _shareButtonKey = GlobalKey();

  // Multi-Photo Support (1 to 4 slots)
  List<XFile?> _selectedImages = [];
  int _activePhotoSlot = 0;

  void _syncPhotoSlots() {
    final maxSlots = _activeFrame?.maxPhotos ?? 1;
    if (_selectedImages.length < maxSlots) {
      while (_selectedImages.length < maxSlots) {
        _selectedImages.add(null);
      }
    } else if (_selectedImages.length > maxSlots) {
      _selectedImages = _selectedImages.sublist(0, maxSlots);
    }
    if (_selectedImage != null && _selectedImages.isNotEmpty && _selectedImages[0] == null) {
      _selectedImages[0] = _selectedImage;
    }
    if (_activePhotoSlot >= maxSlots) {
      _activePhotoSlot = 0;
    }
  }

  // Active Frame System
  FrameTemplate? _activeFrame;

  // Core canvas state
  String _currentText = "brat";
  double _currentFontSize = 36.0;
  String _currentFontFamily = 'Arial';
  String _currentFontWeight = 'Bold';
  TextAlign _currentAlignment = TextAlign.center;
  String _currentTextCase = 'lowercase'; // Iconic Brat signature
  double _letterSpacing = -0.5;

  // Multi-Text Layers Management State
  List<TextLayerModel> _textLayers = [];
  String? _activeTextLayerId;
  bool _isExporting = false;

  TextLayerModel? get _activeTextLayer {
    if (_textLayers.isEmpty) return null;
    return _textLayers.firstWhere(
      (l) => l.id == _activeTextLayerId,
      orElse: () => _textLayers.first,
    );
  }

  void _addTextLayer() {
    HapticFeedback.mediumImpact();
    _recordHistory();
    final newId = 'layer_${DateTime.now().millisecondsSinceEpoch}';
    final offsetStagger = (0.22 + (_textLayers.length * 0.14)).clamp(0.12, 0.88);
    final newLayer = TextLayerModel(
      id: newId,
      text: 'new text',
      fontFamily: _currentFontFamily,
      fontSize: _currentFontSize,
      fontWeight: _currentFontWeight,
      textColor: _getEffectiveTextColor(),
      textAlign: _currentAlignment,
      letterSpacing: _letterSpacing,
      lineHeight: 1.05,
      textCase: _currentTextCase,
      blurSigma: _blurSigma,
      offset: Offset(0.5, offsetStagger),
    );
    setState(() {
      _textLayers.add(newLayer);
      _activeTextLayerId = newId;
    });
  }

  void _deleteTextLayer(String id) {
    if (_textLayers.length <= 1) return;
    HapticFeedback.mediumImpact();
    _recordHistory();
    setState(() {
      _textLayers.removeWhere((l) => l.id == id);
      if (_activeTextLayerId == id) {
        _activeTextLayerId = _textLayers.first.id;
      }
    });
  }

  void _duplicateTextLayer(String id) {
    final layer = _textLayers.firstWhere((l) => l.id == id, orElse: () => _textLayers.first);
    HapticFeedback.lightImpact();
    _recordHistory();
    final newId = 'layer_${DateTime.now().millisecondsSinceEpoch}';
    final duplicated = layer.copyWith(
      id: newId,
      offset: Offset(
        (layer.offset.dx + 0.04).clamp(0.05, 0.95),
        (layer.offset.dy + 0.04).clamp(0.05, 0.95),
      ),
    );
    setState(() {
      _textLayers.add(duplicated);
      _activeTextLayerId = newId;
    });
  }

  void _updateActiveTextLayer(TextLayerModel updated) {
    final idx = _textLayers.indexWhere((l) => l.id == updated.id);
    if (idx != -1) {
      setState(() {
        _textLayers[idx] = updated;
        if (updated.id == _textLayers.first.id || updated.id == _activeTextLayerId) {
          _currentText = updated.text;
          if (_textController.text != updated.text) {
            _textController.text = updated.text;
          }
          _currentFontFamily = updated.fontFamily;
          _currentFontSize = updated.fontSize;
          _currentFontWeight = updated.fontWeight;
          _currentAlignment = updated.textAlign;
          _currentTextCase = updated.textCase;
          _letterSpacing = updated.letterSpacing;
          if (_activeFrame != null) {
            _activeFrame = _activeFrame!.copyWith(
              caption: updated.text,
              captionFont: updated.fontFamily,
              captionSize: updated.fontSize,
              captionColor: updated.textColor,
              captionAlignment: _getAlignmentGeometry(),
            );
            _frameCaptionController.text = updated.text;
          }
        }
      });
    }
  }

  void _showEditTextLayerDialog(String id) {
    final layer = _textLayers.firstWhere((l) => l.id == id, orElse: () => _textLayers.first);
    final editController = TextEditingController(text: layer.text);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Text Label', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter label text...',
            filled: true,
            fillColor: const Color(0xffF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _recordHistory();
              _updateActiveTextLayer(layer.copyWith(text: editController.text));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  // Aspect Ratio (1:1, 9:16, 4:5, 16:9)
  double _aspectRatio = 1.0;

  // Colors & Theme
  int _bgIndex = 0; // Brat Lime
  int _textIndex = 0; // Pitch Black
  Color? _customBgColor;
  Color? _customTextColor;
  bool _isTransparentBg = false;

  // Authentic Brat FX
  double _blurSigma = 0.0;
  bool _hasFilmGrain = true;
  double _grainOpacity = 0.15;
  bool _hasVignette = false;
  bool _isInverted = false;

  // 100x Viral Studio Effects & Badges State
  StudioEffectsModel _studioEffects = const StudioEffectsModel();

  // Photo Background & Interactive Crop / Adjust State
  XFile? _selectedImage;
  double _photoOpacity = 1.0;
  double _photoScale = 1.0;
  Offset _photoOffset = Offset.zero;
  int _photoRotation = 0; // 0: 0°, 1: 90°, 2: 180°, 3: 270°
  double _customAngleDegrees = 0.0; // Free continuous angle (-180° to +180°)
  bool _flipHorizontal = false; // Mirror X
  bool _flipVertical = false; // Mirror Y
  BoxFit _photoFit = BoxFit.cover;

  // Active Tool Tab:
  // 0: 100 Frames, 1: Modify Frame, 2: Text, 3: Style, 4: Theme, 5: Ratio, 6: FX, 7: Photo
  int _selectedTab = 0;

  // Database tracking
  int? _existingMemeId;

  static const List<String> _fontFamilies = [
    'Arial',
    'Outfit',
    'Roboto',
    'Poppins',
    'Montserrat',
    'Inter',
    'Space Grotesk',
    'Syne',
    'Bebas Neue',
    'Oswald',
    'Righteous',
    'Anton',
    'Bangers',
    'Merriweather',
    'Playfair Display',
    'Cinzel',
    'Lora',
    'Bodoni Moda',
    'Pacifico',
    'Dancing Script',
    'Caveat',
    'Sacramento',
    'Indie Flower',
    'Permanent Marker',
    'Lobster',
    'Rubik',
    'Comfortaa',
    'Fredoka',
    'Ubuntu',
    'Press Start 2P',
  ];

  @override
  void initState() {
    super.initState();
    _activeFrame = widget.initialFrame ?? defaultCustomFrame;
    _frameCaptionController.text = _activeFrame?.caption ?? '';
    _aspectRatio = _activeFrame!.aspectRatio;
    _syncPhotoSlots();

    final initialTextStr = (widget.initialText != null && widget.initialText!.isNotEmpty)
        ? widget.initialText!
        : (_activeFrame?.caption.isNotEmpty == true ? _activeFrame!.caption : _currentText);
    _currentText = initialTextStr;
    _activeFrame = _activeFrame!.copyWith(caption: _currentText);
    _frameCaptionController.text = _currentText;
    _textController.text = _currentText;
    _textLayers = [
      TextLayerModel(
        id: 'layer_1',
        text: _currentText,
        fontFamily: _activeFrame?.captionFont ?? _currentFontFamily,
        fontSize: _activeFrame!.captionSize.clamp(14.0, 72.0),
        fontWeight: _currentFontWeight,
        textColor: _activeFrame?.captionColor ?? _getEffectiveTextColor(),
        textAlign: _currentAlignment,
        letterSpacing: _letterSpacing,
        lineHeight: 1.05,
        textCase: _currentTextCase,
        blurSigma: _blurSigma,
        offset: const Offset(0.5, 0.88),
      ),
    ];
    _activeTextLayerId = 'layer_1';

    if (widget.initialImage != null) {
      _selectedImage = widget.initialImage;
      _syncPhotoSlots();
    }
    _selectedTab = 0; // Default to Tab 0: Layout & Slots

    _initializeDesign();
    _textController.addListener(_onTextChange);
    _frameCaptionController.addListener(_onFrameCaptionChange);
  }

  @override
  void didUpdateWidget(GenerateScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFrame != null && widget.initialFrame != _activeFrame) {
      setState(() {
        _activeFrame = widget.initialFrame;
        _frameCaptionController.text = _activeFrame?.caption ?? '';
        _aspectRatio = widget.initialFrame!.aspectRatio;
        _syncPhotoSlots();
      });
    }
    if (widget.initialImage != null && widget.initialImage != oldWidget.initialImage) {
      setState(() {
        _selectedImage = widget.initialImage;
        _syncPhotoSlots();
        _photoScale = 1.0;
        _photoOffset = Offset.zero;
        _photoRotation = 0;
        _customAngleDegrees = 0.0;
        _flipHorizontal = false;
        _flipVertical = false;
        _photoFit = BoxFit.cover;
        _selectedTab = 4; // Photo & Filters tab
      });
    }
    if (widget.initialText != null && widget.initialText != _currentText) {
      setState(() {
        _currentText = widget.initialText!;
        _textController.text = widget.initialText!;
        if (_textLayers.isNotEmpty) {
          final idx = _textLayers.indexWhere((l) => l.id == _activeTextLayerId);
          if (idx != -1) {
            _textLayers[idx] = _textLayers[idx].copyWith(text: widget.initialText!);
          } else {
            _textLayers[0] = _textLayers[0].copyWith(text: widget.initialText!);
          }
        }
        if (_activeFrame != null) {
          _activeFrame = _activeFrame!.copyWith(caption: widget.initialText!);
          _frameCaptionController.text = widget.initialText!;
        }
      });
    }
    if (widget.initialDesign != null && widget.initialDesign != oldWidget.initialDesign) {
      _initializeDesign();
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChange);
    _frameCaptionController.removeListener(_onFrameCaptionChange);
    _textController.dispose();
    _frameCaptionController.dispose();
    super.dispose();
  }

  void _onTextChange() {
    if (_textController.text != _currentText) {
      setState(() {
        _currentText = _textController.text;
        if (_textLayers.isNotEmpty) {
          final idx = _textLayers.indexWhere((l) => l.id == _activeTextLayerId);
          if (idx != -1) {
            _textLayers[idx] = _textLayers[idx].copyWith(text: _currentText);
          } else {
            _textLayers[0] = _textLayers[0].copyWith(text: _currentText);
          }
        }
      });
    }
  }

  void _onFrameCaptionChange() {
    if (_activeFrame != null && _frameCaptionController.text != _activeFrame!.caption) {
      setState(() {
        _activeFrame = _activeFrame!.copyWith(caption: _frameCaptionController.text);
      });
    }
  }

  void _openStudioEffectsSheet() {
    HapticFeedback.lightImpact();
    StudioEffectsSheet.show(
      context,
      currentEffects: _studioEffects,
      onEffectsChanged: (updated) {
        setState(() {
          _studioEffects = updated;
          _blurSigma = updated.blurSigma;
          _hasFilmGrain = updated.hasFilmGrain;
          _grainOpacity = updated.grainOpacity;
          _hasVignette = updated.hasVignette;
          _isInverted = updated.isInverted;
          _aspectRatio = updated.aspectRatio;
        });
      },
      onPaletteSelected: (palette) {
        setState(() {
          _customBgColor = palette.backgroundColor;
          _customTextColor = palette.textColor;
          if (_activeTextLayer != null) {
            final idx = _textLayers.indexWhere((l) => l.id == _activeTextLayer!.id);
            if (idx != -1) {
              _textLayers[idx] = _activeTextLayer!.copyWith(textColor: palette.textColor);
            }
          }
          _studioEffects = _studioEffects.copyWith(
            glowColor: palette.accentColor,
          );
          if (_activeFrame != null) {
            _activeFrame = _activeFrame!.copyWith(
              frameBgColor: palette.backgroundColor,
              captionColor: palette.textColor,
            );
          }
        });
      },
    );
  }

  Future<void> _initializeDesign() async {
    if (widget.initialDesign != null) {
      final design = widget.initialDesign!;
      _existingMemeId = design.id;
      _currentText = design.text;
      _textController.text = _currentText;
      _currentAlignment = design.textAlign;
      _currentFontFamily = design.fontFamily;
      _currentFontSize = design.fontSize.clamp(14.0, 72.0);
      _currentFontWeight = design.fontWeight;

      // Match or set text color
      final textColorIndex = AppColors.textColors.indexWhere(
        (c) => c.toARGB32() == design.textColor.toARGB32(),
      );
      if (textColorIndex != -1) {
        _textIndex = textColorIndex;
        _customTextColor = null;
      } else {
        _customTextColor = design.textColor;
      }

      // Handle background image or color
      if (design.backgroundImageBytes != null) {
        try {
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/temp_bg_${DateTime.now().millisecondsSinceEpoch}.png');
          await tempFile.writeAsBytes(design.backgroundImageBytes!);
          if (mounted) {
            setState(() {
              _selectedImage = XFile(tempFile.path);
            });
          }
        } catch (_) {
          _selectedImage = null;
        }
      } else {
        final bgColorIndex = AppColors.bgColors.indexWhere(
          (c) => c.toARGB32() == design.backgroundColor.toARGB32(),
        );
        if (bgColorIndex != -1) {
          _bgIndex = bgColorIndex;
          _customBgColor = null;
        } else {
          _customBgColor = design.backgroundColor;
        }
      }
      if (mounted) setState(() {});
    } else {
      _textController.text = _currentText;
    }
  }

  // Undo / Redo History Stacks
  final List<EditorSnapshot> _undoStack = [];
  final List<EditorSnapshot> _redoStack = [];

  void _recordHistory() {
    _undoStack.add(_createSnapshot());
    if (_undoStack.length > 25) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    if (mounted) setState(() {});
  }

  EditorSnapshot _createSnapshot() {
    return EditorSnapshot(
      text: _currentText,
      fontSize: _currentFontSize,
      fontFamily: _currentFontFamily,
      fontWeight: _currentFontWeight,
      alignment: _currentAlignment,
      textCase: _currentTextCase,
      letterSpacing: _letterSpacing,
      aspectRatio: _aspectRatio,
      bgIndex: _bgIndex,
      textIndex: _textIndex,
      customBgColor: _customBgColor,
      customTextColor: _customTextColor,
      isTransparentBg: _isTransparentBg,
      blurSigma: _blurSigma,
      hasFilmGrain: _hasFilmGrain,
      grainOpacity: _grainOpacity,
      isInverted: _isInverted,
      hasVignette: _hasVignette,
      selectedImage: _selectedImage,
      photoOpacity: _photoOpacity,
      photoScale: _photoScale,
      photoOffset: _photoOffset,
      photoRotation: _photoRotation,
      customAngleDegrees: _customAngleDegrees,
      flipHorizontal: _flipHorizontal,
      flipVertical: _flipVertical,
      photoFit: _photoFit,
      activeFrame: _activeFrame,
      frameCaption: _frameCaptionController.text,
      textLayers: _textLayers.map((l) => l.copyWith()).toList(),
      activeTextLayerId: _activeTextLayerId,
    );
  }

  void _applySnapshot(EditorSnapshot snap) {
    _currentText = snap.text;
    _textController.text = snap.text;
    _currentFontSize = snap.fontSize;
    _currentFontFamily = snap.fontFamily;
    _currentFontWeight = snap.fontWeight;
    _currentAlignment = snap.alignment;
    _currentTextCase = snap.textCase;
    _letterSpacing = snap.letterSpacing;
    _aspectRatio = snap.aspectRatio;
    _bgIndex = snap.bgIndex;
    _textIndex = snap.textIndex;
    _customBgColor = snap.customBgColor;
    _customTextColor = snap.customTextColor;
    _isTransparentBg = snap.isTransparentBg;
    _blurSigma = snap.blurSigma;
    _hasFilmGrain = snap.hasFilmGrain;
    _grainOpacity = snap.grainOpacity;
    _isInverted = snap.isInverted;
    _hasVignette = snap.hasVignette;
    _selectedImage = snap.selectedImage;
    _photoOpacity = snap.photoOpacity;
    _photoScale = snap.photoScale;
    _photoOffset = snap.photoOffset;
    _photoRotation = snap.photoRotation;
    _customAngleDegrees = snap.customAngleDegrees;
    _flipHorizontal = snap.flipHorizontal;
    _flipVertical = snap.flipVertical;
    _photoFit = snap.photoFit;
    _activeFrame = snap.activeFrame;
    _frameCaptionController.text = snap.frameCaption;
    if (snap.textLayers != null && snap.textLayers!.isNotEmpty) {
      _textLayers = snap.textLayers!.map((l) => l.copyWith()).toList();
      _activeTextLayerId = snap.activeTextLayerId ?? _textLayers.first.id;
    }
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    HapticFeedback.lightImpact();
    final previous = _undoStack.removeLast();
    _redoStack.add(_createSnapshot());
    setState(() {
      _applySnapshot(previous);
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    HapticFeedback.lightImpact();
    final next = _redoStack.removeLast();
    _undoStack.add(_createSnapshot());
    setState(() {
      _applySnapshot(next);
    });
  }

  void _resetToDefault() {
    HapticFeedback.mediumImpact();
    _recordHistory();
    setState(() {
      _activeFrame = predefined100Frames.first;
      _frameCaptionController.text = _activeFrame!.caption;
      _currentText = "brat";
      _textController.text = _currentText;
      _currentFontSize = 36.0;
      _currentFontFamily = 'Arial';
      _currentFontWeight = 'Bold';
      _currentAlignment = TextAlign.center;
      _currentTextCase = 'lowercase';
      _letterSpacing = -0.5;
      _aspectRatio = 1.0;
      _bgIndex = 0;
      _textIndex = 0;
      _customBgColor = null;
      _customTextColor = null;
      _isTransparentBg = false;
      _blurSigma = 0.0;
      _hasFilmGrain = true;
      _grainOpacity = 0.12;
      _isInverted = false;
      _hasVignette = false;
      _selectedImage = null;
      _photoScale = 1.0;
      _photoOffset = Offset.zero;
      _photoRotation = 0;
      _photoFit = BoxFit.cover;
      _existingMemeId = null;
      _selectedTab = 0;
      _textLayers = [
        TextLayerModel(
          id: 'layer_1',
          text: "brat",
          offset: const Offset(0.5, 0.5),
          fontFamily: 'Arial',
          fontSize: 36.0,
          fontWeight: 'Bold',
          textColor: Colors.black,
          textAlign: TextAlign.center,
          letterSpacing: -0.5,
          lineHeight: 1.05,
          textCase: 'lowercase',
        ),
      ];
      _activeTextLayerId = 'layer_1';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.restart_alt_rounded, color: AppColors.bratGreen, size: 18),
            SizedBox(width: 8),
            Text('Reset to Default (Tap Undo to revert)'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xff18181B),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }





  Color _getEffectiveBgColor() {
    if (_isTransparentBg) return Colors.transparent;
    final baseColor = _customBgColor ??
        (_bgIndex >= 0 && _bgIndex < AppColors.bgColors.length
            ? AppColors.bgColors[_bgIndex]
            : AppColors.bratGreen);
    return _isInverted ? _getEffectiveTextColor(ignoreInvert: true) : baseColor;
  }

  Color _getEffectiveTextColor({bool ignoreInvert = false}) {
    final baseColor = _customTextColor ??
        (_textIndex >= 0 && _textIndex < AppColors.textColors.length
            ? AppColors.textColors[_textIndex]
            : AppColors.textBlackColor);
    if (!ignoreInvert && _isInverted) {
      return _customBgColor ??
          (_bgIndex >= 0 && _bgIndex < AppColors.bgColors.length
              ? AppColors.bgColors[_bgIndex]
              : AppColors.bratGreen);
    }
    return baseColor;
  }

  String _getFormattedDisplayString() {
    final raw = _currentText.isEmpty ? "brat" : _currentText;
    switch (_currentTextCase) {
      case 'lowercase':
        return raw.toLowerCase();
      case 'UPPERCASE':
        return raw.toUpperCase();
      default:
        return raw;
    }
  }

  TextStyle _getTextStyle() {
    final fontWeightsMap = {
      'Regular': FontWeight.w400,
      'Medium': FontWeight.w500,
      'Bold': FontWeight.w700,
    };
    final weight = fontWeightsMap[_currentFontWeight] ?? FontWeight.w700;
    final color = _getEffectiveTextColor();

    if (_currentFontFamily == 'Arial' || _currentFontFamily == 'Brat Sans') {
      return TextStyle(
        fontFamily: 'Arial',
        fontSize: _currentFontSize,
        fontWeight: weight,
        color: color,
        letterSpacing: _letterSpacing,
        height: 1.05,
      );
    }

    try {
      return GoogleFonts.getFont(
        _currentFontFamily,
        fontSize: _currentFontSize,
        fontWeight: weight,
        color: color,
        letterSpacing: _letterSpacing,
        height: 1.05,
      );
    } catch (_) {
      return TextStyle(
        fontSize: _currentFontSize,
        fontWeight: weight,
        color: color,
        letterSpacing: _letterSpacing,
        height: 1.05,
      );
    }
  }



  Future<void> _pickPhotoForSlot(int slotIndex, {ImageSource source = ImageSource.gallery}) async {
    HapticFeedback.lightImpact();
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);
      if (image != null) {
        _recordHistory();
        setState(() {
          _activePhotoSlot = slotIndex;
          if (_selectedImages.length <= slotIndex) {
            while (_selectedImages.length <= slotIndex) {
              _selectedImages.add(null);
            }
          }
          _selectedImages[slotIndex] = image;
          if (slotIndex == 0) {
            _selectedImage = image;
          }
          _photoScale = 1.0;
          _photoOffset = Offset.zero;
          _photoRotation = 0;
          _photoFit = BoxFit.cover;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open image: $e')),
        );
      }
    }
  }

  void _deletePhoto() {
    _deletePhotoSlot(0);
  }

  void _deletePhotoSlot(int slotIndex) {
    if (slotIndex < _selectedImages.length && _selectedImages[slotIndex] != null) {
      final removed = _selectedImages[slotIndex];
      _recordHistory();
      HapticFeedback.mediumImpact();
      setState(() {
        _selectedImages[slotIndex] = null;
        if (slotIndex == 0) {
          _selectedImage = null;
        }
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo removed from slot ${slotIndex + 1}'),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: const Color(0xff8ACE00),
            onPressed: () {
              setState(() {
                _selectedImages[slotIndex] = removed;
                if (slotIndex == 0) {
                  _selectedImage = removed;
                }
              });
            },
          ),
        ),
      );
    } else if (_selectedImage != null) {
      final removed = _selectedImage;
      _recordHistory();
      HapticFeedback.mediumImpact();
      setState(() {
        _selectedImage = null;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo removed from canvas'),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: const Color(0xff8ACE00),
            onPressed: () {
              setState(() {
                _selectedImage = removed;
              });
            },
          ),
        ),
      );
    }
  }

  void _showPhotoSourceDialog({int slotIndex = 0}) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _activeFrame != null && _activeFrame!.maxPhotos > 1
                      ? 'Select Photo for Slot ${slotIndex + 1}'
                      : 'Select Photo Source',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Take a fresh picture or pick from your library',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickPhotoForSlot(slotIndex, source: ImageSource.camera);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.camera_alt_rounded, size: 32, color: Colors.black87),
                              SizedBox(height: 8),
                              Text('Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Take new photo', style: TextStyle(fontSize: 11, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickPhotoForSlot(slotIndex, source: ImageSource.gallery);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xff8ACE00).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xff8ACE00), width: 1.5),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.photo_library_rounded, size: 32, color: Colors.black),
                              SizedBox(height: 8),
                              Text('Photo Library', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Choose existing', style: TextStyle(fontSize: 11, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSlotPhotoOptionsSheet(int slotIndex) {
    HapticFeedback.lightImpact();
    final currentSlotImage = (slotIndex < _selectedImages.length) ? _selectedImages[slotIndex] : _selectedImage;
    if (currentSlotImage == null) {
      _showPhotoSourceDialog(slotIndex: slotIndex);
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(currentSlotImage.path),
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activeFrame != null && _activeFrame!.maxPhotos > 1
                                ? 'Photo Slot ${slotIndex + 1}'
                                : 'Photo in Frame',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Text('Crop, change or clear this photo', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.crop_rotate_rounded, color: Colors.black87),
                  ),
                  title: const Text('Crop & Adjust Photo (New Screen)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Full-screen zoom, rotate, pan & crop studio', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openImageCropAndAdjustDialog(slotIndex: slotIndex);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xff8ACE00).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.swap_horiz_rounded, color: Colors.black87),
                  ),
                  title: const Text('Change Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Choose a different photo from Gallery or Camera', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showPhotoSourceDialog(slotIndex: slotIndex);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  ),
                  title: const Text('Delete / Remove Photo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 14)),
                  subtitle: const Text('Remove photo from the frame (can be undone)', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _deletePhotoSlot(slotIndex);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openImageCropAndAdjustDialog({int slotIndex = 0}) async {
    final photoToCrop = (slotIndex < _selectedImages.length ? _selectedImages[slotIndex] : null) ?? _selectedImage;
    if (photoToCrop == null) {
      _showPhotoSourceDialog(slotIndex: slotIndex);
      return;
    }
    HapticFeedback.lightImpact();

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (ctx) => ImageCropScreen(
          imageFile: photoToCrop,
          initialTransform: PhotoTransformState(
            scale: _photoScale,
            offset: _photoOffset,
            rotationQuarter: _photoRotation,
            customAngleDegrees: _customAngleDegrees,
            flipHorizontal: _flipHorizontal,
            flipVertical: _flipVertical,
          ),
          initialAspectRatio: _activeFrame != null ? _activeFrame!.aspectRatio : _aspectRatio,
          title: _activeFrame != null && _activeFrame!.maxPhotos > 1
              ? 'Crop Slot ${slotIndex + 1}'
              : 'Crop & Adjust Photo',
        ),
      ),
    );

    if (result != null && mounted) {
      _recordHistory();
      final PhotoTransformState transform = result['transform'] as PhotoTransformState;
      final double? newRatio = result['aspectRatio'] as double?;
      setState(() {
        _photoScale = transform.scale;
        _photoOffset = transform.offset;
        _photoRotation = transform.rotationQuarter;
        _customAngleDegrees = transform.customAngleDegrees;
        _flipHorizontal = transform.flipHorizontal;
        _flipVertical = transform.flipVertical;
        if (newRatio != null && _activeFrame == null) {
          _aspectRatio = newRatio;
        }
      });
    }
  }

  Future<void> _saveMemeToDatabase() async {
    HapticFeedback.lightImpact();
    setState(() => _isExporting = true);
    await WidgetsBinding.instance.endOfFrame;
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      Uint8List? bgImageBytes;
      if (_selectedImage != null) {
        bgImageBytes = await File(_selectedImage!.path).readAsBytes();
      }

      final meme = MemeDesign(
        id: _existingMemeId,
        backgroundColor: _activeFrame != null ? _activeFrame!.frameBgColor : _getEffectiveBgColor(),
        backgroundImageBytes: bgImageBytes,
        text: _activeFrame != null ? _activeFrame!.caption : _currentText,
        textAlign: _currentAlignment,
        fontFamily: _currentFontFamily,
        fontSize: _currentFontSize,
        fontWeight: _currentFontWeight,
        textColor: _getEffectiveTextColor(),
        imageBytes: pngBytes,
        createdAt: DateTime.now().toIso8601String(),
      );

      final db = DatabaseHelper();
      if (_existingMemeId != null) {
        await db.updateMemeDesign(meme);
      } else {
        _existingMemeId = await db.insertMemeDesign(meme);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: AppColors.bratGreen, size: 20),
                SizedBox(width: 8),
                Text('Saved to Library!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xff18181B),
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      AppLogger.logAction('Database', 'Saved meme to local SQLite DB', {
        'id': _existingMemeId,
        'hasFrame': _activeFrame != null,
        'hasImage': _selectedImage != null,
      });
    } catch (e, st) {
      AppLogger.logError('Database', 'Failed to save meme design', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportToPhotos() async {
    HapticFeedback.mediumImpact();
    setState(() => _isExporting = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    try {
      await ProcessScreen.run(
        context: context,
        title: 'Rendering Ultra-HD Photo...',
        subtitle: 'Encoding 3x Retina resolution to your Photos gallery',
        featureName: 'PhotoExport',
        task: () async {
          final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
          if (boundary == null) return;
          final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData == null) return;
          final pngBytes = byteData.buffer.asUint8List();

          bool isSuccess = false;
          try {
            await Gal.putImageBytes(
              pngBytes,
              name: "bratify_${DateTime.now().millisecondsSinceEpoch}",
            );
            isSuccess = true;
            AppLogger.logInfo('Export', 'Gal saved photo successfully ✓');
          } on GalException catch (e) {
            AppLogger.logError('Export', 'Gal exception: ${e.type}', e);
            isSuccess = false;
          } catch (e, stack) {
            AppLogger.logError('Export', 'Photo gallery save error', e, stack);
            isSuccess = false;
          }

          if (mounted) {
            if (isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: const [
                      Icon(Icons.photo_library, color: AppColors.bratGreen, size: 20),
                      SizedBox(width: 8),
                      Text('Saved in Ultra-HD to Photos!'),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xff18181B),
                  duration: const Duration(seconds: 3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to save. Please allow Photos access in Settings.')),
              );
            }
          }
        },
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareMeme(BuildContext context) async {
    HapticFeedback.lightImpact();
    AppLogger.logAction('Share', 'Preparing meme for iOS share sheet');
    final messenger = ScaffoldMessenger.of(context);
    final shareBox = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final size = MediaQuery.sizeOf(context);
    final origin = (shareBox != null && shareBox.hasSize)
        ? (shareBox.localToGlobal(Offset.zero) & shareBox.size)
        : Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: 80,
            height: 80,
          );

    setState(() => _isExporting = true);
    await WidgetsBinding.instance.endOfFrame;
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/bratify_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      AppLogger.logInfo('Share', 'Wrote temporary share file at $filePath, opening share sheet');

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Created with Bratify',
        sharePositionOrigin: origin,
      );
    } catch (e, st) {
      AppLogger.logError('Share', 'Error sharing meme', e, st);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _openColorPicker(BuildContext context, {required bool isBg, bool isFrameBorder = false}) {
    HapticFeedback.lightImpact();
    Color pickedColor = isFrameBorder
        ? (_activeFrame?.borderColor ?? Colors.black)
        : isBg
            ? (_activeFrame?.frameBgColor ?? _getEffectiveBgColor())
            : _getEffectiveTextColor();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isFrameBorder
                ? 'Border Color'
                : isBg
                    ? 'Background Color'
                    : 'Text Color',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (c) => pickedColor = c,
              enableAlpha: false,
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bratGreen,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                setState(() {
                  if (isFrameBorder && _activeFrame != null) {
                    _activeFrame = _activeFrame!.copyWith(borderColor: pickedColor);
                  } else if (isBg) {
                    if (_activeFrame != null) {
                      _activeFrame = _activeFrame!.copyWith(frameBgColor: pickedColor);
                    }
                    _customBgColor = pickedColor;
                    _isTransparentBg = false;
                  } else {
                    if (_activeFrame != null) {
                      _activeFrame = _activeFrame!.copyWith(captionColor: pickedColor);
                    }
                    _customTextColor = pickedColor;
                    if (_activeTextLayer != null) {
                      final idx = _textLayers.indexWhere((l) => l.id == _activeTextLayer!.id);
                      if (idx != -1) {
                        _textLayers[idx] = _activeTextLayer!.copyWith(textColor: pickedColor);
                      }
                    }
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditScreenAppBar(BuildContext context, bool isTab) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTab ? 20 : 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button to Studio
          IosBounceButton(
            onTap: () {
              HapticFeedback.lightImpact();
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xffF2F2F7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Colors.black87),
                  const SizedBox(width: 4),
                  Text(
                    'Studio',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Title & Template Info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _activeFrame != null ? _activeFrame!.name : 'Custom Frame Studio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: isTab ? 16 : 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _getRatioLabel(_activeFrame?.aspectRatio ?? _aspectRatio),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          // Action Icons: Undo, Redo, Reset
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(
                  Icons.undo_rounded,
                  size: 20,
                  color: _undoStack.isNotEmpty ? Colors.black87 : Colors.black26,
                ),
                onPressed: _undoStack.isNotEmpty ? _undo : null,
                tooltip: 'Undo',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(
                  Icons.redo_rounded,
                  size: 20,
                  color: _redoStack.isNotEmpty ? Colors.black87 : Colors.black26,
                ),
                onPressed: _redoStack.isNotEmpty ? _redo : null,
                tooltip: 'Redo',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.restart_alt_rounded, size: 20, color: Colors.redAccent),
                onPressed: _resetToDefault,
                tooltip: 'Reset',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRatioLabel(double ratio) {
    if ((ratio - 1.0).abs() < 0.05) return '1:1 Square (Feed)';
    if ((ratio - 9 / 16).abs() < 0.05) return '9:16 Story & Reels';
    if ((ratio - 4 / 5).abs() < 0.05) return '4:5 Portrait';
    if ((ratio - 16 / 9).abs() < 0.05) return '16:9 Banner';
    return '${ratio.toStringAsFixed(2)} Aspect';
  }

  @override
  Widget build(BuildContext context) {
    final isTab = context.isTablet;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // Responsive max preview constraints
    final double maxCanvasHeight = isTab ? 380 : (screenHeight < 700 ? 220 : 265);
    final double maxCanvasWidth = isTab ? 500 : double.infinity;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.offWhiteColor,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SafeArea(
            child: Column(
              children: [
                // Top App Bar: Always Dedicated Edit Bar with Back button
                _buildEditScreenAppBar(context, isTab),

                // Main Content Body (Adaptive & Scrollable)
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isTab ? 650 : double.infinity),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTab ? 24 : 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            // 1. Live Studio Canvas Preview (Either Frame or Classic Text Canvas)
                            Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: maxCanvasHeight,
                                  maxWidth: maxCanvasWidth,
                                ),
                                child: RepaintBoundary(
                                  key: _repaintKey,
                                  child: AspectRatio(
                                    aspectRatio: _activeFrame != null ? _activeFrame!.aspectRatio : _aspectRatio,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        _activeFrame != null
                                            ? FrameCanvasWidget(
                                                frame: _activeFrame!,
                                                imageFile: _selectedImage,
                                                imageFiles: _selectedImages,
                                                onPickImage: () => _showPhotoSourceDialog(slotIndex: _activePhotoSlot),
                                                onPhotoTap: () => _showSlotPhotoOptionsSheet(_activePhotoSlot),
                                                onPickSlotImage: (idx) => _showPhotoSourceDialog(slotIndex: idx),
                                                onSlotPhotoTap: (idx) => _showSlotPhotoOptionsSheet(idx),
                                                onClearImage: _deletePhoto,
                                                onCropImage: () => _openImageCropAndAdjustDialog(slotIndex: _activePhotoSlot),
                                                onChangeImage: () => _showPhotoSourceDialog(slotIndex: _activePhotoSlot),
                                                onDeleteImage: _deletePhoto,
                                                photoScale: _photoScale,
                                                photoOffset: _photoOffset,
                                                photoRotation: _photoRotation,
                                                customAngleDegrees: _customAngleDegrees,
                                                flipHorizontal: _flipHorizontal,
                                                flipVertical: _flipVertical,
                                                photoFit: _photoFit,
                                                showCaption: false,
                                                studioEffects: _studioEffects,
                                              )
                                            : _buildClassicCanvas(),

                                        // Draggable, Interactive Multilayer Text Engine
                                        InteractiveTextOverlay(
                                          layers: _textLayers,
                                          activeLayerId: _activeTextLayerId,
                                          isExporting: _isExporting,
                                          onSelectLayer: (id) => setState(() => _activeTextLayerId = id),
                                          onUpdateOffset: (id, newOffset) {
                                            setState(() {
                                              final idx = _textLayers.indexWhere((l) => l.id == id);
                                              if (idx != -1) {
                                                _textLayers[idx] = _textLayers[idx].copyWith(offset: newOffset);
                                              }
                                            });
                                          },
                                          onDeleteLayer: (id) => _deleteTextLayer(id),
                                          onEditLayer: (id) => _showEditTextLayerDialog(id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Floating Quick Photo Actions & Arrange Bar under Canvas
                            if (_selectedImage != null || _selectedImages.any((img) => img != null))
                              _buildCanvasPhotoControlsBar(),

                            const SizedBox(height: 12),

                            // 2. Action Bar (Save Library, Photos, Share)
                            _buildExportActionBar(context, isTab),

                            const SizedBox(height: 12),

                            // 3. Studio Tool Segmented Bar
                            _buildToolTabBar(isTab),

                            const SizedBox(height: 10),

                            // 4. Active Tool Content Panel
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: _buildActiveToolPanel(isTab),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Classic Canvas Renderer (When no Frame is active)
  // ---------------------------------------------------------------------------
  Widget _buildClassicCanvas() {
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: _getEffectiveBgColor()),

              if (_selectedImage != null)
                Opacity(
                  opacity: _photoOpacity.clamp(0.0, 1.0),
                  child: ClipRect(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translateByDouble(_photoOffset.dx, _photoOffset.dy, 0.0, 1.0)
                        ..rotateZ(((_photoRotation * 90.0) + _customAngleDegrees) * (3.141592653589793 / 180.0))
                        ..scaleByDouble(
                          (_flipHorizontal ? -1.0 : 1.0) * _photoScale,
                          (_flipVertical ? -1.0 : 1.0) * _photoScale,
                          1.0,
                          1.0,
                        ),
                      child: Image.file(
                        File(_selectedImage!.path),
                        fit: _photoFit,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),

              if (_hasVignette)
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.9,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.35),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),

              if (_textLayers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: _blurSigma.clamp(0.0, 4.0),
                        sigmaY: _blurSigma.clamp(0.0, 4.0),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: _getAlignmentGeometry(),
                        child: Text(
                          _getFormattedDisplayString(),
                          textAlign: _currentAlignment,
                          style: _getTextStyle(),
                        ),
                      ),
                    ),
                  ),
                ),

              if (_hasFilmGrain && _grainOpacity > 0.0)
                IgnorePointer(
                  child: CustomPaint(
                    painter: FilmGrainPainter(
                      opacity: _grainOpacity.clamp(0.0, 0.4),
                    ),
                    size: Size.infinite,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Alignment _getAlignmentGeometry() {
    switch (_currentAlignment) {
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.center:
      default:
        return Alignment.center;
    }
  }

  // ---------------------------------------------------------------------------
  // Action Bar: Ultra-HD Save, Share, Save Library
  // ---------------------------------------------------------------------------
  Widget _buildExportActionBar(BuildContext context, bool isTab) {
    final buttonSize = isTab ? 50.0 : 44.0;
    return Row(
      children: [
        // Save to Photos (Primary Ultra-HD)
        Expanded(
          child: IosPillActionButton(
            label: 'Save Photo',
            svgPath: 'assets/svg/download.svg',
            backgroundColor: AppColors.bratGreen,
            textColor: Colors.black,
            height: buttonSize,
            fontSize: isTab ? 15 : 13.5,
            isFullWidth: true,
            onTap: _exportToPhotos,
          ),
        ),
        const SizedBox(width: 8),

        // Share
        IosBounceButton(
          key: _shareButtonKey,
          onTap: () => _shareMeme(context),
          child: Container(
            height: buttonSize,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(buttonSize / 2),
              border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppSvgIcon(
                  assetPath: 'assets/svg/share.svg',
                  size: 16,
                  color: AppColors.textBlackColor,
                ),
                const SizedBox(width: 5),
                Text(
                  'Share',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isTab ? 14 : 13,
                    color: AppColors.textBlackColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Save to Database
        IosGlassIconButton(
          svgPath: 'assets/svg/save.svg',
          size: buttonSize,
          iconSize: isTab ? 22 : 18,
          borderRadius: buttonSize / 2,
          iconColor: AppColors.fillColor,
          onTap: _saveMemeToDatabase,
        ),
        const SizedBox(width: 8),

        // Studio FX Button (Circular Symmetrical)
        IosBounceButton(
          onTap: _openStudioEffectsSheet,
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bratGreen, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.bratGreen.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text('✨', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tool Selector Tab Bar (4 Clear, Friendly, Non-Intimidating Tabs)
  // ---------------------------------------------------------------------------
  Widget _buildToolTabBar(bool isTab) {
    final tabs = [
      {'icon': Icons.grid_view_rounded, 'label': 'Layout & Slots'},
      {'icon': Icons.border_style_rounded, 'label': 'Borders & Corners'},
      {'icon': Icons.title_rounded, 'label': 'Text Labels'},
      {'icon': Icons.palette_outlined, 'label': 'Colors & FX'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (idx) {
          final isSelected = _selectedTab == idx;
          final item = tabs[idx];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = idx);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: isTab ? 16 : 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.black12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 16,
                      color: isSelected ? AppColors.bratGreen : Colors.black87,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tool Content Panels
  // ---------------------------------------------------------------------------
  Widget _buildActiveToolPanel(bool isTab) {
    switch (_selectedTab) {
      case 0:
        return _buildLayoutAndSlotsPanel(isTab);
      case 1:
        return _buildBordersAndCornersPanel(isTab);
      case 2:
        return _buildTextToolPanel(isTab);
      case 3:
        return _buildColorsAndFxPanel(isTab);
      default:
        return _buildLayoutAndSlotsPanel(isTab);
    }
  }

  // ---------------------------------------------------------------------------
  // TAB 0: Layout & Photo Slots Manager
  // ---------------------------------------------------------------------------
  Widget _buildLayoutAndSlotsPanel(bool isTab) {
    final active = _activeFrame ?? defaultCustomFrame;

    final layoutPresets = [
      {
        'label': 'Single Photo',
        'sub': '1 Slot',
        'icon': Icons.crop_portrait_rounded,
        'layout': FramePhotoLayout.single,
        'maxPhotos': 1,
        'padding': const EdgeInsets.all(12.0),
      },
      {
        'label': 'Split Duo (H)',
        'sub': '2 Slots H',
        'icon': Icons.view_column_rounded,
        'layout': FramePhotoLayout.split2H,
        'maxPhotos': 2,
        'padding': const EdgeInsets.all(12.0),
      },
      {
        'label': 'Split Duo (V)',
        'sub': '2 Slots V',
        'icon': Icons.table_rows_rounded,
        'layout': FramePhotoLayout.split2V,
        'maxPhotos': 2,
        'padding': const EdgeInsets.all(12.0),
      },
      {
        'label': 'Polaroid Frame',
        'sub': 'Vintage Chin',
        'icon': Icons.photo_camera_back_rounded,
        'layout': FramePhotoLayout.single,
        'maxPhotos': 1,
        'padding': const EdgeInsets.fromLTRB(16, 16, 16, 52),
      },
      {
        'label': '4 Grid Collage',
        'sub': '4 Slots 2x2',
        'icon': Icons.grid_view_rounded,
        'layout': FramePhotoLayout.grid4,
        'maxPhotos': 4,
        'padding': const EdgeInsets.all(12.0),
      },
      {
        'label': '3 Triptych',
        'sub': '3 Slots H',
        'icon': Icons.view_week_rounded,
        'layout': FramePhotoLayout.triptych3,
        'maxPhotos': 3,
        'padding': const EdgeInsets.all(10.0),
      },
      {
        'label': '3 Filmstrip',
        'sub': '3 Slots V',
        'icon': Icons.movie_filter_rounded,
        'layout': FramePhotoLayout.filmstrip3,
        'maxPhotos': 3,
        'padding': const EdgeInsets.all(10.0),
      },
      {
        'label': 'Border Free',
        'sub': 'Edge-to-Edge',
        'icon': Icons.fullscreen_rounded,
        'layout': FramePhotoLayout.single,
        'maxPhotos': 1,
        'padding': EdgeInsets.zero,
      },
    ];

    final ratios = [
      {'label': '1:1 Square', 'ratio': 1.0},
      {'label': '4:5 Portrait', 'ratio': 4 / 5},
      {'label': '9:16 Story', 'ratio': 9 / 16},
      {'label': '16:9 Banner', 'ratio': 16 / 9},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Collage Layout Selector
        Text(
          'COLLAGE LAYOUT & MULTI-FRAMES',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 86,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: layoutPresets.length,
            itemBuilder: (ctx, idx) {
              final p = layoutPresets[idx];
              final layout = p['layout'] as FramePhotoLayout;
              final maxPhotos = p['maxPhotos'] as int;
              final isPolaroid = p['label'] == 'Polaroid Frame';
              final isSelected = active.photoLayout == layout &&
                  active.maxPhotos == maxPhotos &&
                  (!isPolaroid || active.padding.bottom > 30);

              return GestureDetector(
                onTap: () {
                  _recordHistory();
                  HapticFeedback.selectionClick();
                  setState(() {
                    _activeFrame = active.copyWith(
                      name: p['label'] as String,
                      photoLayout: layout,
                      maxPhotos: maxPhotos,
                      padding: p['padding'] as EdgeInsets,
                    );
                    _syncPhotoSlots();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 104,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.bratGreen : Colors.black12,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        p['icon'] as IconData,
                        size: 24,
                        color: isSelected ? AppColors.bratGreen : Colors.black87,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p['label'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        p['sub'] as String,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected ? Colors.white60 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 14),

        // 2. Aspect Ratio Selector
        Row(
          children: [
            Text(
              'RATIO:',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ratios.map((r) {
                    final ratioVal = r['ratio'] as double;
                    final isSelected = (_aspectRatio - ratioVal).abs() < 0.03;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () {
                          _recordHistory();
                          HapticFeedback.selectionClick();
                          setState(() {
                            _aspectRatio = ratioVal;
                            _activeFrame = active.copyWith(aspectRatio: ratioVal);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : const Color(0xffF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.bratGreen : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            r['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppColors.bratGreen : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        const Divider(height: 1, color: Colors.black12),
        const SizedBox(height: 14),

        // 3. Multi-Photo Slots Manager
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PHOTO SLOTS (${active.maxPhotos})',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Colors.black54,
              ),
            ),
            Text(
              'Tap a slot to set or change photo',
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Slots Grid
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(active.maxPhotos, (slotIdx) {
            final hasPhoto = slotIdx < _selectedImages.length && _selectedImages[slotIdx] != null;
            final isSlotActive = _activePhotoSlot == slotIdx;

            return GestureDetector(
              onTap: () {
                setState(() => _activePhotoSlot = slotIdx);
                if (!hasPhoto) {
                  _showPhotoSourceDialog(slotIndex: slotIdx);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isTab ? 130 : 100,
                height: isTab ? 140 : 115,
                decoration: BoxDecoration(
                  color: isSlotActive ? AppColors.bratGreen.withValues(alpha: 0.1) : const Color(0xffF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSlotActive ? AppColors.bratGreen : Colors.black12,
                    width: isSlotActive ? 2.0 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    // Top Slot Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSlotActive ? Colors.black : Colors.black.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Slot ${slotIdx + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSlotActive ? AppColors.bratGreen : Colors.black87,
                            ),
                          ),
                          if (hasPhoto)
                            const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.bratGreen)
                          else
                            const Icon(Icons.add_circle_outline_rounded, size: 12, color: Colors.black45),
                        ],
                      ),
                    ),

                    // Slot Preview Thumbnail
                    Expanded(
                      child: Center(
                        child: hasPhoto
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                                  File(_selectedImages[slotIdx]!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo_outlined, size: 22, color: Colors.black38),
                                  SizedBox(height: 3),
                                  Text('+ Add Photo', style: TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    ),

                    // Bottom Action Strip (if has photo)
                    if (hasPhoto)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => _openImageCropAndAdjustDialog(slotIndex: slotIdx),
                              child: const Icon(Icons.crop_rounded, size: 14, color: Colors.black87),
                            ),
                            GestureDetector(
                              onTap: () => _showPhotoSourceDialog(slotIndex: slotIdx),
                              child: const Icon(Icons.swap_horiz_rounded, size: 14, color: Colors.black87),
                            ),
                            GestureDetector(
                              onTap: () => _deletePhotoSlot(slotIdx),
                              child: const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Borders & Corners Custom Designer
  // ---------------------------------------------------------------------------
  Widget _buildBordersAndCornersPanel(bool isTab) {
    final active = _activeFrame ?? defaultCustomFrame;

    final borderColorsList = [
      Colors.white,
      Colors.black,
      AppColors.bratGreen,
      const Color(0xffF5F5F0),
      const Color(0xffFF80BF),
      const Color(0xff00E5FF),
      const Color(0xffFFE600),
      const Color(0xffD4BBFF),
      const Color(0xff475569),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Corner Radius
        Row(
          children: [
            Text(
              'CORNER RADIUS',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Colors.black54,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${active.borderRadius.toInt()} px',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.bratGreen),
              ),
            ),
          ],
        ),
        Slider(
          value: active.borderRadius.clamp(0.0, 48.0),
          min: 0.0,
          max: 48.0,
          activeColor: Colors.black,
          inactiveColor: Colors.black12,
          onChangeStart: (_) => _recordHistory(),
          onChanged: (v) {
            setState(() {
              _activeFrame = active.copyWith(borderRadius: v);
            });
          },
        ),
        // Quick presets for Corner Radius
        Row(
          children: [
            _buildPresetChip('Sharp 0', active.borderRadius == 0.0, () {
              _recordHistory();
              setState(() => _activeFrame = active.copyWith(borderRadius: 0.0));
            }),
            const SizedBox(width: 6),
            _buildPresetChip('Soft 12', active.borderRadius == 12.0, () {
              _recordHistory();
              setState(() => _activeFrame = active.copyWith(borderRadius: 12.0));
            }),
            const SizedBox(width: 6),
            _buildPresetChip('Squircle 24', active.borderRadius == 24.0, () {
              _recordHistory();
              setState(() => _activeFrame = active.copyWith(borderRadius: 24.0));
            }),
            const SizedBox(width: 6),
            _buildPresetChip('Pill 44', active.borderRadius == 44.0, () {
              _recordHistory();
              setState(() => _activeFrame = active.copyWith(borderRadius: 44.0));
            }),
          ],
        ),

        const SizedBox(height: 16),
        const Divider(height: 1, color: Colors.black12),
        const SizedBox(height: 14),

        // 2. Border Width
        Row(
          children: [
            Text(
              'BORDER WIDTH',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Colors.black54,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${active.borderWidth.toInt()} px',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.bratGreen),
              ),
            ),
          ],
        ),
        Slider(
          value: active.borderWidth.clamp(0.0, 30.0),
          min: 0.0,
          max: 30.0,
          activeColor: Colors.black,
          inactiveColor: Colors.black12,
          onChangeStart: (_) => _recordHistory(),
          onChanged: (v) {
            setState(() {
              _activeFrame = active.copyWith(borderWidth: v);
            });
          },
        ),
        // Quick presets for Border Width
        Row(
          children: [
            _buildPresetChip('None 0', active.borderWidth == 0.0, () {
              _recordHistory();
              setState(() => _activeFrame = active.copyWith(borderWidth: 0.0));
            }),
            const SizedBox(width: 6),
            _buildPresetChip('Thin 4', active.borderWidth == 4.0, () {
              _recordHistory();
              setState(() => _activeFrame = active.copyWith(borderWidth: 4.0));
            }),
            const SizedBox(width: 6),
            _buildPresetChip('Medium 10', active.borderWidth == 10.0, () {
              _recordHistory();
              setState(() => _activeFrame = active.copyWith(borderWidth: 10.0));
            }),
            const SizedBox(width: 6),
            _buildPresetChip('Bold 20', active.borderWidth == 20.0, () {
              _recordHistory();
              setState(() => _activeFrame = active.copyWith(borderWidth: 20.0));
            }),
          ],
        ),

        const SizedBox(height: 16),
        const Divider(height: 1, color: Colors.black12),
        const SizedBox(height: 14),

        // 3. Spacing: Slot Gap & Margins
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SLOT GAP',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                        ),
                      ),
                      Text('${active.slotSpacing.toInt()} px', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: active.slotSpacing.clamp(0.0, 24.0),
                    min: 0.0,
                    max: 24.0,
                    activeColor: Colors.black,
                    inactiveColor: Colors.black12,
                    onChangeStart: (_) => _recordHistory(),
                    onChanged: (v) {
                      setState(() {
                        _activeFrame = active.copyWith(slotSpacing: v);
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PADDING',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                        ),
                      ),
                      Text('${active.padding.left.toInt()} px', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: active.padding.left.clamp(0.0, 36.0),
                    min: 0.0,
                    max: 36.0,
                    activeColor: Colors.black,
                    inactiveColor: Colors.black12,
                    onChangeStart: (_) => _recordHistory(),
                    onChanged: (v) {
                      setState(() {
                        _activeFrame = active.copyWith(
                          padding: active.padding.bottom > 30
                              ? EdgeInsets.fromLTRB(v, v, v, v + 36.0)
                              : EdgeInsets.all(v),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        const Divider(height: 1, color: Colors.black12),
        const SizedBox(height: 14),

        // 4. Border Color
        Text(
          'BORDER COLOR',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            // Rainbow Picker
            GestureDetector(
              onTap: () => _openColorPicker(context, isBg: false, isFrameBorder: true),
              child: Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26),
                  gradient: const SweepGradient(
                    colors: [Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.purple, Colors.red],
                  ),
                ),
                child: const Icon(Icons.colorize, size: 15, color: Colors.white),
              ),
            ),
            // Palette circles
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: borderColorsList.map((c) {
                    final isSelected = active.borderColor.toARGB32() == c.toARGB32();
                    return GestureDetector(
                      onTap: () {
                        _recordHistory();
                        HapticFeedback.selectionClick();
                        setState(() {
                          _activeFrame = active.copyWith(borderColor: c);
                        });
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 7),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.black26,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, size: 14, color: c == Colors.white ? Colors.black : Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 5. Drop Shadow Switch
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.layers_rounded, size: 18, color: Colors.black87),
                  SizedBox(width: 8),
                  Text(
                    'Realistic Drop Shadow',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
              Switch.adaptive(
                value: active.hasShadow,
                activeTrackColor: AppColors.bratGreen,
                onChanged: (val) {
                  _recordHistory();
                  HapticFeedback.lightImpact();
                  setState(() {
                    _activeFrame = active.copyWith(hasShadow: val);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : const Color(0xffF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.bratGreen : Colors.transparent,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? AppColors.bratGreen : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: Text Labels Manager & Typography
  // ---------------------------------------------------------------------------
  Widget _buildTextToolPanel(bool isTab) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TEXT LABELS',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Drag labels freely anywhere on canvas',
                  style: TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
            IosBounceButton(
              onTap: _addTextLayer,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bratGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add_rounded, size: 14, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      'Add Label',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextLayersManagerWidget(
          layers: _textLayers,
          activeLayerId: _activeTextLayerId,
          onSelectLayer: (id) => setState(() => _activeTextLayerId = id),
          onAddLayer: _addTextLayer,
          onDeleteLayer: _deleteTextLayer,
          onDuplicateLayer: _duplicateTextLayer,
          onUpdateLayer: _updateActiveTextLayer,
          onRecordHistory: _recordHistory,
          onOpenFontBrowser: () => _openFontPickerSheet(context),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: Colors & Studio FX
  // ---------------------------------------------------------------------------
  Widget _buildColorsAndFxPanel(bool isTab) {
    final colorsList = [
      AppColors.bratGreen,
      Colors.white,
      Colors.black,
      const Color(0xff121212),
      const Color(0xffF5F5F0),
      const Color(0xffFF80BF),
      const Color(0xff00E5FF),
      const Color(0xffFFE600),
      const Color(0xffFF6B35),
      const Color(0xff8B5CF6),
      const Color(0xff2563EB),
      const Color(0xffE50000),
      const Color(0xffD6D9E0),
    ];

    final currentBg = _activeFrame?.frameBgColor ?? _getEffectiveBgColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FRAME BACKGROUND COLOR',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Rainbow Color Picker Button
            GestureDetector(
              onTap: () => _openColorPicker(context, isBg: true),
              child: Container(
                width: 34,
                height: 34,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26),
                  gradient: const SweepGradient(
                    colors: [Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.purple, Colors.red],
                  ),
                ),
                child: const Icon(Icons.colorize, size: 16, color: Colors.white),
              ),
            ),

            // Color Dots
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: colorsList.map((color) {
                    final isSelected = currentBg.toARGB32() == color.toARGB32();
                    return GestureDetector(
                      onTap: () {
                        _recordHistory();
                        HapticFeedback.selectionClick();
                        setState(() {
                          _customBgColor = color;
                          _isTransparentBg = false;
                          if (_activeFrame != null) {
                            _activeFrame = _activeFrame!.copyWith(frameBgColor: color);
                          }
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.black12,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: color == Colors.white ? Colors.black : Colors.white,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: Colors.black12),
        const SizedBox(height: 14),

        Text(
          'STUDIO EFFECTS & FILTERS',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),

        // Film Grain Slider
        Row(
          children: [
            const SizedBox(
              width: 75,
              child: Text('35mm Grain', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: Slider(
                value: _grainOpacity.clamp(0.0, 0.35),
                min: 0.0,
                max: 0.35,
                activeColor: Colors.black,
                inactiveColor: Colors.black12,
                onChangeStart: (_) => _recordHistory(),
                onChanged: (v) => setState(() {
                  _grainOpacity = v;
                  _hasFilmGrain = v > 0.01;
                }),
              ),
            ),
            Text('${(_grainOpacity * 280).toInt()}%', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),

        // Blur Slider
        Row(
          children: [
            const SizedBox(
              width: 75,
              child: Text('Lo-Fi Blur', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: Slider(
                value: _blurSigma.clamp(0.0, 4.0),
                min: 0.0,
                max: 4.0,
                activeColor: Colors.black,
                inactiveColor: Colors.black12,
                onChangeStart: (_) => _recordHistory(),
                onChanged: (v) => setState(() => _blurSigma = v),
              ),
            ),
            Text('${(_blurSigma * 25).toInt()}%', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),

        // Toggle buttons: Vignette & Invert
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _recordHistory();
                  HapticFeedback.selectionClick();
                  setState(() => _hasVignette = !_hasVignette);
                },
                icon: Icon(_hasVignette ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 16),
                label: Text(
                  _hasVignette ? 'Vignette: ON' : 'Vignette: OFF',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _hasVignette ? Colors.black : Colors.white,
                  foregroundColor: _hasVignette ? AppColors.bratGreen : Colors.black87,
                  side: const BorderSide(color: Colors.black26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _recordHistory();
                  HapticFeedback.lightImpact();
                  setState(() => _isInverted = !_isInverted);
                },
                icon: const Icon(Icons.swap_calls_rounded, size: 16),
                label: Text(
                  _isInverted ? 'Invert: ON' : 'Invert Colors',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _isInverted ? Colors.black : Colors.white,
                  foregroundColor: _isInverted ? AppColors.bratGreen : Colors.black87,
                  side: const BorderSide(color: Colors.black26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Google Fonts Full Browser Sheet (30+ Google Fonts with Search)
  // ---------------------------------------------------------------------------
  void _openFontPickerSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredFonts = _fontFamilies.where((f) {
              return f.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.92,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Choose Google Font',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            '${_fontFamilies.length} Fonts',
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        onChanged: (v) => setSheetState(() => searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search font name...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: AppColors.offWhiteColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: filteredFonts.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black12),
                          itemBuilder: (context, idx) {
                            final font = filteredFonts[idx];
                            final isSelected = _currentFontFamily == font;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              title: Text(
                                font,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Text(
                                _currentText.isNotEmpty ? _currentText : 'Sample Text',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _getFontPreviewStyle(font),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: AppColors.bratGreen)
                                  : null,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _recordHistory();
                                if (_activeTextLayer != null) {
                                  _updateActiveTextLayer(_activeTextLayer!.copyWith(fontFamily: font));
                                } else {
                                  setState(() {
                                    _currentFontFamily = font;
                                    if (_activeFrame != null) {
                                      _activeFrame = _activeFrame!.copyWith(captionFont: font);
                                    }
                                  });
                                }
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  TextStyle _getFontPreviewStyle(String font) {
    if (font == 'Arial' || font == 'Brat Sans') {
      return const TextStyle(fontFamily: 'Arial', fontSize: 16);
    }
    try {
      return GoogleFonts.getFont(font, fontSize: 16);
    } catch (_) {
      return const TextStyle(fontSize: 16);
    }
  }



  Widget _buildCanvasPhotoControlsBar() {
    final totalSlots = _activeFrame?.maxPhotos ?? 1;
    final currentSlotImage = (_activePhotoSlot < _selectedImages.length ? _selectedImages[_activePhotoSlot] : null) ?? _selectedImage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (totalSlots > 1) ...[
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalSlots, (slotIdx) {
                final isSelected = _activePhotoSlot == slotIdx;
                final file = slotIdx < _selectedImages.length ? _selectedImages[slotIdx] : null;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: IosBounceButton(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _activePhotoSlot = slotIdx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.bratGreen : Colors.black12,
                          width: isSelected ? 1.4 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: file != null ? AppColors.bratGreen : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: file != null
                                ? const Icon(Icons.check, size: 8, color: Colors.black)
                                : null,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Slot ${slotIdx + 1}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],

        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: currentSlotImage != null
                        ? DecorationImage(
                            image: FileImage(File(currentSlotImage.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 8),

                // Rotate 90 CW
                _buildQuickPhotoAction(
                  icon: Icons.rotate_right_rounded,
                  label: '+90°',
                  onTap: () {
                    _recordHistory();
                    HapticFeedback.lightImpact();
                    setState(() => _photoRotation = (_photoRotation + 1) % 4);
                  },
                ),

                const SizedBox(width: 4),
                Container(width: 1, height: 14, color: Colors.black12),
                const SizedBox(width: 4),

                // Flip Horizontal
                _buildQuickPhotoAction(
                  icon: Icons.flip_rounded,
                  label: 'Flip H',
                  isActive: _flipHorizontal,
                  onTap: () {
                    _recordHistory();
                    HapticFeedback.lightImpact();
                    setState(() => _flipHorizontal = !_flipHorizontal);
                  },
                ),

                const SizedBox(width: 4),
                Container(width: 1, height: 14, color: Colors.black12),
                const SizedBox(width: 4),

                // Fit Mode Toggle
                _buildQuickPhotoAction(
                  icon: _photoFit == BoxFit.cover ? Icons.fullscreen_rounded : Icons.fit_screen_rounded,
                  label: _photoFit == BoxFit.cover ? 'Cover' : 'Fit',
                  onTap: () {
                    _recordHistory();
                    HapticFeedback.lightImpact();
                    setState(() => _photoFit = _photoFit == BoxFit.cover ? BoxFit.contain : BoxFit.cover);
                  },
                ),

                const SizedBox(width: 4),
                Container(width: 1, height: 14, color: Colors.black12),
                const SizedBox(width: 4),

                // Crop & Adjust (Opens dedicated new screen)
                _buildQuickPhotoAction(
                  icon: Icons.crop_rotate_rounded,
                  label: 'Crop/Zoom',
                  onTap: () => _openImageCropAndAdjustDialog(slotIndex: _activePhotoSlot),
                ),

                const SizedBox(width: 4),
                Container(width: 1, height: 14, color: Colors.black12),
                const SizedBox(width: 4),

                // Change Photo
                _buildQuickPhotoAction(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Change',
                  onTap: () => _showPhotoSourceDialog(slotIndex: _activePhotoSlot),
                ),

                const SizedBox(width: 4),
                Container(width: 1, height: 14, color: Colors.black12),
                const SizedBox(width: 4),

                // Delete Photo
                _buildQuickPhotoAction(
                  icon: Icons.delete_outline_rounded,
                  label: 'Clear',
                  color: Colors.redAccent,
                  onTap: () => _deletePhotoSlot(_activePhotoSlot),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 5),

        // Hint for interactive gestures
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.touch_app_rounded, size: 12, color: Colors.black45),
                SizedBox(width: 4),
                Text(
                  'Drag photo on canvas to position • Pinch to scale',
                  style: TextStyle(fontSize: 10.5, color: Colors.black45, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPhotoAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color? color,
  }) {
    final effectiveColor = color ?? (isActive ? AppColors.bratGreen : Colors.black87);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? AppColors.bratGreen : effectiveColor),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }


}

// -----------------------------------------------------------------------------
// Editor Snapshot for Undo & Redo System
// -----------------------------------------------------------------------------
class EditorSnapshot {
  final String text;
  final double fontSize;
  final String fontFamily;
  final String fontWeight;
  final TextAlign alignment;
  final String textCase;
  final double letterSpacing;
  final double aspectRatio;
  final int bgIndex;
  final int textIndex;
  final Color? customBgColor;
  final Color? customTextColor;
  final bool isTransparentBg;
  final double blurSigma;
  final bool hasFilmGrain;
  final double grainOpacity;
  final bool isInverted;
  final bool hasVignette;
  final XFile? selectedImage;
  final double photoOpacity;
  final double photoScale;
  final Offset photoOffset;
  final int photoRotation;
  final double customAngleDegrees;
  final bool flipHorizontal;
  final bool flipVertical;
  final BoxFit photoFit;
  final FrameTemplate? activeFrame;
  final String frameCaption;
  final List<TextLayerModel>? textLayers;
  final String? activeTextLayerId;

  EditorSnapshot({
    required this.text,
    required this.fontSize,
    required this.fontFamily,
    required this.fontWeight,
    required this.alignment,
    required this.textCase,
    required this.letterSpacing,
    required this.aspectRatio,
    required this.bgIndex,
    required this.textIndex,
    this.customBgColor,
    this.customTextColor,
    required this.isTransparentBg,
    required this.blurSigma,
    required this.hasFilmGrain,
    required this.grainOpacity,
    required this.isInverted,
    required this.hasVignette,
    this.selectedImage,
    required this.photoOpacity,
    this.photoScale = 1.0,
    this.photoOffset = Offset.zero,
    this.photoRotation = 0,
    this.customAngleDegrees = 0.0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.photoFit = BoxFit.cover,
    this.activeFrame,
    required this.frameCaption,
    this.textLayers,
    this.activeTextLayerId,
  });
}

// -----------------------------------------------------------------------------
// Authentic Film Grain Painter
// -----------------------------------------------------------------------------
class FilmGrainPainter extends CustomPainter {
  final double opacity;
  final int seed;

  FilmGrainPainter({this.opacity = 0.12, this.seed = 42});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.001) return;
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final rand = Random(seed);
    final dotCount = (size.width * size.height * 0.0025).clamp(80, 1400).toInt();

    for (int i = 0; i < dotCount; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      final radius = rand.nextDouble() * 0.75 + 0.35;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FilmGrainPainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.seed != seed;
  }
}
