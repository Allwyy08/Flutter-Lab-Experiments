# 24CS2016 – Building Applications using Flutter
## Lab Record - Exercise No. 1

**Ex. No.:** 1  
**Title of the Exercise:** Working with Widgets and Layouts using Flutter (Fruit List Application)  
**Date of Exercise:** 11-11-2026  
**GitHub Code Link:** https://github.com/Allwyy08/Flutter-Lab-Experiments/tree/main/Experiment-01  
**Video Link:** *(Paste your Google Drive screen recording link here)*  

---

### 1. Aim
To develop a simple and attractive **Fruit List application** in Flutter that demonstrates core Flutter layout and styling widgets:
1. `Row`
2. `Column`
3. `Container`
4. `Card`
5. `ListView`

and implements reusable custom widgets (`FruitCard` and `FruitListScreen`).

---

### 2. Description
Flutter uses a reactive widget-tree model where the entire user interface is constructed using widgets. In this exercise, the following foundational widgets are utilized:

1. **`Row`**: A layout widget that displays its children in a horizontal array. In this application, a `Row` is used inside `FruitCard` to position the fruit emoji container, fruit text details, and price badge side by side.
2. **`Column`**: A layout widget that displays its children in a vertical array. A `Column` is used in the card center to vertically stack the fruit name, description, and category badge. Another `Column` on the right aligns the price tag and unit.
3. **`Container`**: A versatile convenience widget combining common painting, positioning, and sizing widgets. It is used to apply custom background colors, borders, and border radius for the fruit emoji container, category tag pill, and price badge.
4. **`Card`**: A Material Design card widget with slightly rounded corners and an elevation shadow. Each fruit item is enclosed inside a `Card` to establish visual hierarchy and depth.
5. **`ListView.builder`**: An efficient, scrollable list widget that lazily creates children on demand as they scroll into view. It displays the scrollable collection of fruit cards.
6. **Reusable Custom Widgets**:
   - `FruitCard`: A custom `StatelessWidget` representing an individual fruit card.
   - `FruitListScreen`: A custom screen `StatelessWidget` containing the `Scaffold`, `AppBar`, and `ListView.builder`.

---

### 3. Program Code (`lib/main.dart`)

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const FruitListApp());
}

/// Root Application Widget
class FruitListApp extends StatelessWidget {
  const FruitListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const FruitListScreen(),
    );
  }
}

/// Data Model representing a Fruit item
class Fruit {
  final String name;
  final String emoji;
  final String price;
  final String unit;
  final String description;
  final String category;
  final Color accentColor;

  const Fruit({
    required this.name,
    required this.emoji,
    required this.price,
    required this.unit,
    required this.description,
    required this.category,
    required this.accentColor,
  });
}

/// Separate Reusable Screen Widget displaying the fruit list
class FruitListScreen extends StatelessWidget {
  const FruitListScreen({super.key});

  final List<Fruit> fruits = const [
    Fruit(
      name: 'Apple',
      emoji: '🍎',
      price: '\$2.99',
      unit: 'per kg',
      description: 'Crisp, sweet, and rich in fiber',
      category: 'Fresh',
      accentColor: Colors.red,
    ),
    Fruit(
      name: 'Banana',
      emoji: '🍌',
      price: '\$1.49',
      unit: 'per dozen',
      description: 'High in potassium and natural energy',
      category: 'Tropical',
      accentColor: Colors.amber,
    ),
    Fruit(
      name: 'Orange',
      emoji: '🍊',
      price: '\$3.20',
      unit: 'per kg',
      description: 'Juicy citrus bursting with Vitamin C',
      category: 'Citrus',
      accentColor: Colors.orange,
    ),
    Fruit(
      name: 'Strawberry',
      emoji: '🍓',
      price: '\$4.50',
      unit: 'per box',
      description: 'Sweet, fragrant, and farm fresh',
      category: 'Berries',
      accentColor: Colors.pink,
    ),
    Fruit(
      name: 'Mango',
      emoji: '🥭',
      price: '\$5.00',
      unit: 'per kg',
      description: 'King of fruits, rich and sweet',
      category: 'Seasonal',
      accentColor: Colors.deepOrange,
    ),
    Fruit(
      name: 'Grapes',
      emoji: '🍇',
      price: '\$3.80',
      unit: 'per kg',
      description: 'Seedless, crisp, and refreshing',
      category: 'Fresh',
      accentColor: Colors.purple,
    ),
    Fruit(
      name: 'Watermelon',
      emoji: '🍉',
      price: '\$4.20',
      unit: 'per piece',
      description: 'Hydrating, sweet, and cooling summer treat',
      category: 'Melons',
      accentColor: Colors.green,
    ),
    Fruit(
      name: 'Pineapple',
      emoji: '🍍',
      price: '\$3.50',
      unit: 'per piece',
      description: 'Tangy tropical goodness with healthy enzymes',
      category: 'Tropical',
      accentColor: Colors.amber,
    ),
    Fruit(
      name: 'Avocado',
      emoji: '🥑',
      price: '\$2.75',
      unit: 'per piece',
      description: 'Creamy texture packed with good fats',
      category: 'Exotic',
      accentColor: Colors.teal,
    ),
    Fruit(
      name: 'Blueberry',
      emoji: '🫐',
      price: '\$5.99',
      unit: 'per box',
      description: 'Antioxidant superfood full of flavor',
      category: 'Berries',
      accentColor: Colors.indigo,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Fruit List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: fruits.length,
        itemBuilder: (context, index) {
          return FruitCard(fruit: fruits[index]);
        },
      ),
    );
  }
}

/// Reusable Custom Widget: FruitCard
class FruitCard extends StatelessWidget {
  final Fruit fruit;

  const FruitCard({
    super.key,
    required this.fruit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Emoji inside styled Container
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: fruit.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                fruit.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: 14),

            // Fruit Name, Description, and Category Tag in a Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fruit.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    fruit.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      fruit.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Price and Unit in a Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.teal.shade200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    fruit.price,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  fruit.unit,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 4. Output Screenshots

#### Screenshot 1: Application Launch & Initial Fruit List
- **Description:** Displays the application upon launch with the `AppBar` titled `"Fruit List"`, teal theme, and the first set of fruits (Apple, Banana, Orange, Strawberry, Mango) rendered inside elevated `Card` widgets using `Row`, `Column`, and `Container`.
- *(Insert Screenshot 1 here)*

#### Screenshot 2: Scrolled View (ListView.builder Demonstration)
- **Description:** Demonstrates the dynamic scrolling capability of `ListView.builder` by scrolling down to display the remaining fruits (Grapes, Watermelon, Pineapple, Avocado, Blueberry).
- *(Insert Screenshot 2 here)*

#### Screenshot 3: Mobile View / Card Widget Anatomy
- **Description:** Displays the responsive mobile layout (emulated via Chrome DevTools `Ctrl + Shift + M`), highlighting the individual `FruitCard` structure: emoji in styled `Container`, title and description in `Column`, and price badge.
- *(Insert Screenshot 3 here)*

---

### 5. Result
The Flutter Fruit List application was successfully designed and executed, demonstrating the proper implementation of `Row`, `Column`, `Container`, `Card`, and `ListView` widgets along with reusable custom widgets.

