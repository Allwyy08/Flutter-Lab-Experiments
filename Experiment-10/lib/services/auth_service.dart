import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

/// Service class handling Firebase Authentication and Cloud Firestore operations.
///
/// Features:
/// 1. User registration with email & password via [FirebaseAuth.createUserWithEmailAndPassword].
/// 2. User profile storage in Cloud Firestore "users" collection (UID as document ID).
/// 3. User login via [FirebaseAuth.signInWithEmailAndPassword].
/// 4. Profile retrieval from Cloud Firestore to display user details on the dashboard.
/// 5. User logout via [FirebaseAuth.signOut].
/// 6. Friendly error message translation for [FirebaseAuthException].
/// 7. Graceful offline simulation fallback when Firebase credentials are not yet configured.
class AuthService {
  final FirebaseAuth? _customAuth;
  final FirebaseFirestore? _customFirestore;
  final bool isFirebaseAvailable;

  // In-memory simulation stores for testing or when Firebase credentials are placeholders
  static final Map<String, Map<String, dynamic>> _simulatedUsers = {};
  static final Map<String, String> _simulatedPasswords = {};
  static UserProfile? _simulatedCurrentUser;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    this.isFirebaseAvailable = true,
  })  : _customAuth = auth,
        _customFirestore = firestore;

  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  /// Current authenticated user from Firebase Auth
  User? get currentUser {
    if (!isFirebaseAvailable) return null;
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Current simulated user profile when running in demo/offline mode
  UserProfile? get simulatedCurrentUser => _simulatedCurrentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new user account with Firebase Authentication and save their
  /// profile in the Cloud Firestore "users" collection.
  ///
  /// CRITICAL SECURITY REQUIREMENT:
  /// - Passwords are processed ONLY by Firebase Authentication.
  /// - Plain-text passwords are NEVER stored in Cloud Firestore.
  Future<UserProfile> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    // 1. If Firebase is active and initialized, use real Firebase services
    if (isFirebaseAvailable) {
      try {
        // Create user in Firebase Authentication
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        final User? user = userCredential.user;
        if (user == null) {
          throw Exception('Account creation failed: User object is null.');
        }

        // Update Firebase Auth display name
        try {
          await user.updateDisplayName(cleanName);
        } catch (_) {
          // Non-critical if display name update fails
        }

        // Store user profile in Firestore "users" collection using UID as document ID
        // Note: Password is never saved to Firestore!
        final profileData = {
          'name': cleanName,
          'email': cleanEmail,
          'created_at': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(user.uid).set(profileData);

        return UserProfile(
          uid: user.uid,
          name: cleanName,
          email: cleanEmail,
          createdAt: DateTime.now(),
        );
      } on FirebaseAuthException catch (e) {
        throw getFriendlyErrorMessage(e);
      } catch (e) {
        throw 'Registration failed: ${e.toString()}';
      }
    } else {
      // 2. Demo / Simulation mode fallback
      if (_simulatedUsers.containsKey(cleanEmail)) {
        throw 'An account already exists for that email address.';
      }

      final simulatedUid = 'sim_user_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();

      _simulatedUsers[cleanEmail] = {
        'uid': simulatedUid,
        'name': cleanName,
        'email': cleanEmail,
        'created_at': now,
      };
      _simulatedPasswords[cleanEmail] = password;

      final profile = UserProfile(
        uid: simulatedUid,
        name: cleanName,
        email: cleanEmail,
        createdAt: now,
      );

      _simulatedCurrentUser = profile;
      return profile;
    }
  }

  /// Sign in an existing user with email and password via Firebase Authentication,
  /// then fetch their profile from Cloud Firestore.
  Future<UserProfile> loginUser({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. If Firebase is active and initialized, use real Firebase services
    if (isFirebaseAvailable) {
      try {
        // Authenticate with Firebase Authentication
        final UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        final User? user = userCredential.user;
        if (user == null) {
          throw Exception('Login failed: User object is null.');
        }

        // Fetch user profile document from Firestore "users" collection
        try {
          final DocumentSnapshot<Map<String, dynamic>> doc =
              await _firestore.collection('users').doc(user.uid).get();

          if (doc.exists && doc.data() != null) {
            return UserProfile.fromFirestore(doc);
          }
        } catch (_) {
          // If Firestore read fails or profile document is missing, fallback to Auth metadata
        }

        return UserProfile(
          uid: user.uid,
          name: user.displayName ?? cleanEmail.split('@').first,
          email: user.email ?? cleanEmail,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        );
      } on FirebaseAuthException catch (e) {
        throw getFriendlyErrorMessage(e);
      } catch (e) {
        throw 'Login failed: ${e.toString()}';
      }
    } else {
      // 2. Demo / Simulation mode fallback
      if (!_simulatedUsers.containsKey(cleanEmail)) {
        throw 'No account found with this email address. Please register first.';
      }

      if (_simulatedPasswords[cleanEmail] != password) {
        throw 'Incorrect password. Please try again.';
      }

      final userData = _simulatedUsers[cleanEmail]!;
      final profile = UserProfile.fromMap(
        userData['uid'] as String,
        userData,
      );

      _simulatedCurrentUser = profile;
      return profile;
    }
  }

  /// Fetch a user profile document from Firestore by user UID
  Future<UserProfile?> fetchUserProfile(String uid) async {
    if (isFirebaseAvailable) {
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          return UserProfile.fromFirestore(doc);
        }
      } catch (_) {
        return null;
      }
    } else {
      if (_simulatedCurrentUser != null && _simulatedCurrentUser!.uid == uid) {
        return _simulatedCurrentUser;
      }
    }
    return null;
  }

  /// Sign out the current user from Firebase Authentication
  Future<void> signOut() async {
    if (isFirebaseAvailable) {
      try {
        await _auth.signOut();
      } catch (e) {
        throw 'Logout failed: ${e.toString()}';
      }
    } else {
      _simulatedCurrentUser = null;
    }
  }

  /// Translates Firebase Authentication error codes into human-friendly messages
  static String getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address format is invalid. Please enter a valid email.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact system support.';
      case 'user-not-found':
        return 'No account found with this email address. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please double check and try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please verify your credentials.';
      case 'email-already-in-use':
        return 'An account already exists for that email address. Please login instead.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in Firebase Console. Please enable it under Authentication > Sign-in method.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'network-request-failed':
        return 'Network connection error. Please verify your internet connection.';
      case 'too-many-requests':
        return 'Access temporarily blocked due to many failed attempts. Try again later.';
      default:
        return e.message ?? 'An unexpected authentication error occurred (${e.code}).';
    }
  }

  /// Reset in-memory simulation store (useful for tests)
  static void resetSimulation() {
    _simulatedUsers.clear();
    _simulatedPasswords.clear();
    _simulatedCurrentUser = null;
  }
}
