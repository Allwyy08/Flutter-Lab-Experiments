import 'package:cloud_firestore/cloud_firestore.dart';

/// User Profile model representing a registered user stored in Google Cloud Firestore.
///
/// Collection: "users"
/// Document ID: Firebase Authentication UID
/// Schema:
///   - name: String (Full name of the user)
///   - email: String (Email address of the user)
///   - created_at: Timestamp (Registration server timestamp)
///
/// NOTE: Plain-text passwords are NEVER stored in Firestore.
/// Authentication credentials are managed exclusively by Firebase Authentication.
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  /// Factory constructor to create a UserProfile from a Firestore DocumentSnapshot.
  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile.fromMap(doc.id, data);
  }

  /// Factory constructor to parse document data with UID.
  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    DateTime parsedCreatedAt;
    final dynamic createdAtField = data['created_at'];

    if (createdAtField is Timestamp) {
      parsedCreatedAt = createdAtField.toDate();
    } else if (createdAtField is DateTime) {
      parsedCreatedAt = createdAtField;
    } else if (createdAtField is String) {
      parsedCreatedAt = DateTime.tryParse(createdAtField) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return UserProfile(
      uid: uid,
      name: data['name'] as String? ?? 'User',
      email: data['email'] as String? ?? '',
      createdAt: parsedCreatedAt,
    );
  }

  /// Converts the profile to a Map suitable for saving into Firestore.
  /// Passwords are intentionally omitted.
  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a copy with optionally updated fields.
  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, name: $name, email: $email, createdAt: $createdAt)';
  }
}
