import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/student.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseInitialized = false;
  String? initError;

  // Initialize Firebase if credentials are configured
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

  runApp(StudentUpdateApp(
    isFirebaseInitialized: isFirebaseInitialized,
    initError: initError,
  ));
}

/// Root Application Widget for Experiment 9: Firestore Data Update
class StudentUpdateApp extends StatelessWidget {
  final bool isFirebaseInitialized;
  final String? initError;
  final FirestoreService? firestoreService;

  const StudentUpdateApp({
    super.key,
    required this.isFirebaseInitialized,
    this.initError,
    this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Update Student Records',
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
      home: StudentUpdateScreen(
        isFirebaseInitialized: isFirebaseInitialized,
        initError: initError,
        firestoreService: firestoreService,
      ),
    );
  }
}

/// Main Screen for Searching and Updating Student Records in Firestore
class StudentUpdateScreen extends StatefulWidget {
  final bool isFirebaseInitialized;
  final String? initError;
  final FirestoreService? firestoreService;

  const StudentUpdateScreen({
    super.key,
    required this.isFirebaseInitialized,
    this.initError,
    this.firestoreService,
  });

  @override
  State<StudentUpdateScreen> createState() => _StudentUpdateScreenState();
}

class _StudentUpdateScreenState extends State<StudentUpdateScreen> {
  // GlobalKey for validating editable student form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text editing controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  // Firestore Service instance
  FirestoreService? _firestoreServiceInstance;
  FirestoreService get _firestoreService =>
      widget.firestoreService ??
      (_firestoreServiceInstance ??= FirestoreService());

