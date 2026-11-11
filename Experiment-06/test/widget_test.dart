import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:exp_6/database_helper.dart';
import 'package:exp_6/main.dart';

void main() {
  setUpAll(() {
    // Initialize FFI for running SQLite in the test environment on Windows
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Reset database table before each test to ensure clean test isolation
    final db = await DatabaseHelper.instance.database;
    await db.delete('students');
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
  });

  /// Helper to let real async SQLite I/O operations finish,
  /// then pump the widget tree to reflect state changes.
  Future<void> pumpRealAsync(WidgetTester tester, [int millis = 200]) async {
    await tester.runAsync(() async {
      await Future.delayed(Duration(milliseconds: millis));
    });
    await tester.pump();
  }

  /// Helper to tap Save Student and wait for both async phases (insert and query refresh)
  Future<void> tapSaveAndPump(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Student'));
    await tester.pump();
    await pumpRealAsync(tester, 200);
    await pumpRealAsync(tester, 200);
  }

  group('DatabaseHelper SQLite Unit Tests', () {
    test('insertStudent() and getStudents() CREATE and READ operations', () async {
      // 1. Verify initially empty
      final initialStudents = await DatabaseHelper.instance.getStudents();
      expect(initialStudents, isEmpty);

      // 2. Insert first student (Allwyn, 23CSE001, CSE (AI))
      final id1 = await DatabaseHelper.instance.insertStudent({
        'name': 'Allwyn',
        'register_number': '23CSE001',
        'department': 'CSE (AI)',
      });
      expect(id1, greaterThan(0));

      // 3. Read back and verify
      final recordsAfterFirst = await DatabaseHelper.instance.getStudents();
      expect(recordsAfterFirst.length, 1);
      expect(recordsAfterFirst.first['name'], 'Allwyn');
      expect(recordsAfterFirst.first['register_number'], '23CSE001');
      expect(recordsAfterFirst.first['department'], 'CSE (AI)');

      // 4. Insert second student
      final id2 = await DatabaseHelper.instance.insertStudent({
        'name': 'Grace Hopper',
        'register_number': '23CSE002',
        'department': 'Information Technology',
      });
      expect(id2, greaterThan(id1));

      // 5. Read back and verify both records persist in order (newest first)
      final recordsAfterSecond = await DatabaseHelper.instance.getStudents();
      expect(recordsAfterSecond.length, 2);
      expect(recordsAfterSecond[0]['name'], 'Grace Hopper');
      expect(recordsAfterSecond[1]['name'], 'Allwyn');
    });
  });

  group('Student Records UI & SQLite Integration Tests', () {
    testWidgets('Renders AppBar, input fields, save button, and empty state',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const StudentRecordsApp());
      await pumpRealAsync(tester);

      // Verify AppBar title
      expect(find.text('Student Records'), findsOneWidget);

      // Verify Input Fields
      expect(find.widgetWithText(TextFormField, 'Student Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Register Number'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Department'), findsOneWidget);

      // Verify Save Button
      expect(find.widgetWithText(ElevatedButton, 'Save Student'), findsOneWidget);

      // Verify Empty State when no records exist
      expect(find.text('No student records available.'), findsOneWidget);
      expect(find.text('0 Records'), findsOneWidget);
    });

    testWidgets('Validates that all input fields are filled before saving',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const StudentRecordsApp());
      await pumpRealAsync(tester);

      // Tap Save Student without entering any values
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Student'));
      await tester.pump();

      // Verify validation error messages are displayed
      expect(find.text('Please enter student name'), findsOneWidget);
      expect(find.text('Please enter register number'), findsOneWidget);
      expect(find.text('Please enter department'), findsOneWidget);

      // Verify no records were added
      expect(find.text('No student records available.'), findsOneWidget);
    });

    testWidgets('Validates whitespace-only input fields are rejected',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const StudentRecordsApp());
      await pumpRealAsync(tester);

      final nameField = find.widgetWithText(TextFormField, 'Student Name');
      final regNoField = find.widgetWithText(TextFormField, 'Register Number');
      final deptField = find.widgetWithText(TextFormField, 'Department');

      await tester.enterText(nameField, '   ');
      await tester.enterText(regNoField, '   ');
      await tester.enterText(deptField, '   ');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Student'));
      await tester.pump();

      expect(find.text('Please enter student name'), findsOneWidget);
      expect(find.text('Please enter register number'), findsOneWidget);
      expect(find.text('Please enter department'), findsOneWidget);
    });

    testWidgets(
        'Step 1-3: Enter Allwyn, 23CSE001, CSE (AI) -> Save -> Record appears in list & SnackBar shown',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const StudentRecordsApp());
      await pumpRealAsync(tester);

      // Enter student details
      final nameField = find.widgetWithText(TextFormField, 'Student Name');
      final regNoField = find.widgetWithText(TextFormField, 'Register Number');
      final deptField = find.widgetWithText(TextFormField, 'Department');

      await tester.enterText(nameField, 'Allwyn');
      await tester.enterText(regNoField, '23CSE001');
      await tester.enterText(deptField, 'CSE (AI)');

      // Tap Save Student and wait for insertion + list refresh
      await tapSaveAndPump(tester);

      // Verify success message in SnackBar
      expect(find.text('Student record saved successfully!'), findsOneWidget);

      // Verify record appears in the list
      expect(find.text('Allwyn'), findsOneWidget);
      expect(find.text('Register No: 23CSE001'), findsOneWidget);
      expect(find.text('Department: CSE (AI)'), findsOneWidget);
      expect(find.text('1 Record'), findsOneWidget);
    });

    testWidgets('Step 4: Add another student and verify both records appear',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const StudentRecordsApp());
      await pumpRealAsync(tester);

      final nameField = find.widgetWithText(TextFormField, 'Student Name');
      final regNoField = find.widgetWithText(TextFormField, 'Register Number');
      final deptField = find.widgetWithText(TextFormField, 'Department');

      // 1. Insert first student (Allwyn)
      await tester.enterText(nameField, 'Allwyn');
      await tester.enterText(regNoField, '23CSE001');
      await tester.enterText(deptField, 'CSE (AI)');
      await tapSaveAndPump(tester);

      // 2. Insert second student (Jane Doe)
      await tester.enterText(nameField, 'Jane Doe');
      await tester.enterText(regNoField, '23CSE002');
      await tester.enterText(deptField, 'Information Technology');
      await tapSaveAndPump(tester);

      // Verify both records appear in the ListView
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('Register No: 23CSE002'), findsOneWidget);
      expect(find.text('Department: Information Technology'), findsOneWidget);

      expect(find.text('Allwyn'), findsOneWidget);
      expect(find.text('Register No: 23CSE001'), findsOneWidget);
      expect(find.text('Department: CSE (AI)'), findsOneWidget);

      expect(find.text('2 Records'), findsOneWidget);
    });

    testWidgets(
        'Step 5-6: Persistence: Close and reopen app -> verify previously saved records are still displayed',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Step 1: Open app and save a record
      await tester.pumpWidget(const StudentRecordsApp());
      await pumpRealAsync(tester);

      final nameField = find.widgetWithText(TextFormField, 'Student Name');
      final regNoField = find.widgetWithText(TextFormField, 'Register Number');
      final deptField = find.widgetWithText(TextFormField, 'Department');

      await tester.enterText(nameField, 'Allwyn');
      await tester.enterText(regNoField, '23CSE001');
      await tester.enterText(deptField, 'CSE (AI)');
      await tapSaveAndPump(tester);

      expect(find.text('Allwyn'), findsOneWidget);

      // Step 2: "Close" the application
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('App Closed'))));
      await tester.pump();
      expect(find.text('App Closed'), findsOneWidget);
      expect(find.text('Allwyn'), findsNothing);

      // Step 3: "Reopen" the application
      await tester.pumpWidget(const StudentRecordsApp());
      await pumpRealAsync(tester);

      // Verify that previously saved SQLite records are still loaded and displayed
      expect(find.text('Allwyn'), findsOneWidget);
      expect(find.text('Register No: 23CSE001'), findsOneWidget);
      expect(find.text('Department: CSE (AI)'), findsOneWidget);
      expect(find.text('1 Record'), findsOneWidget);
    });
  });
}
