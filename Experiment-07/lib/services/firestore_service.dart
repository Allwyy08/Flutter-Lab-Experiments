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
