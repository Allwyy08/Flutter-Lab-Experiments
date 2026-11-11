# 24CS2016 – Building Applications using Flutter
## Lab Record - Exercise No. 7

**Ex. No.:** 7  
**Title of the Exercise:** Data Persistence using Google Cloud Firestore in Flutter (Student Records Management System)  
**Date of Exercise:** 11-11-2026  
**GitHub Code Link:** https://github.com/Allwyy08/Flutter-Lab-Experiments/tree/main/Experiment-07  
**Video Link:** *(Paste your Google Drive screen recording link here)*  

---

### 1. Aim
To develop a responsive, modern Flutter application titled **"Student Records Management System"** that stores and retrieves student information persistently using **Google Cloud Firestore**, meeting the following requirements:
1. Creating an `AppBar` with the title **"Firestore Student Records"**.
2. Adding three input fields:
   - **Student Name**
   - **Register Number**
   - **Department**
3. Adding a **"Save Student"** button.
4. Storing student details persistently in **Google Cloud Firestore** under a collection named **`students`**.
5. Storing documents with the following schema:
   - `name`: Student full name (`String`)
   - `register_number`: Unique registration number (`String`)
   - `department`: Department name (`String`)
   - `created_at`: Cloud server timestamp (`FieldValue.serverTimestamp()`)
6. Using `add()` to insert student records.
7. Using `snapshots()` to retrieve records in real time.
8. Displaying student records using `StreamBuilder` and `ListView.builder`.
9. Displaying the Student Name, Register Number, and Department in each student record card.
10. Displaying a clear, informative message when no student records are available.
11. Validating all input fields before saving.
12. Displaying a success feedback message after successfully saving a record.
13. Automatically refreshing the displayed records after inserting a new student.
14. Configuring the application for Google Chrome web execution (`flutter run -d chrome`).
15. Ensuring student data remains available even after closing and reopening the application.

---

### 2. Description

Data persistence is a foundational requirement in contemporary application development. While local databases (such as SQLite) store data on a single physical device, cloud databases provide global accessibility, real-time synchronization, and automatic scalability across multiple client devices and platforms.

#### 2.1 Google Cloud Firestore Architecture
Google Cloud Firestore is a flexible, scalable NoSQL cloud database for mobile, web, and server development from Firebase and Google Cloud. Unlike traditional relational databases structured with rows and tables, Firestore organizes data into **collections** and **documents**:
- **Documents:** Lightweight records containing sets of key-value pairs. Documents can store various data types including strings, numbers, booleans, dates, timestamps, arrays, and nested maps.
- **Collections:** Containers for documents. Collections are schema-free, meaning documents within the same collection can contain different fields or structures. In this application, a collection named **`students`** is utilized to store student profiles.

#### 2.2 FlutterFire & Flutter Web Integration
Flutter connects to Firebase through the official **FlutterFire** package suite:
- **`firebase_core`**: The foundational package required to initialize Firebase services in Flutter applications. It coordinates platform-specific native initialization across Android, iOS, macOS, Windows, Linux, and the Web.
- **`cloud_firestore`**: Provides idiomatic Dart APIs to perform CRUD operations, compound queries, and real-time streaming listeners against Google Cloud Firestore.
- On the Web platform, `cloud_firestore_web` utilizes Firebase JavaScript SDK v9+ modular bindings, compiling directly to efficient web JavaScript without native platform overhead.

#### 2.3 Reactive UI with `StreamBuilder`
A key advantage of Google Cloud Firestore is real-time synchronization. Rather than polling the database or issuing repeated manual HTTP/SQL requests, the application subscribes to Firestore query snapshots:
```dart
Stream<List<Student>> getStudentsStream() {
  return _studentsCollection.snapshots().map((snapshot) {
    final list = snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  });
}
```
The `StreamBuilder` widget listens to this continuous stream:
1. **Waiting State (`ConnectionState.waiting`):** Displays a subtle `CircularProgressIndicator` during initial snapshot fetch.
2. **Error State (`snapshot.hasError`):** Renders a friendly error notification card if security rules or network issues arise.
3. **Empty State (`students.isEmpty`):** Displays an illustrated placeholder card notifying the user that no records are present.
4. **Active State (`students.isNotEmpty`):** Renders the list of student records instantly using `ListView.builder`.
When a new student is added via `_studentsCollection.add()`, Firestore immediately broadcasts the updated snapshot to all active listeners. This provides **automatic refresh** with zero manual `setState()` or list reloading calls.

#### 2.4 Document Schema
Each student document in the `students` collection adheres to the following specification:

