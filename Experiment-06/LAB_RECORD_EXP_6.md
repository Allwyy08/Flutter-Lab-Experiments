# 24CS2016 – Building Applications using Flutter
## Lab Record - Exercise No. 6

**Ex. No.:** 6  
**Title of the Exercise:** Data Persistence using SQLite in Flutter (Student Records Management System)  
**Date of Exercise:** 11-11-2026  
**GitHub Code Link:** https://github.com/Allwyy08/Flutter-Lab-Experiments/tree/main/Experiment-06  
**Video Link:** *(Paste your Google Drive screen recording link here)*  

---

### 1. Aim
To develop a simple, robust Flutter application titled **"Student Records Management System"** that stores student information in a local on-device SQLite database and retrieves saved records, meeting the following requirements:
1. Creating an `AppBar` with the title **"Student Records"**.
2. Adding three input fields:
   - Student Name
   - Register Number
   - Department
3. Adding a **"Save Student"** button.
4. Storing student details in a local SQLite database named **`students.db`**.
5. Displaying all saved student records below the input form.
6. Displaying Student Name, Register Number, and Department in each student record card.
7. Implementing only:
   - **CREATE:** Insert new student records into SQLite.
   - **READ:** Retrieve and display all student records.
8. Displaying a clear message if no student records are available.
9. Validating that all input fields are filled before saving.
10. Automatically refreshing the student list after saving a record.
11. Displaying a success notification message after inserting a record.
12. Creating a database helper class named **`DatabaseHelper`** and table **`students`** with:
    - `id INTEGER PRIMARY KEY AUTOINCREMENT`
    - `name TEXT`
    - `register_number TEXT`
    - `department TEXT`
13. Configuring the project for Windows desktop execution using **`sqflite_common_ffi`**.
14. Ensuring records remain persistent and accessible after closing and reopening the application.

---

### 2. Description

Data persistence is an essential requirement for production-grade software applications. Mobile and desktop applications frequently need to retain user data across application lifecycles, device reboots, and offline scenarios without relying solely on cloud or network connectivity.

#### 2.1 SQLite Architecture in Flutter
SQLite is an embedded, lightweight, serverless relational database engine. Unlike client-server database engines (such as MySQL or PostgreSQL), SQLite reads and writes directly to standard disk files.

In Flutter, local SQLite data persistence is achieved through the **`sqflite`** plugin ecosystem:
- **`sqflite`**: Provides standard asynchronous SQLite database operations for mobile operating systems (Android and iOS).
- **`sqflite_common_ffi`**: Provides a Dart FFI (Foreign Function Interface) based SQLite implementation, enabling the exact same database API to run seamlessly on desktop platforms (Windows, Linux, macOS) and inside automated unit and widget test environments.

#### 2.2 Database Helper Singleton Pattern
To ensure safe, single-threaded access to the SQLite database file and prevent resource leaks or race conditions, a dedicated helper class named **`DatabaseHelper`** is structured using the Singleton design pattern:
- **Private Constructor (`DatabaseHelper._init()`):** Prevents external instantiation.
- **Static Instance (`DatabaseHelper.instance`):** Exposes a globally accessible, single instance across the entire application.
- **Lazy Database Initialization (`Future<Database> get database`):** Opens the database file only when first requested.

#### 2.3 Database Schema & Methods
The application manages a single relational table within `students.db`:

```sql
CREATE TABLE students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  register_number TEXT NOT NULL,
  department TEXT NOT NULL
);
```

The database helper strictly implements:
1. **`insertStudent(Map<String, dynamic> student)`**: Executes an `INSERT` statement into the `students` table and returns the auto-generated primary key ID.
2. **`getStudents()`**: Executes a `SELECT` query retrieving all stored student records ordered by `id DESC` so newly inserted records appear at the top.

