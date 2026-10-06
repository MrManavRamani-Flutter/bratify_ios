import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_colors.dart';
import '../../models/frame_model.dart';
import '../../services/logger_service.dart';
import '../../widgets/app_svg_icon.dart';

/// Pre-flight Information & Photo Selection Sheet for Templates/Frames.
/// Displays what the template needs (Photo, Caption, Effects) and guides
/// the user through picking a photo before opening the canvas in arrange mode.
class FramePreflightSheet extends StatefulWidget {
  final FrameTemplate frame;
  final Function(FrameTemplate frame, XFile? photo) onProceed;

  const FramePreflightSheet({
    super.key,
    required this.frame,
    required this.onProceed,
  });

  static Future<void> show({
    required BuildContext context,
    required FrameTemplate frame,
    required Function(FrameTemplate frame, XFile? photo) onProceed,
  }) {
    AppLogger.logAction(
      'FramePreflight',
      'Opened Preflight Sheet for frame: ${frame.name}',
      {'category': frame.category, 'id': frame.id},
    );

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FramePreflightSheet(
        frame: frame,
        onProceed: onProceed,
      ),
    );
  }

  @override
  State<FramePreflightSheet> createState() => _FramePreflightSheetState();
}

class _FramePreflightSheetState extends State<FramePreflightSheet> {
  bool _isPicking = false;

  String _formatRatio(double ratio) {
    if ((ratio - 1.0).abs() < 0.05) return '1:1 Square (Feed)';
    if ((ratio - 9 / 16).abs() < 0.05) return '9:16 Vertical (Story/Reels)';
    if ((ratio - 4 / 5).abs() < 0.05) return '4:5 Portrait (Instagram)';
    if ((ratio - 16 / 9).abs() < 0.05) return '16:9 Banner';
    return '${ratio.toStringAsFixed(2)} Ratio';
  }

  Future<void> _handlePickPhoto(ImageSource source) async {
    HapticFeedback.mediumImpact();
    setState(() => _isPicking = true);

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 95,
      );

      if (!mounted) return;
      setState(() => _isPicking = false);

