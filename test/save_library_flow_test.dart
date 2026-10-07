import 'dart:convert';
import 'dart:typed_data';
import 'package:brat_generator/constants/app_colors.dart';
import 'package:brat_generator/models/meme_design_model.dart';
import 'package:brat_generator/models/text_layer_model.dart';
import 'package:brat_generator/screens/generate_screen.dart';
import 'package:brat_generator/screens/save_screen.dart';
import 'package:brat_generator/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Save & Library Tests', () {
    test('MemeDesign safely serializes and deserializes Uint8List imageBytes', () {
      final sampleBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final meme = MemeDesign(
        backgroundColor: Colors.green,
        text: 'brat test meme',
        textAlign: TextAlign.center,
        fontFamily: 'Arial',
        fontSize: 36,
        fontWeight: 'Bold',
        textColor: Colors.black,
        imageBytes: sampleBytes,
        filterId: 'lime_boost',
        filterIntensity: 0.85,
      );

      final dbMap = meme.toDbMap();
      expect(dbMap['imageBytes'], isA<Uint8List>());
      expect(dbMap['filterId'], 'lime_boost');
      expect(dbMap['filterIntensity'], 0.85);

      final fromDb = MemeDesign.fromJson(dbMap);
      expect(fromDb.text, 'brat test meme');
      expect(fromDb.imageBytes, isNotNull);
      expect(fromDb.imageBytes!.length, 5);
      expect(fromDb.filterId, 'lime_boost');
      expect(fromDb.filterIntensity, 0.85);
    });

    test('MemeDesign handles corrupt or string bytes without throwing TypeError', () {
      final mapWithStr = {
        'id': 10,
        'backgroundColor': Colors.black.toARGB32(),
        'text': 'corrupted test',
        'textAlign': 1,
        'fontFamily': 'Arial',
        'fontSize': 30,
        'fontWeight': 'Normal',
        'textColor': Colors.white.toARGB32(),
        'imageBytes': 'not-a-valid-base-64-string!@#%',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final parsed = MemeDesign.fromJson(mapWithStr);
      expect(parsed.id, 10);
      expect(parsed.text, 'corrupted test');
      expect(parsed.imageBytes, isNull);
    });

    test('DatabaseHelper insert, getAll, and delete operations work seamlessly', () async {
      final db = DatabaseHelper();
      int notifyCount = 0;
      void listener() => notifyCount++;
      DatabaseHelper.savedMemesChangeNotifier.addListener(listener);

      final initialCount = (await db.getAllMemeDesigns()).length;

      final meme = MemeDesign(
        backgroundColor: AppColors.bratGreen,
        text: 'persisted brat',
        textAlign: TextAlign.center,
        fontFamily: 'Arial',
        fontSize: 40,
        fontWeight: 'Bold',
        textColor: Colors.black,
        filterId: 'neon_noir',
        filterIntensity: 0.9,
      );

      final id = await db.insertMemeDesign(meme);
      expect(id, isPositive);
      expect(notifyCount, greaterThan(0));

      final designs = await db.getAllMemeDesigns();
      expect(designs.length, initialCount + 1);
      final saved = designs.firstWhere((d) => d.id == id);
      expect(saved.text, 'persisted brat');
      expect(saved.filterId, 'neon_noir');

      await db.deleteMemeDesign(id);
      final afterDelete = await db.getAllMemeDesigns();
      expect(afterDelete.any((d) => d.id == id), isFalse);

      DatabaseHelper.savedMemesChangeNotifier.removeListener(listener);
    });

    testWidgets('SaveScreen renders and displays items from database', (WidgetTester tester) async {
      final db = DatabaseHelper();
      final meme = MemeDesign(
        backgroundColor: Colors.white,
        text: 'library item view test',
        textAlign: TextAlign.center,
        fontFamily: 'Arial',
        fontSize: 32,
        fontWeight: 'Bold',
        textColor: Colors.black,
      );
      await db.insertMemeDesign(meme);

      MemeDesign? selectedForEdit;
      await tester.pumpWidget(
        MaterialApp(
          home: SaveScreen(
            onEditSelected: (m) {
              selectedForEdit = m;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Library'), findsOneWidget);
      expect(find.text('library item view test'), findsWidgets);

      // Tap on item to trigger edit
      await tester.tap(find.text('library item view test').first);
      await tester.pumpAndSettle();

      expect(selectedForEdit, isNotNull);
      expect(selectedForEdit!.text, 'library item view test');
    });

    test('MemeDesign preserves full layout fields including textLayers, frameId, and aspectRatio', () {
      final layer = TextLayerModel(
        id: 'custom_layer_42',
        text: 'placed at custom coordinates',
        offset: const Offset(0.35, 0.22),
        fontSize: 42,
        rotation: 12.0,
      );

      final meme = MemeDesign(
        backgroundColor: Colors.yellow,
        text: 'placed at custom coordinates',
        textAlign: TextAlign.left,
        fontFamily: 'Courier',
        fontSize: 42,
        fontWeight: 'Bold',
        textColor: Colors.blue,
        frameId: 4, // Polaroid Frame
        aspectRatio: 0.8, // 4:5 ratio
        textOffsetX: 0.35,
        textOffsetY: 0.22,
        textLayersJson: jsonEncode([layer.toJson()]),
        isInverted: true,
        hasVignette: true,
      );

      final dbMap = meme.toDbMap();
      expect(dbMap['frameId'], 4);
      expect(dbMap['aspectRatio'], 0.8);
      expect(dbMap['textOffsetX'], 0.35);
      expect(dbMap['textOffsetY'], 0.22);
      expect(dbMap['isInverted'], 1);
      expect(dbMap['hasVignette'], 1);

      final restored = MemeDesign.fromJson(dbMap);
      expect(restored.frameId, 4);
      expect(restored.aspectRatio, 0.8);
      expect(restored.isInverted, isTrue);
      expect(restored.hasVignette, isTrue);
      expect(restored.textLayers, isNotNull);
      expect(restored.textLayers!.length, 1);
      expect(restored.textLayers!.first.offset.dx, 0.35);
      expect(restored.textLayers!.first.offset.dy, 0.22);
      expect(restored.textLayers!.first.rotation, 12.0);
    });

    testWidgets('GenerateScreen restores exact text layer offsets and frame without resetting to defaults', (WidgetTester tester) async {
      final customLayer = TextLayerModel(
        id: 'top_left_label',
        text: 'custom placed text',
        offset: const Offset(0.25, 0.18),
        fontSize: 28,
        fontFamily: 'Arial',
        textColor: Colors.black,
      );

      final designToEdit = MemeDesign(
        id: 99,
        backgroundColor: const Color(0xff8ACE00),
        text: 'custom placed text',
        textAlign: TextAlign.center,
        fontFamily: 'Arial',
        fontSize: 28,
        fontWeight: 'Bold',
        textColor: Colors.black,
        frameId: 4,
        aspectRatio: 0.8,
        textOffsetX: 0.25,
        textOffsetY: 0.18,
        textLayersJson: jsonEncode([customLayer.toJson()]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GenerateScreen(
            initialDesign: designToEdit,
            isDedicatedEditScreen: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find GenerateScreen State
      final generateState = tester.state(find.byType(GenerateScreen));
      expect(generateState, isNotNull);

      // Verify that the text layer offset is NOT hardcoded to (0.5, 0.88)
      final layers = (generateState as dynamic).textLayers as List<TextLayerModel>;
      expect(layers.length, 1);
      expect(layers.first.offset.dx, 0.25);
      expect(layers.first.offset.dy, 0.18);
      expect(layers.first.text, 'custom placed text');
    });
  });
}
