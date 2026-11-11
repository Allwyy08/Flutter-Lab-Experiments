# 24CS2016 – Building Applications using Flutter
## Lab Record - Exercise No. 8

**Ex. No.:** 8  
**Title of the Exercise:** Firestore Data Retrieval using Flutter (Student Search Application)  
**Date of Exercise:** 11-11-2026  
**GitHub Code Link:** https://github.com/Allwyy08/Flutter-Lab-Experiments/tree/main/Experiment-08  
**Video Link:** *(Paste your Google Drive screen recording link here)*  

---

### 1. Aim
To develop a responsive, modern Flutter application titled **"Student Search Application"** that retrieves student information dynamically from **Google Cloud Firestore** based on user search input, meeting the following requirements:
1. Creating an `AppBar` with the title **"Student Search"**.
2. Adding a `TextField` search bar.
3. Allowing users to search students using:
   - **Student Name**
   - **Register Number**
4. Retrieving student records from the existing Firestore collection named **`students`** created in Experiment 7.
5. Displaying matching student records dynamically.
6. Displaying each result with:
   - **Student Name**
   - **Register Number**
   - **Department**
7. Displaying all student records initially when the search field is empty.
8. Updating search results whenever the user enters or changes search text.
9. Displaying **"No students found"** if there are no matching records.
10. Adding a clear search button to reset the search.
11. Displaying a loading indicator while retrieving data.
12. Displaying a friendly error message if Firestore retrieval fails.

---

### 2. Description

#### 2.1 Google Cloud Firestore Cloud Database Retrieval
Google Cloud Firestore is a scalable NoSQL cloud database that organizes data into documents and collections. In Experiment 7, a persistent cloud collection named **`students`** was created to store student records with the following schema:
- `name`: Student full name (`String`)
- `register_number`: Unique registration number (`String`)
- `department`: Academic department / branch (`String`)
- `created_at`: Cloud server timestamp (`Timestamp`)

In Experiment 8, the focus shifts to efficient data retrieval, querying, and real-time presentation. Data is fetched using Flutter's official **`firebase_core`** and **`cloud_firestore`** packages.

#### 2.2 Search & Querying Strategy
Firestore native queries offer prefix queries (such as `isGreaterThanOrEqualTo` and `isLessThanOrEqualTo`), but they possess important limitations:
1. Firestore queries are strictly case-sensitive.
2. Firestore does not support arbitrary substring/contains searches across multiple independent fields simultaneously without third-party indexing engines (like Algolia or Typesense).

To deliver a seamless, responsive search experience where users can type any part of a student's name or register number in any case (uppercase, lowercase, mixed case), the application combines **Firestore real-time streams** with **in-memory Dart filtering**:
1. `FirestoreService.getStudentsStream()` maintains a live reactive subscription to `FirebaseFirestore.instance.collection('students').snapshots()`.
2. As documents arrive from the cloud, they are deserialized into strongly-typed `Student` Dart objects.
3. A case-insensitive matcher checks whether either field contains the user query:
   ```dart
   bool matchesQuery(String query) {
     final cleanQuery = query.trim().toLowerCase();
     if (cleanQuery.isEmpty) return true;
     return name.toLowerCase().contains(cleanQuery) ||
         registerNumber.toLowerCase().contains(cleanQuery);
   }
   ```
4. This approach guarantees instantaneous, 0ms search feedback on every keystroke, zero redundant network calls, and automatic UI updates whenever records are added, modified, or removed in Firestore.

#### 2.3 Reactive UI with `StreamBuilder` & `ListView.builder`
The user interface is structured reactively using `StreamBuilder`:
- **Loading State (`ConnectionState.waiting`):** Renders a royal blue `CircularProgressIndicator` accompanied by "Loading student records from Firestore...".
- **Error State (`snapshot.hasError`):** Renders a structured, friendly error notification card guiding the user to check network connectivity, Firebase setup, or Firestore security rules.
- **Empty Collection State (`allStudents.isEmpty`):** Notifies the user that the Firestore `students` collection is currently empty and prompts them to register students via Experiment 7.
- **Active Search Filtering:** If records exist, the search query is matched:
  - If matching records are found, `ListView.builder` renders attractive student cards containing the initial avatar, student name, styled register number chip, and department chip.
  - If no records match, the prominent empty-state card **"No students found"** is displayed along with a **"Clear Search"** button to restore all records.

---

### 3. Source Code Implementation

