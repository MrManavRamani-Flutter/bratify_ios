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
import '../constants/app_strings.dart';
import '../features/frames/frames_catalog_sheet.dart';
import '../features/photo_transform/photo_transform_controls.dart';
import '../features/photo_transform/photo_transform_model.dart';
import '../features/frames/frame_preflight_sheet.dart';
import '../features/quotes/quotes_picker_sheet.dart';
import '../features/studio_effects/studio_effects_model.dart';
import '../features/studio_effects/studio_effects_sheet.dart';
import '../models/frame_model.dart';
import '../models/meme_design_model.dart';
import '../my_app.dart';
import '../services/database_service.dart';
import '../services/logger_service.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_svg_icon.dart';
import '../widgets/frame_canvas_widget.dart';
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

  // Active Frame System (500 Predefined & Customizable Frames across 10 Categories)
  FrameTemplate? _activeFrame;
  String _selectedFrameCategory = 'All (500)';

  // Core canvas state
  String _currentText = "brat";
  double _currentFontSize = 36.0;
  String _currentFontFamily = 'Arial';
  String _currentFontWeight = 'Bold';
  TextAlign _currentAlignment = TextAlign.center;
  String _currentTextCase = 'lowercase'; // Iconic Brat signature
  double _letterSpacing = -0.5;

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

  // 10 Distinct Categories with 50 Templates each (Total 500 Templates)
  static const List<String> _frameCategories = [
    'All (500)',
    '🍏 Brat & Album',
    '📸 Polaroid & Vintage',
    '🎞️ Y2K & Digicam',
    '🎵 Music & Audio',
    '✨ Acid & Rave Neon',
    '🖤 Minimal & Editorial',
    '📐 Collage, Strips & Stamps',
    '💬 Quotes & Viral Memes',
    '🌈 Pastel & Moodboard',
    '⚡ Social Story & Reels',
  ];

  // Curated viral quotes
  static const List<String> _viralQuotes = [
    "brat",
    "365 partygirl",
    "so transparent",
    "everything is romantic",
    "sympathy is a knife",
    "rewind",
    "von dutch",
    "talk talk",
    "i might say something stupid",
    "guess",
    "girl, so confusing",
    "apple",
    "b2b",
    "mean girls",
    "spring breakers",
    "it's brat summer",
    "hot girl bummer",
    "certified lover girl",
    "delusional in the best way",
    "unhinged and thriving",
    "main character energy",
    "too iconic to care",
    "it's giving brat",
    "club classic",
    "i think about it all the time",
    "dialing that number",
    "angels in the club",
    "doing it for the plot",
    "born to party",
    "overthinking everything",
    "brat and boujee",
    "it's okay to cry",
    "always chaotic",
    "living rent free",
    "no thoughts head empty",
  ];

  int _colorTarget = 0; // 0: Background Color, 1: Text Color

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
    _activeFrame = widget.initialFrame;
    if (_activeFrame != null) {
      _frameCaptionController.text = _activeFrame?.caption ?? '';
      _aspectRatio = _activeFrame!.aspectRatio;
      _syncPhotoSlots();
    }
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _currentText = widget.initialText!;
      if (_activeFrame != null) {
        _activeFrame = _activeFrame!.copyWith(caption: widget.initialText!);
        _frameCaptionController.text = widget.initialText!;
      }
    }
    _textController.text = _currentText;

    if (widget.initialImage != null) {
      _selectedImage = widget.initialImage;
      _syncPhotoSlots();
      _selectedTab = 4; // Photo & Filters tab
    } else if (widget.isDedicatedEditScreen) {
      _selectedTab = 1; // Default to Text & Fonts tab in dedicated edit screen
    }

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

  void _selectFrame(FrameTemplate frame) {
    _recordHistory();
    HapticFeedback.lightImpact();
    setState(() {
      _activeFrame = frame;
      _aspectRatio = frame.aspectRatio;
      _frameCaptionController.text = frame.caption;
      _hasFilmGrain = frame.hasFilmGrain;
      _syncPhotoSlots();
    });
  }

  List<FrameTemplate> get _featuredFrames {
    return [
      predefined500Frames[0], // Brat Classic Album
      predefined500Frames[50], // Aesthetic Polaroid 600
      predefined500Frames[100], // Digicam ISO 400
      predefined500Frames[150], // Spotify Music Player
      predefined500Frames[200], // Acid Rave Lime
      predefined500Frames[250], // Minimal Vogue Editorial
      predefined500Frames[300], // Vintage Filmstrip 35mm
      predefined500Frames[350], // Viral Quote Card
      predefined500Frames[400], // Pastel Moodboard
      predefined500Frames[450], // 9:16 Social Story Neon
    ];
  }

  void _openFramePreflight(FrameTemplate frame) {
    HapticFeedback.lightImpact();
    FramePreflightSheet.show(
      context: context,
      frame: frame,
      onProceed: (selectedFrame, photo) {
        _recordHistory();
        setState(() {
          _activeFrame = selectedFrame;
          _frameCaptionController.text = selectedFrame.caption;
          _aspectRatio = selectedFrame.aspectRatio;
          _hasFilmGrain = selectedFrame.hasFilmGrain;
          _syncPhotoSlots();
          if (photo != null) {
            _selectedImage = photo;
            if (_selectedImages.isNotEmpty) {
              _selectedImages[0] = photo;
            }
            _photoScale = 1.0;
            _photoOffset = Offset.zero;
            _photoRotation = 0;
            _customAngleDegrees = 0.0;
            _flipHorizontal = false;
            _flipVertical = false;
            _photoFit = BoxFit.cover;
            _selectedTab = 4; // Photo & Filters tab
          }
        });

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xff18181B),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.bratGreen, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    photo != null
                        ? 'Photo loaded in "${selectedFrame.name}"! Use controls to arrange.'
                        : 'Template "${selectedFrame.name}" applied!',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }

  void _openQuotesPickerSheet() {
    HapticFeedback.lightImpact();
    AppLogger.logAction('GenerateScreen', 'Opening Quotes Picker Sheet');
    QuotesPickerSheet.show(
      context: context,
      currentQuote: _currentText,
      onQuoteSelected: (selectedQuote) {
        _recordHistory();
        setState(() {
          _currentText = selectedQuote;
          _textController.text = selectedQuote;
          if (_activeFrame != null) {
            _activeFrame = _activeFrame!.copyWith(caption: selectedQuote);
            _frameCaptionController.text = selectedQuote;
          }
        });
      },
    );
  }

  void _inspireMeFull() {
    _recordHistory();
    HapticFeedback.mediumImpact();
    final rand = Random();
    final randomFrame = predefined500Frames[rand.nextInt(predefined500Frames.length)];
    final randomQuote = _viralQuotes[rand.nextInt(_viralQuotes.length)];
    setState(() {
      _activeFrame = randomFrame;
      _aspectRatio = randomFrame.aspectRatio;
      _currentText = randomQuote;
      _textController.text = randomQuote;
      _frameCaptionController.text = randomQuote;
      _hasFilmGrain = randomFrame.hasFilmGrain;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        content: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.bratGreen, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Inspired: "${randomFrame.name}" with quote "$randomQuote"!',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shuffleQuote() {
    _recordHistory();
    HapticFeedback.lightImpact();
    final random = Random();
    final newQuote = _viralQuotes[random.nextInt(_viralQuotes.length)];
    setState(() {
      _currentText = newQuote;
      _textController.text = newQuote;
      if (_activeFrame != null) {
        _activeFrame = _activeFrame!.copyWith(caption: newQuote);
        _frameCaptionController.text = newQuote;
      }
    });
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

  Future<void> _pickPhoto({ImageSource source = ImageSource.gallery}) async {
    return _pickPhotoForSlot(0, source: source);
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
    }
  }

  Future<void> _exportToPhotos() async {
    HapticFeedback.mediumImpact();
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
          // Back button to Templates
          IosBounceButton(
            onTap: () {
              HapticFeedback.lightImpact();
              if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
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
                    'Templates',
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
                  _activeFrame != null ? _activeFrame!.name : 'Post Editor',
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
                // Top App Bar: Dedicated Edit Bar vs Main Tab Bar
                if (widget.isDedicatedEditScreen)
                  _buildEditScreenAppBar(context, isTab)
                else
                  CustomRowWidget(
                    centerText: AppStrings.appTitle,
                    isLeft: false,
                    isRightKing: false,
                    isRightSetting: true,
                    isRightMore: true,
                    onNew: _resetToDefault,
                    onReset: _resetToDefault,
                  ),

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
                            // 0. Quick Controls: Undo, Redo, Reset, Mode Badge (When not dedicated edit screen)
                            if (!widget.isDedicatedEditScreen) ...[
                              _buildHistoryControlsBar(isTab),
                              const SizedBox(height: 8),
                              _buildQuickActionHub(isTab),
                              const SizedBox(height: 10),
                            ],

                            // 1. Live Studio Canvas Preview (Either Frame or Classic Text Canvas)
                            Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: maxCanvasHeight,
                                  maxWidth: maxCanvasWidth,
                                ),
                                child: RepaintBoundary(
                                  key: _repaintKey,
                                  child: _activeFrame != null
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
                                          studioEffects: _studioEffects,
                                        )
                                      : _buildClassicCanvas(),
                                ),
                              ),
                            ),

                            // Floating Quick Photo Actions & Arrange Bar under Canvas
                            if (_selectedImage != null || _selectedImages.any((img) => img != null))
                              _buildCanvasPhotoControlsBar(),

                            const SizedBox(height: 12),

                            // 2. Action Bar (Save Library, Photos, Share)
                            _buildExportActionBar(context, isTab),

                            if (!widget.isDedicatedEditScreen) ...[
                              const SizedBox(height: 12),
                              // 2.5 Featured & Trending Frames Showcase (Directly on Home Screen)
                              _buildFeaturedFramesSection(isTab),
                            ],

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
  // Tool Selector Tab Bar (5 Clear, Friendly, Non-Intimidating Tabs)
  // ---------------------------------------------------------------------------
  Widget _buildToolTabBar(bool isTab) {
    final tabs = [
      {'icon': Icons.filter_frames_rounded, 'label': '500 Frames', 'badge': '500'},
      {'icon': Icons.auto_awesome_rounded, 'label': '✨ Studio FX', 'badge': 'HOT'},
      {'icon': Icons.text_fields_rounded, 'label': 'Text & Fonts'},
      {'icon': Icons.palette_outlined, 'label': 'Colors'},
      {'icon': Icons.aspect_ratio_rounded, 'label': 'Canvas Ratio'},
      {'icon': Icons.tune_rounded, 'label': 'Photo & Filters'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (idx) {
          final isSelected = idx == 1 ? false : (_selectedTab == (idx > 1 ? idx - 1 : idx));
          final item = tabs[idx];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                if (idx == 1) {
                  _openStudioEffectsSheet();
                } else {
                  setState(() => _selectedTab = idx > 1 ? idx - 1 : idx);
                }
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
                    if (item.containsKey('badge')) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.bratGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['badge'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
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
        return _build100FramesBrowserPanel(isTab);
      case 1:
        return _buildTextToolPanel(isTab);
      case 2:
        return _buildThemeToolPanel();
      case 3:
        return _buildRatioToolPanel();
      case 4:
        return _buildEffectsToolPanel();
      default:
        return _build100FramesBrowserPanel(isTab);
    }
  }

  // ---------------------------------------------------------------------------
  // TAB 0: 100 Frames Browser & Inline Customizer
  // ---------------------------------------------------------------------------
  Widget _build100FramesBrowserPanel(bool isTab) {
    final filteredFrames = (_selectedFrameCategory == 'All (500)' || _selectedFrameCategory == 'All')
        ? predefined500Frames
        : predefined500Frames.where((f) => f.category == _selectedFrameCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filter Chips & Browse 500 Catalog Button
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _frameCategories.map((cat) {
                    final isCatSelected = _selectedFrameCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _buildChoiceChip(cat, isCatSelected, () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedFrameCategory = cat);
                        AppLogger.logAction('GenerateScreen', 'Filtered frame category', {'category': cat});
                      }),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Browse 500 Frames Catalog Modal Button
            IosBounceButton(
              onTap: () {
                HapticFeedback.lightImpact();
                AppLogger.logAction('GenerateScreen', 'Opening 500 Frames Catalog Sheet');
                FramesCatalogSheet.show(
                  context: context,
                  currentFrame: _activeFrame,
                  onFrameSelected: (frame) {
                    _selectFrame(frame);
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.dashboard_customize_rounded, size: 13, color: AppColors.bratGreen),
                    SizedBox(width: 4),
                    Text(
                      '500 Catalog',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Action Header: Current Frame Info & Change Photo Shortcut
        Row(
          children: [
            Expanded(
              child: Text(
                _activeFrame != null
                    ? '#${_activeFrame!.id} ${_activeFrame!.name} (${filteredFrames.length} in $_selectedFrameCategory)'
                    : '500 Predefined Frames (50 in each of 10 categories)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_selectedImage == null)
              TextButton.icon(
                onPressed: _showPhotoSourceDialog,
                icon: const Icon(Icons.add_photo_alternate, size: 16, color: Colors.black),
                label: const Text(
                  'Set Your Photo',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.bratGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _openImageCropAndAdjustDialog(slotIndex: _activePhotoSlot),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.crop_rounded, size: 14, color: Colors.black87),
                          SizedBox(width: 3),
                          Text('Crop', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: _showPhotoSourceDialog,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.swap_horiz_rounded, size: 14, color: Colors.black87),
                          SizedBox(width: 3),
                          Text('Change', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: _deletePhoto,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                    tooltip: 'Delete Photo',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Horizontal Scrollable Cards of Frames
        SizedBox(
          height: isTab ? 120 : 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: filteredFrames.length,
            itemBuilder: (context, idx) {
              final frame = filteredFrames[idx];
              final isSelected = _activeFrame?.id == frame.id;

              return GestureDetector(
                onTap: () => _selectFrame(frame),
                child: Container(
                  width: isTab ? 95 : 80,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : AppColors.offWhiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.bratGreen : Colors.black12,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Mini Frame Mockup
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: frame.frameBgColor,
                            borderRadius: BorderRadius.circular(
                              (frame.borderRadius * 0.4).clamp(2.0, 10.0),
                            ),
                            border: frame.borderWidth > 0
                                ? Border.all(color: frame.borderColor, width: 1.5)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Icon(Icons.image, size: 15, color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${frame.id} ${frame.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Inline Modify Frame Controls (If frame is active)
        if (_activeFrame != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.offWhiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune, size: 16, color: Colors.black87),
                    const SizedBox(width: 6),
                    const Text('Customize Frame', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _recordHistory();
                        HapticFeedback.lightImpact();
                        setState(() => _activeFrame = null);
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('Clear Frame (Text Studio)', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Caption Edit
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _frameCaptionController,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Frame Caption...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _openColorPicker(context, isBg: false),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _activeFrame!.captionColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Text & Caption Position Selector
                Row(
                  children: [
                    const SizedBox(
                      width: 50,
                      child: Text('Position', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildPositionPill('Top', Alignment.topCenter),
                            _buildPositionPill('Top-Left', Alignment.topLeft),
                            _buildPositionPill('Top-Right', Alignment.topRight),
                            _buildPositionPill('Center', Alignment.center),
                            _buildPositionPill('Bottom', Alignment.bottomCenter),
                            _buildPositionPill('Bottom-Left', Alignment.bottomLeft),
                            _buildPositionPill('Bottom-Right', Alignment.bottomRight),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Caption Size & Frame BG Color
                Row(
                  children: [
                    const SizedBox(
                      width: 50,
                      child: Text('Size', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: Slider(
                        value: _activeFrame!.captionSize.clamp(10.0, 36.0),
                        min: 10.0,
                        max: 36.0,
                        activeColor: Colors.black,
                        inactiveColor: Colors.black12,
                        onChanged: (v) {
                          setState(() {
                            _activeFrame = _activeFrame!.copyWith(captionSize: v);
                          });
                        },
                      ),
                    ),
                    Text('${_activeFrame!.captionSize.toInt()}pt', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: 'Frame Background Color',
                      child: GestureDetector(
                        onTap: () => _openColorPicker(context, isBg: true),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _activeFrame!.frameBgColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Border Width & Corners Sliders
                Row(
                  children: [
                    const SizedBox(
                      width: 50,
                      child: Text('Border', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: Slider(
                        value: _activeFrame!.borderWidth.clamp(0.0, 20.0),
                        min: 0.0,
                        max: 20.0,
                        activeColor: Colors.black,
                        inactiveColor: Colors.black12,
                        onChanged: (v) {
                          setState(() {
                            _activeFrame = _activeFrame!.copyWith(borderWidth: v);
                          });
                        },
                      ),
                    ),
                    Text('${_activeFrame!.borderWidth.toInt()}px', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _openColorPicker(context, isBg: false, isFrameBorder: true),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _activeFrame!.borderColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 50,
                      child: Text('Corners', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: Slider(
                        value: _activeFrame!.borderRadius.clamp(0.0, 40.0),
                        min: 0.0,
                        max: 40.0,
                        activeColor: Colors.black,
                        inactiveColor: Colors.black12,
                        onChanged: (v) {
                          setState(() {
                            _activeFrame = _activeFrame!.copyWith(borderRadius: v);
                          });
                        },
                      ),
                    ),
                    Text('${_activeFrame!.borderRadius.toInt()}px', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPositionPill(String label, Alignment alignment) {
    final isSelected = _activeFrame?.captionAlignment == alignment;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () {
          _recordHistory();
          HapticFeedback.selectionClick();
          setState(() {
            _activeFrame = _activeFrame!.copyWith(captionAlignment: alignment);
          });
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.black12,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Text & Google Fonts (Deep Customization + 30+ Google Fonts)
  // ---------------------------------------------------------------------------
  Widget _buildTextToolPanel(bool isTab) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text Input & Inspire Me Button
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _textController,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Type your text...',
                  filled: true,
                  fillColor: AppColors.offWhiteColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Quotes & Captions Library Button
            IosBounceButton(
              onTap: () {
                HapticFeedback.lightImpact();
                AppLogger.logAction('GenerateScreen', 'Opening Quotes Picker Sheet');
                QuotesPickerSheet.show(
                  context: context,
                  currentQuote: _currentText,
                  onQuoteSelected: (selectedQuote) {
                    _recordHistory();
                    setState(() {
                      _currentText = selectedQuote;
                      _textController.text = selectedQuote;
                      if (_activeFrame != null) {
                        _activeFrame = _activeFrame!.copyWith(caption: selectedQuote);
                        _frameCaptionController.text = selectedQuote;
                      }
                    });
                    AppLogger.logAction('GenerateScreen', 'Quote applied from picker', {'quote': selectedQuote});
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('💬', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Text(
                      'Quotes',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Inspire Me Button
            IosBounceButton(
              onTap: _shuffleQuote,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bratGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('🎲', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Text(
                      'Inspire',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Google Fonts Browser Bar
        Row(
          children: [
            const Text(
              'Fonts',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const Spacer(),
            // All 30+ Google Fonts Button
            GestureDetector(
              onTap: () => _openFontPickerSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.search, size: 13, color: AppColors.bratGreen),
                    SizedBox(width: 4),
                    Text(
                      'All 30+ Google Fonts',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Quick Font Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              'Arial',
              'Outfit',
              'Roboto',
              'Montserrat',
              'Bebas Neue',
              'Playfair Display',
              'Pacifico',
              'Cinzel',
              'Dancing Script',
              'Space Grotesk',
            ].map((font) {
              final isSelected = _currentFontFamily == font;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _buildChoiceChip(
                  font == 'Arial' ? 'Brat Sans (Arial)' : font,
                  isSelected,
                  () {
                    _recordHistory();
                    HapticFeedback.selectionClick();
                    setState(() {
                      _currentFontFamily = font;
                      if (_activeFrame != null) {
                        _activeFrame = _activeFrame!.copyWith(captionFont: font);
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Sliders: Size & Spacing
        Row(
          children: [
            const SizedBox(
              width: 60,
              child: Text('Size', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: Slider(
                value: _currentFontSize.clamp(12.0, 80.0),
                min: 12.0,
                max: 80.0,
                activeColor: Colors.black,
                inactiveColor: Colors.black12,
                onChangeStart: (_) => _recordHistory(),
                onChanged: (v) => setState(() => _currentFontSize = v),
              ),
            ),
            Text('${_currentFontSize.toInt()} pt', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            const SizedBox(
              width: 60,
              child: Text('Spacing', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: Slider(
                value: _letterSpacing.clamp(-2.0, 8.0),
                min: -2.0,
                max: 8.0,
                activeColor: Colors.black,
                inactiveColor: Colors.black12,
                onChangeStart: (_) => _recordHistory(),
                onChanged: (v) => setState(() => _letterSpacing = v),
              ),
            ),
            Text(_letterSpacing.toStringAsFixed(1), style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),

        // Case, Weight & Alignment
        Row(
          children: [
            _buildChoiceChip('lowercase', _currentTextCase == 'lowercase', () {
              _recordHistory();
              setState(() => _currentTextCase = 'lowercase');
            }),
            const SizedBox(width: 6),
            _buildChoiceChip('UPPER', _currentTextCase == 'UPPERCASE', () {
              _recordHistory();
              setState(() => _currentTextCase = 'UPPERCASE');
            }),
            const SizedBox(width: 6),
            _buildChoiceChip('Normal', _currentTextCase == 'Normal', () {
              _recordHistory();
              setState(() => _currentTextCase = 'Normal');
            }),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.format_align_left, size: 20),
              color: _currentAlignment == TextAlign.left ? Colors.black : Colors.grey,
              onPressed: () {
                _recordHistory();
                setState(() => _currentAlignment = TextAlign.left);
              },
            ),
            IconButton(
              icon: const Icon(Icons.format_align_center, size: 20),
              color: _currentAlignment == TextAlign.center ? Colors.black : Colors.grey,
              onPressed: () {
                _recordHistory();
                setState(() => _currentAlignment = TextAlign.center);
              },
            ),
            IconButton(
              icon: const Icon(Icons.format_align_right, size: 20),
              color: _currentAlignment == TextAlign.right ? Colors.black : Colors.grey,
              onPressed: () {
                _recordHistory();
                setState(() => _currentAlignment = TextAlign.right);
              },
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: Dynamic Colors (Background & Text Color Control)
  // ---------------------------------------------------------------------------
  Widget _buildThemeToolPanel() {
    final colorsList = [
      AppColors.bratGreen,
      Colors.white,
      Colors.black,
      const Color(0xff121212),
      const Color(0xffFF599C),
      const Color(0xff00E5FF),
      const Color(0xffE0FF00),
      const Color(0xffFF6B35),
      const Color(0xff8B5CF6),
      const Color(0xff2563EB),
      const Color(0xffE50000),
      const Color(0xffFDF6E2),
      const Color(0xffD6D9E0),
    ];

    final currentColor = _colorTarget == 0 ? _getEffectiveBgColor() : _getEffectiveTextColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Target Selector: Background vs Text
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _colorTarget = 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _colorTarget == 0 ? Colors.black : AppColors.offWhiteColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.format_paint_outlined, size: 16, color: _colorTarget == 0 ? AppColors.bratGreen : Colors.black87),
                      const SizedBox(width: 6),
                      Text(
                        'Background Color',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _colorTarget == 0 ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _colorTarget = 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _colorTarget == 1 ? Colors.black : AppColors.offWhiteColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.title_rounded, size: 16, color: _colorTarget == 1 ? AppColors.bratGreen : Colors.black87),
                      const SizedBox(width: 6),
                      Text(
                        'Text Color',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _colorTarget == 1 ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Color Swatches Row + Rainbow Custom Color Picker
        Row(
          children: [
            // Rainbow Color Picker Button
            GestureDetector(
              onTap: () => _openColorPicker(context, isBg: _colorTarget == 0),
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
                    final isSelected = currentColor.toARGB32() == color.toARGB32();
                    return GestureDetector(
                      onTap: () {
                        _recordHistory();
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (_colorTarget == 0) {
                            _customBgColor = color;
                            _isTransparentBg = false;
                            if (_activeFrame != null) {
                              _activeFrame = _activeFrame!.copyWith(frameBgColor: color);
                            }
                          } else {
                            _customTextColor = color;
                            if (_activeFrame != null) {
                              _activeFrame = _activeFrame!.copyWith(captionColor: color);
                            }
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
        const SizedBox(height: 12),

        // Action Buttons: Invert Colors & Transparent Sticker Mode
        Row(
          children: [
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
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _isInverted ? Colors.black : Colors.white,
                  foregroundColor: _isInverted ? AppColors.bratGreen : Colors.black87,
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
                  setState(() => _isTransparentBg = !_isTransparentBg);
                },
                icon: const Icon(Icons.layers_clear_outlined, size: 16),
                label: Text(
                  _isTransparentBg ? 'Sticker: ON' : 'Transparent PNG',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _isTransparentBg ? Colors.black : Colors.white,
                  foregroundColor: _isTransparentBg ? AppColors.bratGreen : Colors.black87,
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
  // TAB 3: Canvas Ratio (Presets + Custom Aspect Ratio Slider)
  // ---------------------------------------------------------------------------
  Widget _buildRatioToolPanel() {
    final ratios = [
      {'label': '1:1 Square', 'ratio': 1.0, 'sub': 'Instagram / DP'},
      {'label': '9:16 Story', 'ratio': 9 / 16, 'sub': 'Reels / TikTok'},
      {'label': '4:5 Post', 'ratio': 4 / 5, 'sub': 'Feed Portrait'},
      {'label': '16:9 Wide', 'ratio': 16 / 9, 'sub': 'X / Landscape'},
      {'label': '3:4 Photo', 'ratio': 3 / 4, 'sub': 'Classic Print'},
      {'label': '4:3 Screen', 'ratio': 4 / 3, 'sub': 'Retro Display'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preset Social Ratios',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),

        // Grid of 6 Presets
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: ratios.length,
          itemBuilder: (context, idx) {
            final r = ratios[idx];
            final ratioVal = r['ratio'] as double;
            final isSelected = (_aspectRatio - ratioVal).abs() < 0.02;

            return GestureDetector(
              onTap: () {
                _recordHistory();
                HapticFeedback.selectionClick();
                setState(() {
                  _aspectRatio = ratioVal;
                  if (_activeFrame != null) {
                    _activeFrame = _activeFrame!.copyWith(aspectRatio: ratioVal);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : AppColors.offWhiteColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.bratGreen : Colors.black12,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      r['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.bratGreen : Colors.black87,
                      ),
                    ),
                    Text(
                      r['sub'] as String,
                      style: TextStyle(
                        fontSize: 8,
                        color: isSelected ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 14),

        // Custom Ratio Slider
        Row(
          children: [
            const Text(
              'Custom Free Ratio',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.bratGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Ratio: ${_aspectRatio.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Tall (1:2)', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Expanded(
              child: Slider(
                value: _aspectRatio.clamp(0.50, 2.00),
                min: 0.50,
                max: 2.00,
                activeColor: Colors.black,
                inactiveColor: Colors.black12,
                onChangeStart: (_) => _recordHistory(),
                onChanged: (v) {
                  setState(() {
                    _aspectRatio = v;
                    if (_activeFrame != null) {
                      _activeFrame = _activeFrame!.copyWith(aspectRatio: v);
                    }
                  });
                },
              ),
            ),
            const Text('Wide (2:1)', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4: Effects & Photo Remixer
  // ---------------------------------------------------------------------------
  Widget _buildEffectsToolPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Real-Time Blur Slider
        Row(
          children: [
            const SizedBox(
              width: 70,
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
        // Film Grain Slider
        Row(
          children: [
            const SizedBox(
              width: 70,
              child: Text('Film Grain', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
        const SizedBox(height: 6),

        // Vignette Toggle
        Row(
          children: [
            _buildChoiceChip(
              _hasVignette ? 'Vignette: ON' : 'Vignette: OFF',
              _hasVignette,
              () {
                _recordHistory();
                HapticFeedback.selectionClick();
                setState(() => _hasVignette = !_hasVignette);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Dedicated Photo Management Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.offWhiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.photo_library_outlined, size: 18, color: Colors.black87),
                  const SizedBox(width: 6),
                  const Text(
                    'Photo in Canvas / Frame',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  if (_selectedImage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.bratGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('PHOTO ACTIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (_selectedImage != null || _selectedImages.any((img) => img != null)) ...[
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ((_activePhotoSlot < _selectedImages.length ? _selectedImages[_activePhotoSlot] : null) ?? _selectedImage) != null
                          ? Image.file(
                              File(((_activePhotoSlot < _selectedImages.length ? _selectedImages[_activePhotoSlot] : null) ?? _selectedImage)!.path),
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            )
                          : Container(width: 44, height: 44, color: Colors.black12, child: const Icon(Icons.add_a_photo_outlined, size: 20)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _openImageCropAndAdjustDialog(slotIndex: _activePhotoSlot),
                              icon: const Icon(Icons.crop_rotate_rounded, size: 14),
                              label: const Text('Crop & Adjust', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showPhotoSourceDialog(slotIndex: _activePhotoSlot),
                              icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                              label: const Text('Change', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () => _deletePhotoSlot(_activePhotoSlot),
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            tooltip: 'Delete Photo',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 12),
                PhotoTransformControls(
                  state: PhotoTransformState(
                    rotationQuarter: _photoRotation,
                    customAngleDegrees: _customAngleDegrees,
                    flipHorizontal: _flipHorizontal,
                    flipVertical: _flipVertical,
                    scale: _photoScale,
                    offset: _photoOffset,
                  ),
                  onChanged: (newState) {
                    _recordHistory();
                    setState(() {
                      _photoRotation = newState.rotationQuarter;
                      _customAngleDegrees = newState.customAngleDegrees;
                      _flipHorizontal = newState.flipHorizontal;
                      _flipVertical = newState.flipVertical;
                      _photoScale = newState.scale;
                      _photoOffset = newState.offset;
                    });
                  },
                  onReset: () {
                    _recordHistory();
                    setState(() {
                      _photoRotation = 0;
                      _customAngleDegrees = 0.0;
                      _flipHorizontal = false;
                      _flipVertical = false;
                      _photoScale = 1.0;
                      _photoOffset = Offset.zero;
                    });
                  },
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickPhoto(source: ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, size: 16),
                        label: const Text('Camera', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickPhoto(source: ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined, size: 16),
                        label: const Text('Photo Library', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
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
                                setState(() {
                                  _currentFontFamily = font;
                                  if (_activeFrame != null) {
                                    _activeFrame = _activeFrame!.copyWith(captionFont: font);
                                  }
                                });
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

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : AppColors.offWhiteColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.black12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionHub(bool isTab) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // 1. Add Photo
          _buildQuickActionPill(
            icon: Icons.add_a_photo_rounded,
            label: _selectedImage == null ? 'Add Photo' : 'Change Photo',
            isHighlighted: _selectedImage == null,
            onTap: _showPhotoSourceDialog,
          ),
          const SizedBox(width: 8),

          // 2. 500 Frames Catalog
          _buildQuickActionPill(
            icon: Icons.dashboard_customize_rounded,
            label: '500 Frames',
            badge: '500',
            onTap: () {
              FramesCatalogSheet.show(
                context: context,
                currentFrame: _activeFrame,
                onFrameSelected: _selectFrame,
              );
            },
          ),
          const SizedBox(width: 8),

          // 3. Inspire Me
          _buildQuickActionPill(
            icon: Icons.casino_rounded,
            label: 'Inspire Me',
            badge: '🎲',
            onTap: _inspireMeFull,
          ),
          const SizedBox(width: 8),

          // 4. Viral Quotes
          _buildQuickActionPill(
            icon: Icons.format_quote_rounded,
            label: 'Viral Quotes',
            onTap: _openQuotesPickerSheet,
          ),
          const SizedBox(width: 8),

          // 5. Studio Effects
          _buildQuickActionPill(
            icon: Icons.auto_awesome_rounded,
            label: 'Brat FX',
            onTap: _openStudioEffectsSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? badge,
    bool isHighlighted = false,
  }) {
    return IosBounceButton(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.bratGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlighted ? AppColors.bratGreen : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlighted
                  ? AppColors.bratGreen.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isHighlighted ? Colors.black : Colors.black87,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isHighlighted ? Colors.black : Colors.black87,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isHighlighted ? Colors.black : AppColors.bratGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: isHighlighted ? AppColors.bratGreen : Colors.black,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedFramesSection(bool isTab) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bratGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'HOT',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRENDING AESTHETIC FRAMES',
                      style: GoogleFonts.outfit(
                        fontSize: isTab ? 15 : 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Tap any frame to customize with your photo',
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IosBounceButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  FramesCatalogSheet.show(
                    context: context,
                    currentFrame: _activeFrame,
                    onFrameSelected: _selectFrame,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'All 500',
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.bratGreen,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 8, color: AppColors.bratGreen),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Horizontal Featured Frames Carousel
          SizedBox(
            height: isTab ? 145 : 125,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _featuredFrames.length,
              itemBuilder: (context, index) {
                final frame = _featuredFrames[index];
                final isSelected = _activeFrame?.id == frame.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 9),
                  child: IosBounceButton(
                    onTap: () => _openFramePreflight(frame),
                    child: Container(
                      width: isTab ? 115 : 98,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.bratGreen.withValues(alpha: 0.15)
                            : const Color(0xffF7F7F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.bratGreen : Colors.black.withValues(alpha: 0.08),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Miniature Preview
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: frame.frameBgColor,
                                borderRadius: BorderRadius.circular(
                                  (frame.borderRadius * 0.35).clamp(3.0, 8.0),
                                ),
                                border: frame.borderWidth > 0
                                    ? Border.all(
                                        color: frame.borderColor,
                                        width: (frame.borderWidth * 0.4).clamp(1.0, 2.5),
                                      )
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 18,
                                      color: Colors.black.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    left: 2,
                                    right: 2,
                                    child: Text(
                                      frame.caption.isNotEmpty ? frame.caption : 'brat',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: frame.captionColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Frame Title
                          Text(
                            frame.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),

                          // Category & Ratio
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                frame.category.split(' ').first,
                                style: const TextStyle(fontSize: 9),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  (frame.aspectRatio - 1.0).abs() < 0.1
                                      ? '1:1'
                                      : (frame.aspectRatio < 1.0 ? '9:16' : '4:5'),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
        Row(
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

  Widget _buildHistoryControlsBar(bool isTab) {
    return Row(
      children: [
        // Undo Button
        IosBounceButton(
          onTap: _undoStack.isNotEmpty ? _undo : null,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.undo_rounded,
              size: 19,
              color: _undoStack.isNotEmpty ? Colors.black : Colors.black26,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Redo Button
        IosBounceButton(
          onTap: _redoStack.isNotEmpty ? _redo : null,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.redo_rounded,
              size: 19,
              color: _redoStack.isNotEmpty ? Colors.black : Colors.black26,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Reset Button
        IosBounceButton(
          onTap: _resetToDefault,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.restart_alt_rounded, size: 16, color: Colors.redAccent),
                SizedBox(width: 4),
                Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Mode Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _activeFrame != null ? Icons.filter_frames_outlined : Icons.edit_note_outlined,
                size: 14,
                color: Colors.black87,
              ),
              const SizedBox(width: 4),
              Text(
                _activeFrame != null ? 'Frame Mode' : 'Text Studio',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
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
