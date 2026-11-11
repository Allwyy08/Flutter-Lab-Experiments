import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a Student document retrieved from Google Cloud Firestore.
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

  /// Factory constructor for direct map initialization (useful in tests).
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

  /// Checks whether this student record matches the search query.
  /// Matches case-insensitively against both Student Name and Register Number.
  bool matchesQuery(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return true;
    return name.toLowerCase().contains(cleanQuery) ||
        registerNumber.toLowerCase().contains(cleanQuery);
  }
}
