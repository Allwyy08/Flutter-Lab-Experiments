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
