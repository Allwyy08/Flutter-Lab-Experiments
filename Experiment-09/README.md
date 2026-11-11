# Experiment 9 – Firestore Data Update using Flutter

## 📌 Project Overview
**Student Record Update System** is a clean, modern, and responsive Flutter application that allows users to search for existing student records stored in **Google Cloud Firestore** using their unique **Register Number** and update their details in place.

The application connects to the cloud database collection named **`students`** created in Experiment 7, searches for the matching document using the `register_number` field, displays the current student details inside an attractive card, allows editing of the **Student Name** and **Department** while keeping the **Register Number** permanently locked as the unique identifier, and modifies the existing document in place using Firestore's `documentReference.update()`.

---

## 🎯 Requirements & Implementation Matrix

| Requirement | Implementation Details |
| :--- | :--- |
| **1. Professional AppBar** | Styled `AppBar` with title **"Update Student Records"**, cloud status indicator, blue accent (`#1976D2`), white text, and subtle elevation. |
| **2. Register Number TextField** | Clean `TextField` with `Icons.badge_outlined`, character auto-capitalization, hint text, and clear button. |
| **3. Search Student Button** | Dedicated elevated button with search icon that triggers Firestore query. |
| **4. Cloud Firestore Search** | Queries existing Firestore collection **`students`** using `where('register_number', isEqualTo: regNo)`. |
| **5. Display Student Details** | Displays Student Name, Register Number, Department, and Document ID inside an attractive `Card`. |
| **6. Editable Fields** | Editable `TextFormField` widgets for **Student Name** and **Department** with icons and validation. |
| **7. Locked Register Number** | Register Number is displayed as read-only / disabled with a lock icon (`Icons.lock_rounded`) to guarantee immutability. |
| **8. Update Student Button** | Dedicated elevated button with `Icons.save_rounded` that validates and triggers the update operation. |
| **9. Document update()** | Executes `FirebaseFirestore.instance.collection('students').doc(docId).update({...})` without creating a new document. |
| **10. Success Message** | Displays clear floating green SnackBar and inline success card upon successful cloud update. |
| **11. Error Message** | Displays informative red alert banner and SnackBar if student does not exist or network fails. |
| **12. Refresh Displayed Info** | Refetches updated document data from Firestore and refreshes the displayed card in real time. |
| **13. Input Validation** | `GlobalKey<FormState>` enforces validation ensuring neither Name nor Department can be submitted empty. |
| **14. Reset Button** | Clear button that resets search input, editable form, and hides the student card. |

---

## ☁️ Google Cloud Firestore Architecture

### Database Schema (reused from Experiment 7):
- **Collection Name:** `students`
- **Document Fields:**
  - `name`: Full name of student (`String`)
  - `register_number`: Unique registration number (`String`) — **IMMUTABLE**
  - `department`: Department / Branch (`String`)
  - `created_at`: Initial creation timestamp (`Timestamp`)
  - `updated_at`: Document update timestamp (`Timestamp`)

### Update vs Insert Strategy:
- **`add()` / `set()` (Insert/Overwrite):** Used when creating new documents.
- **`update()` (In-place Mutation):** Used in Experiment 9 to safely modify only specified fields (`name`, `department`, `updated_at`) on the existing document reference without deleting, duplicating, or recreating documents.

```dart
// Safe in-place document update
await FirebaseFirestore.instance
    .collection('students')
    .doc(docId)
    .update({
      'name': name.trim(),
      'department': department.trim(),
      'updated_at': FieldValue.serverTimestamp(),
    });
```

---

## 🛠️ Firebase Setup & Configuration

This project reuses the Firebase configuration from Experiment 7:

### Option 1: Automated Configuration with FlutterFire CLI
```bash
firebase login
flutterfire configure
```
Select your Firebase project; FlutterFire CLI will update `lib/firebase_options.dart`.

### Option 2: Manual Configuration via Firebase Console
1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Select your Firebase project created in Experiment 7.
3. Verify the **`students`** collection exists under **Firestore Database**.
4. Paste the Web configuration into `lib/firebase_options.dart`:
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

---

## 🚀 Running the Application

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the Web Application
```bash
flutter run -d chrome
```

### 3. Run Automated Unit & Widget Tests
```bash
flutter test
```
All 14 tests will execute and pass:
- Student Model toMap, fromMap, copyWith unit tests
- Search and retrieval widget tests
- Locked register number verification
- Editable form validation tests
- In-place Firestore update tests
- Reset button tests

---

## 🧪 Testing Checklist

- [x] **Test 1:** Search using an existing Register Number (e.g. `23CSE001`).
- [x] **Test 2:** Verify that the student details appear inside the card.
- [x] **Test 3:** Change the student name.
- [x] **Test 4:** Change the department.
- [x] **Test 5:** Click "Update Student".
- [x] **Test 6:** Verify the success message appears.
- [x] **Test 7:** Check Firebase Console and confirm the document is updated in place.
- [x] **Test 8:** Search again and verify the new details appear.
- [x] **Test 9:** Test with a non-existing Register Number (e.g. `99XYZ999`).
- [x] **Test 10:** Test empty input validation (empty search and empty name/department).