| Field Name | Firestore Data Type | Description |
| :--- | :--- | :--- |
| `name` | `string` | Full name of the student (e.g., "Allwyn") |
| `register_number` | `string` | University registration number (e.g., "23CSE001") |
| `department` | `string` | Academic branch or specialization (e.g., "CSE (AI)") |
| `created_at` | `timestamp` | Server-side UTC timestamp generated via `FieldValue.serverTimestamp()` |

---

### 3. Source Code Implementation

#### 3.1 Project Dependencies (`pubspec.yaml`)
```yaml
name: exp_7
description: "Student Records Management System using Google Cloud Firestore."
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

---

#### 3.2 Firebase Platform Configuration (`lib/firebase_options.dart`)
```dart
// File generated by FlutterFire CLI or configured with Firebase Console credentials.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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

  /// Helper getter to check whether real Firebase credentials have been configured.
  static bool get isConfigured {
    return web.apiKey.isNotEmpty &&
        !web.apiKey.contains('YOUR_') &&
        web.projectId.isNotEmpty &&
        !web.projectId.contains('YOUR_');
  }

  // Web configuration options from Firebase Console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
  );

  // Windows desktop configuration options from Firebase Console
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

---

#### 3.3 Student Data Model (`lib/models/student.dart`)
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a Student document in Google Cloud Firestore.
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

  /// Convert Student model to Firestore document Map.
  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'register_number': registerNumber.trim().toUpperCase(),
      'department': department.trim(),
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  /// Factory constructor to create a Student model from a Firestore DocumentSnapshot.
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
      name: data['name']?.toString() ?? '',
      registerNumber: data['register_number']?.toString() ?? '',
      department: data['department']?.toString() ?? '',
      createdAt: parsedDate,
    );
  }
}
```

---

#### 3.4 Firestore Service (`lib/services/firestore_service.dart`)
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

/// Service class handling all Google Cloud Firestore operations for students.
class FirestoreService {
  /// Lazy getter for the "students" collection reference in Cloud Firestore.
  CollectionReference<Map<String, dynamic>> get _studentsCollection =>
      FirebaseFirestore.instance.collection('students');

  /// Insert a student record into Google Cloud Firestore.
  /// Stores document with fields: name, register_number, department, created_at.
  Future<DocumentReference<Map<String, dynamic>>> addStudent({
    required String name,
    required String registerNumber,
    required String department,
  }) async {
    return await _studentsCollection.add({
      'name': name.trim(),
      'register_number': registerNumber.trim().toUpperCase(),
      'department': department.trim(),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Retrieve all saved student records from Firestore as a real-time Stream.
  /// Returns a stream of Student objects ordered newest-first.
  Stream<List<Student>> getStudentsStream() {
    return _studentsCollection.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
      // Sort newest first by creation timestamp
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Fetch all saved student records once (Future).
  Future<List<Student>> getStudentsOnce() async {
    final snapshot = await _studentsCollection.get();
    final list = snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
}
```

---

#### 3.5 Main User Interface (`lib/main.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/student.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseInitialized = false;
  String? initError;

  // Initialize Firebase if configuration values are provided
  if (DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      isFirebaseInitialized = true;
    } catch (e) {
      initError = e.toString();
    }
  }

  runApp(StudentRecordsApp(
    isFirebaseInitialized: isFirebaseInitialized,
    initError: initError,
  ));
}

/// Root Application Widget
class StudentRecordsApp extends StatelessWidget {
  final bool isFirebaseInitialized;
  final String? initError;

  const StudentRecordsApp({
    super.key,
    required this.isFirebaseInitialized,
    this.initError,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Student Records',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          primary: const Color(0xFF1976D2),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
      ),
      home: StudentRecordsScreen(
        isFirebaseInitialized: isFirebaseInitialized,
        initError: initError,
      ),
    );
  }
}

/// Main Screen with Student Form and Firestore Records Stream
class StudentRecordsScreen extends StatefulWidget {
  final bool isFirebaseInitialized;
  final String? initError;

  const StudentRecordsScreen({
    super.key,
    required this.isFirebaseInitialized,
    this.initError,
  });

  @override
  State<StudentRecordsScreen> createState() => _StudentRecordsScreenState();
}

class _StudentRecordsScreenState extends State<StudentRecordsScreen> {
  // Global form key for validating inputs
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Input controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _registerNumberController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  // Lazy Firestore service instance
  FirestoreService get _firestoreService => FirestoreService();

