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

  // List of fruits to display (at least 8 fruits)
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
      // Widget 5: ListView (ListView.builder) to display the scrollable list of fruits
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: fruits.length,
        itemBuilder: (context, index) {
          // Reusable custom FruitCard widget
          return FruitCard(fruit: fruits[index]);
        },
      ),
    );
  }
}

/// Reusable Custom Widget: FruitCard
/// Demonstrates the use of Card, Container, Row, and Column widgets.
class FruitCard extends StatelessWidget {
  final Fruit fruit;

  const FruitCard({
    super.key,
    required this.fruit,
  });

  @override
  Widget build(BuildContext context) {
    // Widget 4: Card - Provides elevation, rounded corners, and card layout
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        // Widget 1: Row - Horizontally organizes emoji, fruit info, and price
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Widget 3: Container - Styled container with rounded corners and background color for the emoji
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

            // Widget 2: Column - Vertically stacks the fruit title, description, and category tag
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
                  // Widget 3: Container - Styled pill tag for fruit category
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

            // Widget 2: Column - Vertically stacks the price badge and measurement unit
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Widget 3: Container - Styled badge for fruit price
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
