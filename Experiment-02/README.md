# Experiment 2 – Adaptive and Responsive UI Design using Flutter

## 📌 Project Overview
**ShopEasy** is a clean, modern, and fully responsive e-commerce product catalog application developed using Flutter. The application automatically adapts its layout across different screen form factors (Mobile, Tablet, and Desktop) using Flutter's layout mechanisms (`LayoutBuilder` and dynamic `GridView.builder`).

---

## 🎯 Key Features & Requirements Met

| Requirement | Implementation Details |
| :--- | :--- |
| **1. Professional AppBar** | Clean white AppBar titled **"ShopEasy"** with branded store icon and a live shopping cart badge indicator. |
| **2. At Least 8 Products** | Catalog of 8 curated items spanning Audio, Wearables, Accessories, Electronics, Fashion, and Lifestyle. |
| **3. Complete Product Details** | Each product showcases: image (network with graceful placeholder fallback), title, price, and "Add to Cart" button. |
| **4. Reusable Custom Widget** | Standalone custom widget **`ProductCard`** encapsulating the card UI, image container, details, and cart action. |
| **5. GridView.builder** | Efficient, lazy-loaded grid view displaying product cards on demand. |
| **6. Responsive Layout** | Implemented using **`LayoutBuilder`** to query available constraint width dynamically. |
| **7. Multi-Column Breakpoints** | <ul><li>**Mobile Screen (< 600px):** 2 Columns</li><li>**Tablet Screen (600px - 1024px):** 3 Columns</li><li>**Desktop Screen (≥ 1024px):** 4 Columns</li></ul> |
| **8. Proportionate Resizing** | `Expanded` flex-based layout inside cards eliminates any `RenderFlex` overflow across all screen dimensions. |
| **9. Beginner-Friendly Code** | Pure standard Flutter SDK widgets, structured models, clean architecture, and thorough comments. |
| **10. Interactive Cart State** | `StatefulWidget` managing cart count badge, animated floating SnackBars, and a full interactive Cart Summary modal. |

---

## 📐 Responsive Breakpoint Design

```
+-----------------------------------------------------------------------------------+
| Breakpoint Threshold        | Target Device Category | Column Count | Card Ratio  |
+-----------------------------------------------------------------------------------+
| Available Width < 600px     | Mobile Screen          | 2 Columns    | 0.65        |
| 600px <= Width < 1024px     | Tablet Screen          | 3 Columns    | 0.70        |
| Available Width >= 1024px   | Desktop / Web Wide     | 4 Columns    | 0.75        |
+-----------------------------------------------------------------------------------+
```

---

## 🏗️ Architecture & Code Structure

```
Experiment-02/
├── lib/
│   └── main.dart            # Complete application (ShopEasyApp, Product, ProductCatalogScreen, ProductCard)
├── test/
│   └── widget_test.dart     # Comprehensive responsive unit & widget tests
├── web/                     # Web deployment assets (index.html, manifest.json)
├── pubspec.yaml             # Flutter project dependencies and metadata
├── analysis_options.yaml    # Flutter linting and static analysis rules
├── LAB_RECORD_EXP_2.md      # Complete laboratory documentation and lab record
└── README.md                # Project documentation
```

---

## 🚀 How to Run the Project

1. Navigate to the Experiment-02 directory:
   ```bash
   cd Experiment-02
   ```

2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```

3. Run the application in Chrome:
   ```bash
   flutter run -d chrome
   ```

4. Run unit and responsive tests:
   ```bash
   flutter test
   ```

5. Run static analysis:
   ```bash
   flutter analyze
   ```
