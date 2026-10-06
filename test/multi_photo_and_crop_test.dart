import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:brat_generator/models/frame_model.dart';
import 'package:brat_generator/screens/generate_screen.dart';
import 'package:brat_generator/screens/image_crop_screen.dart';
import 'package:brat_generator/screens/save_screen.dart';
import 'package:brat_generator/services/database_service.dart';
import 'package:brat_generator/widgets/frame_canvas_widget.dart';
import 'package:brat_generator/features/studio_effects/studio_effects_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multi-Photo Frame Layout Tests', () {
    testWidgets('Renders 2-photo split layout properly', (WidgetTester tester) async {
      final multiFrame = predefined500Frames.firstWhere(
        (f) => f.photoLayout == FramePhotoLayout.split2H,
        orElse: () => predefined500Frames[55],
      );

      expect(multiFrame.maxPhotos, 2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrameCanvasWidget(
              frame: multiFrame,
              imageFile: null,
              onPickImage: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FrameCanvasWidget), findsOneWidget);
    });

    testWidgets('Renders 4-photo grid collage layout properly', (WidgetTester tester) async {
      final gridFrame = predefined500Frames.firstWhere(
        (f) => f.photoLayout == FramePhotoLayout.grid4,
        orElse: () => predefined500Frames[60],
      );

      expect(gridFrame.maxPhotos, 4);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrameCanvasWidget(
              frame: gridFrame,
              imageFile: null,
              onPickImage: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FrameCanvasWidget), findsOneWidget);
    });
  });

  group('Dedicated ImageCropScreen Tests', () {
    testWidgets('ImageCropScreen displays controls, performs rotation and applies', (WidgetTester tester) async {
      // Create a temporary dummy image file for widget testing
      final tempFile = File('${Directory.systemTemp.path}/test_crop_sample.png');
      if (!tempFile.existsSync()) {
        tempFile.writeAsBytesSync([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
      }

      await tester.pumpWidget(
        MaterialApp(
          home: ImageCropScreen(
            imageFile: XFile(tempFile.path),
            title: 'Test Crop Studio',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Crop Studio'), findsOneWidget);
      expect(find.text('Rotate 90°'), findsOneWidget);
      expect(find.text('Mirror X'), findsOneWidget);
      expect(find.text('Mirror Y'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Tap Rotate
      await tester.tap(find.text('Rotate 90°'));
      await tester.pumpAndSettle();

      // Tap Flip H
      await tester.tap(find.text('Mirror X'));
      await tester.pumpAndSettle();
    });
  });

  group('Dedicated Edit Screen & Quotes Integration', () {
    testWidgets('GenerateScreen with isDedicatedEditScreen shows back button and hides trending frames', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GenerateScreen(
            isDedicatedEditScreen: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show 'Studio' back button
      expect(find.text('Studio'), findsOneWidget);
      expect(find.text('Custom Frame'), findsWidgets);
      // In dedicated edit screen, the redundant bottom trending frames showcase should be hidden
      expect(find.text('TRENDING AESTHETIC FRAMES'), findsNothing);
    });

    testWidgets('GenerateScreen properly initializes with initialText applied to canvas', (WidgetTester tester) async {
      const customQuote = '365 party girl';
      await tester.pumpWidget(
        const MaterialApp(
          home: GenerateScreen(
            initialText: customQuote,
            isDedicatedEditScreen: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Custom quote must appear on the canvas
      expect(find.text(customQuote), findsWidgets);
    });
  });

  group('Library / SaveScreen Real-time Database Notification', () {
    testWidgets('SaveScreen listens to savedMemesChangeNotifier', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SaveScreen(
            onEditSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SaveScreen), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);

      // Trigger change notification
      DatabaseHelper.savedMemesChangeNotifier.value++;
      await tester.pumpAndSettle();

      expect(find.byType(SaveScreen), findsOneWidget);
    });
  });

  group('Aspect Ratio Tests', () {
    testWidgets('FrameCanvasWidget applies 9:16 aspect ratio correctly without being overridden by default studio effects', (WidgetTester tester) async {
      final storyFrame = defaultCustomFrame.copyWith(aspectRatio: 9 / 16);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrameCanvasWidget(
              frame: storyFrame,
              studioEffects: const StudioEffectsModel(),
              imageFile: null,
              onPickImage: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final arFinder = find.descendant(
        of: find.byType(FrameCanvasWidget),
        matching: find.byType(AspectRatio),
      );
      expect(arFinder, findsWidgets);
      final AspectRatio arWidget = tester.widget(arFinder.first);
      expect(arWidget.aspectRatio, closeTo(9 / 16, 0.001));
    });

    testWidgets('FrameCanvasWidget applies 4:5 aspect ratio correctly', (WidgetTester tester) async {
      final portraitFrame = defaultCustomFrame.copyWith(aspectRatio: 4 / 5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrameCanvasWidget(
              frame: portraitFrame,
              studioEffects: const StudioEffectsModel(),
              imageFile: null,
              onPickImage: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final arFinder = find.descendant(
        of: find.byType(FrameCanvasWidget),
        matching: find.byType(AspectRatio),
      );
      final AspectRatio arWidget = tester.widget(arFinder.first);
      expect(arWidget.aspectRatio, closeTo(4 / 5, 0.001));
    });

    testWidgets('Changing ratio in GenerateScreen updates ratio chips and canvas', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: GenerateScreen(
            isDedicatedEditScreen: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find 9:16 Story ratio button in Tab 0
      final storyRatioBtn = find.text('9:16 Story');
      expect(storyRatioBtn, findsOneWidget);

      await tester.ensureVisible(storyRatioBtn);
      await tester.pumpAndSettle();

      await tester.tap(storyRatioBtn);
      await tester.pumpAndSettle();

      // Verify the top app bar subtitle updated to 9:16 Story & Reels
      expect(find.text('9:16 Story & Reels'), findsOneWidget);
    });
  });
}
