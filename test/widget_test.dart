import 'package:brat_generator/models/frame_model.dart';
import 'package:brat_generator/my_app.dart';
import 'package:brat_generator/screens/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verify custom frame layout presets are available for DIY frame creation', () {
    expect(customFrameLayoutPresets.isNotEmpty, true);
    expect(customFrameLayoutPresets.length, 8);

    // Verify key layout structures are present
    final layoutNames = customFrameLayoutPresets.map((f) => f.name).toList();
    expect(layoutNames.contains('Classic Single'), true);
    expect(layoutNames.contains('Polaroid Card'), true);
    expect(layoutNames.contains('Split Duo (H)'), true);
    expect(layoutNames.contains('Split Duo (V)'), true);
    expect(layoutNames.contains('Grid 4 Collage'), true);
  });

  testWidgets('App launches with SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
