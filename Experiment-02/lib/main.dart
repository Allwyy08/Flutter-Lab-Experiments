import 'package:flutter/material.dart';

void main() {
  runApp(const ShopEasyApp());
}

/// Root Application Widget
class ShopEasyApp extends StatelessWidget {
  const ShopEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopEasy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: const Color(0xFFF8FAFC),
        ),
        useMaterial3: true,
      ),
      home: const ProductCatalogScreen(),
    );
  }
}

/// Product Model representing an e-commerce item
class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final String imageUrl;
  final IconData placeholderIcon;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.placeholderIcon,
  });
}

/// Main Product Catalog Screen demonstrating Responsive UI
class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  // Simple cart state management using StatefulWidget
  int _cartCount = 0;
  final Map<int, int> _cartItems = {};

  // Catalog with at least 8 distinct e-commerce products
  final List<Product> _products = const [
    Product(
      id: 1,
      name: 'Wireless Noise-Canceling Headphones',
      category: 'Audio',
      price: 199.99,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80',
      placeholderIcon: Icons.headphones,
    ),
    Product(
      id: 2,
      name: 'Smart Fitness Watch Series 5',
      category: 'Wearables',
      price: 129.50,
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&q=80',
      placeholderIcon: Icons.watch,
    ),
    Product(
      id: 3,
      name: 'Ergonomic RGB Mechanical Keyboard',
      category: 'Accessories',
      price: 89.00,
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500&q=80',
      placeholderIcon: Icons.keyboard,
    ),
    Product(
      id: 4,
      name: 'Ultra HD 4K Action Camera',
      category: 'Electronics',
      price: 149.99,
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=500&q=80',
      placeholderIcon: Icons.videocam,
    ),
    Product(
      id: 5,
      name: 'Minimalist Water-Resistant Backpack',
      category: 'Fashion',
      price: 75.00,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&q=80',
      placeholderIcon: Icons.backpack,
    ),
    Product(
      id: 6,
      name: 'Portable Waterproof Bluetooth Speaker',
      category: 'Audio',
      price: 49.99,
      rating: 4.4,
      imageUrl:
          'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500&q=80',
      placeholderIcon: Icons.speaker,
    ),
    Product(
      id: 7,
      name: 'Classic Polarized Sunglasses',
      category: 'Accessories',
      price: 35.00,
      rating: 4.3,
      imageUrl:
          'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=500&q=80',
      placeholderIcon: Icons.wb_sunny,
    ),
    Product(
      id: 8,
      name: 'Ceramic Insulated Travel Coffee Mug',
      category: 'Lifestyle',
      price: 24.99,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&q=80',
      placeholderIcon: Icons.coffee,
    ),
  ];

  /// Handles adding product to cart and updates state
  void _addToCart(Product product) {
    setState(() {
      _cartCount++;
      _cartItems[product.id] = (_cartItems[product.id] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added "${product.name}" to cart!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: const Color(0xFF60A5FA),
          onPressed: _showCartDialog,
        ),
      ),
    );
  }

  /// Displays Cart Summary Dialog
  void _showCartDialog() {
    double totalAmount = 0.0;
    _cartItems.forEach((productId, quantity) {
      final product = _products.firstWhere((p) => p.id == productId);
      totalAmount += product.price * quantity;
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.shopping_cart, color: Color(0xFF2563EB)),
            const SizedBox(width: 8),
            const Text(
              'Shopping Cart',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_cartCount items',
                style: const TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        content: _cartCount == 0
            ? const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'Your cart is currently empty.\nTap "Add to Cart" on any product!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            : SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _cartItems.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 12),
                        itemBuilder: (ctx, index) {
                          final productId = _cartItems.keys.elementAt(index);
                          final qty = _cartItems[productId]!;
                          final product =
                              _products.firstWhere((p) => p.id == productId);
                          return Row(
                            children: [
                              Icon(
                                product.placeholderIcon,
                                size: 24,
                                color: const Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                'x$qty  \$${(product.price * qty).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(thickness: 1.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        actions: [
          if (_cartCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  _cartCount = 0;
                  _cartItems.clear();
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cart cleared successfully'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('Clear Cart', style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // 1. Professional AppBar with title "ShopEasy" and active Cart icon badge
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'ShopEasy',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Shopping Cart',
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xFF0F172A),
                  size: 26,
                ),
                onPressed: _showCartDialog,
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        '$_cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      // 6. Implement responsive layouts using LayoutBuilder
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive Breakpoint Logic:
          // 7. Display 2 columns on mobile screens (< 600px),
          //    3 columns on tablets (600px - 1024px),
          //    4 columns on desktop screens (>= 1024px).
          int crossAxisCount;
          double childAspectRatio;
          double horizontalPadding;
          String deviceType;
          IconData deviceIcon;

          if (constraints.maxWidth < 600) {
            crossAxisCount = 2;
            childAspectRatio = 0.65;
            horizontalPadding = 12.0;
            deviceType = 'Mobile Screen (2 Columns)';
            deviceIcon = Icons.phone_android;
          } else if (constraints.maxWidth < 1024) {
            crossAxisCount = 3;
            childAspectRatio = 0.70;
            horizontalPadding = 20.0;
            deviceType = 'Tablet Screen (3 Columns)';
            deviceIcon = Icons.tablet_mac;
          } else {
            crossAxisCount = 4;
            childAspectRatio = 0.75;
            horizontalPadding = 32.0;
            deviceType = 'Desktop Screen (4 Columns)';
            deviceIcon = Icons.desktop_windows;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Adaptive info banner highlighting active responsive breakpoint
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 12.0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(deviceIcon, size: 20, color: const Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Active Layout: $deviceType',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Width: ${constraints.maxWidth.toInt()} px',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 5. Use GridView.builder to display products
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: 24.0,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14.0,
                    mainAxisSpacing: 14.0,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    // 4. Reusable custom widget named ProductCard
                    return ProductCard(
                      product: product,
                      onAddToCart: () => _addToCart(product),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 4. Reusable Custom Widget: ProductCard
/// 8. Resizes properly on different screen sizes using Expanded and proportional layouts
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: const Color(0x14000000),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 3a. Product Image with graceful loading and fallback placeholder icon
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to suitable placeholder icon
                    return Container(
                      color: const Color(0xFFEFF6FF),
                      child: Center(
                        child: Icon(
                          product.placeholderIcon,
                          size: 44,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    );
                  },
                ),
                // Category Tag Pill
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xA6000000),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product Details & Add to Cart Section
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 3b. Product Name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      height: 1.2,
                    ),
                  ),

                  // 3c. Price and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 13,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // 3d. Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton.icon(
                      onPressed: onAddToCart,
                      icon: const Icon(Icons.add_shopping_cart, size: 15),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
