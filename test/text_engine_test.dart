import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brat_generator/models/text_layer_model.dart';
import 'package:brat_generator/widgets/interactive_text_overlay.dart';
import 'package:brat_generator/widgets/text_layers_manager_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TextLayerModel Unit Tests', () {
    test('TextLayerModel defaults and copyWith work correctly', () {
      final layer = TextLayerModel(
        id: 'test_1',
        text: 'hello brat',
        offset: const Offset(0.5, 0.5),
        fontSize: 32.0,
      );

      expect(layer.id, 'test_1');
      expect(layer.formattedText, 'hello brat');
      expect(layer.offset, const Offset(0.5, 0.5));
      expect(layer.fontSize, 32.0);

      // copyWith uppercase
      final updated = layer.copyWith(
        textCase: 'UPPERCASE',
        fontSize: 48.0,
        letterSpacing: 2.5,
      );

      expect(updated.formattedText, 'HELLO BRAT');
      expect(updated.fontSize, 48.0);
      expect(updated.letterSpacing, 2.5);
    });

    test('TextLayerModel JSON serialization and deserialization', () {
      final layer = TextLayerModel(
        id: 'json_1',
        text: 'viral post',
        offset: const Offset(0.2, 0.8),
        fontFamily: 'Outfit',
        fontSize: 42.0,
        fontWeight: 'Black',
        textColor: Colors.white,
        textAlign: TextAlign.right,
        letterSpacing: -1.5,
        lineHeight: 1.2,
      );

      final json = layer.toJson();
      final revived = TextLayerModel.fromJson(json);

      expect(revived.id, 'json_1');
      expect(revived.text, 'viral post');
      expect(revived.offset.dx, closeTo(0.2, 0.001));
      expect(revived.offset.dy, closeTo(0.8, 0.001));
      expect(revived.fontFamily, 'Outfit');
      expect(revived.fontSize, 42.0);
      expect(revived.fontWeight, 'Black');
      expect(revived.textAlign, TextAlign.right);
      expect(revived.letterSpacing, -1.5);
      expect(revived.lineHeight, closeTo(1.2, 0.001));
    });
  });

  group('InteractiveTextOverlay Widget Tests', () {
    testWidgets('Renders multiple text layers and handles drag gesture', (tester) async {
      Offset lastOffset = const Offset(0.5, 0.5);
      String? selectedId;

      final layers = [
        TextLayerModel(
          id: 'l1',
          text: 'Layer 1 Text',
          offset: const Offset(0.5, 0.5),
        ),
        TextLayerModel(
          id: 'l2',
          text: 'Layer 2 Text',
          offset: const Offset(0.3, 0.3),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: InteractiveTextOverlay(
                layers: layers,
                activeLayerId: 'l1',
                isExporting: false,
                onSelectLayer: (id) => selectedId = id,
                onUpdateOffset: (id, newOffset) => lastOffset = newOffset,
                onDeleteLayer: (_) {},
                onEditLayer: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify both text layers are rendered
      expect(find.text('layer 1 text'), findsOneWidget);
      expect(find.text('layer 2 text'), findsOneWidget);

      // Verify dragging l1 updates normalized coordinates
      final layerFinder = find.text('layer 1 text');
      await tester.drag(layerFinder, const Offset(40, 40));
      await tester.pumpAndSettle();

      expect(lastOffset.dx, isNot(0.5));
      expect(lastOffset.dy, isNot(0.5));
    });

    testWidgets('Hides selection badges when isExporting is true', (tester) async {
      final layers = [
        TextLayerModel(
          id: 'l1',
          text: 'Export Preview',
          offset: const Offset(0.5, 0.5),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: InteractiveTextOverlay(
                layers: layers,
                activeLayerId: 'l1',
                isExporting: true, // Exporting
                onSelectLayer: (_) {},
                onUpdateOffset: (_, __) {},
                onDeleteLayer: (_) {},
                onEditLayer: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Close badge icon should NOT be visible during export
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    });
  });

  group('TextLayersManagerWidget UI Tests', () {
    testWidgets('Displays layer list, inline text editor, and typography controls', (tester) async {
      bool addCalled = false;
      String? deletedId;
      TextLayerModel? updatedModel;

      final layers = [
        TextLayerModel(
          id: 't1',
          text: 'brat summer',
          offset: const Offset(0.5, 0.5),
          fontFamily: 'Arial',
          fontSize: 36.0,
        ),
        TextLayerModel(
          id: 't2',
          text: 'club classics',
          offset: const Offset(0.5, 0.7),
          fontFamily: 'Outfit',
          fontSize: 28.0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TextLayersManagerWidget(
                layers: layers,
                activeLayerId: 't1',
                onSelectLayer: (_) {},
                onAddLayer: () => addCalled = true,
                onDeleteLayer: (id) => deletedId = id,
                onDuplicateLayer: (_) {},
                onUpdateLayer: (updated) => updatedModel = updated,
                onRecordHistory: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify layer cards list
      expect(find.text('LAYERS (2)'), findsOneWidget);
      expect(find.text('T1'), findsOneWidget);
      expect(find.text('T2'), findsOneWidget);

      // Verify Add Text button
      final addBtn = find.text('Add Text');
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      expect(addCalled, isTrue);

      // Verify inline text editing field contains active layer text
      expect(find.text('brat summer'), findsWidgets);

      // Verify alignment buttons exist
      expect(find.byIcon(Icons.format_align_left), findsOneWidget);
      expect(find.byIcon(Icons.format_align_center), findsOneWidget);
      expect(find.byIcon(Icons.format_align_right), findsOneWidget);

      // Tap align right and verify update
      await tester.tap(find.byIcon(Icons.format_align_right));
      await tester.pumpAndSettle();
      expect(updatedModel?.textAlign, TextAlign.right);

      // Tap UPPERCASE chip and verify update
      final upperChip = find.text('UPPER');
      expect(upperChip, findsOneWidget);
      await tester.tap(upperChip);
      await tester.pumpAndSettle();
      expect(updatedModel?.textCase, 'UPPERCASE');
    });
  });
}
