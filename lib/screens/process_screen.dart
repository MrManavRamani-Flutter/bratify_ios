import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../services/logger_service.dart';
import 'maintenance_screen.dart';

/// Luxury Animated Processing Screen & Overlay.
/// Displays positive, fluid progress feedback for heavy operations
/// (Ultra-HD photo exports, SQLite transactions, canvas rendering).
class ProcessScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final double? progress; // null = indeterminate smooth pulse

  const ProcessScreen({
    super.key,
    this.title = 'Crafting Your Masterpiece...',
    this.subtitle = 'Applying high-resolution typography & aesthetic filters',
    this.progress,
  });

  /// Shows the Process Screen as a non-blocking graceful overlay
  static void show(
    BuildContext context, {
    String title = 'Processing Your Post...',
    String subtitle = 'Optimizing layout and styling details',
  }) {
    AppLogger.logAction('ProcessScreen', 'Showing process overlay', {'title': title});
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => ProcessScreen(title: title, subtitle: subtitle),
    );
  }

  /// Closes the active process overlay safely
  static void hide(BuildContext context) {
    AppLogger.logInfo('ProcessScreen', 'Hiding process overlay');
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Executes an async task with automatic processing UI & zero-crash guarantee.
  /// If the task encounters an unexpected error, logs full diagnostics to AppLogger
  /// and gracefully presents MaintenanceScreen instead of an ugly crash.
  static Future<T?> run<T>({
    required BuildContext context,
    required Future<T> Function() task,
    String title = 'Studio is Working...',
    String subtitle = 'Fine-tuning aesthetic frames and graphics',
    String featureName = 'StudioTask',
  }) async {
    show(context, title: title, subtitle: subtitle);

    try {
      final result = await task();
      if (context.mounted) hide(context);
      return result;
    } catch (e, st) {
      AppLogger.logError(featureName, 'Process task encountered issue', e, st);
      if (context.mounted) {
        hide(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MaintenanceScreen(
              featureName: featureName,
              errorDetails: e.toString(),
            ),
          ),
        );
      }
      return null;
    }
  }

  @override
  State<ProcessScreen> createState() => _ProcessScreenState();
}

class _ProcessScreenState extends State<ProcessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  int _tipIndex = 0;
  Timer? _tipTimer;

  static const List<String> _inspiringTips = [
    '✨ Adding high-resolution sharpness...',
    '🍏 Infusing signature Brat aesthetic...',
    '📐 Balancing typography & margins...',
    '🎨 Blending curated color harmonies...',
    '📸 Ensuring crisp Retina export quality...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _tipTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (mounted) {
        setState(() {
          _tipIndex = (_tipIndex + 1) % _inspiringTips.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xff1E1E24) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xff111827);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xff6B7280);
    final trackColor = isDark ? Colors.white12 : const Color(0xffE5E7EB);

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: dialogBg,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final scale = 1.0 + (math.sin(_pulseController.value * math.pi * 2) * 0.08);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.bratGreen,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.bratGreen.withValues(alpha: 0.45),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'brat',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 22),

              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: primaryTextColor,
                  letterSpacing: -0.3,
                ),
              ),

              if (widget.subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  widget.subtitle!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: secondaryTextColor,
                    height: 1.35,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 5,
                  child: widget.progress != null
                      ? LinearProgressIndicator(
                          value: widget.progress,
                          backgroundColor: trackColor,
                          valueColor: const AlwaysStoppedAnimation(AppColors.bratGreen),
                        )
                      : LinearProgressIndicator(
                          backgroundColor: trackColor,
                          valueColor: const AlwaysStoppedAnimation(AppColors.bratGreen),
                        ),
                ),
              ),

              const SizedBox(height: 14),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _inspiringTips[_tipIndex],
                  key: ValueKey(_tipIndex),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: secondaryTextColor.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
