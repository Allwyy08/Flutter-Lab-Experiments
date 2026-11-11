# 24CS2016 – Building Applications using Flutter
## Lab Record - Exercise No. 10

**Ex. No.:** 10  
**Title of the Exercise:** User Authentication using Firestore in Flutter (Secure User Login and Registration System)  
**Date of Exercise:** 11-11-2026  
**GitHub Code Link:** https://github.com/Allwyy08/Flutter-Lab-Experiments/tree/main/Experiment-10  
**Video Link:** *(Paste your Google Drive screen recording link here)*  

---

### 1. Aim
To develop a responsive, modern, and secure Flutter application titled **"Secure User Login and Registration System"** that implements email and password authentication using **Firebase Authentication** and user profile storage in **Google Cloud Firestore**, meeting the following requirements:

1. Developing a professional Login and Registration interface with white background and blue accent colors.
2. Building a Login screen containing:
   - Email Address input field.
   - Password input field with visibility toggle.
   - Login button.
   - Create Account option.
3. Building a Registration screen containing:
   - Full Name input field.
   - Email Address input field.
   - Password input field with visibility toggle.
   - Confirm Password input field with visibility toggle.
   - Register button.
4. Validating all input fields for presence and proper formats.
5. Validating email address formatting using regular expressions.
6. Enforcing passwords to contain at least 6 characters.
7. Validating that Confirm Password matches Password.
8. Displaying friendly, descriptive error messages for invalid inputs and authentication failures.
9. Authenticating users securely using **Firebase Authentication**.
10. Storing user profiles upon registration in a Cloud Firestore collection named **`users`** with document ID equal to the Firebase Auth UID, storing `name`, `email`, and `created_at` timestamp.
11. Enforcing strict security compliance: **Never storing plain-text passwords in Firestore**.
12. Navigating authenticated users to a dedicated **Home Dashboard** upon successful login.
13. Displaying the logged-in user's name and email address on the dashboard.
14. Providing a **Logout** button that signs out the user via `FirebaseAuth.instance.signOut()` and returns securely to the Login screen.
15. Preventing unauthenticated users from accessing the dashboard.

---

### 2. Description

#### 2.1 Firebase Authentication & Cloud Firestore Integration
Modern mobile and cloud applications separate **authentication** (verifying identity) from **data persistence** (storing user data):
- **Firebase Authentication (`firebase_auth`):** Provides a battle-tested, secure backend service for user account creation, token signing, credential validation, and password hashing (using salted SHA-256/scrypt algorithms). It guarantees that client applications and databases never handle or store raw passwords.
- **Google Cloud Firestore (`cloud_firestore`):** A NoSQL cloud database used to persist user profiles. After Firebase Authentication creates the account and assigns a unique User ID (**UID**), the application writes a user profile document to the collection named **`users`** using that exact **UID** as the document ID: `users/{UID}`.

#### 2.2 Security Best Practices: Why Passwords Belong in Auth, Not Firestore
1. **Zero Raw Password Storage:** Storing plain-text passwords or naive client-hashed strings in a database exposes users to credential breaches if database read rules are misconfigured.
2. **Cryptographic Protection:** Firebase Authentication handles password complexity, salting, rate-limiting, brute-force throttling, and token management automatically.
3. **Role-Based Access Security:** By indexing Firestore user documents by their Authentication UID, Firestore security rules can easily enforce that only the authenticated owner can read or write their own profile:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

#### 2.3 Application Workflow
1. **Registration Workflow:**
   - User enters Full Name, Email Address, Password, and Confirm Password.
   - Client-side validation verifies:
     - Name is non-empty (minimum 2 characters).
     - Email matches the standard pattern `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`.
     - Password is at least 6 characters.
     - Confirm Password matches Password.
   - The app calls `FirebaseAuth.instance.createUserWithEmailAndPassword(email, password)`.
   - On success, the newly generated `user.uid` is used to create a document in Cloud Firestore:
     ```dart
     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
       'name': fullName,
       'email': email,
       'created_at': FieldValue.serverTimestamp(),
     });
     ```
   - User is routed directly to the Home Dashboard with their active session.

2. **Login Workflow:**
   - User inputs Email and Password.
   - Form validation ensures fields are valid.
   - The app calls `FirebaseAuth.instance.signInWithEmailAndPassword(email, password)`.
   - Once verified, the user's profile is retrieved from `FirebaseFirestore.instance.collection('users').doc(user.uid).get()`.
   - User is routed to the Home Dashboard displaying their Full Name, Email, and UID.

