# Experiment 1 – Working with Widgets and Layouts using Flutter

## 📌 Project Overview
A simple, clean, and colorful **Fruit List** application developed in Flutter. The application demonstrates the core layout and styling widgets in Flutter by presenting a catalog of fresh fruits with their emojis, names, descriptions, categories, and prices.

---

## 🎯 Key Flutter Widgets Demonstrated

| Widget | Usage / Location in App |
| :--- | :--- |
| **1. Row** | Horizontally arranges the fruit emoji container on the left, fruit details in the center, and price badge on the right inside each `FruitCard`. |
| **2. Column** | <ul><li>**Center Column:** Vertically stacks the fruit name, description, and category badge.</li><li>**Right Column:** Vertically aligns the price badge and unit of measurement (e.g. `per kg`).</li></ul> |
| **3. Container** | <ul><li>Styled rounded container with background opacity for displaying the fruit emoji.</li><li>Styled pill badge for category tags (`Fresh`, `Tropical`, `Citrus`, etc.).</li><li>Styled bordered badge highlighting the fruit price.</li></ul> |
| **4. Card** | Wraps every individual fruit item, providing rounded corners (`16px`), custom elevation (`3`), and card margin for separation and visual depth. |
| **5. ListView** | Uses `ListView.builder` inside `FruitListScreen` to render the scrollable list of fruits efficiently. |

---

## 🏗️ Reusable Custom Widgets
- **`FruitCard`**: A standalone custom `StatelessWidget` that accepts a `Fruit` object and renders a styled card layout.
- **`FruitListScreen`**: A separate reusable screen widget encapsulating the `Scaffold`, `AppBar` ("Fruit List"), and `ListView.builder`.

---

## 🚀 How to Run the Project

1. Open a terminal in this directory:
   ```bash
   cd "d:\Flutter Lab exp\Exp 1"
   ```

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

