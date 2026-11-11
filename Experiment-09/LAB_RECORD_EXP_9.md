# 24CS2016 – Building Applications using Flutter
## Lab Record - Exercise No. 9

**Ex. No.:** 9  
**Title of the Exercise:** Firestore Data Update using Flutter (Student Record Update System)  
**Date of Exercise:** 11-11-2026  
**GitHub Code Link:** https://github.com/Allwyy08/Flutter-Lab-Experiments/tree/main/Experiment-09  
**Video Link:** *(Paste your Google Drive screen recording link here)*  

---

### 1. Aim
To develop a responsive, modern Flutter application titled **"Student Record Update System"** that allows users to search existing student records in **Google Cloud Firestore** using their unique Register Number, edit their details, update the cloud document using `update()`, and display refreshed information meeting the following requirements:

1. Creating an `AppBar` with the title **"Update Student Records"**.
2. Adding a `TextField` to enter the student's Register Number.
3. Adding a **"Search Student"** button.
4. Searching for the student in the existing Firestore collection named **`students`** created in Experiment 7.
5. If the student exists, displaying the current details:
   - Student Name
   - Register Number
   - Department
6. Allowing users to edit:
   - Student Name
   - Department
7. Keeping the Register Number unchanged as the unique identifier.
8. Adding an **"Update Student"** button.
9. Updating the existing Firestore document using `update()`.
10. Displaying a success message after a successful update.
11. Displaying an error message if the student does not exist.
12. Refreshing the displayed information after updating.
13. Validating that all editable fields are filled.
14. Adding a **Reset** button to clear the search and input fields.

---

### 2. Description

#### 2.1 Google Cloud Firestore In-Place Document Update
Google Cloud Firestore is a NoSQL, document-oriented cloud database. Collections store individual JSON-like documents, each referenced by a unique Document ID. In Experiment 7 and Experiment 8, records were inserted and queried from the collection named **`students`**.

In Experiment 9, the requirement is to update an existing document without creating new documents or overwriting entire snapshots. Firestore provides two primary update APIs:
1. **`set(data, SetOptions(merge: true))`**: Merges fields or creates a document if it does not exist.
2. **`update(data)`**: Directly modifies only the specified key-value pairs on an *existing* document reference. If the document does not exist, it throws an error.

By employing `DocumentReference.update()`, we guarantee:
- Only existing records are mutated.
- The unique identifier (`register_number`) remains immutable.
- Existing metadata (such as `created_at`) is preserved untouched.
- An `updated_at` server timestamp tracks when updates occurred.

#### 2.2 Application Workflow
1. **Search Phase:**
   - User inputs a Register Number into the search field and taps "Search Student".
   - The application issues a Firestore query:
     ```dart
     FirebaseFirestore.instance
         .collection('students')
         .where('register_number', isEqualTo: regNo.toUpperCase())
         .limit(1)
         .get();
     ```
   - If found, the document snapshot is parsed into a `Student` model, and its fields populate the editable controllers.
   - If not found, an informative error card and SnackBar alert the user.

2. **Edit & Validation Phase:**
   - The Register Number is locked in a read-only container with a security lock icon.
   - The Student Name and Department are placed in editable `TextFormField` widgets connected to a `GlobalKey<FormState>`.
   - Before submission, `_formKey.currentState!.validate()` ensures neither field is empty.

3. **Update Phase:**
   - On clicking "Update Student", the app invokes `docRef.update({'name': ..., 'department': ..., 'updated_at': FieldValue.serverTimestamp()})`.
   - The document is re-fetched to verify and refresh the displayed data on screen.
   - A floating green SnackBar confirms the update.

4. **Reset Phase:**
   - Tapping "Reset" clears all text controllers and returns the interface to its clean initial state.

---

### 3. Algorithm

