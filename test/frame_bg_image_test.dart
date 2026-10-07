import 'dart:io';
import 'dart:typed_data';
import 'package:brat_generator/models/frame_model.dart';
import 'package:brat_generator/models/meme_design_model.dart';
import 'package:brat_generator/widgets/frame_canvas_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late File tempSampleFile;

  setUpAll(() {
    tempSampleFile = File('${Directory.systemTemp.path}/test_bg_sample.png');
    if (!tempSampleFile.existsSync()) {
      // 1x1 transparent PNG header
      final sampleBytes = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
        0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
        0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
        0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
        0x42, 0x60, 0x82,
      ]);
      tempSampleFile.writeAsBytesSync(sampleBytes);
    }
  });

  tearDownAll(() {
    if (tempSampleFile.existsSync()) {
      tempSampleFile.deleteSync();
    }
  });

  group('Frame Background Image Feature Tests', () {
    testWidgets('FrameCanvasWidget renders with frameBgImage', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrameCanvasWidget(
              frame: defaultCustomFrame,
              imageFile: null,
              frameBgImage: XFile(tempSampleFile.path),
              frameBgFit: BoxFit.cover,
              frameBgOpacity: 0.9,
              onPickImage: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FrameCanvasWidget), findsOneWidget);
      // Image widget for background is rendered
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('FrameCanvasWidget renders with frameBgImageBytes', (WidgetTester tester) async {
      final bytes = tempSampleFile.readAsBytesSync();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrameCanvasWidget(
              frame: defaultCustomFrame,
              imageFile: null,
              frameBgImageBytes: bytes,
              onPickImage: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FrameCanvasWidget), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Empty slot does not render opaque placeholder when frameBgImage is active', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrameCanvasWidget(
              frame: defaultCustomFrame,
              imageFile: null,
              frameBgImage: XFile(tempSampleFile.path),
              onPickImage: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In editor mode, shows subtle translucent pill '+ Photo Cutout'
      expect(find.text('+ Photo Cutout'), findsOneWidget);
    });

    testWidgets('When isExporting is true, placeholder pill is hidden for clean background image export', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrameCanvasWidget(
              frame: defaultCustomFrame,
              imageFile: null,
              frameBgImage: XFile(tempSampleFile.path),
              isExporting: true,
              onPickImage: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // When exporting, '+ Photo Cutout' should be completely omitted
      expect(find.text('+ Photo Cutout'), findsNothing);
    });

    test('MemeDesign model correctly encodes and decodes backgroundImageBytes', () {
      final sampleBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final design = MemeDesign(
        backgroundColor: Colors.white,
        backgroundImageBytes: sampleBytes,
        text: 'test meme',
        textAlign: TextAlign.center,
        fontFamily: 'Arial',
        fontSize: 32.0,
        fontWeight: 'Bold',
        textColor: Colors.black,
      );

      final json = design.toJson();
      expect(json['backgroundImageBytes'], isNotNull);

      final reconstructed = MemeDesign.fromJson(json);
      expect(reconstructed.backgroundImageBytes, isNotNull);
      expect(reconstructed.backgroundImageBytes, equals(sampleBytes));
    });
  });
}
