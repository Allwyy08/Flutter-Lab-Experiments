import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exp_9/main.dart';
import 'package:exp_9/models/student.dart';
import 'package:exp_9/services/firestore_service.dart';
import 'package:exp_9/firebase_options.dart';

/// Test mock implementation of FirestoreService for automated unit and widget testing
class MockFirestoreService extends FirestoreService {
  final Map<String, Student> _store = {};

  MockFirestoreService({List<Student>? initialStudents}) {
    if (initialStudents != null) {
      for (final s in initialStudents) {
        _store[s.id] = s;
      }
    }
  }

  @override
  Future<Student?> searchStudentByRegisterNumber(String registerNumber) async {
    final cleanReg = registerNumber.trim().toUpperCase();
    for (final s in _store.values) {
      if (s.registerNumber.toUpperCase() == cleanReg) {
        return s;
      }
    }
    return null;
  }

  @override
  Future<void> updateStudent({
    required String docId,
    required String name,
    required String department,
  }) async {
    final existing = _store[docId];
    if (existing == null) {
      throw Exception('Document $docId not found in mock store');
    }
    _store[docId] = existing.copyWith(
      name: name.trim(),
      department: department.trim(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Student?> getStudentById(String docId) async {
    return _store[docId];
  }
}

void main() {
  group('Experiment 9 - Student Model Unit Tests', () {
    final sampleStudent = Student(
      id: 'doc-001',
      name: 'Allwyn Noble',
      registerNumber: '23CSE001',
      department: 'Computer Science and Engineering',
      createdAt: DateTime(2026, 11, 11, 10, 0, 0),
    );

    test('Student.toMap creates correct Firestore schema', () {
      final map = sampleStudent.toMap();
      expect(map['name'], 'Allwyn Noble');
      expect(map['register_number'], '23CSE001');
      expect(map['department'], 'Computer Science and Engineering');
      expect(map.containsKey('created_at'), true);
    });

    test('Student.fromMap parses properties accurately', () {
      final parsed = Student.fromMap('doc-002', {
        'name': 'Bob Ross',
        'register_number': '23ART005',
        'department': 'Fine Arts',
        'created_at': DateTime(2026, 11, 11, 9, 30),
      });

      expect(parsed.id, 'doc-002');
      expect(parsed.name, 'Bob Ross');
      expect(parsed.registerNumber, '23ART005');
      expect(parsed.department, 'Fine Arts');
    });

    test('Student.copyWith creates updated copy with new values', () {
      final updated = sampleStudent.copyWith(
        name: 'Allwyn N.',
        department: 'Artificial Intelligence & Data Science',
      );

      expect(updated.id, 'doc-001');
      expect(updated.name, 'Allwyn N.');
      expect(updated.registerNumber, '23CSE001'); // registerNumber unchanged
      expect(updated.department, 'Artificial Intelligence & Data Science');
    });

    test('DefaultFirebaseOptions isConfigured checks placeholder values', () {
      expect(DefaultFirebaseOptions.web.apiKey, 'YOUR_WEB_API_KEY');
      expect(DefaultFirebaseOptions.isConfigured, false);
    });
  });

  group('Experiment 9 - Update Student Records Widget Tests', () {
    late MockFirestoreService mockService;
    late List<Student> testStudents;

    setUp(() {
      testStudents = [
        Student(
          id: 'doc-101',
          name: 'John Doe',
          registerNumber: '23CSE001',
          department: 'Computer Science',
          createdAt: DateTime(2026, 11, 11, 9, 0),
        ),
        Student(
          id: 'doc-102',
          name: 'Jane Smith',
          registerNumber: '23ECE015',
          department: 'Electronics',
          createdAt: DateTime(2026, 11, 11, 10, 0),
        ),
      ];

      mockService = MockFirestoreService(initialStudents: testStudents);
    });

    testWidgets('UI Test 1: Renders AppBar with title "Update Student Records"',
        (tester) async {
      await tester.pumpWidget(StudentUpdateApp(
        isFirebaseInitialized: false,
        firestoreService: mockService,
      ));

      expect(find.text('Update Student Records'), findsOneWidget);
    });

    testWidgets('UI Test 2: Renders Register Number TextField & Buttons',
        (tester) async {
      await tester.pumpWidget(StudentUpdateApp(
        isFirebaseInitialized: false,
        firestoreService: mockService,
      ));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search Student'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('UI Test 3: Renders initial guide placeholder card',
        (tester) async {
      await tester.pumpWidget(StudentUpdateApp(
        isFirebaseInitialized: false,
        firestoreService: mockService,
      ));

      expect(find.text('Update Student Record'), findsOneWidget);
      expect(find.byIcon(Icons.manage_search_rounded), findsOneWidget);
    });

    testWidgets('UI Test 4: Empty search input triggers validation error',
        (tester) async {
      await tester.pumpWidget(StudentUpdateApp(
        isFirebaseInitialized: false,
        firestoreService: mockService,
      ));

      // Click Search Student without typing anything
      await tester.tap(find.text('Search Student'));
      await tester.pump();

      expect(
        find.text('Please enter a student Register Number to search.'),
        findsWidgets,
      );
    });

    testWidgets('UI Test 5: Search non-existing student displays error message',
        (tester) async {
      await tester.pumpWidget(StudentUpdateApp(
        isFirebaseInitialized: false,
        firestoreService: mockService,
      ));

      // Enter non-existing register number
      await tester.enterText(find.byType(TextField), '99XYZ999');
      await tester.tap(find.text('Search Student'));
      await tester.pumpAndSettle();

      expect(
        find.text('Student with Register Number "99XYZ999" does not exist.'),
        findsOneWidget,
      );
    });

    testWidgets('UI Test 6: Search existing student displays details card',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(StudentUpdateApp(
        isFirebaseInitialized: false,
        firestoreService: mockService,
      ));

      // Enter existing register number
      await tester.enterText(find.byType(TextField), '23CSE001');
      await tester.tap(find.text('Search Student'));
      await tester.pumpAndSettle();

      // Verify Student Details Card appears
      expect(find.text('Student Details'), findsOneWidget);
      expect(find.text('23CSE001'), findsNWidgets(2)); // in search field and details card
      expect(find.text('Unchanged'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Computer Science'), findsOneWidget);
      expect(find.text('Update Student'), findsOneWidget);
    });

    testWidgets(
        'UI Test 7: Register Number is displayed as locked/non-editable',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(StudentUpdateApp(
        isFirebaseInitialized: false,
        firestoreService: mockService,
      ));

      await tester.enterText(find.byType(TextField), '23CSE001');
      await tester.tap(find.text('Search Student'));
      await tester.pumpAndSettle();

      // Register number should have the lock icon and Unchanged label
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.text('Unchanged'), findsOneWidget);
    });

    testWidgets(
        'UI Test 8: Empty editable fields validation prevents update',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(StudentUpdateApp(
        isFirebaseInitialized: false,
        firestoreService: mockService,
      ));

      await tester.enterText(find.byType(TextField), '23CSE001');
      await tester.tap(find.text('Search Student'));
      await tester.pumpAndSettle();

      // Clear student name
      final textFormFields = find.byType(TextFormField);
      expect(textFormFields, findsNWidgets(2)); // Name and Dept

      await tester.enterText(textFormFields.at(0), ''); // clear name
      await tester.tap(find.text('Update Student'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter student name'), findsOneWidget);
    });

    testWidgets(
        'UI Test 9: Update student modifies record and shows success message',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(StudentUpdateApp(
        isFirebaseInitialized: false,
        firestoreService: mockService,
      ));

      // Search existing record
      await tester.enterText(find.byType(TextField), '23CSE001');
      await tester.tap(find.text('Search Student'));
      await tester.pumpAndSettle();

      // Edit Name and Department
      final textFormFields = find.byType(TextFormField);
      await tester.enterText(textFormFields.at(0), 'Johnathon Doe');
      await tester.enterText(
          textFormFields.at(1), 'Computer Science & AI');

      // Click Update Student
      await tester.tap(find.text('Update Student'));
      await tester.pumpAndSettle();

      // Success message should appear
      expect(
        find.text(
            'Student record updated successfully in Google Cloud Firestore!'),
        findsOneWidget,
      );

      // Verify that mock store was updated
      final updatedInStore = await mockService.getStudentById('doc-101');
      expect(updatedInStore?.name, 'Johnathon Doe');
      expect(updatedInStore?.department, 'Computer Science & AI');
      expect(updatedInStore?.registerNumber, '23CSE001');
    });

    testWidgets(
        'UI Test 10: Reset button clears search input, editable form, and state',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(StudentUpdateApp(
        isFirebaseInitialized: false,
        firestoreService: mockService,
      ));

      // Search student
      await tester.enterText(find.byType(TextField), '23CSE001');
      await tester.tap(find.text('Search Student'));
      await tester.pumpAndSettle();

      expect(find.text('Student Details'), findsOneWidget);

      // Tap Reset button in search card
      final resetButtons = find.text('Reset');
      await tester.tap(resetButtons.first);
      await tester.pumpAndSettle();

      // Search field should be empty, Student Details Card should be gone, placeholder should be back
      expect(find.text('Search and input fields have been reset.'), findsOneWidget);
      expect(find.text('Update Student Record'), findsOneWidget);
      expect(find.text('Student Details'), findsNothing);
    });
  });
}