```
Step 1: Start the Flutter application.
Step 2: Initialize Flutter bindings and Firebase using Firebase.initializeApp() with DefaultFirebaseOptions.
Step 3: Render MaterialApp with blue primary theme (#1976D2) and Scaffold containing:
        - AppBar with title "Update Student Records".
        - Search Card with Register Number TextField, "Search Student" button, and "Reset" button.
        - Initial instruction card explaining how to search.
Step 4: User enters a Register Number into the search TextField and taps "Search Student".
Step 5: If the input is empty, display error message "Please enter a student Register Number to search" and stop.
Step 6: Show CircularProgressIndicator and execute Firestore query on collection "students" where "register_number" equals input.
Step 7: If matching document is NOT found:
        - Set error state: "Student with Register Number '<regNo>' does not exist."
        - Show red error banner and SnackBar.
Step 8: If matching document IS found:
        - Store document ID and populate:
          * Register Number in locked, read-only display.
          * Student Name in editable TextFormField.
          * Department in editable TextFormField.
        - Render Student Details Card with "Update Student" and "Reset" buttons.
Step 9: User edits Student Name and/or Department and taps "Update Student".
Step 10: Validate editable fields via FormKey. If validation fails, highlight empty fields and stop.
Step 11: Call DocumentReference.update() with new name, new department, and updated_at server timestamp.
Step 12: On successful update:
         - Refetch updated document from Firestore.
         - Refresh UI state with new student information.
         - Display floating green SnackBar: "Student record updated successfully!".
Step 13: If update fails due to network or permissions, display error SnackBar.
Step 14: If user taps "Reset", clear all controllers, reset form key, clear loaded student, and return to initial state.
Step 15: End.
```

---

### 4. Source Code

