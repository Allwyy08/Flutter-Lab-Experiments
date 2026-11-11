# Experiment 10 – User Authentication using Firestore in Flutter

## 📌 Project Overview
**Secure User Login and Registration System** is a modern, responsive, and robust Flutter application implementing secure user authentication with **Firebase Authentication** (Email & Password credentials) and cloud user profile storage using **Google Cloud Firestore**.

The application enforces end-to-end security principles:
1. User registration creates an authentication account in Firebase Authentication.
2. User profile metadata (Full Name, Email Address, and Server Timestamp) is persistently stored in a Cloud Firestore collection named **`users`** using the Firebase Authentication **UID** as the document ID.
3. **Critical Security Compliance:** Passwords are processed and hashed exclusively by Firebase Authentication. Plain-text passwords are **NEVER** stored in Cloud Firestore.
4. User login authenticates credentials via `signInWithEmailAndPassword()`.
5. Upon successful login, the user is navigated to a clean **Home Dashboard** displaying their verified full name and email address.
6. A **Logout** action signs out the user via `signOut()` and returns securely to the Login screen, preventing unauthenticated access to the dashboard.

---

## 🎯 Requirements & Implementation Matrix

| Requirement | Implementation Details |
| :--- | :--- |
| **1. Professional Interface** | Modern, clean UI with white backgrounds, royal blue accents (`#1976D2`), rounded cards, and responsive layout. |
| **2. Login Screen** | Contains Email Address, Password, Login button, and "Create Account" option. |
| **3. Registration Screen** | Contains Full Name, Email Address, Password, Confirm Password, and Register button. |
| **4. Input Validation** | `Form` and `GlobalKey<FormState>` validate all input fields for presence and minimum lengths. |
| **5. Email Format Validation** | Validates email format using regex `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`. |
| **6. Password Length** | Enforces passwords with at least 6 characters (`length >= 6`). |
| **7. Password Matching** | Validates that Confirm Password matches Password exactly. |
| **8. Friendly Error Messages** | Clear error banners, helper texts, and floating SnackBars for invalid inputs or authentication errors. |
| **9. Firebase Authentication** | Authenticates users using official `firebase_auth` package (`createUserWithEmailAndPassword`, `signInWithEmailAndPassword`). |
| **10. Firestore Profile Storage** | Saves `{ 'name': name, 'email': email, 'created_at': FieldValue.serverTimestamp() }` into `users/{UID}` in Cloud Firestore. Never stores passwords! |
| **11. Home Dashboard Navigation** | Navigates to a dedicated Home Dashboard upon successful authentication. |
| **12. Display Name & Email** | Displays the authenticated user's name, email, UID, and creation timestamp on the dashboard. |
| **13. Logout Button** | Prominent Logout button on dashboard and AppBar with confirmation dialog. |
| **14. Secure Logout** | Calls `FirebaseAuth.instance.signOut()` and routes back to the Login screen using `pushAndRemoveUntil`. |
| **15. Error Handling** | Maps `FirebaseAuthException` codes (`wrong-password`, `user-not-found`, `invalid-credential`, `email-already-in-use`, `weak-password`) to human-friendly feedback. |
| **16. Access Protection** | Blocks unauthenticated users from accessing the dashboard. |

---

## ☁️ Firebase Architecture & Security Design

### Firebase Authentication + Cloud Firestore Workflow:
```
           [ Registration Flow ]
User Input ─────────────────────────────────────► Firebase Authentication
(Name, Email, Password)                          (Creates user, hashes password)
                                                               │
                                                               ▼ (returns UID)
                                                  Cloud Firestore
                                                  Collection: "users"
                                                  Document ID: UID
                                                  Data: {
                                                    name: "Full Name",
                                                    email: "user@example.com",
                                                    created_at: ServerTimestamp
                                                  }
                                                  * ZERO PASSWORDS STORED! *

              [ Login Flow ]
User Input ─────────────────────────────────────► Firebase Authentication
(Email, Password)                                (Verifies credentials)
                                                               │
                                                               ▼ (valid session)
                                                  Cloud Firestore
                                                  Fetches users/{UID}
                                                               │
                                                               ▼
                                                  Home Dashboard Screen
                                                  (Displays Name, Email, Status)
```

### Firestore Security Rules:
To protect user profiles so that each user can only read and write their own document:
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

---

## 🛠️ Firebase Console Configuration Guide

This project reuses the existing Firebase project configured in Experiment 7:

1. **Verify Email/Password Sign-in Method:**
   - Open [Firebase Console](https://console.firebase.google.com/).
   - Select your project.
   - Navigate to **Authentication** → **Sign-in method**.
   - Ensure **Email/Password** is **Enabled**.
   - If not enabled, click **Email/Password**, toggle the **Enable** switch, and click **Save**.

2. **Verify Cloud Firestore Database:**
   - Navigate to **Firestore Database**.
   - Ensure the database is initialized.
   - The **`users`** collection will be automatically populated with document IDs corresponding to the user UID upon registration.

3. **Configure Project Credentials in `lib/firebase_options.dart`:**
   - Copy your Web configuration keys from **Project Settings** → **General** → **Your apps**.
   - Paste them into `lib/firebase_options.dart`:
   ```dart
   static const FirebaseOptions web = FirebaseOptions(
     apiKey: 'YOUR_API_KEY',
     appId: 'YOUR_APP_ID',
     messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
     projectId: 'YOUR_PROJECT_ID',
     authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
     storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
   );
   ```

*(Note: When real credentials are pending in `lib/firebase_options.dart`, the app runs in interactive Demo Mode with simulated in-memory Firestore storage, allowing immediate UI verification without crashing).*

---

## 🚀 Running the Application

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run in Google Chrome
```bash
flutter run -d chrome
```

### 3. Run Automated Unit & Widget Tests
```bash
flutter test
```
All 16 unit and widget tests will execute and pass:
- UserProfile model serialization and security checks (zero passwords in Firestore map)
- Placeholder credentials detection
- Form validation (empty inputs, invalid email, password < 6 chars, mismatch)
- Password visibility toggling
- Registration flow & Firestore profile creation
- Login flow & credentials verification
- Unauthenticated access prevention
- Dashboard display of name and email
- Secure logout flow

---

## 🧪 Testing Checklist

- [x] **Test 1: Registration** — Register new user with full name, valid email, and password.
- [x] **Test 2: Firebase Auth Verification** — Account created via `createUserWithEmailAndPassword`.
- [x] **Test 3: Firestore Storage** — Profile document saved in `users/{UID}` with name, email, and created_at.
- [x] **Test 4: Password Security** — Plain-text password is never stored in Firestore.
- [x] **Test 5: Login** — Sign in with registered email and password.
- [x] **Test 6: Home Dashboard** — Authenticated dashboard displays user name, email, and status.
- [x] **Test 7: Incorrect Password** — Friendly error message "Incorrect password" displayed.
- [x] **Test 8: Unregistered Email** — Friendly error message "No account found with this email" displayed.
- [x] **Test 9: Invalid Email Format** — Validation error "Please enter a valid email address".
- [x] **Test 10: Empty Fields** — Validation errors displayed for missing inputs.
- [x] **Test 11: Password Mismatch** — Validation error "Confirm Password must match Password".
- [x] **Test 12: Password Length** — Validation error "Password must contain at least 6 characters".
- [x] **Test 13: Password Visibility** — Toggle button switches between visible and obscured text.
- [x] **Test 14: Logout Flow** — Signs out via `signOut()` and returns cleanly to Login screen.
- [x] **Test 15: Route Protection** — Direct access to dashboard without auth is blocked.
