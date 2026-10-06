import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../my_app.dart';
import '../widgets/app_button.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

// Backward compatibility alias
typedef OnBoardScreen = OnboardingScreen;

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingSlideData> _slides = const [
    OnboardingSlideData(
      badge: 'VIRAL MEME STUDIO',
      title: 'Bratify Your World',
      subtitle: 'Iconic Aesthetic Maker',
      description: 'Create viral brat text, low-res blur effects, authentic film grain, and high-contrast statements.',
      painterType: PainterType.bratStudio,
    ),
    OnboardingSlideData(
      badge: '500 PRESET FRAMES',
      title: 'Polaroids & Y2K',
      subtitle: 'Instant Creative Layouts',
      description: 'Choose from 500 predefined frames: Digicam ISO, VHS REC, Spotify audio bars, and retro Windows 98.',
      painterType: PainterType.frames,
    ),
    OnboardingSlideData(
      badge: 'PHOTO FREEDOM',
      title: 'Crop & Transform',
      subtitle: 'Pan, Zoom, Rotate & Fit',
      description: 'Full image freedom: pinch to zoom, drag to crop, rotate 90°, change photos, or delete anytime.',
      painterType: PainterType.cropTransform,
    ),
    OnboardingSlideData(
      badge: 'EXPORT & SHARE',
      title: 'Google Fonts Studio',
      subtitle: 'Pro Typography & Ratios',
      description: 'Browse 30+ Google Fonts, custom aspect ratios (1:1, 9:16, 4:5), and export in ultra-high resolution.',
      painterType: PainterType.exportTypography,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
  }

  void _onSkipOrDone() {
    HapticFeedback.mediumImpact();
    _setOnboardingSeen();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainScreen(),
      ),
    );
  }

  void _onNextPressed() {
    HapticFeedback.lightImpact();
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _onSkipOrDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTab = MediaQuery.sizeOf(context).shortestSide >= 600;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.offWhiteColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.offWhiteColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.bratGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.appTitle.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            fontSize: isTab ? 16 : 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    if (_currentIndex < _slides.length - 1)
                      TextButton(
                        onPressed: _onSkipOrDone,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black54,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.outfit(
                            fontSize: isTab ? 16 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 36),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: isTab ? 40 : 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: screenHeight * (isTab ? 0.44 : 0.38),
                                width: double.infinity,
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: 1.15,
                                    child: CustomPaint(
                                      painter: _getPainterForType(
                                        slide.painterType,
                                        _animController.value,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.bratGreen.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.bratGreen,
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  slide.badge,
                                  style: GoogleFonts.outfit(
                                    fontSize: isTab ? 13 : 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                slide.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: isTab ? 32 : (iphoneX ? 24 : 26),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                slide.subtitle,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: isTab ? 22 : (iphoneX ? 17 : 19),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textFillColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: isTab ? 500 : 320),
                                child: Text(
                                  slide.description,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: isTab ? 17 : 14,
                                    height: 1.35,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (dotIndex) {
                  final isSelected = _currentIndex == dotIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.bratGreen : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                      border: isSelected ? Border.all(color: Colors.black, width: 1.0) : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.bratGreen.withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTab ? 48 : 24,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    if (_currentIndex > 0) ...[
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (_currentIndex == _slides.length - 1
                                      ? AppColors.bratGreen
                                      : Colors.black)
                                  .withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CustomOnboardButton(
                          title: _currentIndex == _slides.length - 1
                              ? 'Get Started  🚀'
                              : 'Next  →',
                          isFilled: true,
                          isOnBoard: true,
                          onTap: _onNextPressed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  CustomPainter _getPainterForType(PainterType type, double progress) {
    switch (type) {
      case PainterType.bratStudio:
        return BratStudioCustomPainter(progress: progress);
      case PainterType.frames:
        return FramesShowcaseCustomPainter(progress: progress);
      case PainterType.cropTransform:
        return CropTransformCustomPainter(progress: progress);
      case PainterType.exportTypography:
        return ExportTypographyCustomPainter(progress: progress);
    }
  }
}

enum PainterType { bratStudio, frames, cropTransform, exportTypography }

class OnboardingSlideData {
  final String badge;
  final String title;
  final String subtitle;
  final String description;
  final PainterType painterType;

  const OnboardingSlideData({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.painterType,
  });
}

class BratStudioCustomPainter extends CustomPainter {
  final double progress;
  BratStudioCustomPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final waveRadius1 = (size.width * 0.28) + (math.sin(progress * math.pi * 2) * 8);
    final waveRadius2 = (size.width * 0.38) + (math.cos(progress * math.pi * 2) * 10);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xff8ACE00).withValues(alpha: 0.35),
          const Color(0xff8ACE00).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.45));
    canvas.drawCircle(center, size.width * 0.45, glowPaint);

    final wavePaint = Paint()
      ..color = const Color(0xff8ACE00).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, waveRadius1, wavePaint);

    wavePaint.color = Colors.black.withValues(alpha: 0.15);
    canvas.drawCircle(center, waveRadius2, wavePaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.04 + (math.sin(progress * math.pi * 2) * 0.02));

    final cardWidth = size.width * 0.62;
    final cardHeight = cardWidth * 0.95;
    final cardRect = Rect.fromCenter(
      center: Offset.zero,
      width: cardWidth,
      height: cardHeight,
    );
    final cardRRect = RRect.fromRectAndRadius(cardRect, const Radius.circular(20));

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawRRect(cardRRect.shift(const Offset(4, 10)), shadowPaint);

    final fillPaint = Paint()..color = const Color(0xff8ACE00);
    canvas.drawRRect(cardRRect, fillPaint);

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(cardRRect, borderPaint);

    final scanlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;
    for (double y = cardRect.top + 8; y < cardRect.bottom - 8; y += 7) {
      canvas.drawLine(Offset(cardRect.left + 10, y), Offset(cardRect.right - 10, y), scanlinePaint);
    }

    final badgeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cardRect.left + 14, cardRect.top + 14, 40, 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(badgeRRect, Paint()..color = Colors.black);

    final badgePainter = TextPainter(
      text: const TextSpan(
        text: '365',
        style: TextStyle(
          color: Color(0xff8ACE00),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    badgePainter.paint(canvas, Offset(cardRect.left + 22, cardRect.top + 16));

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'brat',
        style: TextStyle(
          color: Colors.black,
          fontSize: 44,
          fontFamily: 'Arial',
          fontWeight: FontWeight.bold,
          letterSpacing: -1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2 + 4),
    );

    canvas.restore();

    _drawSparkle(canvas, Offset(center.dx - size.width * 0.38, center.dy - size.height * 0.28), 12, progress);
    _drawSparkle(canvas, Offset(center.dx + size.width * 0.36, center.dy + size.height * 0.24), 14, progress + 0.3);
    _drawSparkle(canvas, Offset(center.dx + size.width * 0.32, center.dy - size.height * 0.32), 9, progress + 0.6);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, double anim) {
    final angle = anim * math.pi * 2;
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < 4; i++) {
      final a = angle + (i * math.pi / 2);
      final x1 = center.dx + math.cos(a) * radius;
      final y1 = center.dy + math.sin(a) * radius;
      final aMid = a + math.pi / 4;
      final xMid = center.dx + math.cos(aMid) * (radius * 0.25);
      final yMid = center.dy + math.sin(aMid) * (radius * 0.25);

      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
      path.lineTo(xMid, yMid);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BratStudioCustomPainter oldDelegate) => true;
}

class FramesShowcaseCustomPainter extends CustomPainter {
  final double progress;
  FramesShowcaseCustomPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);

    final perfPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    const holeSize = 10.0;
    const holeSpacing = 24.0;
    for (double x = 12; x < size.width - 12; x += holeSpacing) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, 14, holeSize, holeSize), const Radius.circular(2)),
        perfPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height - 24, holeSize, holeSize), const Radius.circular(2)),
        perfPaint,
      );
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.06 + (math.sin(progress * math.pi * 2) * 0.02));

    final frameW = size.width * 0.62;
    final frameH = frameW * 1.22;
    final frameRect = Rect.fromCenter(center: Offset.zero, width: frameW, height: frameH);

    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect.shift(const Offset(0, 10)), const Radius.circular(16)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(16)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(16)),
      Paint()
        ..color = Colors.black12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final photoRect = Rect.fromLTWH(
      frameRect.left + 16,
      frameRect.top + 16,
      frameW - 32,
      frameW - 32,
    );
    final photoRRect = RRect.fromRectAndRadius(photoRect, const Radius.circular(8));

    final photoPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xff1A1A24), Color(0xff2A2D3E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(photoRect);
    canvas.drawRRect(photoRRect, photoPaint);

    final isBlinking = math.sin(progress * math.pi * 4) > 0;
    final recDotPaint = Paint()
      ..color = isBlinking ? Colors.redAccent : Colors.redAccent.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(photoRect.left + 16, photoRect.top + 16), 5, recDotPaint);

    final recTextPainter = TextPainter(
      text: const TextSpan(
        text: 'REC',
        style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    recTextPainter.paint(canvas, Offset(photoRect.left + 26, photoRect.top + 11));

    final isoTextPainter = TextPainter(
      text: const TextSpan(
        text: 'ISO 400',
        style: TextStyle(color: Colors.amberAccent, fontSize: 8, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    isoTextPainter.paint(canvas, Offset(photoRect.right - 44, photoRect.top + 11));

    final reticlePaint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final photoCenter = photoRect.center;
    const rSize = 14.0;
    canvas.drawLine(Offset(photoCenter.dx - 6, photoCenter.dy), Offset(photoCenter.dx + 6, photoCenter.dy), reticlePaint);
    canvas.drawLine(Offset(photoCenter.dx, photoCenter.dy - 6), Offset(photoCenter.dx, photoCenter.dy + 6), reticlePaint);
    canvas.drawRect(Rect.fromCenter(center: photoCenter, width: rSize * 2, height: rSize * 2), reticlePaint);

    final captionPainter = TextPainter(
      text: const TextSpan(
        text: '★ 365 party girl ★',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          fontFamily: 'Courier',
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    captionPainter.paint(
      canvas,
      Offset(frameRect.left + (frameW - captionPainter.width) / 2, frameRect.bottom - 32),
    );

    final tapeRect = Rect.fromCenter(
      center: Offset(0, frameRect.top),
      width: 72,
      height: 18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tapeRect, const Radius.circular(3)),
      Paint()..color = const Color(0xff8ACE00).withValues(alpha: 0.85),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FramesShowcaseCustomPainter oldDelegate) => true;
}

class CropTransformCustomPainter extends CustomPainter {
  final double progress;
  CropTransformCustomPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.45));
    canvas.drawCircle(center, size.width * 0.45, glowPaint);

    final boxW = size.width * 0.62;
    final boxH = boxW * 0.88;
    final cropRect = Rect.fromCenter(center: center, width: boxW, height: boxH);

    final clipRRect = RRect.fromRectAndRadius(cropRect, const Radius.circular(12));
    canvas.save();
    canvas.clipRRect(clipRRect);

    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xff181824), Color(0xff3B2D54), Color(0xffE76F51)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(cropRect);
    canvas.drawRect(cropRect, skyPaint);

    final sunOffset = Offset(center.dx + 28, center.dy - 12);
    canvas.drawCircle(
      sunOffset,
      26,
      Paint()..color = const Color(0xffF4A261).withValues(alpha: 0.9),
    );

    final mountain1 = Path()
      ..moveTo(cropRect.left - 10, cropRect.bottom)
      ..lineTo(center.dx - 30, center.dy + 8)
      ..lineTo(center.dx + 50, cropRect.bottom)
      ..close();
    canvas.drawPath(mountain1, Paint()..color = const Color(0xff2A2D3E));

    final mountain2 = Path()
      ..moveTo(center.dx - 10, cropRect.bottom)
      ..lineTo(center.dx + 40, center.dy + 18)
      ..lineTo(cropRect.right + 20, cropRect.bottom)
      ..close();
    canvas.drawPath(mountain2, Paint()..color = const Color(0xff11121C));

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;
    final stepX = cropRect.width / 3;
    final stepY = cropRect.height / 3;

    canvas.drawLine(Offset(cropRect.left + stepX, cropRect.top), Offset(cropRect.left + stepX, cropRect.bottom), gridPaint);
    canvas.drawLine(Offset(cropRect.left + stepX * 2, cropRect.top), Offset(cropRect.left + stepX * 2, cropRect.bottom), gridPaint);
    canvas.drawLine(Offset(cropRect.left, cropRect.top + stepY), Offset(cropRect.right, cropRect.top + stepY), gridPaint);
    canvas.drawLine(Offset(cropRect.left, cropRect.top + stepY * 2), Offset(cropRect.right, cropRect.top + stepY * 2), gridPaint);

    canvas.restore();

    final handlePaint = Paint()
      ..color = const Color(0xff8ACE00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    const hLen = 18.0;

    canvas.drawLine(Offset(cropRect.left, cropRect.top), Offset(cropRect.left + hLen, cropRect.top), handlePaint);
    canvas.drawLine(Offset(cropRect.left, cropRect.top), Offset(cropRect.left, cropRect.top + hLen), handlePaint);

    canvas.drawLine(Offset(cropRect.right, cropRect.top), Offset(cropRect.right - hLen, cropRect.top), handlePaint);
    canvas.drawLine(Offset(cropRect.right, cropRect.top), Offset(cropRect.right, cropRect.top + hLen), handlePaint);

    canvas.drawLine(Offset(cropRect.left, cropRect.bottom), Offset(cropRect.left + hLen, cropRect.bottom), handlePaint);
    canvas.drawLine(Offset(cropRect.left, cropRect.bottom), Offset(cropRect.left, cropRect.bottom - hLen), handlePaint);

    canvas.drawLine(Offset(cropRect.right, cropRect.bottom), Offset(cropRect.right - hLen, cropRect.bottom), handlePaint);
    canvas.drawLine(Offset(cropRect.right, cropRect.bottom), Offset(cropRect.right, cropRect.bottom - hLen), handlePaint);

    final sliderW = boxW * 0.75;
    final sliderY = cropRect.bottom + 22;
    final sliderRect = Rect.fromCenter(
      center: Offset(center.dx, sliderY),
      width: sliderW,
      height: 18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(sliderRect, const Radius.circular(9)),
      Paint()..color = Colors.black87,
    );

    canvas.drawLine(
      Offset(sliderRect.left + 16, sliderY),
      Offset(sliderRect.right - 16, sliderY),
      Paint()
        ..color = Colors.white24
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    final thumbProgress = (math.sin(progress * math.pi * 2) + 1) / 2;
    final thumbX = (sliderRect.left + 20) + (sliderW - 40) * thumbProgress;
    canvas.drawCircle(Offset(thumbX, sliderY), 7, Paint()..color = const Color(0xff8ACE00));
    canvas.drawCircle(Offset(thumbX, sliderY), 7, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5);

    final rotBadgeRect = Rect.fromLTWH(cropRect.right - 28, cropRect.top - 14, 38, 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rotBadgeRect, const Radius.circular(6)),
      Paint()..color = Colors.black,
    );
    final rotPainter = TextPainter(
      text: const TextSpan(
        text: '⟳ 90°',
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    rotPainter.paint(canvas, Offset(rotBadgeRect.left + 4, rotBadgeRect.top + 4));
  }

  @override
  bool shouldRepaint(covariant CropTransformCustomPainter oldDelegate) => true;
}

class ExportTypographyCustomPainter extends CustomPainter {
  final double progress;
  ExportTypographyCustomPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.48);

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (progress * math.pi * 0.5);
      final dist = (size.width * 0.38) + (math.sin(progress * math.pi * 2 + i) * 10);
      final dotOffset = Offset(center.dx + math.cos(angle) * dist, center.dy + math.sin(angle) * dist);
      final color = [
        const Color(0xff8ACE00),
        const Color(0xff00F0FF),
        const Color(0xffFF007F),
        Colors.black,
      ][i % 4];
      canvas.drawCircle(dotOffset, 4, Paint()..color = color);
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.10 + (math.sin(progress * math.pi * 2) * 0.02));

    final cardW = size.width * 0.54;
    final cardH = cardW * 0.95;
    final backRect = Rect.fromCenter(center: Offset.zero, width: cardW, height: cardH);

    canvas.drawRRect(
      RRect.fromRectAndRadius(backRect, const Radius.circular(16)),
      Paint()..color = Colors.black87,
    );

    final fontAPainter = TextPainter(
      text: const TextSpan(
        text: 'Aa',
        style: TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontFamily: 'serif',
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    fontAPainter.paint(canvas, Offset(-fontAPainter.width / 2, -fontAPainter.height / 2));

    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.06);

    final frontRect = Rect.fromCenter(center: Offset.zero, width: cardW, height: cardH);

    canvas.drawRRect(
      RRect.fromRectAndRadius(frontRect.shift(const Offset(0, 8)), const Radius.circular(16)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(frontRect, const Radius.circular(16)),
      Paint()..color = const Color(0xff8ACE00),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frontRect, const Radius.circular(16)),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final hdPainter = TextPainter(
      text: const TextSpan(
        text: 'HD ✦',
        style: TextStyle(
          color: Colors.black,
          fontSize: 36,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    hdPainter.paint(canvas, Offset(-hdPainter.width / 2, -hdPainter.height / 2 - 8));

    final sharePill = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, frontRect.bottom - 22), width: cardW * 0.72, height: 20),
      const Radius.circular(10),
    );
    canvas.drawRRect(sharePill, Paint()..color = Colors.black);

    final shareText = TextPainter(
      text: const TextSpan(
        text: 'EXPORT PNG',
        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    shareText.paint(canvas, Offset(-shareText.width / 2, frontRect.bottom - 28));

    canvas.restore();

    final dotY = center.dy + cardH * 0.65;
    final colors = [
      const Color(0xff8ACE00),
      const Color(0xff39FF14),
      const Color(0xffFF007F),
      const Color(0xff00F0FF),
      Colors.black,
    ];
    const dotSpacing = 22.0;
    final startX = center.dx - ((colors.length - 1) * dotSpacing) / 2;

    for (int i = 0; i < colors.length; i++) {
      final x = startX + (i * dotSpacing);
      final bounce = math.sin(progress * math.pi * 2 + (i * 0.6)) * 3;
      canvas.drawCircle(Offset(x, dotY + bounce), 8, Paint()..color = colors[i]);
      canvas.drawCircle(
        Offset(x, dotY + bounce),
        8,
        Paint()
          ..color = Colors.black26
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ExportTypographyCustomPainter oldDelegate) => true;
}
