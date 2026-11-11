import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exp_5/main.dart';

void main() {
  group('Personal Budget Calculator Tests', () {
    testWidgets('Renders AppBar, input fields, and action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const PersonalBudgetCalculatorApp());

      // Verify AppBar title
      expect(find.text('Personal Budget Calculator'), findsOneWidget);

      // Verify Input Fields
      expect(find.byKey(const Key('income_field')), findsOneWidget);
      expect(find.byKey(const Key('expenses_field')), findsOneWidget);

      // Verify Buttons
      expect(find.byKey(const Key('calculate_button')), findsOneWidget);
      expect(find.byKey(const Key('reset_button')), findsOneWidget);

      // Verify initial placeholder
      expect(find.byKey(const Key('placeholder_card')), findsOneWidget);
      expect(find.text('No Budget Calculated Yet'), findsOneWidget);
    });

    testWidgets('Validates empty input fields', (WidgetTester tester) async {
      await tester.pumpWidget(const PersonalBudgetCalculatorApp());

      // Tap Calculate without entering any data
      await tester.tap(find.byKey(const Key('calculate_button')));
      await tester.pumpAndSettle();

      // Expect validation error messages
      expect(find.text('Please enter your monthly income'), findsOneWidget);
      expect(find.text('Please enter your monthly expenses'), findsOneWidget);

      // Result cards should not be displayed
      expect(find.byKey(const Key('status_card')), findsNothing);
      expect(find.byKey(const Key('balance_card')), findsNothing);
    });

    testWidgets('Validates negative input values', (WidgetTester tester) async {
      await tester.pumpWidget(const PersonalBudgetCalculatorApp());

      await tester.enterText(find.byKey(const Key('income_field')), '-30000');
      await tester.enterText(find.byKey(const Key('expenses_field')), '-18000');

      await tester.tap(find.byKey(const Key('calculate_button')));
      await tester.pumpAndSettle();

      expect(find.text('Income must be a valid non-negative number (>= 0)'), findsOneWidget);
      expect(find.text('Expenses must be a valid non-negative number (>= 0)'), findsOneWidget);
      expect(find.byKey(const Key('status_card')), findsNothing);
    });

    testWidgets('Calculates savings correctly: Income = 30000, Expenses = 18000 -> Balance = 12000', (WidgetTester tester) async {
      await tester.pumpWidget(const PersonalBudgetCalculatorApp());

      // Input 30000 income and 18000 expenses
      await tester.enterText(find.byKey(const Key('income_field')), '30000');
      await tester.enterText(find.byKey(const Key('expenses_field')), '18000');

      // Tap Calculate
      await tester.tap(find.byKey(const Key('calculate_button')));
      await tester.pumpAndSettle();

      // Verify Result Cards are present
      expect(find.byKey(const Key('status_card')), findsOneWidget);
      expect(find.byKey(const Key('balance_card')), findsOneWidget);
      expect(find.byKey(const Key('income_card')), findsOneWidget);
      expect(find.byKey(const Key('expenses_card')), findsOneWidget);

      // Verify Status message
      expect(find.text('Good! You have savings.'), findsOneWidget);

      // Verify Balance value
      expect(find.byKey(const Key('remaining_balance_text')), findsOneWidget);
      expect(find.text('12000'), findsOneWidget);
      expect(find.byKey(const Key('income_value_text')), findsOneWidget);
      expect(find.byKey(const Key('expenses_value_text')), findsOneWidget);
      expect(find.text('₹ 30000'), findsOneWidget);
      expect(find.text('₹ 18000'), findsOneWidget);
    });

    testWidgets('Calculates balanced budget correctly: Income = 25000, Expenses = 25000 -> Balance = 0', (WidgetTester tester) async {
      await tester.pumpWidget(const PersonalBudgetCalculatorApp());

      await tester.enterText(find.byKey(const Key('income_field')), '25000');
      await tester.enterText(find.byKey(const Key('expenses_field')), '25000');

      await tester.tap(find.byKey(const Key('calculate_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('status_card')), findsOneWidget);
      expect(find.text('Your budget is balanced.'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Calculates overspending correctly: Income = 20000, Expenses = 25000 -> Balance = -5000', (WidgetTester tester) async {
      await tester.pumpWidget(const PersonalBudgetCalculatorApp());

      await tester.enterText(find.byKey(const Key('income_field')), '20000');
      await tester.enterText(find.byKey(const Key('expenses_field')), '25000');

      await tester.tap(find.byKey(const Key('calculate_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('status_card')), findsOneWidget);
      expect(find.text('Warning! You are overspending.'), findsOneWidget);
      expect(find.text('5000'), findsOneWidget);
    });

    testWidgets('Reset button clears all inputs, errors, and results', (WidgetTester tester) async {
      await tester.pumpWidget(const PersonalBudgetCalculatorApp());

      // Enter data and calculate
      await tester.enterText(find.byKey(const Key('income_field')), '30000');
      await tester.enterText(find.byKey(const Key('expenses_field')), '18000');
      await tester.tap(find.byKey(const Key('calculate_button')));
      await tester.pumpAndSettle();

      // Ensure calculation was displayed
      expect(find.byKey(const Key('status_card')), findsOneWidget);

      // Tap Reset button
      await tester.tap(find.byKey(const Key('reset_button')));
      await tester.pumpAndSettle();

      // Check fields are cleared
      expect(find.widgetWithText(TextFormField, '30000'), findsNothing);
      expect(find.widgetWithText(TextFormField, '18000'), findsNothing);

      // Result cards should be cleared and replaced with placeholder
      expect(find.byKey(const Key('status_card')), findsNothing);
      expect(find.byKey(const Key('balance_card')), findsNothing);
      expect(find.byKey(const Key('placeholder_card')), findsOneWidget);
      expect(find.text('No Budget Calculated Yet'), findsOneWidget);
    });
  });
}