#### 2.4 User Interface & Responsive Design
- **Material 3 Design:** Professional royal blue theme (`#1565C0`) with white card backgrounds (`#FFFFFF`) and slate grey borders (`#E2E8F0`).
- **Form Validation:** A `GlobalKey<FormState>` and `TextFormField` validators prevent empty or whitespace-only submissions.
- **Visual Feedback:** A floating emerald green `SnackBar` confirms successful persistence.
- **Responsive Layout:** A centered `ConstrainedBox` with maximum width ($650\text{ px}$) ensures optimal rendering on both mobile devices and wide desktop monitors.
- **Empty State Indicator:** Informative empty placeholder card displayed when no records exist.

---

### 3. Algorithm

#### Algorithm 1: Application Initialization & Windows SQLite FFI Setup
1. **Start** the application inside `main()`.
2. Call `WidgetsFlutterBinding.ensureInitialized()` to bind Flutter framework services.
3. Check the host operating system platform:
   - If running on desktop (Windows/Linux/macOS), call `sqfliteFfiInit()` and assign `databaseFactory = databaseFactoryFfi;`.
4. Launch `StudentRecordsApp` with `runApp()`.
5. In `StudentRecordsScreen.initState()`, trigger `_refreshStudentList()` to asynchronously read any existing records from `students.db`.

#### Algorithm 2: Inserting a Student Record (CREATE)
1. User enters:
   - Student Name into `_nameController`.
   - Register Number into `_registerNumberController`.
   - Department into `_departmentController`.
2. User taps **"Save Student"**.
3. Call `_formKey.currentState!.validate()`:
   - If any field is empty or contains only whitespace, display validator error message and **Exit**.
4. Construct a student Map:
   $$\text{newStudent} = \{\text{'name'}: \text{Name}, \text{'register\_number'}: \text{RegNo}, \text{'department'}: \text{Dept}\}$$
5. Call `DatabaseHelper.instance.insertStudent(newStudent)`.
6. Clear all input text fields and reset form state.
7. Display a success `SnackBar` notification: `"Student record saved successfully!"`.
8. Call `_refreshStudentList()` to refresh the records from SQLite and rebuild the UI.

#### Algorithm 3: Retrieving Student Records (READ)
1. Invoke `DatabaseHelper.instance.getStudents()`.
2. Execute SQL query: `SELECT * FROM students ORDER BY id DESC`.
3. Receive `List<Map<String, dynamic>>` records from SQLite.
4. Call `setState()` to update `_students` list and set `_isLoading = false`.
5. If `_students.isEmpty`, display the empty state placeholder card.
6. Else, construct and display each record inside a styled Material `Card` using `ListView.builder`.

---

### 4. Source Code

