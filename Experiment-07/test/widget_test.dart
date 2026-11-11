import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exp_7/main.dart';
import 'package:exp_7/models/student.dart';
import 'package:exp_7/firebase_options.dart';

void main() {
  group('Experiment 7 - Firestore Student Records Unit & Widget Tests', () {
    test('Student Model - toMap produces correct Firestore fields', () {
      final student = Student(
        id: 'test-doc-id',
        name: 'Allwyn',
        registerNumber: '23CSE001',
        department: 'CSE (AI)',
        createdAt: DateTime(2026, 11, 11, 10, 0, 0),
      );

      final map = student.toMap();

      expect(map['name'], 'Allwyn');
      expect(map['register_number'], '23CSE001');
      expect(map['department'], 'CSE (AI)');
      expect(map.containsKey('created_at'), true);
    });

    test('DefaultFirebaseOptions - reports unconfigured when placeholders present', () {
      expect(DefaultFirebaseOptions.web.apiKey, 'YOUR_WEB_API_KEY');
      expect(DefaultFirebaseOptions.isConfigured, false);
    });

    testWidgets('UI Test 1: Renders AppBar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const StudentRecordsApp(
        isFirebaseInitialized: false,
      ));

      expect(find.text('Firestore Student Records'), findsOneWidget);
    });

    testWidgets('UI Test 2: Renders three input fields with labels and icons', (WidgetTester tester) async {
      await tester.pumpWidget(const StudentRecordsApp(
        isFirebaseInitialized: false,
      ));

      expect(find.text('Student Name *'), findsOneWidget);
      expect(find.text('Register Number *'), findsOneWidget);
      expect(find.text('Department *'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
    });

    testWidgets('UI Test 3: Renders Save Student button', (WidgetTester tester) async {
      await tester.pumpWidget(const StudentRecordsApp(
        isFirebaseInitialized: false,
      ));

      expect(find.text('Save Student'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    });

    testWidgets('UI Test 4: Form validation displays errors when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(const StudentRecordsApp(
        isFirebaseInitialized: false,
      ));

      // Tap Save Student without entering details
      await tester.tap(find.text('Save Student'));
      await tester.pumpAndSettle();

      // Form validation errors should appear
      expect(find.text('Please enter student name'), findsOneWidget);
      expect(find.text('Please enter register number'), findsOneWidget);
      expect(find.text('Please enter department'), findsOneWidget);
    });

    testWidgets('UI Test 5: Entering valid values passes form validation', (WidgetTester tester) async {
      await tester.pumpWidget(const StudentRecordsApp(
        isFirebaseInitialized: false,
      ));

      // Enter student details
      final nameField = find.widgetWithText(TextFormField, 'Student Name *');
      final regNoField = find.widgetWithText(TextFormField, 'Register Number *');
      final deptField = find.widgetWithText(TextFormField, 'Department *');

      await tester.enterText(nameField, 'Allwyn');
      await tester.enterText(regNoField, '23CSE001');
      await tester.enterText(deptField, 'CSE (AI)');

      await tester.tap(find.text('Save Student'));
      await tester.pumpAndSettle();

      // Form validation errors must NOT appear
      expect(find.text('Please enter student name'), findsNothing);
      expect(find.text('Please enter register number'), findsNothing);
      expect(find.text('Please enter department'), findsNothing);
    });

    testWidgets('UI Test 6: Shows guidance dialog when saving without Firebase initialization', (WidgetTester tester) async {
      await tester.pumpWidget(const StudentRecordsApp(
        isFirebaseInitialized: false,
      ));

      // Enter valid student details
      await tester.enterText(find.widgetWithText(TextFormField, 'Student Name *'), 'Allwyn');
      await tester.enterText(find.widgetWithText(TextFormField, 'Register Number *'), '23CSE001');
      await tester.enterText(find.widgetWithText(TextFormField, 'Department *'), 'CSE (AI)');

      // Tap Save Student
      await tester.tap(find.text('Save Student'));
      await tester.pumpAndSettle();

      // Dialog explaining setup should appear
      expect(find.text('Firebase Setup Required'), findsWidgets);
      expect(find.text('OK'), findsOneWidget);
    });
  });
}