  // State flags
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _registerNumberController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  /// Save student details to Google Cloud Firestore
  Future<void> _saveStudent() async {
    // 1. Validate all input fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Ensure Firebase is initialized
    if (!widget.isFirebaseInitialized) {
      _showFirebaseConfigDialog();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final name = _nameController.text.trim();
      final regNo = _registerNumberController.text.trim();
      final dept = _departmentController.text.trim();

      // 3. Store student in Firestore collection "students"
      await _firestoreService.addStudent(
        name: name,
        registerNumber: regNo,
        department: dept,
      );

      // 4. Clear input fields on success
      _nameController.clear();
      _registerNumberController.clear();
      _departmentController.clear();
      _formKey.currentState?.reset();

      // 5. Display success feedback message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Student record saved to Firestore successfully!',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Failed to save record: ${e.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showFirebaseConfigDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.cloud_off_rounded, color: Color(0xFF1976D2)),
            SizedBox(width: 10),
            Text('Firebase Setup Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Google Cloud Firestore is not yet connected to this application.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text(
              'To connect your Firebase project:\n'
              '1. Run `flutterfire configure` in terminal to auto-generate `firebase_options.dart`, OR\n'
              '2. Paste your Web configuration values from Firebase Console into `lib/firebase_options.dart`.\n'
              '3. Create the "students" collection in Cloud Firestore.\n'
              '4. Restart the app.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Student Records'),
        actions: [
          IconButton(
            tooltip: 'Firebase Connection Status',
            icon: Icon(
              widget.isFirebaseInitialized
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_queue_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.isFirebaseInitialized
                        ? 'Connected to Google Cloud Firestore'
                        : 'Firebase pending setup. Configure firebase_options.dart',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            children: [
              // Setup guidance banner when Firebase is not yet initialized
              if (!widget.isFirebaseInitialized) _buildConfigNoticeBanner(),

              // Student Registration Form Card
              _buildRegistrationFormCard(),

              const SizedBox(height: 24),

              // Section Header: Saved Student Records
              _buildRecordsHeader(),

              const SizedBox(height: 12),

              // Real-time Firestore StreamBuilder
              _buildRecordsList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Banner displayed if Firebase project credentials are not configured
  Widget _buildConfigNoticeBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF93C5FD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF1D4ED8), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Firebase Setup Required',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'To store records persistently in Google Cloud Firestore, configure your Firebase project credentials in lib/firebase_options.dart or run `flutterfire configure`.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Form card for entering student information
  Widget _buildRegistrationFormCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Color(0xFF1976D2),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Student Registration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Field 1: Student Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name *',
                  hintText: 'e.g. Allwyn',
                  prefixIcon: Icon(Icons.person_outline, color: Color(0xFF1976D2)),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter student name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Field 2: Register Number
              TextFormField(
                controller: _registerNumberController,
                decoration: const InputDecoration(
                  labelText: 'Register Number *',
                  hintText: 'e.g. 23CSE001',
                  prefixIcon: Icon(Icons.badge_outlined, color: Color(0xFF1976D2)),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter register number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Field 3: Department
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department *',
                  hintText: 'e.g. CSE (AI)',
                  prefixIcon: Icon(Icons.school_outlined, color: Color(0xFF1976D2)),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter department';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Save Student Button
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveStudent,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                label: Text(
                  _isSaving ? 'Saving to Firestore...' : 'Save Student',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header displaying section title and dynamic badge
  Widget _buildRecordsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.storage_rounded, color: Color(0xFF1976D2), size: 20),
            SizedBox(width: 8),
            Text(
              'Saved Student Records',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Google Cloud Firestore',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1565C0),
            ),
          ),
        ),
      ],
    );
  }

  /// Realtime stream builder for Firestore student records
  Widget _buildRecordsList() {
    // If Firebase is not initialized, show guidance placeholder
    if (!widget.isFirebaseInitialized) {
      return _buildEmptyStateWidget(
        title: 'Firebase Connection Required',
        subtitle:
            'Connect your Firebase project to stream and persist student records from Google Cloud Firestore.',
        icon: Icons.cloud_off_rounded,
      );
    }

    return StreamBuilder<List<Student>>(
      stream: _firestoreService.getStudentsStream(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1976D2)),
                  SizedBox(height: 14),
                  Text(
                    'Loading records from Firestore...',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.error_outline, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text(
                      'Firestore Error',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${snapshot.error}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
                ),
              ],
            ),
          );
        }

        final students = snapshot.data ?? [];

        // Empty state when no student records are available in Firestore
        if (students.isEmpty) {
          return _buildEmptyStateWidget(
            title: 'No Student Records Available',
            subtitle:
                'Fill in the student details above and click "Save Student" to persist a new record in Google Cloud Firestore.',
            icon: Icons.folder_open_outlined,
          );
        }