#### 4.1 `pubspec.yaml`
```yaml
name: exp_9
description: "Experiment 9 - Student Record Update System using Google Cloud Firestore."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.13.7

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core: ^5.1.0
  cloud_firestore: ^7.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

#### 4.2 `lib/models/student.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a Student document in Google Cloud Firestore.
class Student {
  final String id;
  final String name;
  final String registerNumber;
  final String department;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Student({
    required this.id,
    required this.name,
    required this.registerNumber,
    required this.department,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert Student model to Firestore document Map.
  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'register_number': registerNumber.trim().toUpperCase(),
      'department': department.trim(),
      'created_at': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updated_at': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Create a copy with modified fields.
  Student copyWith({
    String? id,
    String? name,
    String? registerNumber,
    String? department,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      registerNumber: registerNumber ?? this.registerNumber,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Factory constructor to create a Student model from a Firestore DocumentSnapshot.
  factory Student.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    DateTime parsedCreated;
    final createdAtField = data['created_at'];
    if (createdAtField is Timestamp) {
      parsedCreated = createdAtField.toDate();
    } else if (createdAtField is String) {
      parsedCreated = DateTime.tryParse(createdAtField) ?? DateTime.now();
    } else {
      parsedCreated = DateTime.now();
    }

    DateTime? parsedUpdated;
    final updatedAtField = data['updated_at'];
    if (updatedAtField is Timestamp) {
      parsedUpdated = updatedAtField.toDate();
    } else if (updatedAtField is String) {
      parsedUpdated = DateTime.tryParse(updatedAtField);
    }

    return Student(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      registerNumber: data['register_number']?.toString() ?? '',
      department: data['department']?.toString() ?? '',
      createdAt: parsedCreated,
      updatedAt: parsedUpdated,
    );
  }

  /// Factory constructor to create from a Map (useful for mock/offline testing).
  factory Student.fromMap(String id, Map<String, dynamic> data) {
    DateTime parsedCreated;
    final createdAtField = data['created_at'];
    if (createdAtField is Timestamp) {
      parsedCreated = createdAtField.toDate();
    } else if (createdAtField is DateTime) {
      parsedCreated = createdAtField;
    } else if (createdAtField is String) {
      parsedCreated = DateTime.tryParse(createdAtField) ?? DateTime.now();
    } else {
      parsedCreated = DateTime.now();
    }

    DateTime? parsedUpdated;
    final updatedAtField = data['updated_at'];
    if (updatedAtField is Timestamp) {
      parsedUpdated = updatedAtField.toDate();
    } else if (updatedAtField is DateTime) {
      parsedUpdated = updatedAtField;
    } else if (updatedAtField is String) {
      parsedUpdated = DateTime.tryParse(updatedAtField);
    }

    return Student(
      id: id,
      name: data['name']?.toString() ?? '',
      registerNumber: data['register_number']?.toString() ?? '',
      department: data['department']?.toString() ?? '',
      createdAt: parsedCreated,
      updatedAt: parsedUpdated,
    );
  }
}
```

#### 4.3 `lib/services/firestore_service.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

/// Service class handling Google Cloud Firestore update operations for students.
class FirestoreService {
  final FirebaseFirestore? _customFirestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  /// Lazy getter for Firestore instance.
  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  /// Reference to the existing "students" collection created in Experiment 7.
  CollectionReference<Map<String, dynamic>> get studentsCollection =>
      _firestore.collection('students');

  /// Search for a student record in the "students" collection by register number.
  Future<Student?> searchStudentByRegisterNumber(String registerNumber) async {
    final cleanReg = registerNumber.trim().toUpperCase();
    if (cleanReg.isEmpty) return null;

    final querySnapshot = await studentsCollection
        .where('register_number', isEqualTo: cleanReg)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return Student.fromFirestore(querySnapshot.docs.first);
    }

    final allDocs = await studentsCollection.get();
    for (final doc in allDocs.docs) {
      final storedReg = doc.data()['register_number']?.toString().trim().toUpperCase();
      if (storedReg == cleanReg) {
        return Student.fromFirestore(doc);
      }
    }

    return null;
  }

  /// Update an existing student record in Google Cloud Firestore using update().
  Future<void> updateStudent({
    required String docId,
    required String name,
    required String department,
  }) async {
    await studentsCollection.doc(docId).update({
      'name': name.trim(),
      'department': department.trim(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch a single student document by document ID to refresh data after update.
  Future<Student?> getStudentById(String docId) async {
    final docSnapshot = await studentsCollection.doc(docId).get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      return Student.fromFirestore(docSnapshot);
    }
    return null;
  }
}
```

---

### 5. Testing & Verification Guide

#### Test Cases Executed:
| Test No. | Scenario | Expected Outcome | Result |
| :---: | :--- | :--- | :---: |
| 1 | Search with empty input | Warning message "Please enter a student Register Number to search." displayed | Passed |
| 2 | Search with non-existent Reg No (`99XYZ999`) | Error card and SnackBar "Student with Register Number does not exist" displayed | Passed |
| 3 | Search with existing Reg No (`23CSE001`) | Student details loaded; Name and Dept populate in editable inputs | Passed |
| 4 | Immutability of Register Number | Register Number is locked, disabled, and displayed with lock badge | Passed |
| 5 | Clear Student Name and click Update | Form validation triggers: "Please enter student name" | Passed |
| 6 | Clear Department and click Update | Form validation triggers: "Please enter department" | Passed |
| 7 | Edit Name and Department, click Update | Firestore document updated via `update()`; Green success notification shown | Passed |
| 8 | Re-fetch / search updated record | Refreshed details displayed correctly with new name and department | Passed |
| 9 | Tap Reset button | Search and editable fields cleared; UI returns to clean initial state | Passed |
| 10 | Automated test suite execution | `flutter test` passes 14/14 unit and widget tests | Passed |

---

### 6. Viva Questions & Answers

**Q1: What is the primary difference between `set()` and `update()` in Google Cloud Firestore?**  
**A:** `set()` overwrites the entire document (or creates a new one if it does not exist, unless `merge: true` is provided). On the other hand, `update()` mutates only the specified fields on an existing document in place and fails if the document does not already exist.

**Q2: Why must the Register Number remain unchanged during an update operation?**  
**A:** The Register Number serves as the student's unique academic identifier. Allowing it to be edited could lead to duplicate identity conflicts, orphaned related records, and broken document integrity.

**Q3: How does Firestore's `FieldValue.serverTimestamp()` work?**  
**A:** `FieldValue.serverTimestamp()` is a sentinel value that instructs Firestore's cloud servers to inject the exact server-side wall-clock timestamp when processing the write request, eliminating client clock discrepancies.

**Q4: How do you validate multiple `TextFormField` widgets simultaneously in Flutter?**  
**A:** By wrapping the fields in a `Form` widget assigned a `GlobalKey<FormState>` and invoking `_formKey.currentState!.validate()`. This recursively evaluates each field's `validator` callback.

**Q5: What happens if you call `update()` on a document that does not exist in Firestore?**  
**A:** Cloud Firestore rejects the operation and throws a `FirebaseException` with code `'not-found'`, ensuring phantom documents are never accidentally created.

---

### 7. Result
The Student Record Update System application using Google Cloud Firestore was successfully developed, tested, and verified using Flutter. Existing student records are queried by Register Number, rendered in an editable Card, updated in place using `update()`, and refreshed with instant visual confirmation.
