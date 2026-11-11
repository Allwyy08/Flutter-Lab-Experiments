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
