# Experiment 6 – Data Persistence using SQLite in Flutter

## 📌 Project Overview
**Student Records Management System** is a clean, modern, and robust Flutter application designed to store and manage student information locally using an on-device SQLite database. 

The application demonstrates reliable local data persistence using Flutter's **`sqflite`** package along with **`sqflite_common_ffi`** for cross-platform and Windows desktop execution. It encapsulates all SQLite operations within a dedicated **`DatabaseHelper`** singleton and provides reactive user interface updates with **`StatefulWidget`**, Material 3 cards, and form validation.

---

## 🎯 Requirements & Implementation Matrix

| Requirement | Implementation Details |
| :--- | :--- |
| **1. Professional AppBar** | Styled AppBar with title **"Student Records"**, school icon, deep royal blue styling (`#1565C0`), and elevation. |
| **2. Three Input Fields** | • **Student Name:** `TextFormField` with prefix icon `Icons.person_outline_rounded` and hint text.<br>• **Register Number:** `TextFormField` with prefix icon `Icons.badge_outlined` and hint text.<br>• **Department:** `TextFormField` with prefix icon `Icons.school_outlined` and hint text. |
| **3. Save Student Button** | Prominent primary blue `ElevatedButton.icon` with save icon that validates fields and triggers database insertion. |
| **4. SQLite Persistence** | Saves records in a local SQLite database named **`students.db`** using **`sqflite`** and **`sqflite_common_ffi`**. |
| **5. Display Below Input Form** | Dynamically renders all stored student records underneath the input form inside a scrollable view. |
| **6. Student Card Display** | Each student record card displays:<br>• **Student Name** (with circle avatar initial)<br>• **Register Number** (with badge icon)<br>• **Department** (with school icon)<br>• **ID Sequence Badge** (`#id`) |
| **7. CREATE & READ Only** | Strictly implements **CREATE** (`insertStudent()`) and **READ** (`getStudents()`). No extraneous update/delete operations. |
| **8. Empty State Message** | When the database contains no records, an informative placeholder card is displayed: *"No student records available. Fill in the student details above and click 'Save Student' to persist a record."* |
| **9. Strict Input Validation** | `GlobalKey<FormState>` validates that all three fields are non-empty and non-whitespace before saving. |
| **10. Automatic Refresh** | Automatically calls `_refreshStudentList()` after every insertion to update the UI instantly. |
| **11. Success Notification** | Displays a floating emerald green `SnackBar` notification with checkmark: *"Student record saved successfully!"*. |
| **12. Platform Architecture** | Configured with `sqflite_common_ffi` for native Windows desktop and test execution. |

---

## 🗄️ Database Architecture & Schema

### Database Configuration:
- **Database Name:** `students.db`
- **Helper Class:** `DatabaseHelper` (Thread-safe singleton)
- **Table Name:** `students`

### Table Schema:
```sql
CREATE TABLE students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  register_number TEXT NOT NULL,
  department TEXT NOT NULL
);
```

### Methods Implemented:
- `insertStudent(Map<String, dynamic> student)`: Inserts a new student record into SQLite table `students` and returns the autoincrement ID.
- `getStudents()`: Retrieves all records from `students` ordered by `id DESC` (newest records first).

---

## 🧪 Verified Test Cases

All 7 unit and widget tests pass with 100% verification:

| Test Case | Inputs | Expected Behavior | Result |
| :--- | :--- | :--- | :---: |
| **1. DatabaseHelper SQLite Unit Tests** | `insertStudent()` & `getStudents()` | Verifies SQLite table creation, row insertion, and reading records in order. | ✅ Passed |
| **2. Initial UI & Empty State** | Initial render | Renders AppBar title, 3 input fields, Save button, and empty state placeholder. | ✅ Passed |
| **3. Empty Field Validation** | All fields blank $\rightarrow$ Save | Triggers error messages: *"Please enter student name"*, *"Please enter register number"*, *"Please enter department"*. | ✅ Passed |
| **4. Whitespace Validation** | Fields filled with whitespace | Rejects input and displays validation error prompts. | ✅ Passed |
| **5. Insert Student (Allwyn)** | `Name: Allwyn`<br>`Reg: 23CSE001`<br>`Dept: CSE (AI)` | Inserts record, clears inputs, displays success SnackBar, and renders student card in list. | ✅ Passed |
| **6. Multiple Records** | Adds 2nd student (`Jane Doe`, `23CSE002`) | Displays both records in the list with active record counter badge (`2 Records`). | ✅ Passed |
| **7. SQLite Persistence** | Close app & reopen widget tree | Previously saved SQLite record (`Allwyn`) persists and is reloaded automatically from `students.db`. | ✅ Passed |

---

## 🚀 Running the Application

### 1. Fetch Dependencies
```bash
flutter pub get
```

### 2. Run on Windows Desktop
```bash
flutter run -d windows
```

### 3. Run Automated Tests
```bash
flutter test
```

### 4. Run Code Quality & Static Analysis
```bash
flutter analyze
```

---

## 📁 Project Structure
```text
Experiment-06/
├── lib/
│   ├── database_helper.dart  # SQLite DatabaseHelper singleton with CREATE & READ
│   └── main.dart             # Responsive Flutter UI with Form, SnackBar & ListView.builder
├── test/
│   └── widget_test.dart      # 7 comprehensive SQLite unit, widget & persistence tests
├── windows/                  # Windows desktop native C++ runner
├── LAB_RECORD_EXP_6.md       # Comprehensive academic lab record
├── pubspec.yaml              # Project metadata & sqflite dependencies
└── README.md                 # Project documentation
```
