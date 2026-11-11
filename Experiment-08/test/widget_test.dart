import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exp_8/main.dart';
import 'package:exp_8/models/student.dart';
import 'package:exp_8/firebase_options.dart';

void main() {
  group('Experiment 8 - Student Model & Search Logic Unit Tests', () {
    final sampleStudent = Student(
      id: 'doc-001',
      name: 'Allwyn Noble',
      registerNumber: '23CSE001',
      department: 'CSE (AI)',
      createdAt: DateTime(2026, 11, 11, 10, 0, 0),
    );

    test('Student.toMap creates correct Firestore schema', () {
      final map = sampleStudent.toMap();
      expect(map['name'], 'Allwyn Noble');
      expect(map['register_number'], '23CSE001');
      expect(map['department'], 'CSE (AI)');
      expect(map.containsKey('created_at'), true);
    });

    test('Student.matchesQuery performs case-insensitive name matching', () {
      expect(sampleStudent.matchesQuery('allwyn'), true);
      expect(sampleStudent.matchesQuery('ALLWYN'), true);
      expect(sampleStudent.matchesQuery('noble'), true);
      expect(sampleStudent.matchesQuery('wyn'), true);
    });

    test('Student.matchesQuery performs case-insensitive register number matching', () {
      expect(sampleStudent.matchesQuery('23cse'), true);
      expect(sampleStudent.matchesQuery('23CSE001'), true);
      expect(sampleStudent.matchesQuery('001'), true);
    });

    test('Student.matchesQuery returns false for non-matching queries', () {
      expect(sampleStudent.matchesQuery('John'), false);
      expect(sampleStudent.matchesQuery('9999'), false);
    });

    test('Student.matchesQuery returns true for empty search string', () {
      expect(sampleStudent.matchesQuery(''), true);
      expect(sampleStudent.matchesQuery('   '), true);
    });

    test('DefaultFirebaseOptions reports unconfigured with placeholder keys', () {
      expect(DefaultFirebaseOptions.web.apiKey, 'YOUR_WEB_API_KEY');
      expect(DefaultFirebaseOptions.isConfigured, false);
    });
  });

  group('Experiment 8 - Student Search Widget Tests', () {
    final List<Student> testStudents = [
      Student(
        id: '1',
        name: 'Allwyn Noble',
        registerNumber: '23CSE001',
        department: 'Computer Science & Engineering',
        createdAt: DateTime(2026, 11, 11, 10, 0),
      ),
      Student(
        id: '2',
        name: 'Beatrice Jones',
        registerNumber: '23ECE015',
        department: 'Electronics & Communication',
        createdAt: DateTime(2026, 11, 11, 9, 30),
      ),
      Student(
        id: '3',
        name: 'Charles Xavier',
        registerNumber: '23MECH042',
        department: 'Mechanical Engineering',
        createdAt: DateTime(2026, 11, 11, 9, 0),
      ),
    ];

    testWidgets('UI Test 1: Renders AppBar with title "Student Search"', (tester) async {
      await tester.pumpWidget(const StudentSearchApp(
        isFirebaseInitialized: false,
      ));

      expect(find.text('Student Search'), findsOneWidget);
    });

    testWidgets('UI Test 2: Renders search TextField with search icon and placeholder', (tester) async {
      await tester.pumpWidget(const StudentSearchApp(
        isFirebaseInitialized: false,
      ));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(
        find.text('Search by student name or register number...'),
        findsOneWidget,
      );
    });

    testWidgets('UI Test 3: Displays loading indicator during Stream connection waiting', (tester) async {
      final controller = StreamController<List<Student>>();

      await tester.pumpWidget(StudentSearchApp(
        isFirebaseInitialized: true,
        customStream: controller.stream,
      ));

      // Connection is waiting
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading student records from Firestore...'), findsOneWidget);

      await controller.close();
    });

    testWidgets('UI Test 4: Displays all student records initially when search text is empty', (tester) async {
      final stream = Stream<List<Student>>.value(testStudents);

      await tester.pumpWidget(StudentSearchApp(
        isFirebaseInitialized: true,
        customStream: stream,
      ));
      await tester.pumpAndSettle();

      // All 3 students should be rendered
      expect(find.text('All Students (3)'), findsOneWidget);
      expect(find.text('Allwyn Noble'), findsOneWidget);
      expect(find.text('23CSE001'), findsOneWidget);
      expect(find.text('Computer Science & Engineering'), findsOneWidget);

      expect(find.text('Beatrice Jones'), findsOneWidget);
      expect(find.text('23ECE015'), findsOneWidget);

      expect(find.text('Charles Xavier'), findsOneWidget);
      expect(find.text('23MECH042'), findsOneWidget);
    });

    testWidgets('UI Test 5: Dynamic search by student name filters records', (tester) async {
      final stream = Stream<List<Student>>.value(testStudents);

      await tester.pumpWidget(StudentSearchApp(
        isFirebaseInitialized: true,
        customStream: stream,
      ));
      await tester.pumpAndSettle();

      // Enter search query for "Beatrice"
      await tester.enterText(find.byType(TextField), 'beatrice');
      await tester.pumpAndSettle();

      // Only Beatrice should be visible
      expect(find.text('Beatrice Jones'), findsOneWidget);
      expect(find.text('23ECE015'), findsOneWidget);
      expect(find.text('Allwyn Noble'), findsNothing);
      expect(find.text('Charles Xavier'), findsNothing);
      expect(find.text('Matching Results (1 of 3)'), findsOneWidget);
    });

    testWidgets('UI Test 6: Dynamic search by register number filters records', (tester) async {
      final stream = Stream<List<Student>>.value(testStudents);

      await tester.pumpWidget(StudentSearchApp(
        isFirebaseInitialized: true,
        customStream: stream,
      ));
      await tester.pumpAndSettle();

      // Search by register number "23MECH"
      await tester.enterText(find.byType(TextField), '23MECH');
      await tester.pumpAndSettle();

      // Only Charles Xavier should be visible
      expect(find.text('Charles Xavier'), findsOneWidget);
      expect(find.text('23MECH042'), findsOneWidget);
      expect(find.text('Allwyn Noble'), findsNothing);
      expect(find.text('Beatrice Jones'), findsNothing);
    });

    testWidgets('UI Test 7: Non-existing search query displays "No students found"', (tester) async {
      final stream = Stream<List<Student>>.value(testStudents);

      await tester.pumpWidget(StudentSearchApp(
        isFirebaseInitialized: true,
        customStream: stream,
      ));
      await tester.pumpAndSettle();

      // Search for non-existing student
      await tester.enterText(find.byType(TextField), 'NonExistentStudent123');
      await tester.pumpAndSettle();

      // Prominent "No students found" message must appear
      expect(find.text('No students found'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Clear Search'), findsOneWidget);
    });

    testWidgets('UI Test 8: Clear search button resets search and restores all records', (tester) async {
      final stream = Stream<List<Student>>.value(testStudents);

      await tester.pumpWidget(StudentSearchApp(
        isFirebaseInitialized: true,
        customStream: stream,
      ));
      await tester.pumpAndSettle();

      // Search for "Charles"
      await tester.enterText(find.byType(TextField), 'Charles');
      await tester.pumpAndSettle();
      expect(find.text('Allwyn Noble'), findsNothing);

      // Tap suffix clear icon
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pumpAndSettle();

      // All records should be back
      expect(find.text('All Students (3)'), findsOneWidget);
      expect(find.text('Allwyn Noble'), findsOneWidget);
      expect(find.text('Beatrice Jones'), findsOneWidget);
      expect(find.text('Charles Xavier'), findsOneWidget);
    });

    testWidgets('UI Test 9: Displays friendly error message if Firestore retrieval fails', (tester) async {
      final controller = StreamController<List<Student>>();

      await tester.pumpWidget(StudentSearchApp(
        isFirebaseInitialized: true,
        customStream: controller.stream,
      ));
      await tester.pump();

      // Add error to stream
      controller.addError(Exception('Cloud Firestore permission-denied'));
      await tester.pumpAndSettle();

      expect(find.text('Unable to Retrieve Student Records'), findsOneWidget);
      expect(find.textContaining('permission-denied'), findsOneWidget);

      await controller.close();
    });

    testWidgets('UI Test 10: Displays empty message when Firestore collection is empty', (tester) async {
      final stream = Stream<List<Student>>.value(<Student>[]);

      await tester.pumpWidget(StudentSearchApp(
        isFirebaseInitialized: true,
        customStream: stream,
      ));
      await tester.pumpAndSettle();

      expect(find.text('No Students Found in Firestore'), findsOneWidget);
      expect(find.byIcon(Icons.folder_open_rounded), findsOneWidget);
    });
  });
}