#### 4.1 `pubspec.yaml`
```yaml
name: exp_6
description: "Experiment 6 - Data Persistence using SQLite in Flutter (Student Records Management System)"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.13.7

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.4.6
  sqflite_common_ffi: 2.3.0
  sqlite3: 2.4.6
  path: ^1.9.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

#### 4.2 `lib/database_helper.dart`
```dart
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database Helper class for managing SQLite operations.
///
/// Implements local persistence for Student Records:
/// - Database name: `students.db`
/// - Table name: `students`
/// - Operations: CREATE (`insertStudent`) and READ (`getStudents`).
class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Returns the existing database instance or initializes a new one.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('students.db');
    return _database!;
  }

  /// Initializes the SQLite database file at the device database directory.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Creates the `students` table with the required schema:
  /// - id: INTEGER PRIMARY KEY AUTOINCREMENT
  /// - name: TEXT
  /// - register_number: TEXT
  /// - department: TEXT
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        register_number TEXT NOT NULL,
        department TEXT NOT NULL
      )
    ''');
  }

  /// Inserts a new student record into the SQLite database.
  ///
  /// [student] is a Map containing 'name', 'register_number', and 'department'.
  /// Returns the auto-generated row ID.
  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await database;
    return await db.insert(
      'students',
      student,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all student records stored in the SQLite database.
  ///
  /// Returns a List of Maps ordered by insertion order (newest first).
  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    return await db.query(
      'students',
      orderBy: 'id DESC',
    );
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
```

#### 4.3 `lib/main.dart`
```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI database factory for Windows desktop execution
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const StudentRecordsApp());
}

/// Root Application Widget
class StudentRecordsApp extends StatelessWidget {
  const StudentRecordsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Records',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          primary: const Color(0xFF1565C0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
      ),
      home: const StudentRecordsScreen(),
    );
  }
}

/// Main Screen with Student Input Form and SQLite Saved Records
class StudentRecordsScreen extends StatefulWidget {
  const StudentRecordsScreen({super.key});

  @override
  State<StudentRecordsScreen> createState() => _StudentRecordsScreenState();
}

class _StudentRecordsScreenState extends State<StudentRecordsScreen> {
  // Global form key for input validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Input controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _registerNumberController =
      TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  // List of student records fetched from SQLite database
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshStudentList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registerNumberController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  /// READ operation: Retrieves all student records from SQLite and updates state
  Future<void> _refreshStudentList() async {
    try {
      final records = await DatabaseHelper.instance.getStudents();
      if (mounted) {
        setState(() {
          _students = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading student records: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  /// CREATE operation: Validates inputs, inserts student into SQLite, and refreshes UI
  Future<void> _saveStudent() async {
    // Validate that all fields are filled
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String name = _nameController.text.trim();
    final String registerNumber = _registerNumberController.text.trim();
    final String department = _departmentController.text.trim();

    final Map<String, dynamic> newStudent = {
      'name': name,
      'register_number': registerNumber,
      'department': department,
    };

    try {
      // Insert student record into SQLite
      await DatabaseHelper.instance.insertStudent(newStudent);

      // Clear input fields
      _nameController.clear();
      _registerNumberController.clear();
      _departmentController.clear();
      _formKey.currentState?.reset();

      // Show floating success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Student record saved successfully!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Automatically refresh the student list
      await _refreshStudentList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save student record: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.school_rounded, size: 28),
        title: const Text(
          'Student Records',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section 1: Input Form Card
                  _buildInputFormCard(),

                  const SizedBox(height: 24),

                  // Section 2: Header for Saved Records
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.table_rows_rounded,
                            color: Color(0xFF1565C0),
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Saved Student Records',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF90CAF9)),
                        ),
                        child: Text(
                          '${_students.length} ${_students.length == 1 ? "Record" : "Records"}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Section 3: Records List or Empty State
                  _buildRecordsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the Input Form inside a styled Material Card
  Widget _buildInputFormCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Color(0xFF1565C0),
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Add New Student',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter student details to persist in SQLite database.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

              // Field 1: Student Name
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Student Name',
                  hintText: 'e.g., Allwyn',
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF1565C0),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Field 2: Register Number
              TextFormField(
                controller: _registerNumberController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Register Number',
                  hintText: 'e.g., 23CSE001',
                  prefixIcon: const Icon(
                    Icons.badge_outlined,
                    color: Color(0xFF1565C0),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter register number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Field 3: Department
              TextFormField(
                controller: _departmentController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _saveStudent(),
                decoration: InputDecoration(
                  labelText: 'Department',
                  hintText: 'e.g., CSE (AI)',
                  prefixIcon: const Icon(
                    Icons.school_outlined,
                    color: Color(0xFF1565C0),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 2,
                    ),
                  ),
                ),
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
                onPressed: _saveStudent,
                icon: const Icon(Icons.save_rounded, size: 20),
                label: const Text(
                  'Save Student',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the records section using ListView.builder or empty state placeholder
  Widget _buildRecordsSection() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF1565C0)),
        ),
      );
    }

    // Empty state message when no student records exist
    if (_students.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFBBDEFB), width: 1.2),
        ),
        color: const Color(0xFFF0F7FF),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 56,
                color: Color(0xFF64B5F6),
              ),
              SizedBox(height: 14),
              Text(
                'No student records available.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Fill in the student details above and click "Save Student" to persist a record.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF546E7A)),
              ),
            ],
          ),
        ),
      );
    }

    // Saved records rendered with ListView.builder
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final String name = student['name']?.toString() ?? 'Unknown';
        final String regNo = student['register_number']?.toString() ?? 'N/A';
        final String dept = student['department']?.toString() ?? 'N/A';
        final int id = student['id'] is int ? student['id'] as int : index + 1;

        // Avatar letter
        final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1.5,
          shadowColor: Colors.black12,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar circle with student initials
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF1565C0),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Student Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.badge_outlined,
                            size: 16,
                            color: Color(0xFF1565C0),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Register No: $regNo',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: Color(0xFF1565C0),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Department: $dept',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Record Sequence Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    '#$id',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

#### 4.4 `test/widget_test.dart`
```dart
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
```

---

### 5. Output & Verification

#### 5.1 Verification Checklist

| S.No. | Requirement Verified | Status |
| :---: | :--- | :---: |
| 1 | AppBar title "Student Records" with school icon | ✅ Verified |
| 2 | Three input fields: Student Name, Register Number, Department | ✅ Verified |
| 3 | "Save Student" button with icon and royal blue accent | ✅ Verified |
| 4 | Data persisted in local SQLite database (`students.db`, table `students`) | ✅ Verified |
| 5 | Saved records displayed dynamically below form using `ListView.builder` | ✅ Verified |
| 6 | Each card displays Student Name, Register Number, and Department | ✅ Verified |
| 7 | Strictly implemented CREATE (`insertStudent`) and READ (`getStudents`) | ✅ Verified |
| 8 | Empty state message displayed when 0 records exist | ✅ Verified |
| 9 | Form validates that all input fields are filled before saving | ✅ Verified |
| 10 | Student list automatically refreshed after saving | ✅ Verified |
| 11 | Floating green SnackBar notification displayed upon successful insert | ✅ Verified |
| 12 | Persistence verified across application close and reopen cycles | ✅ Verified |
| 13 | Cross-platform and Windows desktop compatibility with `sqflite_common_ffi` | ✅ Verified |

#### 5.2 Test Execution Output
```text
00:00 +0: loading D:/Flutter Lab exp/Flutter-Lab-Experiments/Experiment-06/test/widget_test.dart
00:00 +0: (setUpAll)
00:00 +0: DatabaseHelper SQLite Unit Tests insertStudent() and getStudents() CREATE and READ operations
00:00 +1: Student Records UI & SQLite Integration Tests Renders AppBar, input fields, save button, and empty state
00:00 +2: Student Records UI & SQLite Integration Tests Validates that all input fields are filled before saving
00:01 +3: Student Records UI & SQLite Integration Tests Validates whitespace-only input fields are rejected
00:01 +4: Student Records UI & SQLite Integration Tests Step 1-3: Enter Allwyn, 23CSE001, CSE (AI) -> Save -> Record appears in list & SnackBar shown
00:02 +5: Student Records UI & SQLite Integration Tests Step 4: Add another student and verify both records appear
00:03 +6: Student Records UI & SQLite Integration Tests Step 5-6: Persistence: Close and reopen app -> verify previously saved records are still displayed
00:04 +7: (tearDownAll)
00:04 +7: All tests passed!
```

---

### 6. Result
The **Student Records Management System** Flutter application was successfully developed and verified:
1. Student records are persisted locally inside an on-device SQLite database named `students.db` via a clean `DatabaseHelper` singleton class.
2. The user interface allows users to insert records with comprehensive form validation, immediately refreshes the `ListView.builder` display, and notifies the user with a floating success message.
3. Records persist seamlessly across application restarts.
4. All 7 unit and widget tests passed with 0 static analysis issues (`flutter analyze` clean).
