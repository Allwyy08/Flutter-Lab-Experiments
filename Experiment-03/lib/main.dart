import 'package:flutter/material.dart';

void main() {
  runApp(const ProductExplorerApp());
}

/// Root Application Widget
class ProductExplorerApp extends StatelessWidget {
  const ProductExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF06B6D4),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
      ),
      home: const ProductExplorerScreen(),
    );
  }
}

/// Product Data Model
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String emoji;
  final IconData icon;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.emoji,
    required this.icon,
    this.description = '',
  });
}

/// Interactive Product Search and Filter Screen
class ProductExplorerScreen extends StatefulWidget {
  const ProductExplorerScreen({super.key});

  @override
  State<ProductExplorerScreen> createState() => _ProductExplorerScreenState();
}

class _ProductExplorerScreenState extends State<ProductExplorerScreen> {
  // Controller for the search input field
  final TextEditingController _searchController = TextEditingController();

  // Active search query
  String _searchQuery = '';

  // Currently selected category filter
  String _selectedCategory = 'All Categories';

  // Available categories for dropdown filter
  final List<String> _categories = const [
    'All Categories',
    'Electronics',
    'Footwear',
    'Apparel',
    'Accessories',
    'Home & Kitchen',
    'Stationery',
  ];

  // Predefined catalog containing 12 distinct products across 6 categories
  final List<Product> _allProducts = const [
    Product(
      id: 'p1',
      name: 'Wireless Noise-Canceling Headphones',
      category: 'Electronics',
      price: 149.99,
      emoji: '🎧',
      icon: Icons.headphones,
      description: 'High-fidelity audio with active noise cancellation and 30-hour battery life.',
    ),
    Product(
      id: 'p2',
      name: 'Mechanical Gaming Keyboard',
      category: 'Electronics',
      price: 89.50,
      emoji: '⌨️',
      icon: Icons.keyboard,
      description: 'Tactile mechanical switches with customizable RGB per-key backlighting.',
    ),
    Product(
      id: 'p3',
      name: 'Ultra HD 4K Monitor 27-inch',
      category: 'Electronics',
      price: 329.00,
      emoji: '🖥️',
      icon: Icons.desktop_windows,
      description: 'IPS display with HDR400, 99% sRGB color gamut, and ultra-thin bezels.',
    ),
    Product(
      id: 'p4',
      name: 'Smart Fitness Watch',
      category: 'Electronics',
      price: 119.95,
      emoji: '⌚',
      icon: Icons.watch,
      description: 'Tracks heart rate, sleep metrics, daily steps, and workout sessions.',
    ),
    Product(
      id: 'p5',
      name: 'Running Trail Sneakers',
      category: 'Footwear',
      price: 79.99,
      emoji: '👟',
      icon: Icons.directions_run,
      description: 'Lightweight cushioned soles engineered for rugged trail and road running.',
    ),
    Product(
      id: 'p6',
      name: 'Classic Leather Loafers',
      category: 'Footwear',
      price: 95.00,
      emoji: '👞',
      icon: Icons.hiking,
      description: 'Handcrafted premium leather loafers suitable for formal and smart casual wear.',
    ),
    Product(
      id: 'p7',
      name: 'Cotton Crewneck T-Shirt',
      category: 'Apparel',
      price: 24.99,
      emoji: '👕',
      icon: Icons.checkroom,
      description: '100% combed ringspun cotton providing breathable, everyday comfort.',
    ),
    Product(
      id: 'p8',
      name: 'Water-Resistant Winter Jacket',
      category: 'Apparel',
      price: 135.00,
      emoji: '🧥',
      icon: Icons.dry_cleaning,
      description: 'Thermal insulated winter jacket with fleece lining and detachable hood.',
    ),
    Product(
      id: 'p9',
      name: 'Polarized Sunglasses',
      category: 'Accessories',
      price: 45.00,
      emoji: '🕶️',
      icon: Icons.wb_sunny,
      description: 'UV400 protective polarized lenses housed in lightweight titanium frames.',
    ),
    Product(
      id: 'p10',
      name: 'Ergonomic Office Backpack',
      category: 'Accessories',
      price: 59.99,
      emoji: '🎒',
      icon: Icons.backpack,
      description: 'Spacious multi-compartment backpack with dedicated 16-inch laptop sleeve.',
    ),
    Product(
      id: 'p11',
      name: 'Stainless Steel Coffee Maker',
      category: 'Home & Kitchen',
      price: 64.50,
      emoji: '☕',
      icon: Icons.coffee,
      description: 'Programmable 12-cup drip coffee brewer with automatic keep-warm plate.',
    ),
    Product(
      id: 'p12',
      name: 'Hardcover Dot-Grid Notebook',
      category: 'Stationery',
      price: 14.99,
      emoji: '📓',
      icon: Icons.menu_book,
      description: '160 pages of 120gsm ink-proof paper ideal for sketching and bullet journaling.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Dynamically computes filtered products matching both search query and selected category
  List<Product> get _filteredProducts {
    final cleanQuery = _searchQuery.trim().toLowerCase();

    return _allProducts.where((product) {
      // Search matches against product name
      final matchesSearch =
          cleanQuery.isEmpty || product.name.toLowerCase().contains(cleanQuery);

      // Category matches selected dropdown option
      final matchesCategory = _selectedCategory == 'All Categories' ||
          product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// Clears only the search field
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  /// Resets both search query and category dropdown to defaults
  void _resetAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'All Categories';
    });
  }

  /// Displays product details modal sheet when a card is tapped
  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      product.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} selected!'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Got it'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;
    final bool hasActiveFilter =
        _searchQuery.isNotEmpty || _selectedCategory != 'All Categories';

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_rounded, color: Color(0xFF4F46E5), size: 24),
            SizedBox(width: 8),
            Text(
              'Product Explorer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: [
          if (hasActiveFilter)
            TextButton.icon(
              onPressed: _resetAllFilters,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4F46E5),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1.0,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              // Search & Filter Input Control Panel
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                color: Colors.white,
                child: Column(
                  children: [
                    // Requirement 4 & 5: TextField Search Bar with clear button
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search products by name...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF4F46E5),
                          size: 22,
                        ),
                        // Requirement 10: Clear search button
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                ),
                                tooltip: 'Clear search',
                                onPressed: _clearSearch,
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4F46E5),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Requirement 6 & 7: DropdownButtonFormField for Category Filter
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedCategory),
                      // ignore: deprecated_member_use
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Filter by Category',
                        labelStyle: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.filter_list_rounded,
                          color: Color(0xFF4F46E5),
                          size: 22,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4F46E5),
                            width: 1.5,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Results Status Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                color: const Color(0xFFF1F5F9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${filtered.length} of ${_allProducts.length} products',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    if (hasActiveFilter)
                      InkWell(
                        onTap: _resetAllFilters,
                        child: const Text(
                          'Clear Filters',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Product Display List or Empty State
              Expanded(
                child: filtered.isEmpty
                    // Requirement 9: "No products found" message
                    ? _buildEmptyState()
                    // Requirement 8: Dynamically display products using ListView.builder
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          // Requirement 12: Reusable custom widget for product cards
                          return ProductCard(
                            product: product,
                            onTap: () => _showProductDetails(product),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty state display shown when no products match filters
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'No products matched "$_searchQuery" in $_selectedCategory. Try checking your spelling or selecting another category.'
                    : 'No products found in $_selectedCategory.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _resetAllFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Requirement 12: Reusable Custom Widget for Product Card
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Icon & Emoji Container
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  product.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              const SizedBox(width: 14),

              // Product Name and Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          product.icon,
                          size: 14,
                          color: const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Product Price & Arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
