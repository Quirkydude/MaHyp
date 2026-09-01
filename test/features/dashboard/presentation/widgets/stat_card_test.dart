import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahyp_app/features/dashboard/presentation/widgets/stat_card.dart';

void main() {
  testWidgets('StatCard renders correctly with provided data', (
    WidgetTester tester,
  ) async {
    bool wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatCard(
            type: StatCardType.bp,
            title: 'Test BP',
            value: '120/80',
            subtitle: 'Today',
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      ),
    );

    // Verify correct texts are displayed
    expect(find.text('Test BP'), findsOneWidget);
    expect(find.text('120/80'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);

    // Tap the card and verify callback
    await tester.tap(find.byType(StatCard));
    await tester.pumpAndSettle();

    expect(wasTapped, isTrue);
  });
}
