import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a Student document in Google Cloud Firestore.
class Student {
  final String id;
  final String name;
  final String registerNumber;
  final String department;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Student({
    required this.id,
    required this.name,
    required this.registerNumber,
    required this.department,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert Student model to Firestore document Map.
  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'register_number': registerNumber.trim().toUpperCase(),
      'department': department.trim(),
      'created_at': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updated_at': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Create a copy with modified fields.
  Student copyWith({
    String? id,
    String? name,
    String? registerNumber,
    String? department,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      registerNumber: registerNumber ?? this.registerNumber,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Factory constructor to create a Student model from a Firestore DocumentSnapshot.
  factory Student.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    DateTime parsedCreated;
    final createdAtField = data['created_at'];
    if (createdAtField is Timestamp) {
      parsedCreated = createdAtField.toDate();
    } else if (createdAtField is String) {
      parsedCreated = DateTime.tryParse(createdAtField) ?? DateTime.now();
    } else {
      parsedCreated = DateTime.now();
    }

    DateTime? parsedUpdated;
    final updatedAtField = data['updated_at'];
    if (updatedAtField is Timestamp) {
      parsedUpdated = updatedAtField.toDate();
    } else if (updatedAtField is String) {
      parsedUpdated = DateTime.tryParse(updatedAtField);
    }

    return Student(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      registerNumber: data['register_number']?.toString() ?? '',
      department: data['department']?.toString() ?? '',
      createdAt: parsedCreated,
      updatedAt: parsedUpdated,
    );
  }

  /// Factory constructor to create from a Map (useful for mock/offline testing).
  factory Student.fromMap(String id, Map<String, dynamic> data) {
    DateTime parsedCreated;
    final createdAtField = data['created_at'];
    if (createdAtField is Timestamp) {
      parsedCreated = createdAtField.toDate();
    } else if (createdAtField is DateTime) {
      parsedCreated = createdAtField;
    } else if (createdAtField is String) {
      parsedCreated = DateTime.tryParse(createdAtField) ?? DateTime.now();
    } else {
      parsedCreated = DateTime.now();
    }

    DateTime? parsedUpdated;
    final updatedAtField = data['updated_at'];
    if (updatedAtField is Timestamp) {
      parsedUpdated = updatedAtField.toDate();
    } else if (updatedAtField is DateTime) {
      parsedUpdated = updatedAtField;
    } else if (updatedAtField is String) {
      parsedUpdated = DateTime.tryParse(updatedAtField);
    }

    return Student(
      id: id,
      name: data['name']?.toString() ?? '',
      registerNumber: data['register_number']?.toString() ?? '',
      department: data['department']?.toString() ?? '',
      createdAt: parsedCreated,
      updatedAt: parsedUpdated,
    );
  }
}
