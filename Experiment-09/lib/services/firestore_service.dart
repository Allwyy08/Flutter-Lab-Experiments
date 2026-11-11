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
  /// Uses a Firestore query on the 'register_number' field.
  Future<Student?> searchStudentByRegisterNumber(String registerNumber) async {
    final cleanReg = registerNumber.trim().toUpperCase();
    if (cleanReg.isEmpty) return null;

    // 1. Primary Query: exact match on uppercase register_number
    final querySnapshot = await studentsCollection
        .where('register_number', isEqualTo: cleanReg)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return Student.fromFirestore(querySnapshot.docs.first);
    }

    // 2. Fallback scan for case-insensitive match (in case legacy records differ)
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
  ///
  /// CRITICAL REQUIREMENTS:
  /// - Uses DocumentReference.update() to modify existing fields in place.
  /// - Does NOT use add() or set(), ensuring no new document is inserted.
  /// - Modifies only 'name' and 'department' while keeping 'register_number' intact.
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
