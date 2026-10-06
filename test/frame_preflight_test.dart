import 'package:brat_generator/features/frames/frame_preflight_sheet.dart';
import 'package:brat_generator/models/frame_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FramePreflightSheet renders requirements checklist and CTA buttons',
      (WidgetTester tester) async {
    final testFrame = predefined500Frames[3]; // Polaroid Preset

    bool proceedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  FramePreflightSheet.show(
                    context: context,
                    frame: testFrame,
                    onProceed: (frame, photo) {
                      proceedCalled = true;
                    },
                  );
                },
                child: const Text('Open Preflight'),
              );
            },
          ),
        ),
      ),
    );

    // Tap to open sheet
    await tester.tap(find.text('Open Preflight'));
    await tester.pumpAndSettle();

    // Verify sheet contents
    expect(find.text(testFrame.name), findsAtLeastNWidgets(1));
    expect(find.text('TEMPLATE WORKFLOW & REQUIREMENTS'), findsOneWidget);
    expect(find.text('1 Photo Required'), findsOneWidget);
    expect(find.text('Arrange & Transform Freedom'), findsOneWidget);
    expect(find.text('Customizable Caption & Google Fonts'), findsOneWidget);
    expect(find.text('Authentic Brat FX & Film Grain'), findsOneWidget);
    expect(find.text('Select Photo & Start ➔'), findsOneWidget);
    expect(find.text('Use Frame with Color Background (No Photo)'), findsOneWidget);

    // Tap "Use Frame with Color Background (No Photo)"
    await tester.tap(find.text('Use Frame with Color Background (No Photo)'));
    await tester.pumpAndSettle();

    expect(proceedCalled, isTrue);
  });
}
