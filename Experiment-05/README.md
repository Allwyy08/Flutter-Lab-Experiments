# Experiment 5 – Application State Management using Flutter

## 📌 Project Overview
**Personal Budget Calculator** is a clean, modern, and beginner-friendly Flutter application designed to track personal finances by accepting monthly income and expenses, dynamically computing the remaining balance, and presenting real-time financial health status.

This application demonstrates fundamental Flutter state management principles using **`StatefulWidget`** and **`setState()`**, alongside robust form handling with **`Form`**, **`GlobalKey<FormState>`**, **`TextFormField`**, and **`TextEditingController`**.

---

## 🎯 Requirements & Implementation Matrix

| Requirement | Implementation Details |
| :--- | :--- |
| **1. Professional AppBar** | Styled AppBar with title **"Personal Budget Calculator"**, wallet icon, and AppBar reset action button. |
| **2. Monthly Income Field** | `TextFormField` with prefix icon (`Icons.account_balance_wallet_outlined`), `₹` prefix, numeric decimal keyboard, and helper text. |
| **3. Monthly Expenses Field** | `TextFormField` with prefix icon (`Icons.shopping_bag_outlined`), `₹` prefix, numeric decimal keyboard, and helper text. |
| **4. Calculate Budget Button** | Primary royal blue `ElevatedButton.icon` with calculator icon that triggers form validation and computes remaining balance. |
| **5. Balance Formula** | Implements the formula: `Remaining Balance = Monthly Income - Monthly Expenses`. |
| **6. Dynamic Display** | Dynamically presents Monthly Income, Monthly Expenses, and Remaining Balance across responsive, attractive Cards. |
| **7. Financial Status Feedback** | • **Positive Balance:** `"Good! You have savings."` (Emerald Green)<br>• **Zero Balance:** `"Your budget is balanced."` (Ocean Blue)<br>• **Negative Balance:** `"Warning! You are overspending."` (Crimson Red) |
| **8. StatefulWidget & setState()** | Reactive state updates using Flutter's native `StatefulWidget` and `setState()` without external state management overhead. |
| **9. Reset Functionality** | Clear/Reset button that wipes all input fields, resets validation errors, clears calculated values, and restores initial placeholder state. |
| **10. Strict Input Validation** | Validates that fields are not empty and accept only valid non-negative numbers (`>= 0`). |
| **11. Clean Modern UI** | White background with royal blue (`#1565C0`) and emerald green (`#2E7D32`) accent colors. |
| **12. Responsive Layout** | Centered constrained container with scrollable viewport for seamless responsiveness on mobile and Google Chrome. |

---

## 📐 Mathematical Formula & Logic

$$\text{Remaining Balance} = \text{Monthly Income} - \text{Monthly Expenses}$$

### Financial Status Logic:
$$\text{Status} = \begin{cases} 
\text{"Good! You have savings."} & \text{if } \text{Remaining Balance} > 0 \\
\text{"Your budget is balanced."} & \text{if } \text{Remaining Balance} = 0 \\
\text{"Warning! You are overspending."} & \text{if } \text{Remaining Balance} < 0 
\end{cases}$$

---

## 🧪 Verified Test Cases

| Test Case | Monthly Income | Monthly Expenses | Expected Balance | Financial Status | Result |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **1. Standard Savings** | `₹ 30,000` | `₹ 18,000` | `₹ 12,000` | **Good! You have savings.** | ✅ Passed |
| **2. Balanced Budget** | `₹ 25,000` | `₹ 25,000` | `₹ 0` | **Your budget is balanced.** | ✅ Passed |
| **3. Overspending** | `₹ 20,000` | `₹ 25,000` | `-₹ 5,000` | **Warning! You are overspending.** | ✅ Passed |
| **4. Empty Input Validation** | `[Empty]` | `[Empty]` | *None* | Shows validation error messages | ✅ Passed |
| **5. Negative Input Validation** | `-30000` | `-18000` | *None* | Shows non-negative validation error | ✅ Passed |
| **6. Reset Button** | `₹ 30,000` | `₹ 18,000` | *Cleared* | Restores initial placeholder card | ✅ Passed |

---

## 🚀 Running the Application

### 1. Fetch Dependencies
```bash
flutter pub get
```

### 2. Run on Google Chrome
```bash
flutter run -d chrome
```

### 3. Run on Windows Desktop
```bash
flutter run -d windows
```

### 4. Run Automated Widget & Unit Tests
```bash
flutter test
```

### 5. Check Code Quality & Static Analysis
```bash
flutter analyze
```

---

## 📁 Project Structure
```text
Experiment-05/
├── lib/
│   └── main.dart             # Full implementation with StatefulWidget, Form validation & UI
├── test/
│   └── widget_test.dart      # 7 comprehensive widget & unit tests covering all requirements
├── web/                      # Web support files (manifest, index.html, icons)
├── windows/                  # Windows desktop native runner
├── LAB_RECORD_EXP_5.md       # Comprehensive academic lab record
├── pubspec.yaml              # Project metadata & dependencies
└── README.md                 # Detailed documentation
```
