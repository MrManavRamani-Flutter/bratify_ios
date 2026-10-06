import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brat_generator/constants/app_colors.dart';
import 'package:brat_generator/features/frames/frame_preflight_sheet.dart';
import 'package:brat_generator/models/frame_model.dart';
import 'package:brat_generator/screens/generate_screen.dart';
import 'package:brat_generator/screens/onboarding_screen.dart';
import 'package:brat_generator/screens/save_screen.dart';
import 'package:brat_generator/screens/settings/settings_screen.dart';
import 'package:brat_generator/screens/templates_screen.dart';
import 'package:brat_generator/widgets/frame_canvas_widget.dart';

/// Capture widget wrapped with RepaintBoundary and write PNG bytes to disk
Future<void> _captureAndSavePng({
  required WidgetTester tester,
  required GlobalKey boundaryKey,
  required String screenshotName,
}) async {
  await tester.runAsync(() async {
    final RenderRepaintBoundary? boundary =
        boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final Uint8List bytes = byteData.buffer.asUint8List();

    // 1. Save to project test/screenshots
    final projectDir = Directory('test/screenshots');
    if (!projectDir.existsSync()) {
      projectDir.createSync(recursive: true);
    }
    File('test/screenshots/$screenshotName.png').writeAsBytesSync(bytes);

    // 2. Also save to brain artifact scratch for direct IDE viewing
    final artifactDir = Directory(
      '/Users/manavramani/.gemini/antigravity-ide/brain/fdb0cb41-a0f8-46dd-9f83-4852cc6e7fae/scratch',
    );
    if (!artifactDir.existsSync()) {
      artifactDir.createSync(recursive: true);
    }
    File('${artifactDir.path}/$screenshotName.png').writeAsBytesSync(bytes);
  });
}