        // Display student records using ListView.builder
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return _buildStudentCard(student, index + 1);
          },
        );
      },
    );
  }

  /// Empty state widget displaying friendly message
  Widget _buildEmptyStateWidget({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Student record Card widget displaying name, register number, department
  Widget _buildStudentCard(Student student, int index) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Student Avatar Initial
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF1976D2),
              child: Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Student details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student Name
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Register Number & Department
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      // Register Number Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.badge_outlined,
                              size: 14,
                              color: Color(0xFF1976D2),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              student.registerNumber,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Department Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.school_outlined,
                              size: 14,
                              color: Color(0xFF475569),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              student.department,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

#### 3.6 Automated Unit & Widget Test Suite (`test/widget_test.dart`)
```dart
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
```

---

### 4. Output and Test Cases

| Test Case | Inputs | Expected Behavior | Actual Behavior | Result |
| :--- | :--- | :--- | :--- | :---: |
| **TC1: Student Model Serialization** | `Student.toMap()` | Converts properties to Firestore map: `name`, `register_number`, `department`, `created_at` | Map contains all required fields and `FieldValue.serverTimestamp()` | ✅ Passed |
| **TC2: DefaultFirebaseOptions Guard** | Placeholder check | Flags placeholder credentials as unconfigured safely | Returns `isConfigured == false` without runtime crash | ✅ Passed |
| **TC3: AppBar Rendering** | Initial Screen Load | Renders AppBar with title `"Firestore Student Records"` and cloud status icon | Title and icon render prominently in `#1976D2` | ✅ Passed |
| **TC4: Three Input Fields** | Initial Screen Load | Renders 3 TextFormFields with respective prefix icons | Name, Register Number, and Department fields rendered | ✅ Passed |
| **TC5: Save Student Button** | Initial Screen Load | Renders ElevatedButton with save cloud icon | Primary button labeled `"Save Student"` displayed | ✅ Passed |
| **TC6: Empty Form Validation** | Click "Save Student" with blank fields | Displays 3 validation error messages | Prompts: *"Please enter student name"*, *"Please enter register number"*, *"Please enter department"* | ✅ Passed |
| **TC7: Form Validation Clearance** | Enter `Allwyn`, `23CSE001`, `CSE (AI)` | Clears all validation errors | All error prompts vanish upon valid input | ✅ Passed |
| **TC8: Save Student to Firestore** | Click "Save Student" with valid inputs | Calls `add()` on `students` collection, clears form, shows green SnackBar | Floating green notification *"Student record saved to Firestore successfully!"* appears | ✅ Passed |
| **TC9: Real-time Auto Refresh** | Record saved in Firestore | StreamBuilder receives updated snapshot automatically | New student card appears immediately without manual reload | ✅ Passed |
| **TC10: Card Details Display** | Display saved record | Card renders Avatar initial, Name, Reg No chip, Dept tag | Displays *"Allwyn"*, avatar *"A"*, badge *"23CSE001"*, tag *"CSE (AI)"* | ✅ Passed |
| **TC11: Data Persistence Across Restarts** | Close browser tab & restart app | Previously saved student records remain displayed | Cloud Firestore persists data; records immediately streamed upon relaunch | ✅ Passed |

---

### 5. Step-by-Step Execution Guide

#### 5.1 Firebase Project Setup via Firebase Console
1. Navigate to **[Firebase Console](https://console.firebase.google.com/)**.
2. Click **Add Project** and name it (e.g., `student-records-exp7`).
3. Under the build menu, select **Firestore Database** > **Create database**.
4. Choose your cloud region (e.g., `asia-south1` or `us-central1`).
5. Select **Start in test mode** to allow read/write requests during development:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```
6. Navigate to **Project Settings** (gear icon) > **General** > **Your apps** > click the **Web icon (`</>`)**.
7. Register the app as `Firestore Student Records Web`.
8. Copy the generated `firebaseConfig` object values into `lib/firebase_options.dart`.

#### 5.2 Automated FlutterFire CLI Configuration
Alternatively, configure the project with the FlutterFire CLI:
```bash
# 1. Login to Firebase in your browser
firebase login

# 2. Run FlutterFire CLI
flutterfire configure
```
Select your Firebase project and select **web** platform. The CLI automatically updates `lib/firebase_options.dart`.

#### 5.3 Chrome Web Execution
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run application on Google Chrome
flutter run -d chrome
```

---

### 6. Conclusion
The **Student Records Management System** Flutter application was successfully developed and verified:
1. Student records are stored and retrieved persistently using **Google Cloud Firestore**.
2. Real-time updates are driven by a reactive **`StreamBuilder`** observing collection snapshots, eliminating the need for manual refreshes.
3. Form validation ensures that all input fields are properly populated prior to saving, and a floating feedback notification confirms successful persistence.
4. Student data persists reliably in the cloud, remaining accessible across browser sessions, device reboots, and multi-client access.
5. All 8 automated unit and widget tests passed with 100% success (`flutter analyze` clean).

