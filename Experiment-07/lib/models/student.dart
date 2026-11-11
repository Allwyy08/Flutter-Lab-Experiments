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