Widget _wrapWithPhoneFrame(Widget child, {GlobalKey? captureKey}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.offWhiteColor,
      useMaterial3: true,
    ),
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: RepaintBoundary(
          key: captureKey,
          child: Container(
            width: 393,
            height: 852,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(44),
              border: Border.all(color: Colors.black12, width: 2),
            ),
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;
    GoogleFonts.config.allowRuntimeFetching = true;

    final fontFile = File('test/assets/Roboto.ttf');
    if (fontFile.existsSync()) {
      final fontBytes = fontFile.readAsBytesSync();
      final fontFamilies = [
        'Roboto',
        'Arial',
        'Outfit',
        'Outfit_regular',
        'Outfit_300',
        'Outfit_400',
        'Outfit_500',
        'Outfit_600',
        'Outfit_700',
        'Outfit_800',
        'Outfit_900',
        'Outfit_italic',
        'Brat Sans',
        'Inter',
        'Inter_regular',
        'Inter_600',
        'Inter_700',
      ];
      for (final family in fontFamilies) {
        final loader = FontLoader(family);
        loader.addFont(Future.value(ByteData.view(fontBytes.buffer)));
        await loader.load();
      }
    }
  });

  setUp(() {
    HttpOverrides.global = null;
    GoogleFonts.config.allowRuntimeFetching = true;
    SharedPreferences.setMockInitialValues({
      'seenOnboarding': true,
      'hasShownAppProcess': true,
    });
  });

  group('Automated UI Screen Capture Suite', () {
    testWidgets('1. Capture Screen: Onboarding Flow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final key = GlobalKey();
      await tester.pumpWidget(
        _wrapWithPhoneFrame(const OnboardingScreen(), captureKey: key),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(OnboardingScreen), findsOneWidget);
      await _captureAndSavePng(
        tester: tester,
        boundaryKey: key,
        screenshotName: 'screen_1_onboarding',
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('2. Capture Screen: Home / GenerateScreen Studio',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final key = GlobalKey();
      await tester.pumpWidget(
        _wrapWithPhoneFrame(const GenerateScreen(), captureKey: key),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(GenerateScreen), findsOneWidget);
      expect(find.text('500 Frames'), findsAtLeastNWidgets(1));
      expect(find.text('TRENDING AESTHETIC FRAMES'), findsOneWidget);

      await _captureAndSavePng(
        tester: tester,
        boundaryKey: key,
        screenshotName: 'screen_2_home_generate',
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('3. Capture Screen: Frame Preflight Guidance Modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final key = GlobalKey();
      final testFrame = predefined500Frames[50]; // Polaroid 600

      await tester.pumpWidget(
        _wrapWithPhoneFrame(
          Stack(
            children: [
              // Dark backdrop mimicking modal overlay
              Container(
                color: Colors.black.withValues(alpha: 0.75),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white.withValues(alpha: 0.2), size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Select Aesthetic Frame',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              // Preflight Sheet modal
              Align(
                alignment: Alignment.bottomCenter,
                child: FramePreflightSheet(
                  frame: testFrame,
                  onProceed: (_, __) {},
                ),
              ),
            ],
          ),
          captureKey: key,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TEMPLATE WORKFLOW & REQUIREMENTS'), findsOneWidget);
      expect(find.text('1 Photo Required'), findsOneWidget);

      await _captureAndSavePng(
        tester: tester,
        boundaryKey: key,
        screenshotName: 'screen_3_frame_preflight',
      );
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('4. Capture Screen: 500+ Aesthetic Templates Library',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final key = GlobalKey();
      await tester.pumpWidget(
        _wrapWithPhoneFrame(
          TemplatesScreen(onSelectTemplateWithPhoto: (_, __) {}),
          captureKey: key,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(TemplatesScreen), findsOneWidget);
      expect(find.text('500 AESTHETIC FRAMES'), findsOneWidget);

      await _captureAndSavePng(
        tester: tester,
        boundaryKey: key,
        screenshotName: 'screen_4_templates_library',
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('5. Capture Screen: Saved Memes & Drafts Library',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final key = GlobalKey();
      await tester.pumpWidget(
        _wrapWithPhoneFrame(
          SaveScreen(onEditSelected: (_) {}),
          captureKey: key,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SaveScreen), findsOneWidget);
      await _captureAndSavePng(
        tester: tester,
        boundaryKey: key,
        screenshotName: 'screen_5_saved_drafts',
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('6. Capture Screen: Settings & Privacy Options',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final key = GlobalKey();
      await tester.pumpWidget(
        _wrapWithPhoneFrame(const SettingScreen(), captureKey: key),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SettingScreen), findsOneWidget);
      expect(find.text('Privacy & Data Safety'), findsOneWidget);

      await _captureAndSavePng(
        tester: tester,
        boundaryKey: key,
        screenshotName: 'screen_6_settings',
      );
      await tester.pump(const Duration(seconds: 1));
    });
  });

  group('5 Distinct Automated Post Showcases', () {
    testWidgets('Post 1: Classic Brat Viral Post (Lime Green Album Aesthetic)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: Container(
                  width: 500,
                  height: 500,
                  color: AppColors.bratGreen,
                  padding: const EdgeInsets.all(40),
                  child: Stack(
                    children: [
                      // Film Grain Simulator
                      CustomPaint(
                        size: const Size(500, 500),
                        painter: FilmGrainPainter(opacity: 0.12),
                      ),
                      // Text content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              '365\nparty girl',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: -1.2,
                                height: 0.95,
                              ),
                            ),
                            SizedBox(height: 14),
                            Text(
                              'brat and it\'s completely the same\nbut there\'s three more songs so it\'s not',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await _captureAndSavePng(
        tester: tester,
        boundaryKey: key,
        screenshotName: 'post_1_classic_brat',
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Post 2: Vintage Polaroid 600 Aesthetic Frame Post',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1250);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final key = GlobalKey();
      final polaroidFrame = predefined500Frames[50].copyWith(
        caption: 'endless summer memories • august 2024',
      );

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0xff121216),
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: 440,
                  height: 550,
                  child: FrameCanvasWidget(
                    frame: polaroidFrame,
                    imageFile: null,
                    onPickImage: () {},
                    showFloatingControls: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await _captureAndSavePng(
        tester: tester,
        boundaryKey: key,
        screenshotName: 'post_2_vintage_polaroid',
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Post 3: Y2K Cyber Digicam ISO Viewfinder Post',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final key = GlobalKey();
      final digicamFrame = predefined500Frames[100].copyWith(
        caption: 'CLUB CLASSICS • TOKYO LIVE',
      );

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: 400,
                  height: 711, // 9:16 aspect ratio
                  child: FrameCanvasWidget(
                    frame: digicamFrame,
                    imageFile: null,
                    onPickImage: () {},
                    showFloatingControls: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await _captureAndSavePng(
        tester: tester,
        boundaryKey: key,
        screenshotName: 'post_3_cyber_digicam',
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Post 4: Spotify Aesthetic Music Player Post',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final key = GlobalKey();
      final musicFrame = predefined500Frames[150].copyWith(
        caption: 'Von Dutch — Charli XCX (Brat Album)',
      );

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0xff0c0c0e),
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: 480,
                  height: 480,
                  child: FrameCanvasWidget(
                    frame: musicFrame,
                    imageFile: null,
                    onPickImage: () {},
                    showFloatingControls: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await _captureAndSavePng(
        tester: tester,
        boundaryKey: key,
        screenshotName: 'post_4_spotify_music_player',
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Post 5: Retro 90s Windows Dialog Post',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final key = GlobalKey();
      final retroFrame = predefined500Frames
          .firstWhere((f) => f.overlayType == FrameOverlayType.retroWindow)
          .copyWith(
            caption: 'SYSTEM_ERROR.EXE: Too iconic to handle',
          );

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0xff008080), // Classic Win98 Teal
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: 480,
                  height: 480,
                  child: FrameCanvasWidget(
                    frame: retroFrame,
                    imageFile: null,
                    onPickImage: () {},
                    showFloatingControls: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await _captureAndSavePng(
        tester: tester,
        boundaryKey: key,
        screenshotName: 'post_5_retro_win98_dialog',
      );
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