      if (image != null) {
        AppLogger.logAction('FramePreflight', 'Photo selected from $source', {'path': image.path});
        Navigator.pop(context); // Close sheet
        widget.onProceed(widget.frame, image);
      }
    } catch (e, stack) {
      if (mounted) setState(() => _isPicking = false);
      AppLogger.logError('FramePreflight', 'Failed to pick photo', e, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showPhotoSourcePicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose Photo Source',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select a photo to place inside "${widget.frame.name}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    // Camera
                    Expanded(
                      child: IosBounceButton(
                        onTap: () {
                          Navigator.pop(ctx);
                          _handlePickPhoto(ImageSource.camera);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xffF2F2F7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 26, color: Colors.black87),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Camera',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Take new photo',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Gallery / Photo Library
                    Expanded(
                      child: IosBounceButton(
                        onTap: () {
                          Navigator.pop(ctx);
                          _handlePickPhoto(ImageSource.gallery);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.bratGreen.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.bratGreen, width: 1.5),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: AppColors.bratGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.photo_library_rounded, size: 26, color: Colors.black),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Photo Library',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Select from device',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: Colors.black54,
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleContinueWithoutPhoto() {
    HapticFeedback.lightImpact();
    AppLogger.logAction('FramePreflight', 'Continued without photo', {'frame': widget.frame.name});
    Navigator.pop(context);
    widget.onProceed(widget.frame, null);
  }

  @override
  Widget build(BuildContext context) {
    final isTab = MediaQuery.sizeOf(context).shortestSide >= 600;
    final frame = widget.frame;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xff121217),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Top Header: Badge + Title + Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bratGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.bratGreen, width: 1),
                    ),
                    child: Text(
                      frame.category.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.bratGreen,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Title & Aspect Ratio Tag
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      frame.name,
                      style: GoogleFonts.outfit(
                        fontSize: isTab ? 24 : 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatRatio(frame.aspectRatio),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Scrollable Content: Preview + Requirements
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Visual Preview of the Frame
                    Center(
                      child: Container(
                        height: 180,
                        width: 220,
                        decoration: BoxDecoration(
                          color: frame.frameBgColor,
                          borderRadius: BorderRadius.circular(frame.borderRadius.clamp(4.0, 20.0)),
                          border: frame.borderWidth > 0
                              ? Border.all(
                                  color: frame.borderColor,
                                  width: frame.borderWidth.clamp(1.0, 8.0),
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            (frame.borderRadius - frame.borderWidth).clamp(2.0, 18.0),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Inner sample photo placeholder
                              Container(
                                color: Colors.black.withValues(alpha: 0.35),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo_rounded,
                                        size: 22,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Your Photo Placed Here',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Sample Frame Caption
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Text(
                                  frame.caption.isNotEmpty ? frame.caption : 'brat',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: frame.captionFont == 'Brat Sans' ? 'Arial' : frame.captionFont,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: frame.captionColor,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // "What You Need & What You'll Create" Header
                    Row(
                      children: [
                        const Icon(Icons.checklist_rounded, size: 18, color: AppColors.bratGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'TEMPLATE WORKFLOW & REQUIREMENTS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.bratGreen,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Step 1: 1 Photo
                    _buildRequirementRow(
                      number: '1',
                      icon: Icons.photo_camera_rounded,
                      title: '${widget.frame.maxPhotos} Photo${widget.frame.maxPhotos > 1 ? "s" : ""} Required',
                      description: widget.frame.maxPhotos > 1
                          ? 'This template supports ${widget.frame.maxPhotos} photos. Import your first shot now and arrange slots on canvas.'
                          : 'Take a photo or import from your camera roll to place inside this frame.',
                      highlight: true,
                    ),

                    const SizedBox(height: 8),

                    // Step 2: Arrange & Transform
                    _buildRequirementRow(
                      number: '2',
                      icon: Icons.crop_rotate_rounded,
                      title: 'Arrange & Transform Freedom',
                      description: 'Pinch to zoom, drag to position, rotate 90°, mirror flip, or crop fit.',
                    ),

                    const SizedBox(height: 8),

                    // Step 3: Text & Typography
                    _buildRequirementRow(
                      number: '3',
                      icon: Icons.title_rounded,
                      title: 'Customizable Caption & Google Fonts',
                      description: 'Customize signature text with 30+ Google fonts, case, size & colors.',
                    ),

                    const SizedBox(height: 8),

                    // Step 4: Authentic Retro Effects
                    _buildRequirementRow(
                      number: '4',
                      icon: Icons.auto_awesome_rounded,
                      title: 'Authentic Brat FX & Film Grain',
                      description: 'Add 35mm film grain, vintage low-res blur, and retro vignette.',
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Primary CTA: "Select Photo & Start"
                  IosPillActionButton(
                    label: _isPicking ? 'Opening...' : 'Select Photo & Start ➔',
                    iconData: Icons.add_photo_alternate_rounded,
                    backgroundColor: AppColors.bratGreen,
                    textColor: Colors.black,
                    height: 52,
                    fontSize: 16,
                    isFullWidth: true,
                    onTap: _isPicking ? null : _showPhotoSourcePicker,
                  ),

                  const SizedBox(height: 8),

                  // Secondary CTA: Continue without photo (Solid/Color background)
                  TextButton(
                    onPressed: _handleContinueWithoutPhoto,
                    child: Text(
                      'Use Frame with Color Background (No Photo)',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementRow({
    required String number,
    required IconData icon,
    required String title,
    required String description,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.bratGreen.withValues(alpha: 0.12)
            : const Color(0xff1C1C24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? AppColors.bratGreen.withValues(alpha: 0.4)
              : Colors.white10,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: highlight ? AppColors.bratGreen : Colors.white12,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 15,
              color: highlight ? Colors.black : Colors.white70,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: highlight ? Colors.white : Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    color: Colors.white54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