  // Application State
  Student? _loadedStudent;
  bool _isSearching = false;
  bool _isUpdating = false;
  bool _hasSearched = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  /// Search for a student in Firestore by Register Number
  Future<void> _searchStudent() async {
    final regNo = _searchController.text.trim();

    // 1. Validate empty search input
    if (regNo.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a student Register Number to search.';
        _successMessage = null;
      });
      _showSnackBar(
        message: 'Please enter a student Register Number to search.',
        isError: true,
      );
      return;
    }

    // 2. Hide keyboard and clear previous messages
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _successMessage = null;
      _hasSearched = true;
    });

    try {
      // 3. Query Firestore "students" collection for the record
      final student =
          await _firestoreService.searchStudentByRegisterNumber(regNo);

      if (!mounted) return;

      if (student != null) {
        // Record found: populate editable controllers
        setState(() {
          _loadedStudent = student;
          _nameController.text = student.name;
          _departmentController.text = student.department;
          _errorMessage = null;
        });

        _showSnackBar(
          message:
              'Student found: ${student.name} (${student.registerNumber})',
          isError: false,
        );
      } else {
        // Record not found: clear controllers and display error
        setState(() {
          _loadedStudent = null;
          _nameController.clear();
          _departmentController.clear();
          _errorMessage =
              'Student with Register Number "$regNo" does not exist.';
        });

        _showSnackBar(
          message: 'Student with Register Number "$regNo" not found.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadedStudent = null;
        _errorMessage = 'Error retrieving student record: ${e.toString()}';
      });
      _showSnackBar(
        message: 'Error searching Firestore: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  /// Update the existing student record in Google Cloud Firestore
  Future<void> _updateStudent() async {
    // 1. Validate that all editable fields are filled (Requirement 13)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_loadedStudent == null) {
      _showSnackBar(
        message: 'Please search and select a student first.',
        isError: true,
      );
      return;
    }

    final newName = _nameController.text.trim();
    final newDept = _departmentController.text.trim();

    FocusScope.of(context).unfocus();
    setState(() {
      _isUpdating = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // 2. Call Firestore update() on the existing document reference
      await _firestoreService.updateStudent(
        docId: _loadedStudent!.id,
        name: newName,
        department: newDept,
      );

      // 3. Refresh displayed information after updating (Requirement 12)
      final refreshed =
          await _firestoreService.getStudentById(_loadedStudent!.id);

      if (!mounted) return;

      setState(() {
        if (refreshed != null) {
          _loadedStudent = refreshed;
          _nameController.text = refreshed.name;
          _departmentController.text = refreshed.department;
        } else {
          _loadedStudent = _loadedStudent!.copyWith(
            name: newName,
            department: newDept,
            updatedAt: DateTime.now(),
          );
        }
        _successMessage =
            'Student record updated successfully in Google Cloud Firestore!';
      });

      // 4. Display success message (Requirement 10)
      _showSnackBar(
        message: 'Student record updated successfully!',
        isError: false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to update student: ${e.toString()}';
      });
      _showSnackBar(
        message: 'Update failed: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  /// Reset all input fields and search state (Requirement 14)
  void _resetAll() {
    _searchController.clear();
    _nameController.clear();
    _departmentController.clear();
    _formKey.currentState?.reset();

    setState(() {
      _loadedStudent = null;
      _isSearching = false;
      _isUpdating = false;
      _hasSearched = false;
      _errorMessage = null;
      _successMessage = null;
    });

    _showSnackBar(
      message: 'Search and input fields have been reset.',
      isError: false,
    );
  }

  /// Helper to show floating SnackBar notifications
  void _showSnackBar({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? Colors.red.shade700 : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Student Records'),
        actions: [
          IconButton(
            tooltip: 'Firebase Status',
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
                        ? 'Connected to Firestore (Collection: students)'
                        : 'Firebase setup pending. Configure lib/firebase_options.dart',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Reset All',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _resetAll,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            children: [
              // Top Search Section
              _buildSearchCard(),

              const SizedBox(height: 16),

              // Firebase Setup Notice (if not yet configured)
              if (!widget.isFirebaseInitialized && widget.firestoreService == null)
                _buildFirebaseSetupBanner(),

              // Loading Indicator during search
              if (_isSearching) ...[
                const SizedBox(height: 32),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF1976D2)),
                      SizedBox(height: 12),
                      Text(
                        'Searching student in Google Cloud Firestore...',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Inline Error Message Box (Requirement 11)
              if (!_isSearching && _errorMessage != null) ...[
                const SizedBox(height: 12),
                _buildErrorMessageCard(_errorMessage!),
              ],

              // Inline Success Message Box (Requirement 10)
              if (!_isSearching && _successMessage != null) ...[
                const SizedBox(height: 12),
                _buildSuccessMessageCard(_successMessage!),
              ],

              // Student Details & Editable Form Card (Requirements 5, 6, 7, 8, 9, 13)
              if (!_isSearching && _loadedStudent != null) ...[
                const SizedBox(height: 16),
                _buildStudentDetailsCard(),
              ],

              // Initial placeholder guide when no search has been executed
              if (!_isSearching && !_hasSearched && _loadedStudent == null) ...[
                const SizedBox(height: 24),
                _buildPlaceholderCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Search Card containing Register Number input and Search / Reset buttons
  Widget _buildSearchCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF1976D2),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Search Student Record',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Enter Register Number:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),

            // Register Number search TextField (Requirement 2)
            TextField(
              controller: _searchController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'e.g., 23CSE001, 23ECE015',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.badge_outlined,
                  color: Color(0xFF1976D2),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: Color(0xFF94A3B8)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _searchStudent(),
            ),
            const SizedBox(height: 16),

            // Action Buttons: Search Student & Reset
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _isSearching ? null : _searchStudent,
                    icon: const Icon(Icons.search_rounded, size: 20),
                    label: const Text(
                      'Search Student',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: _resetAll,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card displaying student details with editable form and non-editable register number
  Widget _buildStudentDetailsCard() {
    return Card(
      elevation: 2.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFBFDBFE), width: 1.2),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with student avatar and found badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF1976D2),
                    child: Text(
                      _loadedStudent!.name.isNotEmpty
                          ? _loadedStudent!.name[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Student Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Doc ID: ${_loadedStudent!.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            size: 14, color: Color(0xFF059669)),
                        SizedBox(width: 4),
                        Text(
                          'Record Found',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 28, color: Color(0xFFE2E8F0)),

              // 1. Register Number - READ ONLY / LOCKED (Requirements 5 & 7)
              const Text(
                'Register Number (Unique Identifier):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      color: Color(0xFF64748B),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _loadedStudent!.registerNumber,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_rounded,
                              size: 14, color: Color(0xFF475569)),
                          SizedBox(width: 4),
                          Text(
                            'Unchanged',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'Register Number is the primary identifier and cannot be edited.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 2. Student Name - EDITABLE (Requirements 5, 6, 13)
              const Text(
                'Student Name:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter updated student name',
                  prefixIcon: Icon(Icons.person_outline,
                      color: Color(0xFF1976D2)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // 3. Department - EDITABLE (Requirements 5, 6, 13)
              const Text(
                'Department:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  hintText: 'Enter updated department',
                  prefixIcon: Icon(Icons.school_outlined,
                      color: Color(0xFF1976D2)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter department';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Action Buttons: Update Student & Reset
              Row(
                children: [
                  // Update Student Button (Requirements 8 & 9)
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _updateStudent,
                      icon: _isUpdating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded, size: 20),
                      label: Text(
                        _isUpdating ? 'Updating...' : 'Update Student',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Reset Button (Requirement 14)
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: _isUpdating ? null : _resetAll,
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Error Message Card for not found or network errors (Requirement 11)
  Widget _buildErrorMessageCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFDC2626),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Not Found / Search Error',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Success Message Card displayed after document update (Requirement 10)
  Widget _buildSuccessMessageCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF16A34A),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Successful',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Placeholder card shown before searching
  Widget _buildPlaceholderCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.manage_search_rounded,
                size: 48,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Update Student Record',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter a student Register Number in the search field above and click "Search Student" to fetch existing Firestore records. You can then edit the Name and Department while keeping the Register Number locked.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Informational banner shown if Firebase credentials have not been configured yet
  Widget _buildFirebaseSetupBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: Color(0xFFD97706), size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Firebase Setup Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Paste your Firebase credentials from Experiment 7 into lib/firebase_options.dart to connect to live Google Cloud Firestore.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
