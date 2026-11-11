import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/student.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseInitialized = false;
  String? initError;

  // Initialize Firebase if credentials have been configured
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

  runApp(StudentSearchApp(
    isFirebaseInitialized: isFirebaseInitialized,
    initError: initError,
  ));
}

/// Root Application Widget for Experiment 8
class StudentSearchApp extends StatelessWidget {
  final bool isFirebaseInitialized;
  final String? initError;
  final Stream<List<Student>>? customStream;
  final FirestoreService? firestoreService;

  const StudentSearchApp({
    super.key,
    required this.isFirebaseInitialized,
    this.initError,
    this.customStream,
    this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Search',
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
      ),
      home: StudentSearchScreen(
        isFirebaseInitialized: isFirebaseInitialized,
        initError: initError,
        customStream: customStream,
        firestoreService: firestoreService,
      ),
    );
  }
}

/// Main Screen with Search Bar and Firestore Data Retrieval
class StudentSearchScreen extends StatefulWidget {
  final bool isFirebaseInitialized;
  final String? initError;
  final Stream<List<Student>>? customStream;
  final FirestoreService? firestoreService;

  const StudentSearchScreen({
    super.key,
    required this.isFirebaseInitialized,
    this.initError,
    this.customStream,
    this.firestoreService,
  });

  @override
  State<StudentSearchScreen> createState() => _StudentSearchScreenState();
}

class _StudentSearchScreenState extends State<StudentSearchScreen> {
  // Controller for the search input field
  final TextEditingController _searchController = TextEditingController();

  // Active search query
  String _searchQuery = '';

  // Firestore service instance (lazily resolved)
  FirestoreService? _firestoreServiceInstance;
  FirestoreService get _firestoreService =>
      widget.firestoreService ??
      (_firestoreServiceInstance ??= FirestoreService());

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Called whenever the user types or alters text in the search bar
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  /// Clears the search text and resets search results to show all records
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Search'),
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
                        ? 'Connected to Google Cloud Firestore (Collection: students)'
                        : 'Firebase setup pending. Configure lib/firebase_options.dart',
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
          child: Column(
            children: [
              // Search Bar Section at the Top
              _buildSearchBar(),

              // Firebase Setup Notice (if not yet configured)
              if (!widget.isFirebaseInitialized && widget.customStream == null)
                Expanded(child: _buildConfigNotice())
              else
                // Dynamic Firestore Results Stream
                Expanded(child: _buildFirestoreResults()),
            ],
          ),
        ),
      ),
    );
  }

  /// Search bar widget with prefix search icon and clear button
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Search by student name or register number...',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF1976D2),
            size: 24,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B)),
                  tooltip: 'Clear search',
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.8),
          ),
        ),
      ),
    );
  }

  /// Real-time Firestore StreamBuilder with dynamic local filtering
  Widget _buildFirestoreResults() {
    final stream = widget.customStream ?? _firestoreService.getStudentsStream();

    return StreamBuilder<List<Student>>(
      stream: stream,
      builder: (context, snapshot) {
        // 1. Loading State (Requirement 11)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF1976D2),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading student records from Firestore...',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // 2. Error State (Requirement 12)
        if (snapshot.hasError) {
          return _buildFriendlyErrorWidget(snapshot.error.toString());
        }

        final allStudents = snapshot.data ?? [];

        // 3. Empty Firestore Collection State
        if (allStudents.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_open_rounded,
                      size: 48,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Students Found in Firestore',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The Firestore "students" collection is currently empty.\nPlease add student records in Experiment 7 first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 4. Filter records locally in Dart (Case-insensitive matching for name & register number)
        final matchingStudents = FirestoreService.filterStudents(
          allStudents,
          _searchQuery,
        );

        // 5. No Matching Records State (Requirement 9)
        if (matchingStudents.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      size: 52,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No students found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No records matched "$_searchQuery".\nCheck the spelling or search by register number.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Clear Search Button (Requirement 10)
                  OutlinedButton.icon(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Clear Search'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1976D2),
                      side: const BorderSide(color: Color(0xFF1976D2)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 6. Display Student Records List (Requirements 5, 6, 7, 8)
        return Column(
          children: [
            // Status bar showing record counts
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchQuery.isEmpty
                        ? 'All Students (${allStudents.length})'
                        : 'Matching Results (${matchingStudents.length} of ${allStudents.length})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: _clearSearch,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: const Color(0xFF1976D2),
                      ),
                      child: const Text('Reset'),
                    ),
                ],
              ),
            ),

            // Responsive Student List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: matchingStudents.length,
                itemBuilder: (context, index) {
                  final student = matchingStudents[index];
                  return _buildStudentCard(student);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Attractive Card displaying a single student's details (Requirement 6)
  Widget _buildStudentCard(Student student) {
    // Generate initial for avatar
    final initial = student.name.isNotEmpty
        ? student.name.trim()[0].toUpperCase()
        : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular Avatar with First Letter
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE3F2FD),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Student Information Column
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

                  // Register Number & Department Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      // Register Number Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBBDEFB)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.badge_outlined,
                              size: 14,
                              color: Color(0xFF1565C0),
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

                      // Department Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                color: Color(0xFF475569),
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

  /// Friendly error card displayed if Firestore retrieval fails (Requirement 12)
  Widget _buildFriendlyErrorWidget(String errorDetails) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.error_outline_rounded,
                      color: Colors.redAccent, size: 26),
                  SizedBox(width: 10),
                  Text(
                    'Unable to Retrieve Student Records',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Firestore retrieval failed. Please verify that:\n'
                '1. Firebase project credentials are configured in lib/firebase_options.dart\n'
                '2. Your internet connection is active\n'
                '3. Firestore Security Rules permit read access to the "students" collection',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7F1D1D),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  'Details: $errorDetails',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Banner displayed when Firebase is not configured in firebase_options.dart
  Widget _buildConfigNotice() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF93C5FD)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFF1D4ED8), size: 26),
                  SizedBox(width: 10),
                  Text(
                    'Firebase Configuration Required',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'To retrieve and search student records from Google Cloud Firestore:\n\n'
                '1. Open lib/firebase_options.dart\n'
                '2. Paste your Firebase project configuration credentials\n'
                '3. Ensure the "students" collection from Experiment 7 exists\n'
                '4. Restart or refresh the application',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E40AF),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