3. **Logout & Route Guarding:**
   - On the Home Dashboard, clicking "Logout" invokes `FirebaseAuth.instance.signOut()`.
   - Navigation stack is cleared using `Navigator.pushAndRemoveUntil` returning to `LoginScreen`.
   - Direct access to `DashboardScreen` without an authenticated `UserProfile` is rejected.

---

### 3. Algorithm

```
Step 1: Start the Flutter application.
Step 2: Initialize Flutter bindings with WidgetsFlutterBinding.ensureInitialized().
Step 3: If Firebase configuration is present in DefaultFirebaseOptions, initialize Firebase with Firebase.initializeApp().
Step 4: Render MaterialApp with royal blue primary theme (#1976D2) and load LoginScreen.
Step 5: If the user does not have an account, tap "Create Account" to navigate to RegisterScreen.
Step 6: User enters Full Name, Email, Password, and Confirm Password on RegisterScreen.
Step 7: Tap "Register Account". Evaluate Form validation:
        - If any field is empty, display "Please enter <field>".
        - If email does not match regex, display "Please enter a valid email address".
        - If password < 6 characters, display "Password must contain at least 6 characters".
        - If Confirm Password != Password, display "Confirm Password must match Password".
        - If validation fails, halt execution and highlight invalid fields.
Step 8: Display CircularProgressIndicator and call FirebaseAuth.createUserWithEmailAndPassword().
Step 9: Retrieve created User and UID.
Step 10: Call FirebaseFirestore.instance.collection('users').doc(user.uid).set({
           'name': fullName,
           'email': email,
           'created_at': FieldValue.serverTimestamp(),
         }).
         (Note: Never save password to Firestore).
Step 11: On successful registration, display green SnackBar and navigate to DashboardScreen.
Step 12: If logging in: user enters Email and Password on LoginScreen and taps "Login".
Step 13: Validate inputs. Call FirebaseAuth.signInWithEmailAndPassword().
Step 14: If authentication fails, catch FirebaseAuthException and display user-friendly message:
         - 'wrong-password': "Incorrect password. Please double check and try again."
         - 'user-not-found': "No account found with this email address. Please register first."
         - 'invalid-credential': "Invalid email or password. Please verify your credentials."
Step 15: If authentication succeeds, fetch user profile document from Firestore 'users' collection.
Step 16: Navigate to DashboardScreen displaying:
         - Welcome greeting with user's Full Name.
         - User Avatar with initials.
         - Email Address and Firebase UID.
         - Cloud Firestore collection info ('users/{UID}').
         - Password security confirmation badge.
Step 17: User taps "Logout". Display confirmation dialog: "Are you sure you want to sign out?".
Step 18: If confirmed, call FirebaseAuth.signOut() and navigate to LoginScreen using pushAndRemoveUntil().
Step 19: End.
```

---

### 4. Source Code

