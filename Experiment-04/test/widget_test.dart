import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exp_4/main.dart';

void main() {
  group('Car Mileage Calculator Tests', () {
    testWidgets('Renders AppBar, input fields, and action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const CarMileageCalculatorApp());

      // Verify AppBar title
      expect(find.text('Car Mileage Calculator'), findsOneWidget);

      // Verify Input Fields
      expect(find.byKey(const Key('distance_field')), findsOneWidget);
      expect(find.byKey(const Key('fuel_field')), findsOneWidget);

      // Verify Buttons
      expect(find.byKey(const Key('calculate_button')), findsOneWidget);
      expect(find.byKey(const Key('reset_button')), findsOneWidget);

      // Verify initial placeholder
      expect(find.text('No Calculation Yet'), findsOneWidget);
    });

    testWidgets('Validates empty input fields', (WidgetTester tester) async {
      await tester.pumpWidget(const CarMileageCalculatorApp());

      // Tap Calculate without entering any data
      await tester.tap(find.byKey(const Key('calculate_button')));
      await tester.pumpAndSettle();

      // Expect validation error messages
      expect(find.text('Please enter the distance travelled'), findsOneWidget);
      expect(find.text('Please enter the fuel consumed'), findsOneWidget);

      // Result card should not be displayed
      expect(find.byKey(const Key('result_card')), findsNothing);
    });

    testWidgets('Validates negative values', (WidgetTester tester) async {
      await tester.pumpWidget(const CarMileageCalculatorApp());

      await tester.enterText(find.byKey(const Key('distance_field')), '-100');
      await tester.enterText(find.byKey(const Key('fuel_field')), '-5');

      await tester.tap(find.byKey(const Key('calculate_button')));
      await tester.pumpAndSettle();

      expect(find.text('Distance must be a positive number greater than 0'), findsOneWidget);
      expect(find.text('Fuel consumption must be greater than zero'), findsOneWidget);
      expect(find.byKey(const Key('result_card')), findsNothing);
    });

    testWidgets('Validates zero fuel consumption', (WidgetTester tester) async {
      await tester.pumpWidget(const CarMileageCalculatorApp());

      await tester.enterText(find.byKey(const Key('distance_field')), '150');
      await tester.enterText(find.byKey(const Key('fuel_field')), '0');

      await tester.tap(find.byKey(const Key('calculate_button')));
      await tester.pumpAndSettle();

      expect(find.text('Fuel consumption must be greater than zero'), findsOneWidget);
      expect(find.byKey(const Key('result_card')), findsNothing);
    });

    testWidgets('Calculates mileage correctly: Distance = 150 km, Fuel = 5 L -> 30 km/l', (WidgetTester tester) async {
      await tester.pumpWidget(const CarMileageCalculatorApp());

      // Input 150 km and 5 litres
      await tester.enterText(find.byKey(const Key('distance_field')), '150');
      await tester.enterText(find.byKey(const Key('fuel_field')), '5');

      // Tap Calculate
      await tester.tap(find.byKey(const Key('calculate_button')));
      await tester.pumpAndSettle();

      // Verify Result Card is present
      expect(find.byKey(const Key('result_card')), findsOneWidget);

      // Verify Expected Mileage = 30 km/l
      expect(find.text('30 km/l'), findsOneWidget);
      expect(find.text('CALCULATED MILEAGE'), findsOneWidget);
      expect(find.text('Exceptional Fuel Economy'), findsOneWidget);
    });

    testWidgets('Reset button clears all inputs, errors, and results', (WidgetTester tester) async {
      await tester.pumpWidget(const CarMileageCalculatorApp());

      // Enter data and calculate
      await tester.enterText(find.byKey(const Key('distance_field')), '150');
      await tester.enterText(find.byKey(const Key('fuel_field')), '5');
      await tester.tap(find.byKey(const Key('calculate_button')));
      await tester.pumpAndSettle();

      // Ensure calculation was displayed
      expect(find.byKey(const Key('result_card')), findsOneWidget);

      // Tap Reset button
      await tester.tap(find.byKey(const Key('reset_button')));
      await tester.pumpAndSettle();

      // Check fields are cleared
      expect(find.widgetWithText(TextFormField, '150'), findsNothing);
      expect(find.widgetWithText(TextFormField, '5'), findsNothing);

      // Result card should be cleared and replaced with placeholder
      expect(find.byKey(const Key('result_card')), findsNothing);
      expect(find.text('No Calculation Yet'), findsOneWidget);
    });
  });
}
