import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../features/photo_transform/photo_transform_model.dart';
import '../widgets/app_svg_icon.dart';

/// Dedicated Full-Screen Image Crop & Adjustment Studio
/// Allows free pan, pinch-zoom, 90° rotation, mirror flips,
/// and aspect ratio guides before applying to the meme frame.
class ImageCropScreen extends StatefulWidget {
  final XFile imageFile;
  final PhotoTransformState initialTransform;
  final double initialAspectRatio;
  final String title;

  const ImageCropScreen({
    super.key,
    required this.imageFile,
    this.initialTransform = const PhotoTransformState(),
    this.initialAspectRatio = 1.0,
    this.title = 'Crop & Adjust Photo',
  });

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  late int _rotationQuarter;
  late double _customAngleDegrees;
  late bool _flipHorizontal;
  late bool _flipVertical;
  late double _scale;
  late Offset _offset;
  late double _aspectRatio;

  // Track initial gesture values
  double _baseScale = 1.0;
  Offset _baseOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _rotationQuarter = widget.initialTransform.rotationQuarter;
    _customAngleDegrees = widget.initialTransform.customAngleDegrees;
    _flipHorizontal = widget.initialTransform.flipHorizontal;
    _flipVertical = widget.initialTransform.flipVertical;
    _scale = widget.initialTransform.scale;
    _offset = widget.initialTransform.offset;
    _aspectRatio = widget.initialAspectRatio;
  }

  void _rotate90() {
    HapticFeedback.lightImpact();
    setState(() {
      _rotationQuarter = (_rotationQuarter + 1) % 4;
    });
  }

  void _toggleFlipH() {
    HapticFeedback.lightImpact();
    setState(() {
      _flipHorizontal = !_flipHorizontal;
    });
  }

  void _toggleFlipV() {
    HapticFeedback.lightImpact();
    setState(() {
      _flipVertical = !_flipVertical;
    });
  }

  void _resetTransform() {
    HapticFeedback.mediumImpact();
    setState(() {
      _rotationQuarter = 0;
      _customAngleDegrees = 0.0;
      _flipHorizontal = false;
      _flipVertical = false;
      _scale = 1.0;
      _offset = Offset.zero;
    });
  }

  void _applyAndDone() {
    HapticFeedback.mediumImpact();
    final result = PhotoTransformState(
      rotationQuarter: _rotationQuarter,
      customAngleDegrees: _customAngleDegrees,
      flipHorizontal: _flipHorizontal,
      flipVertical: _flipVertical,
      scale: _scale,
      offset: _offset,
    );
    Navigator.pop(context, {
      'transform': result,
      'aspectRatio': _aspectRatio,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xff121217),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xff121217),
        body: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    // Cancel
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Pinch to zoom • Drag to position',
                            style: GoogleFonts.outfit(
                              color: Colors.white38,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Done Button
                    IosBounceButton(
                      onTap: _applyAndDone,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.bratGreen,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.bratGreen.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_rounded, color: Colors.black, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Done',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Interactive Crop Preview Workspace
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _aspectRatio,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.bratGreen, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Interactive gesture area
                            GestureDetector(
                              onScaleStart: (details) {
                                _baseScale = _scale;
                                _baseOffset = _offset;
                              },
                              onScaleUpdate: (details) {
                                setState(() {
                                  _scale = (_baseScale * details.scale).clamp(0.5, 4.0);
                                  _offset = _baseOffset + details.focalPointDelta;
                                });
                              },
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..translateByDouble(_offset.dx, _offset.dy, 0.0, 1.0)
                                  ..rotateZ(((_rotationQuarter * 90.0) + _customAngleDegrees) * (3.141592653589793 / 180.0))
                                  ..scaleByDouble(
                                    (_flipHorizontal ? -1.0 : 1.0) * _scale,
                                    (_flipVertical ? -1.0 : 1.0) * _scale,
                                    1.0,
                                    1.0,
                                  ),
                                child: Image.file(
                                  File(widget.imageFile.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),

                            // Grid Overlay Guide
                            IgnorePointer(
                              child: CustomPaint(
                                painter: _CropGridPainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Aspect Ratio Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildRatioChip('1:1 Square', 1.0),
                      _buildRatioChip('4:5 Portrait', 4 / 5),
                      _buildRatioChip('9:16 Story', 9 / 16),
                      _buildRatioChip('16:9 Banner', 16 / 9),
                      _buildRatioChip('3:4 Classic', 3 / 4),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Bottom Action Controls Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xff18181E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Rotate 90°
                    _buildToolButton(
                      icon: Icons.rotate_90_degrees_cw_rounded,
                      label: 'Rotate 90°',
                      onTap: _rotate90,
                    ),
                    // Flip H
                    _buildToolButton(
                      icon: Icons.flip_rounded,
                      label: 'Mirror X',
                      isActive: _flipHorizontal,
                      onTap: _toggleFlipH,
                    ),
                    // Flip V
                    _buildToolButton(
                      icon: Icons.swap_vert_rounded,
                      label: 'Mirror Y',
                      isActive: _flipVertical,
                      onTap: _toggleFlipV,
                    ),
                    // Reset
                    _buildToolButton(
                      icon: Icons.refresh_rounded,
                      label: 'Reset',
                      onTap: _resetTransform,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatioChip(String label, double ratio) {
    final isSelected = (_aspectRatio - ratio).abs() < 0.03;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _aspectRatio = ratio);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.bratGreen : Colors.white12,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.bratGreen : Colors.white24,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.black : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return IosBounceButton(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? AppColors.bratGreen : Colors.white10,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.bratGreen : Colors.white24,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isActive ? AppColors.bratGreen : Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CropGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.0;

    // 3x3 Rule of Thirds grid lines
    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
