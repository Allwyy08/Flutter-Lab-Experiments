import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exp_2/main.dart';

void main() {
  testWidgets('ShopEasy App loads with AppBar and ProductCards',
      (WidgetTester tester) async {
    // Set screen size to mobile
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ShopEasyApp());
    await tester.pump();

    // Verify AppBar title 'ShopEasy'
    expect(find.text('ShopEasy'), findsOneWidget);

    // Verify presence of ProductCard widgets
    expect(find.byType(ProductCard), findsWidgets);

    // Verify responsive indicator shows Mobile View
    expect(find.textContaining('Mobile Screen (2 Columns)'), findsOneWidget);

    // Verify initial cart badge is not visible (count 0)
    expect(find.text('0'), findsNothing);

    // Tap first 'Add to Cart' button
    final addToCartButtons = find.widgetWithText(ElevatedButton, 'Add to Cart');
    expect(addToCartButtons, findsWidgets);
    await tester.tap(addToCartButtons.first);
    await tester.pump();

    // Verify cart count badge now shows '1'
    expect(find.text('1'), findsWidgets);

    // Verify SnackBar appears
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Adaptive layout adapts to tablet and desktop screen sizes',
      (WidgetTester tester) async {
    // 1. Test Tablet Screen (width: 800)
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const ShopEasyApp());
    await tester.pump();

    expect(find.textContaining('Tablet Screen (3 Columns)'), findsOneWidget);

    // 2. Test Desktop Screen (width: 1200)
    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpWidget(const ShopEasyApp());
    await tester.pump();

    expect(find.textContaining('Desktop Screen (4 Columns)'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
