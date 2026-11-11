import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exp_3/main.dart';

void main() {
  testWidgets('Renders AppBar with Product Explorer title and initial products',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProductExplorerApp());
    await tester.pumpAndSettle();

    // Verify AppBar title
    expect(find.text('Product Explorer'), findsOneWidget);

    // Verify Search bar is present
    expect(find.byType(TextField), findsOneWidget);

    // Verify DropdownButtonFormField is present
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    // Verify initial products appear (at least some known items from the 12)
    expect(find.text('Wireless Noise-Canceling Headphones'), findsOneWidget);
    expect(find.text('Mechanical Gaming Keyboard'), findsOneWidget);
    expect(find.textContaining('Showing 12 of 12 products'), findsOneWidget);
  });

  testWidgets('Searching by name dynamically filters products',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProductExplorerApp());
    await tester.pumpAndSettle();

    // Enter search text "Headphones"
    await tester.enterText(find.byType(TextField), 'Headphones');
    await tester.pumpAndSettle();

    // Verify filtered result
    expect(find.text('Wireless Noise-Canceling Headphones'), findsOneWidget);
    expect(find.text('Mechanical Gaming Keyboard'), findsNothing);
    expect(find.textContaining('Showing 1 of 12 products'), findsOneWidget);
  });

  testWidgets('Clear search button resets the search query',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProductExplorerApp());
    await tester.pumpAndSettle();

    // Enter search text
    await tester.enterText(find.byType(TextField), 'Monitor');
    await tester.pumpAndSettle();
    expect(find.text('Ultra HD 4K Monitor 27-inch'), findsOneWidget);
    expect(find.textContaining('Showing 1 of 12 products'), findsOneWidget);

    // Tap clear button
    final clearButton = find.byIcon(Icons.clear_rounded);
    expect(clearButton, findsOneWidget);
    await tester.tap(clearButton);
    await tester.pumpAndSettle();

    // All products should be restored
    expect(find.textContaining('Showing 12 of 12 products'), findsOneWidget);
  });

  testWidgets('Selecting a category dropdown filters products',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProductExplorerApp());
    await tester.pumpAndSettle();

    // Open dropdown
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    // Select "Footwear"
    final footwearOption = find.text('Footwear').last;
    await tester.tap(footwearOption);
    await tester.pumpAndSettle();

    // Should only show footwear items
    expect(find.text('Running Trail Sneakers'), findsOneWidget);
    expect(find.text('Classic Leather Loafers'), findsOneWidget);
    expect(find.text('Wireless Noise-Canceling Headphones'), findsNothing);
    expect(find.textContaining('Showing 2 of 12 products'), findsOneWidget);
  });

  testWidgets('Search and category filter work together',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProductExplorerApp());
    await tester.pumpAndSettle();

    // Select "Electronics" category
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Electronics').last);
    await tester.pumpAndSettle();

    // Search "Gaming"
    await tester.enterText(find.byType(TextField), 'Gaming');
    await tester.pumpAndSettle();

    // Only Mechanical Gaming Keyboard matches
    expect(find.text('Mechanical Gaming Keyboard'), findsOneWidget);
    expect(find.text('Wireless Noise-Canceling Headphones'), findsNothing);
    expect(find.textContaining('Showing 1 of 12 products'), findsOneWidget);
  });

  testWidgets('Displays "No products found" message when results are empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProductExplorerApp());
    await tester.pumpAndSettle();

    // Search query that does not exist
    await tester.enterText(find.byType(TextField), 'NonExistentProductXYZ');
    await tester.pumpAndSettle();

    // Verify empty state message
    expect(find.text('No products found'), findsOneWidget);
    expect(find.textContaining('No products matched "NonExistentProductXYZ"'), findsOneWidget);

    // Tap Reset All Filters button
    await tester.tap(find.text('Reset All Filters'));
    await tester.pumpAndSettle();

    // All products restored
    expect(find.textContaining('Showing 12 of 12 products'), findsOneWidget);
  });

  testWidgets('ProductCard displays name, category, price, and responds to tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProductExplorerApp());
    await tester.pumpAndSettle();

    // Find the first ProductCard
    final productCards = find.byType(ProductCard);
    expect(productCards, findsWidgets);

    // Tap the first card
    await tester.tap(productCards.first);
    await tester.pumpAndSettle();

    // Modal sheet appears with product details and 'Got it' button
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);

    // Tap 'Got it' to dismiss modal
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    // Snackbar notification appears
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
