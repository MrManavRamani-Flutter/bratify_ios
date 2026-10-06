import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../constants/app_colors.dart';
import '../../my_app.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/app_svg_icon.dart';
import 'faqs_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Future<void> appRating() async {
    try {
      final uri = Uri.parse(
        'https://apps.apple.com/app/id${AppConfig.appRateId}?action=write-review',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    if (mounted) {
      await rateMyApp.showRateDialog(context);
    }
  }

  void _showPrivacyPolicyModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.bratGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy & Data Safety',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '100% On-Device • Zero Data Collection',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildPrivacyPoint(
                icon: Icons.offline_bolt_rounded,
                title: '100% Local Image Compositing',
                desc:
                    'All meme rendering, 500+ frame styling, filters, and fonts execute locally on your device using Flutter Canvas.',
              ),
              const SizedBox(height: 14),
              _buildPrivacyPoint(
                icon: Icons.person_off_rounded,
                title: 'No Accounts & No Tracking',
                desc:
                    'Bratify has no advertising SDKs, tracking cookies, or analytics identifiers. We collect zero personal information.',
              ),
              const SizedBox(height: 14),
              _buildPrivacyPoint(
                icon: Icons.lock_outline_rounded,
                title: 'Private Photo Access',
                desc:
                    'Photos picked from Camera or Photo Library remain in local device memory and are never uploaded to any cloud or server.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Understood',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPoint({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
        body: SafeArea(
          child: Stack(
            children: [
              const CustomRowWidget(
                centerText: "Settings",
                isLeft: true,
                isRightSetting: false,
                isRightMore: false,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: ipad ? 85 : 60,
                  left: ipad ? 30 : 20,
                  right: ipad ? 30 : 20,
                  bottom: ipad ? 30 : 20,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: "Support & Feedback",
                        color: AppColors.textFillColor,
                      ),
                      InfoRow(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FAQsScreen(),
                            ),
                          );
                        },
                        svgPath: "assets/svg/faqs.svg",
                        title: "FAQs & Guide",
                        subtitle: "How to use 500 templates & customize memes",
                      ),
                      SizedBox(height: ipad ? 16 : 10),
                      InfoRow(
                        onTap: () async {
                          await appRating();
                        },
                        svgPath: "assets/svg/star.svg",
                        iconColor: const Color(0xffFFB800),
                        title: "Leave a Rating",
                        subtitle: "Share your love & feedback on the App Store",
                      ),
                      SizedBox(height: ipad ? 16 : 10),
                      InfoRow(
                        onTap: _showPrivacyPolicyModal,
                        svgPath: "assets/svg/star.svg",
                        iconColor: AppColors.bratGreen,
                        title: "Privacy & Data Safety",
                        subtitle: "100% On-Device • Zero Data Collection",
                      ),
                    ],
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

class InfoRow extends StatelessWidget {
  final String svgPath;
  final String title;
  final String subtitle;
  final Function()? onTap;
  final Color? iconColor;

  const InfoRow({
    super.key,
    required this.svgPath,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IosBounceButton(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ipad ? 20 : 15,
          horizontal: ipad ? 24 : 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: ipad ? 56 : 44,
              height: ipad ? 56 : 44,
              decoration: BoxDecoration(
                color: AppColors.offWhiteColor,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: AppSvgIcon(
                assetPath: svgPath,
                size: ipad ? 30 : 22,
                color: iconColor ?? AppColors.textBlackColor,
              ),
            ),
            SizedBox(width: ipad ? 20 : 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: AppColors.textBlackColor,
                      fontWeight: FontWeight.w600,
                      fontSize: iphoneX
                          ? 17
                          : ipad
                              ? 24
                              : 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: AppColors.textBlackColor.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                      fontSize: iphoneX
                          ? 13
                          : ipad
                              ? 18
                              : 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: iphoneX
                  ? 18
                  : ipad
                      ? 26
                      : 18,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const SectionHeader({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ipad ? 30 : 20),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: iphoneX
                ? 20
                : ipad
                    ? 30
                    : 22,
          ),
        ),
        SizedBox(height: ipad ? 30 : 20),
      ],
    );
  }
}
