import 'package:flutter_test/flutter_test.dart';
import 'package:exp_1/main.dart';

void main() {
  testWidgets('Fruit list application smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FruitListApp());

    // Verify AppBar title is 'Fruit List'
    expect(find.text('Fruit List'), findsOneWidget);

    // Verify presence of fruits
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('🍎'), findsOneWidget);
    expect(find.text('\$2.99'), findsOneWidget);

    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('🍌'), findsOneWidget);
  });
}

