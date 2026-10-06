import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../services/logger_service.dart';
import '../widgets/studio_reusable_widgets.dart';
import 'main_screen.dart';

/// Positive, Luxury Maintenance / Graceful Fallback Screen.
/// In case of an unexpected crash or uncaught error, prevents ugly crash screens
/// and negative UX. Instead, presents a positive "Studio Upgrading / Continuing Building"
/// experience, while logging comprehensive diagnostic details to AppLogger.
class MaintenanceScreen extends StatelessWidget {
  final String? featureName;
  final String? errorDetails;
  final StackTrace? stackTrace;

  const MaintenanceScreen({
    super.key,
    this.featureName,
    this.errorDetails,
    this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    if (errorDetails != null) {
      AppLogger.logError(
        featureName ?? 'StudioBoundary',
        'Fallback triggered: $errorDetails',
        errorDetails,
        stackTrace,
      );
    }

    final isTab = MediaQuery.sizeOf(context).shortestSide >= 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xff0D0D11),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                Container(
                  width: isTab ? 110 : 88,
                  height: isTab ? 110 : 88,
                  decoration: BoxDecoration(
                    color: AppColors.bratGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bratGreen, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.bratGreen.withValues(alpha: 0.35),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text('✨', style: TextStyle(fontSize: 40)),
                ),

                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.bratGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '⚡ CONTINUOUSLY BUILDING · COMING SOON',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Fine-Tuning Studio Magic',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "We're refining this creative experience to make it even more iconic. Your designs and saved templates are completely safe!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff18181E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      _buildCheckRow('🔒 Your memes & drafts remain safe in your library'),
                      const SizedBox(height: 10),
                      _buildCheckRow('🍏 500 aesthetic templates ready to customize'),
                      const SizedBox(height: 10),
                      _buildCheckRow('🚀 Continuous free updates & performance tuning'),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                IosPillActionButton(
                  label: 'Return to Studio',
                  backgroundColor: AppColors.bratGreen,
                  textColor: Colors.black,
                  height: 50,
                  fontSize: 15,
                  isFullWidth: true,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    AppLogger.logAction('MaintenanceScreen', 'User tapped Return to Studio');
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                      (route) => false,
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckRow(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.bratGreen, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
