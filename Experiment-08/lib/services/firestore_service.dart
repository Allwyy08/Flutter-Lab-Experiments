import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

/// Service class handling Google Cloud Firestore retrieval operations for students.
class FirestoreService {
  final FirebaseFirestore? _customFirestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  /// Lazy getter for Firestore instance.
  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  /// Reference to the existing "students" collection in Cloud Firestore.
  CollectionReference<Map<String, dynamic>> get studentsCollection =>
      _firestore.collection('students');

  /// Retrieve all student records from Firestore as a real-time Stream.
  /// Subscribes to snapshots() and maps documents to Student objects.
  Stream<List<Student>> getStudentsStream() {
    return studentsCollection.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Student.fromFirestore(doc))
          .toList();
      // Sort newest first by creation timestamp
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Fetch all saved student records once using get().
  Future<List<Student>> getStudentsOnce() async {
    final snapshot = await studentsCollection.get();
    final list = snapshot.docs
        .map((doc) => Student.fromFirestore(doc))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Filter a list of students based on user search query.
  /// Supports case-insensitive partial matching on both Student Name and Register Number.
  static List<Student> filterStudents(List<Student> students, String query) {
    if (query.trim().isEmpty) {
      return students;
    }
    return students.where((student) => student.matchesQuery(query)).toList();
  }
}
