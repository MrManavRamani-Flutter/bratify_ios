import 'package:brat_generator/screens/settings/faqs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FAQsScreen renders category chips, search bar, and filters items', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FAQsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FAQs & Guide'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Multi-Photo & Frames'), findsOneWidget);

    // Search for "Undo"
    await tester.enterText(find.byType(TextField), 'Undo');
    await tester.pumpAndSettle();

    expect(find.text('How does the Undo and Redo system work?'), findsOneWidget);

    // Tap on the FAQ to expand answer
    await tester.tap(find.text('How does the Undo and Redo system work?'));
    await tester.pumpAndSettle();

    expect(find.textContaining('remembers up to 25 history steps'), findsOneWidget);
  });
}
