import 'package:brat_generator/features/studio_effects/studio_effects_model.dart';
import 'package:brat_generator/models/frame_model.dart';
import 'package:brat_generator/models/meme_design_model.dart';
import 'package:brat_generator/models/studio_filter_model.dart';
import 'package:brat_generator/widgets/frame_canvas_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudioFilterCatalog Tests', () {
    test('Catalog contains 13 aesthetic filters', () {
      expect(StudioFilterCatalog.filters.length, 13);
      final ids = StudioFilterCatalog.filters.map((f) => f.id).toSet();
      expect(ids.contains('none'), isTrue);
      expect(ids.contains('brat'), isTrue);
      expect(ids.contains('noir'), isTrue);
      expect(ids.contains('vintage'), isTrue);
      expect(ids.contains('cyberpunk'), isTrue);
      expect(ids.contains('golden'), isTrue);
      expect(ids.contains('cold'), isTrue);
      expect(ids.contains('vivid'), isTrue);
      expect(ids.contains('sepia'), isTrue);
      expect(ids.contains('acid'), isTrue);
      expect(ids.contains('pastel'), isTrue);
      expect(ids.contains('cinematic'), isTrue);
      expect(ids.contains('invert'), isTrue);
    });

    test('getFilter returns fallback for unknown ID', () {
      final filter = StudioFilterCatalog.getFilter('unknown_id');
      expect(filter.id, 'none');
    });

    test('getMatrix for none returns identity matrix', () {
      final matrix = StudioFilterCatalog.getMatrix('none');
      expect(matrix, StudioFilterCatalog.identityMatrix);
    });

    test('getMatrix interpolates smoothly based on intensity', () {
      final bratTarget = StudioFilterCatalog.getFilter('brat').matrix;
      final fullMatrix = StudioFilterCatalog.getMatrix('brat', intensity: 1.0);
      expect(fullMatrix, bratTarget);

      final zeroMatrix = StudioFilterCatalog.getMatrix('brat', intensity: 0.0);
      expect(zeroMatrix, StudioFilterCatalog.identityMatrix);

      final halfMatrix = StudioFilterCatalog.getMatrix('brat', intensity: 0.5);
      expect(halfMatrix.length, 20);
      // Value at index 0 should be midpoint
      final expectedMid = StudioFilterCatalog.identityMatrix[0] +
          (bratTarget[0] - StudioFilterCatalog.identityMatrix[0]) * 0.5;
      expect((halfMatrix[0] - expectedMid).abs() < 0.001, isTrue);
    });
  });

  group('MemeDesign Filter Persistence Tests', () {
    test('MemeDesign stores and parses filterId and filterIntensity', () {
      final design = MemeDesign(
        backgroundColor: Colors.black,
        text: 'brat viral',
        textAlign: TextAlign.center,
        fontFamily: 'Arial',
        fontSize: 32.0,
        fontWeight: 'Bold',
        textColor: Colors.white,
        filterId: 'vintage',
        filterIntensity: 0.85,
      );

      final json = design.toJson();
      expect(json['filterId'], 'vintage');
      expect(json['filterIntensity'], 0.85);

      final parsed = MemeDesign.fromJson(json);
      expect(parsed.filterId, 'vintage');
      expect(parsed.filterIntensity, 0.85);
    });

    test('MemeDesign safely defaults missing filter fields from older schemas', () {
      final legacyJson = {
        'id': 99,
        'backgroundColor': Colors.green.toARGB32(),
        'text': 'vintage post',
        'textAlign': 0,
        'fontFamily': 'Arial',
        'fontSize': 28.0,
        'fontWeight': 'Regular',
        'textColor': Colors.black.toARGB32(),
        'createdAt': '2026-01-01T00:00:00Z',
      };

      final parsed = MemeDesign.fromJson(legacyJson);
      expect(parsed.filterId, 'none');
      expect(parsed.filterIntensity, 1.0);
    });
  });

  group('FrameCanvasWidget Filter Integration Tests', () {
    testWidgets('FrameCanvasWidget renders ColorFiltered when filter is active', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrameCanvasWidget(
              frame: predefined100Frames.first,
              imageFile: null,
              onPickImage: () {},
              studioEffects: const StudioEffectsModel(
                activeFilterId: 'brat',
                filterIntensity: 0.9,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ColorFiltered), findsWidgets);
    });
  });
}
