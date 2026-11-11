# Experiment 3 – Add Interactivity to App (Input and Forms) using Flutter

## 📌 Project Overview
**Product Explorer** is an interactive, modern, and user-friendly Flutter application designed to demonstrate state management, user input handling, and dynamic filtering. The app allows users to search products by name using a `TextField` and filter them by category using a `DropdownButtonFormField`, with dynamic results updating seamlessly via `StatefulWidget` and `setState()`.

---

## 🎯 Key Features & Requirements Met

| Requirement | Implementation Details |
| :--- | :--- |
| **1. Professional AppBar** | Clean AppBar titled **"Product Explorer"** with an explore icon and a dynamic reset action button. |
| **2. At Least 10 Products** | Curated catalog of **12 products** across 6 diverse categories (Electronics, Footwear, Apparel, Accessories, Home & Kitchen, Stationery). |
| **3. Complete Product Attributes** | Each product includes: `id`, `name`, `category`, `price`, `emoji`, `icon`, and `description`. |
| **4. TextField Search Bar** | Styled `TextField` search bar with search icon, subtle borders, and placeholder text at the top of the interface. |
| **5. Product Name Search** | Real-time, case-insensitive substring search matching against product names dynamically. |
| **6. Dropdown Category Filter** | `DropdownButtonFormField<String>` styled with category icon, rounded borders, and custom dropdown items. |
| **7. "All Categories" Option** | Default category option allowing users to view products across all categories simultaneously. |
| **8. Dynamic Result Updates** | Combined filter computation updates the UI reactively as the user types or selects categories. |
| **9. "No products found" State** | Dedicated empty state view with illustration icon, bold **"No products found"** headline, contextual feedback, and a quick reset button. |
| **10. Clear Search Button** | Dedicated clear button (`IconButton` suffix) inside the search field to reset queries instantly. |
| **11. StatefulWidget & setState()** | Interactive state managed cleanly using Flutter's native `StatefulWidget` and `setState()` without unnecessary external state packages. |
| **12. Reusable ProductCard** | Encapsulated custom widget (`ProductCard`) displaying product emoji/icon container, name, category badge, and formatted price. |

---

## 🏗️ Architecture & Code Structure

```
Experiment-03/
├── lib/
│   └── main.dart            # Complete application (ProductExplorerApp, Product, ProductExplorerScreen, ProductCard)
├── test/
│   └── widget_test.dart     # Comprehensive unit and widget tests for search, filter, and UI behavior
├── web/                     # Web platform runner and assets
├── windows/                 # Windows desktop runner and configuration
├── pubspec.yaml             # Flutter project metadata and dependencies
├── analysis_options.yaml    # Flutter linting and static analysis rules
├── LAB_RECORD_EXP_3.md      # Laboratory record and comprehensive experiment documentation
└── README.md                # Project documentation and guide
```

---

## 💡 How the Filtering Mechanism Works

```
+-------------------------------------------------------------------------------+
| User Types Search Query ("Watch")  |  User Selects Category ("Electronics")   |
+------------------------------------+------------------------------------------+
                                    │
                                    ▼
                _searchQuery = "watch".toLowerCase()
                _selectedCategory = "Electronics"
                                    │
                                    ▼
                    Computed Getter: _filteredProducts
  ┌───────────────────────────────────────────────────────────────────────────┐
  │  _allProducts.where((product) {                                           │
  │    final matchesSearch = cleanQuery.isEmpty ||                            │
  │        product.name.toLowerCase().contains(cleanQuery);                  │
  │    final matchesCategory = _selectedCategory == 'All Categories' ||       │
  │        product.category == _selectedCategory;                            │
  │    return matchesSearch && matchesCategory;                               │
  │  }).toList();                                                             │
  └───────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
        _filteredProducts.isNotEmpty    _filteredProducts.isEmpty
                    │                               │
                    ▼                               ▼
          ListView.builder(...)             _buildEmptyState()
        (Shows ProductCard items)       ("No products found" + Reset)
```

---

## 🚀 How to Run the Project

1. Navigate to the Experiment-03 directory:
   ```bash
   cd Experiment-03
   ```

2. Fetch Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application in Google Chrome:
   ```bash
   flutter run -d chrome
   ```

4. Run the automated widget tests:
   ```bash
   flutter test
   ```

5. Run static analysis:
   ```bash
   flutter analyze
   ```