#### 3.1 Project Dependencies (`pubspec.yaml`)
```yaml
name: exp_8
description: "Experiment 8 - Student Search Application using Google Cloud Firestore."
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

#### 3.2 Firebase Configuration (`lib/firebase_options.dart`)
```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static bool get isConfigured {
    return web.apiKey.isNotEmpty &&
        !web.apiKey.contains('YOUR_') &&
        web.projectId.isNotEmpty &&
        !web.projectId.contains('YOUR_');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: 'YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
  );
}
```

#### 3.3 Student Data Model (`lib/models/student.dart`)
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String registerNumber;
  final String department;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.name,
    required this.registerNumber,
    required this.department,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'register_number': registerNumber.trim().toUpperCase(),
      'department': department.trim(),
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  factory Student.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    DateTime parsedDate;
    final createdAtField = data['created_at'];
    if (createdAtField is Timestamp) {
      parsedDate = createdAtField.toDate();
    } else if (createdAtField is String) {
      parsedDate = DateTime.tryParse(createdAtField) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Student(
      id: doc.id,
      name: (data['name'] ?? data['student_name'] ?? '').toString(),
      registerNumber: (data['register_number'] ??
              data['registerNumber'] ??
              data['reg_no'] ??
              '')
          .toString(),
      department: (data['department'] ?? data['dept'] ?? '').toString(),
      createdAt: parsedDate,
    );
  }

  factory Student.fromMap(Map<String, dynamic> data, {String id = ''}) {
    DateTime parsedDate;
    final createdAtField = data['created_at'];
    if (createdAtField is Timestamp) {
      parsedDate = createdAtField.toDate();
    } else if (createdAtField is DateTime) {
      parsedDate = createdAtField;
    } else if (createdAtField is String) {
      parsedDate = DateTime.tryParse(createdAtField) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Student(
      id: id.isNotEmpty ? id : (data['id']?.toString() ?? ''),
      name: (data['name'] ?? data['student_name'] ?? '').toString(),
      registerNumber: (data['register_number'] ??
              data['registerNumber'] ??
              data['reg_no'] ??
              '')
          .toString(),
      department: (data['department'] ?? data['dept'] ?? '').toString(),
      createdAt: parsedDate,
    );
  }

  bool matchesQuery(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return true;
    return name.toLowerCase().contains(cleanQuery) ||
        registerNumber.toLowerCase().contains(cleanQuery);
  }
}
```

#### 3.4 Firestore Service (`lib/services/firestore_service.dart`)
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class FirestoreService {
  final FirebaseFirestore? _customFirestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get studentsCollection =>
      _firestore.collection('students');

  Stream<List<Student>> getStudentsStream() {
    return studentsCollection.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Student.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<List<Student>> getStudentsOnce() async {
    final snapshot = await studentsCollection.get();
    final list = snapshot.docs
        .map((doc) => Student.fromFirestore(doc))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static List<Student> filterStudents(List<Student> students, String query) {
    if (query.trim().isEmpty) {
      return students;
    }
    return students.where((student) => student.matchesQuery(query)).toList();
  }
}
```

---

### 4. Verification and Test Results

#### 4.1 Automated Test Execution (`flutter test`)
All 16 unit and widget tests executed with 100% pass rate:
```text
00:00 +0: loading D:/Flutter Lab exp/Exp8/test/widget_test.dart
00:00 +0: Experiment 8 - Student Model & Search Logic Unit Tests Student.toMap creates correct Firestore schema
00:00 +1: Experiment 8 - Student Model & Search Logic Unit Tests Student.matchesQuery performs case-insensitive name matching
00:00 +2: Experiment 8 - Student Model & Search Logic Unit Tests Student.matchesQuery performs case-insensitive register number matching
00:00 +3: Experiment 8 - Student Model & Search Logic Unit Tests Student.matchesQuery returns false for non-matching queries
00:00 +4: Experiment 8 - Student Model & Search Logic Unit Tests Student.matchesQuery returns true for empty search string
00:00 +5: Experiment 8 - Student Model & Search Logic Unit Tests DefaultFirebaseOptions reports unconfigured with placeholder keys
00:00 +6: Experiment 8 - Student Search Widget Tests UI Test 1: Renders AppBar with title "Student Search"
00:00 +7: Experiment 8 - Student Search Widget Tests UI Test 2: Renders search TextField with search icon and placeholder
00:00 +8: Experiment 8 - Student Search Widget Tests UI Test 3: Displays loading indicator during Stream connection waiting
00:00 +9: Experiment 8 - Student Search Widget Tests UI Test 4: Displays all student records initially when search text is empty
00:00 +10: Experiment 8 - Student Search Widget Tests UI Test 5: Dynamic search by student name filters records
00:00 +11: Experiment 8 - Student Search Widget Tests UI Test 6: Dynamic search by register number filters records
00:00 +12: Experiment 8 - Student Search Widget Tests UI Test 7: Non-existing search query displays "No students found"
00:01 +13: Experiment 8 - Student Search Widget Tests UI Test 8: Clear search button resets search and restores all records
00:01 +14: Experiment 8 - Student Search Widget Tests UI Test 9: Displays friendly error message if Firestore retrieval fails
00:01 +15: Experiment 8 - Student Search Widget Tests UI Test 10: Displays empty message when Firestore collection is empty
00:01 +16: All tests passed!
```

#### 4.2 Static Code Analysis (`flutter analyze`)
```text
Analyzing Exp8...
No issues found! (ran in 1.3s)
```

#### 4.3 Web Build Verification (`flutter build web`)
```text
Compiling lib\main.dart for the Web...
√ Built build\web
```

---

### 5. Conclusion
Experiment 8 was successfully designed, implemented, and verified. The Student Search Application dynamically retrieves student records from Google Cloud Firestore, provides instant multi-field case-insensitive searching on Student Name and Register Number, displays all records initially, updates results dynamically on every keystroke, presents an informative empty-state message when no matching records exist, includes clear search functionality, and handles loading and error states gracefully.
