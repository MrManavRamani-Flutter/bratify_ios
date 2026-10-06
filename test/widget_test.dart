import 'package:brat_generator/models/frame_model.dart';
import 'package:brat_generator/my_app.dart';
import 'package:brat_generator/screens/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verify 500 predefined frames across 10 categories (50 each)', () {
    expect(predefined500Frames.length, 500);

    final Map<String, int> categoryCounts = {};
    for (final frame in predefined500Frames) {
      categoryCounts[frame.category] = (categoryCounts[frame.category] ?? 0) + 1;
    }

    expect(categoryCounts.keys.length, 10);
    for (final entry in categoryCounts.entries) {
      expect(
        entry.value,
        50,
        reason: 'Category "${entry.key}" should have exactly 50 templates',
      );
    }
  });

  testWidgets('App launches with SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
