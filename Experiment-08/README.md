# Experiment 8 – Firestore Data Retrieval using Flutter

## 📌 Project Overview
**Student Search Application** is a modern, responsive Flutter application that dynamically retrieves and searches student records from **Google Cloud Firestore**.

The application connects to the cloud database collection named **`students`** created in Experiment 7, listens to real-time updates via **`StreamBuilder`**, and enables fast, case-insensitive partial searching across both **Student Name** and **Register Number**. When the search field is empty, all student records are displayed. When a search query is entered, the list dynamically filters in real time. If no matching records exist, an informative **"No students found"** message is displayed with a one-click **"Clear Search"** button.

---

## 🎯 Requirements & Implementation Matrix

| Requirement | Implementation Details |
| :--- | :--- |
| **1. Professional AppBar** | Styled `AppBar` with title **"Student Search"**, cloud status icon, blue accent (`#1976D2`), and subtle elevation. |
| **2. Search Bar** | Clean `TextField` search bar with search icon (`Icons.search_rounded`), rounded border, and dynamic clear button (`Icons.clear_rounded`). |
| **3. Multi-field Search** | Allows users to search students by either **Student Name** or **Register Number**. |
| **4. Cloud Firestore Retrieval** | Subscribes to the existing Firestore collection named **`students`** using `snapshots()`. |
| **5. Dynamic Display** | Matches student records dynamically on every keystroke without requiring a manual search trigger. |
| **6. Student Card Details** | Each result displays:<br>• **Student Name** (bold typography with circular initial avatar)<br>• **Register Number** (styled blue badge with ID card icon)<br>• **Department** (clean gray badge with graduation cap icon) |
| **7. Initial State** | Displays all student records initially when the search field is empty. |
| **8. Real-time Search Update** | Updates search results immediately whenever the user enters or changes search text. |
| **9. Empty Search State** | Displays an attractive **"No students found"** illustration and message when no records match the query. |
| **10. Clear Search Button** | Dedicated suffix clear icon in the search bar and a prominent **"Clear Search"** button in the empty state to reset the search instantly. |
| **11. Loading Indicator** | Displays a centered `CircularProgressIndicator` with informative loading text while retrieving data from Firestore. |
| **12. Friendly Error Handling** | Displays a clear, actionable error card if Firestore retrieval encounters network or permission issues. |

---

## ☁️ Google Cloud Firestore Architecture

### Database Schema (from Experiment 7):
- **Collection Name:** `students`
- **Document Fields:**
  - `name`: Full name of the student (`String`)
  - `register_number`: Unique registration number (`String`)
  - `department`: Department/Specialization (`String`)
  - `created_at`: Cloud server timestamp (`Timestamp`)

### Search & Filtering Strategy:
Firestore's native querying supports prefix and exact matching but lacks case-insensitive partial/substring matching without third-party search engines. Therefore, following Flutter and Firebase best practices:
1. `FirestoreService.getStudentsStream()` subscribes to the collection `snapshots()`.
2. As records arrive or update in the cloud, documents are mapped into strongly-typed `Student` models.
3. `FirestoreService.filterStudents(students, query)` applies case-insensitive partial matching across `name` and `registerNumber` in Dart memory, delivering instant 0ms latency filtering.

```dart
bool matchesQuery(String query) {
  final cleanQuery = query.trim().toLowerCase();
  if (cleanQuery.isEmpty) return true;
  return name.toLowerCase().contains(cleanQuery) ||
      registerNumber.toLowerCase().contains(cleanQuery);
}
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

## 🧪 Verified Test Cases

All 16 unit and widget tests pass with 100% verification:

| Test Case | Inputs | Expected Behavior | Result |
| :--- | :--- | :--- | :---: |
| **1. Student Model toMap** | Model instance | Produces correct Firestore keys (`name`, `register_number`, `department`, `created_at`). | ✅ Passed |
| **2. Name Search Matching** | Query: `'allwyn'` | Matches "Allwyn Noble" case-insensitively. | ✅ Passed |
| **3. Reg No Search Matching** | Query: `'23cse'` | Matches "23CSE001" case-insensitively. | ✅ Passed |
| **4. Non-matching Search** | Query: `'John'` | Returns false when no fields match. | ✅ Passed |
| **5. Empty Query Handling** | Query: `''` | Returns true (all students visible). | ✅ Passed |
| **6. Firebase Config Check** | Placeholder detection | Safely identifies unconfigured state without app crash. | ✅ Passed |
| **7. UI: AppBar Render** | Initial build | Renders title **"Student Search"** with blue accent. | ✅ Passed |
| **8. UI: Search Bar Render** | Initial build | Renders `TextField` with search icon and placeholder text. | ✅ Passed |
| **9. UI: Loading Indicator** | Waiting stream | Renders `CircularProgressIndicator` and loading label. | ✅ Passed |
| **10. UI: Initial All Records** | Empty search query | Displays all 3 sample student cards with names, reg nos, and departments. | ✅ Passed |
| **11. UI: Search by Name** | Query: `'beatrice'` | Displays only Beatrice Jones card; hides others. | ✅ Passed |
| **12. UI: Search by Reg No** | Query: `'23MECH'` | Displays only Charles Xavier card. | ✅ Passed |
| **13. UI: No Students Found** | Non-existent query | Displays **"No students found"** empty-state card with Clear button. | ✅ Passed |
| **14. UI: Clear Search Button** | Tap clear icon | Clears search input and restores all student records. | ✅ Passed |
| **15. UI: Friendly Error Card** | Stream exception | Displays friendly error message card with instructions. | ✅ Passed |
| **16. UI: Empty Collection** | 0 records stream | Displays empty Firestore collection guidance state. | ✅ Passed |

---

## 🚀 How to Run the Application

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run on Google Chrome (Web)
```bash
flutter run -d chrome
```

### 3. Run Automated Tests
```bash
flutter test
```

### 4. Run Code Analysis
```bash
flutter analyze
```

---

## 📁 Project Structure
```text
Experiment-08/
├── lib/
│   ├── firebase_options.dart     # Firebase platform configuration credentials
│   ├── main.dart                 # Responsive search UI, StreamBuilder & cards
│   ├── models/
│   │   └── student.dart          # Strongly-typed Student model with Firestore serialization & search
│   └── services/
│       └── firestore_service.dart# Cloud Firestore service with snapshots() & local filtering
├── test/
│   └── widget_test.dart          # 16 unit and widget tests covering all requirements
├── web/
│   └── index.html                # Web entry point configured for Chrome execution
├── LAB_RECORD_EXP_8.md           # Comprehensive academic lab record
├── pubspec.yaml                  # Project dependencies (firebase_core, cloud_firestore)
└── README.md                     # Project documentation
```