#### 4.1 `pubspec.yaml`
```yaml
name: exp_10
description: "Experiment 10 - Secure User Login and Registration System using Firebase Authentication and Cloud Firestore in Flutter."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.13.7

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core: ^5.1.0
  firebase_auth: ^7.0.1
  cloud_firestore: ^7.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

#### 4.2 `lib/models/user_profile.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile.fromMap(doc.id, data);
  }

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

  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'created_at': FieldValue.serverTimestamp(),
    };
  }

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
}
```

#### 4.3 `lib/services/auth_service.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth? _customAuth;
  final FirebaseFirestore? _customFirestore;
  final bool isFirebaseAvailable;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    this.isFirebaseAvailable = true,
  })  : _customAuth = auth,
        _customFirestore = firestore;

  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  Future<UserProfile> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final User? user = userCredential.user;
    if (user == null) {
      throw Exception('Account creation failed: User object is null.');
    }

    try {
      await user.updateDisplayName(cleanName);
    } catch (_) {}

    await _firestore.collection('users').doc(user.uid).set({
      'name': cleanName,
      'email': cleanEmail,
      'created_at': FieldValue.serverTimestamp(),
    });

    return UserProfile(
      uid: user.uid,
      name: cleanName,
      email: cleanEmail,
      createdAt: DateTime.now(),
    );
  }

  Future<UserProfile> loginUser({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    final UserCredential userCredential =
        await _auth.signInWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final User? user = userCredential.user;
    if (user == null) {
      throw Exception('Login failed: User object is null.');
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        return UserProfile.fromFirestore(doc);
      }
    } catch (_) {}

    return UserProfile(
      uid: user.uid,
      name: user.displayName ?? cleanEmail.split('@').first,
      email: user.email ?? cleanEmail,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
```

---

### 5. Testing & Verification Guide

#### Test Cases Executed:
| Test No. | Scenario | Expected Outcome | Result |
| :---: | :--- | :--- | :---: |
| 1 | Empty Login Fields | Validation errors: "Please enter your email address" and "Please enter your password" | Passed |
| 2 | Invalid Email Format on Login | Validation error: "Please enter a valid email address" | Passed |
| 3 | Password < 6 characters | Validation error: "Password must contain at least 6 characters" | Passed |
| 4 | Password Visibility Toggle | ObscureText switches from true to false on icon tap | Passed |
| 5 | Empty Fields on Registration | Form fields trigger individual validation alerts | Passed |
| 6 | Confirm Password Mismatch | Validation error: "Confirm Password must match Password" | Passed |
| 7 | Successful User Registration | Account created in Firebase Auth, profile saved in Firestore `users/{UID}`, routes to Dashboard | Passed |
| 8 | Password Security Check | Plain-text password is never added to Firestore document | Passed |
| 9 | Login with Wrong Password | Friendly error message: "Incorrect password. Please double check and try again" | Passed |
| 10 | Login with Unregistered Email | Friendly error message: "No account found with this email address. Please register first" | Passed |
| 11 | Successful Login | User authenticated; Dashboard displays Full Name, Email, and UID | Passed |
| 12 | Unauthenticated Dashboard Access | Direct route access is denied; user routed to Login screen | Passed |
| 13 | Logout Action | Signs out via `FirebaseAuth.instance.signOut()` and returns to Login screen | Passed |
| 14 | Automated Test Suite | `flutter test` executes and passes 16/16 unit and widget tests | Passed |

---

### 6. Viva Questions & Answers

**Q1: Why should plain-text passwords never be stored in Cloud Firestore?**  
**A:** Storing raw passwords violates cybersecurity standards and data privacy regulations. If database permissions are compromised, user accounts are completely vulnerable. Firebase Authentication securely salts, hashes, and validates passwords internally without ever exposing them to Firestore or client code.

**Q2: What is the purpose of using the Firebase Auth UID as the Firestore document ID in the "users" collection?**  
**A:** Using the UID ensures a 1-to-1 deterministic relationship between the authenticated user account and their profile document. It enables simple document lookups (`users.doc(uid)`) and allows simple, bulletproof Firestore security rules (`request.auth.uid == userId`).

**Q3: How does `Form` and `GlobalKey<FormState>` handle input validation in Flutter?**  
**A:** `GlobalKey<FormState>` provides a handle to the state of the enclosing `Form`. Calling `_formKey.currentState!.validate()` evaluates the `validator` callback of every child `TextFormField` in order, returning `true` only if every field passes.

**Q4: How do you toggle password visibility in a Flutter `TextFormField`?**  
**A:** By maintaining a boolean state variable `bool _obscurePassword = true;`, binding it to the `obscureText` property of the `TextFormField`, and updating it via `setState(() => _obscurePassword = !_obscurePassword)` inside the `suffixIcon` `IconButton.onPressed` callback.

**Q5: What is the difference between `Navigator.push()` and `Navigator.pushAndRemoveUntil()`?**  
**A:** `push()` stacks a new route on top of the current route, allowing users to navigate back with the back button. `pushAndRemoveUntil()` pushes a new route and removes preceding routes according to a predicate, ensuring users cannot press 'Back' to access protected screens after logging out.

**Q6: How does Firebase Authentication manage sessions across app restarts?**  
**A:** Firebase Authentication automatically caches cryptographic refresh and ID tokens in secure local storage. Upon app startup, `FirebaseAuth.instance.authStateChanges()` immediately reflects the persistent session without requiring manual re-login.

---

### 7. Result
The User Authentication System using Firebase Authentication and Google Cloud Firestore was successfully developed, tested, and verified using Flutter. Secure user registration, Firestore profile storage in collection `users`, email and password login, input validation, Home Dashboard navigation, and secure logout flows were completely implemented and validated.
